import 'dart:async';
import 'dart:convert';
import 'dart:io' show Platform;
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';
import 'package:get/get.dart';
import 'package:installed_apps/installed_apps.dart';
import 'package:installed_apps/app_info.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:usage_stats/usage_stats.dart';
import '../models/usage_model.dart';
import '../routes/app_routes.dart';

class UsageService extends GetxService with WidgetsBindingObserver {
  final RxList<AppUsageInfo> apps = <AppUsageInfo>[].obs;
  final Rx<DeviceUsageStats> stats = Rx<DeviceUsageStats>(DeviceUsageStats());
  final RxList<DailyUsagePoint> weeklyUsage = <DailyUsagePoint>[].obs;
  final RxBool isPermissionGranted = false.obs;

  Timer? _simulationTimer;
  Timer? _permissionCheckTimer;
  Timer? _realTimePollTimer;
  final _random = Random();
  final Map<String, double> _previousElapsedMinutes = {};
  List<AppInfo>? _installedAppsCache;
  Set<String> _userPackageNamesCache = {};
  DateTime? _installedAppsCacheTime;
  bool _initialFetchDone = false;
  bool _isFetchingRealUsage = false;
  bool _hasLoadedRealUsageData = false;
  static const String _dailyUsageHistoryKey = 'daily_usage_history_v1';
  static const String _dailyGoalKey = 'daily_goal_minutes_v1';
  static const Duration _installedAppsCacheDuration = Duration(minutes: 30);
  final RxDouble totalMinutes = 0.0.obs;

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
    initService();
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    _simulationTimer?.cancel();
    _permissionCheckTimer?.cancel();
    _realTimePollTimer?.cancel();
    super.onClose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _recheckPermissionOnResume();
      if (isPermissionGranted.value) {
        _startRealTimePolling();
      } else {
        _startSimulation();
        _startPermissionPolling();
      }
    } else if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
      _realTimePollTimer?.cancel();
      _realTimePollTimer = null;
      _simulationTimer?.cancel();
      _simulationTimer = null;
      _permissionCheckTimer?.cancel();
      _permissionCheckTimer = null;
    }
  }

  Future<void> initService() async {
    await _loadDailyGoal();
    if (Platform.isAndroid) {
      try {
        bool? granted = await UsageStats.checkUsagePermission();
        isPermissionGranted.value = granted ?? false;

        if (isPermissionGranted.value) {
          await fetchRealUsageStats();
          await _loadWeeklyUsageHistory();
          _startRealTimePolling();
        } else {
          _loadInitialData();
          await _loadWeeklyUsageHistory();
          _startSimulation();
          _startPermissionPolling();
        }
      } catch (e) {
        debugPrint("Error initializing usage stats on Android: $e");
        _loadInitialData();
        await _loadWeeklyUsageHistory();
        _startSimulation();
      }
    } else {
      // Non-Android platforms (iOS, macOS, etc.) fallback to mock data
      _loadInitialData();
      await _loadWeeklyUsageHistory();
      _startSimulation();
    }
  }

  void _startPermissionPolling() {
    _permissionCheckTimer?.cancel();
    _permissionCheckTimer = Timer.periodic(const Duration(seconds: 3), (timer) async {
      try {
        bool? granted = await UsageStats.checkUsagePermission();
        if (granted == true) {
          isPermissionGranted.value = true;
          _permissionCheckTimer?.cancel();
          _simulationTimer?.cancel(); // stop mock simulation
          await fetchRealUsageStats();
          await _loadWeeklyUsageHistory();
          _startRealTimePolling();
        }
      } catch (e) {
        debugPrint("Error polling usage permission: $e");
      }
    });
  }

  void _startRealTimePolling() {
    _realTimePollTimer?.cancel();
    _realTimePollTimer = Timer.periodic(const Duration(seconds: 10), (timer) async {
      if (isPermissionGranted.value) {
        await fetchRealUsageStats();
      }
    });
  }

  Future<void> _recheckPermissionOnResume() async {
    if (!Platform.isAndroid) return;

    try {
      final bool? granted = await UsageStats.checkUsagePermission();
      final bool isGranted = granted ?? false;

      if (isGranted == isPermissionGranted.value) return; // no change, skip

      isPermissionGranted.value = isGranted;

      if (isGranted) {
        // Permission just granted — start real data
        _permissionCheckTimer?.cancel();
        _simulationTimer?.cancel();
        _hasLoadedRealUsageData = false; // force fresh load
        apps.clear();
        await fetchRealUsageStats();
        await _loadWeeklyUsageHistory();
        _startRealTimePolling();
      } else {
        // Permission just revoked — stop polling, show permission gate
        _realTimePollTimer?.cancel();
        _simulationTimer?.cancel();
        apps.clear();
        totalMinutes.value = 0.0;
        weeklyUsage.clear();
        _hasLoadedRealUsageData = false;
        _initialFetchDone = false;
      }
    } catch (e) {
      debugPrint('Error rechecking permission on resume: $e');
    }
  }

  Future<void> requestUsagePermission() async {
    if (Platform.isAndroid) {
      try {
        await UsageStats.grantUsagePermission();
        bool? granted = await UsageStats.checkUsagePermission();
        isPermissionGranted.value = granted ?? false;
        if (isPermissionGranted.value) {
          _permissionCheckTimer?.cancel();
          _simulationTimer?.cancel();
          await fetchRealUsageStats();
          await _loadWeeklyUsageHistory();
          _startRealTimePolling();
        }
      } catch (e) {
        debugPrint("Error granting usage permission: $e");
      }
    }
  }

  Future<void> fetchRealUsageStats() async {
    if (_isFetchingRealUsage) return;
    _isFetchingRealUsage = true;

    try {
      final now = DateTime.now();
      final startDate = DateTime(now.year, now.month, now.day);

      final List<AppInfo> installedList = await _getInstalledApps();
      if (installedList.isEmpty) {
        if (apps.isEmpty) _loadInitialData();
        return;
      }

      final Map<String, double> usageMinutesMap = await _fetchAccurateUsageMinutes(startDate, now);

      final savedLimits = await _loadSavedLimits();
      final Map<String, AppUsageInfo> currentAppsById = {for (final app in apps) app.id: app};
      final List<AppUsageInfo> loadedApps = [];

      for (final app in installedList) {
        final packageName = app.packageName;
        if (packageName.isEmpty) continue;

        final double elapsedMin = usageMinutesMap[packageName] ?? 0.0;

        // Eliminate system apps with 0 mins of usage
        final isSystemApp = _userPackageNamesCache.isNotEmpty && !_userPackageNamesCache.contains(packageName);
        if (isSystemApp && elapsedMin == 0.0) {
          continue;
        }

        final category = _categorizeApp(packageName, app.name);
        final themeColor = _getAppColor(packageName);

        final existingApp = currentAppsById[packageName];
        UsageLimit? existingLimit;
        if (existingApp != null) {
          existingLimit = existingApp.limit;
        } else if (savedLimits.containsKey(packageName)) {
          final savedLimit = savedLimits[packageName]!;
          existingLimit = UsageLimit(limitMinutes: savedLimit.limitMinutes, isActive: true, repeatDaily: savedLimit.repeatDaily, notifyAt80: savedLimit.notifyAt80);
        }

        final info =
            existingApp ??
            AppUsageInfo(id: packageName, name: app.name, category: category, appIconBytes: app.icon, themeColor: themeColor, elapsedMinutes: elapsedMin, limit: existingLimit);

        info.elapsedMinutes = elapsedMin;
        info.limit = existingLimit;
        loadedApps.add(info);
      }

      if (!_hasLoadedRealUsageData) {
        loadedApps.sort((a, b) {
          final comp = b.elapsedMinutes.compareTo(a.elapsedMinutes);
          if (comp != 0) return comp;
          return a.name.toLowerCase().compareTo(b.name.toLowerCase());
        });
        apps.assignAll(loadedApps);
        _hasLoadedRealUsageData = true;
      } else {
        final loadedById = {for (final app in loadedApps) app.id: app};
        final loadedIds = loadedById.keys.toSet();

        apps.removeWhere((existing) => !loadedIds.contains(existing.id));
        for (final app in apps) {
          final fresh = loadedById[app.id];
          if (fresh != null) {
            app.elapsedMinutes = fresh.elapsedMinutes;
            app.limit = fresh.limit;
          }
        }

        final existingIds = apps.map((app) => app.id).toSet();
        for (final app in loadedApps) {
          if (!existingIds.contains(app.id)) {
            apps.add(app);
          }
        }

        apps.refresh();
      }

      _installedAppsCacheTime = now;
      totalMinutes.value = totalElapsedMinutes;
      await _persistTodayUsageSnapshot(totalElapsedMinutes);
      _checkAndTriggerLimitAlerts();
    } catch (e) {
      debugPrint("Error fetching real usage stats: $e");
      if (apps.isEmpty) _loadInitialData();
    } finally {
      _isFetchingRealUsage = false;
    }
  }

  Future<Map<String, double>> _fetchAccurateUsageMinutes(DateTime startDate, DateTime endDate) async {
    final Map<String, double> result = {};
    final Map<String, int> foregroundStartMs = {};

    try {
      final List<EventUsageInfo> events = await UsageStats.queryEvents(startDate, endDate);

      for (final event in events) {
        final pkg = event.packageName;
        if (pkg == null || pkg.isEmpty) continue;
        if (_excludedPackages.any((excluded) => pkg.startsWith(excluded))) continue;

        // Skip system packages (no dot usually means system process)
        if (!pkg.contains('.')) continue;

        final typeStr = event.eventType;
        final tsStr = event.timeStamp;
        if (typeStr == null || tsStr == null) continue;

        final int? type = int.tryParse(typeStr);
        final int? tsMs = int.tryParse(tsStr);
        if (type == null || tsMs == null) continue;

        if (type == 1) {
          // MOVE_TO_FOREGROUND — app became visible
          foregroundStartMs[pkg] = tsMs;
        } else if (type == 2) {
          // MOVE_TO_BACKGROUND — app went hidden
          final startMs = foregroundStartMs[pkg];
          if (startMs != null) {
            final sessionMs = tsMs - startMs;
            final sessionMin = sessionMs / 1000.0 / 60.0;

            // Sanity bounds: ignore <1s glitches and >4h sessions (bad data)
            if (sessionMin >= (1 / 60) && sessionMin < 240) {
              result[pkg] = (result[pkg] ?? 0.0) + sessionMin;
            }
            foregroundStartMs.remove(pkg);
          }
        }
      }

      // Apps still in foreground at query end (currently open)
      final endMs = endDate.millisecondsSinceEpoch;
      for (final entry in foregroundStartMs.entries) {
        final sessionMs = endMs - entry.value;
        final sessionMin = sessionMs / 1000.0 / 60.0;
        if (sessionMin >= (1 / 60) && sessionMin < 240) {
          result[entry.key] = (result[entry.key] ?? 0.0) + sessionMin;
        }
      }
    } catch (e) {
      debugPrint('Error querying usage events: $e');
    }
    return result;
  }

  Future<List<AppInfo>> _getInstalledApps({bool forceRefresh = false}) async {
    final cacheAge = _installedAppsCacheTime == null ? null : DateTime.now().difference(_installedAppsCacheTime!);
    final hasFreshCache = _installedAppsCache != null && _installedAppsCache!.isNotEmpty && cacheAge != null && cacheAge < _installedAppsCacheDuration;

    if (!forceRefresh && hasFreshCache) {
      return _installedAppsCache!;
    }

    final installedList = await InstalledApps.getInstalledApps(excludeSystemApps: false, excludeNonLaunchableApps: false, withIcon: false);
    try {
      final userApps = await InstalledApps.getInstalledApps(excludeSystemApps: true, excludeNonLaunchableApps: false, withIcon: false);
      _userPackageNamesCache = userApps.map((app) => app.packageName).toSet();
    } catch (e) {
      debugPrint("Error fetching user apps: $e");
      _userPackageNamesCache = {};
    }
    _installedAppsCache = installedList;
    _installedAppsCacheTime = DateTime.now();
    return installedList;
  }

  Future<void> _checkAndTriggerLimitAlerts() async {
    final skipAlert = !_initialFetchDone;
    _initialFetchDone = true;

    final isInForeground = WidgetsBinding.instance.lifecycleState == AppLifecycleState.resumed;

    for (final app in apps) {
      final prev = _previousElapsedMinutes[app.id] ?? 0.0;
      _previousElapsedMinutes[app.id] = app.elapsedMinutes;

      if (skipAlert) continue;
      if (!isInForeground) continue; // background service handles overlay
      if (app.limit == null || !app.limit!.isActive) continue;
      final limitMin = app.limit!.limitMinutes;
      if (app.elapsedMinutes >= limitMin && prev < limitMin) {
        // Mark as notified so background service skips overlay for today
        final prefs = await SharedPreferences.getInstance();
        final now = DateTime.now();
        await prefs.setString('last_notified_${app.id}', '${now.year}-${now.month}-${now.day}');
        Get.toNamed(AppRoutes.limitReached, arguments: app);
        break;
      }
    }
  }

  String _categorizeApp(String packageName, String appName) {
    final lowerPkg = packageName.toLowerCase();
    final lowerName = appName.toLowerCase();

    if (lowerPkg.contains('social') ||
        lowerPkg.contains('facebook') ||
        lowerPkg.contains('instagram') ||
        lowerPkg.contains('twitter') ||
        lowerPkg.contains('reddit') ||
        lowerPkg.contains('snapchat') ||
        lowerPkg.contains('tiktok') ||
        lowerPkg.contains('linkedin') ||
        lowerName.contains('instagram') ||
        lowerName.contains('facebook') ||
        lowerName.contains('twitter') ||
        lowerName.contains('reddit') ||
        lowerName.contains('snapchat') ||
        lowerName.contains('tiktok')) {
      return 'Social Media';
    }

    if (lowerPkg.contains('youtube') ||
        lowerPkg.contains('netflix') ||
        lowerPkg.contains('spotify') ||
        lowerPkg.contains('game') ||
        lowerPkg.contains('play') ||
        lowerPkg.contains('music') ||
        lowerPkg.contains('tv') ||
        lowerPkg.contains('disney') ||
        lowerPkg.contains('video') ||
        lowerName.contains('youtube') ||
        lowerName.contains('netflix') ||
        lowerName.contains('spotify') ||
        lowerName.contains('music')) {
      return 'Entertainment';
    }

    if (lowerPkg.contains('slack') ||
        lowerPkg.contains('gmail') ||
        lowerPkg.contains('calendar') ||
        lowerPkg.contains('drive') ||
        lowerPkg.contains('doc') ||
        lowerPkg.contains('sheet') ||
        lowerPkg.contains('task') ||
        lowerPkg.contains('notes') ||
        lowerPkg.contains('keep') ||
        lowerPkg.contains('notion') ||
        lowerPkg.contains('office') ||
        lowerPkg.contains('adobe') ||
        lowerName.contains('slack') ||
        lowerName.contains('gmail') ||
        lowerName.contains('drive') ||
        lowerName.contains('notion')) {
      return 'Productivity';
    }

    if (lowerPkg.contains('whatsapp') ||
        lowerPkg.contains('messenger') ||
        lowerPkg.contains('chat') ||
        lowerPkg.contains('tele') ||
        lowerPkg.contains('signal') ||
        lowerPkg.contains('discord') ||
        lowerPkg.contains('sms') ||
        lowerName.contains('whatsapp') ||
        lowerName.contains('messenger') ||
        lowerName.contains('telegram') ||
        lowerName.contains('discord')) {
      return 'Communication';
    }

    return 'Productivity';
  }

  Color _getAppColor(String packageName) {
    final colors = [
      const Color(0xFFD2BBFF), // purple
      const Color(0xFFC8A0F0), // purple
      const Color(0xFF88B4CC), // slate blue
      const Color(0xFFA0B4C4), // light blue gray
      const Color(0xFF38BDF8), // secondary blue
      const Color(0xFFF472B6), // pink
      const Color(0xFFFB7185), // rose
      const Color(0xFF34D399), // green/emerald
      const Color(0xFFFBBF24), // amber
    ];
    int hash = 0;
    for (int i = 0; i < packageName.length; i++) {
      hash = packageName.codeUnitAt(i) + ((hash << 5) - hash);
    }
    return colors[hash.abs() % colors.length];
  }

  void _loadInitialData() {
    apps.addAll([
      AppUsageInfo(
        id: 'instagram',
        name: 'Instagram',
        category: 'Social Media',
        icon: Icons.camera_alt,
        themeColor: const Color(0xFFD2BBFF),
        elapsedMinutes: 105,
        limit: UsageLimit(limitMinutes: 120, repeatDaily: true, notifyAt80: true),
      ),
      AppUsageInfo(
        id: 'youtube',
        name: 'YouTube',
        category: 'Entertainment',
        icon: Icons.play_circle_fill,
        themeColor: const Color(0xFFC8A0F0),
        elapsedMinutes: 58,
        limit: UsageLimit(limitMinutes: 120, repeatDaily: true, notifyAt80: true),
      ),
      AppUsageInfo(id: 'slack', name: 'Slack', category: 'Productivity', icon: Icons.mail_outline, themeColor: const Color(0xFF88B4CC), elapsedMinutes: 42),
      AppUsageInfo(id: 'whatsapp', name: 'WhatsApp', category: 'Communication', icon: Icons.chat_bubble_outline, themeColor: const Color(0xFFA0B4C4), elapsedMinutes: 31),
    ]);
  }

  void _startSimulation() {
    _simulationTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (apps.isEmpty) return;
      final index = _random.nextDouble() > 0.4 ? 0 : 1;
      if (index >= apps.length) return;
      final app = apps[index];
      final delta = 0.5 + _random.nextDouble() * 2.0;
      app.elapsedMinutes += delta;
      apps[index] = app; // trigger obx update

      stats.value.pickups += _random.nextBool() ? 1 : 0;
      stats.value.notifications += _random.nextInt(3);
      stats.refresh();
      _persistTodayUsageSnapshot(totalElapsedMinutes);

      if (app.limit != null && app.limit!.isActive && isPermissionGranted.value) {
        if (app.elapsedMinutes >= app.limit!.limitMinutes && (app.elapsedMinutes - delta) < app.limit!.limitMinutes) {
          Get.toNamed(AppRoutes.limitReached, arguments: app);
        }
      }
    });
  }

  double get totalElapsedMinutes {
    final total = apps.where((app) => !_excludedPackages.contains(app.id)).fold(0.0, (sum, app) => sum + app.elapsedMinutes);
    totalMinutes.value = total;
    return total;
  }

  Future<void> _persistTodayUsageSnapshot([double? totalMinutes]) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final history = _decodeUsageHistory(prefs.getString(_dailyUsageHistoryKey));
      final todayMinutes = (totalMinutes ?? totalElapsedMinutes).clamp(0.0, double.infinity);
      history[_dateKey(DateTime.now())] = todayMinutes;
      await prefs.setString(_dailyUsageHistoryKey, jsonEncode(history));
      _updateTodayWeeklyPoint(todayMinutes);
    } catch (e) {
      debugPrint("Error persisting daily usage snapshot: $e");
    }
  }

  Future<void> _loadWeeklyUsageHistory() async {
    try {
      if (Platform.isAndroid && isPermissionGranted.value) {
        weeklyUsage.assignAll(await _loadWeeklyUsageFromDevice());
        if (apps.isNotEmpty) {
          _updateTodayWeeklyPoint(totalElapsedMinutes);
        }
        return;
      }

      final prefs = await SharedPreferences.getInstance();
      final history = _decodeUsageHistory(prefs.getString(_dailyUsageHistoryKey));
      weeklyUsage.assignAll(_buildWeeklyUsageFromMap(history));
    } catch (e) {
      debugPrint("Error loading weekly usage history: $e");
      weeklyUsage.assignAll(_fallbackWeeklyUsage());
    }
  }

  Future<List<DailyUsagePoint>> _loadWeeklyUsageFromDevice() async {
    final today = DateTime.now();
    final todayMidnight = DateTime(today.year, today.month, today.day);
    final start = todayMidnight.subtract(const Duration(days: 6));

    final installedList = await _getInstalledApps();
    final installedPackageIds = {
      for (final a in installedList)
        if (a.packageName.isNotEmpty) a.packageName,
    };

    final points = await Future.wait(
      List.generate(7, (index) async {
        final day = start.add(Duration(days: index));
        final startDate = DateTime(day.year, day.month, day.day);
        final isToday = startDate.day == today.day && startDate.month == today.month && startDate.year == today.year;
        final endDate = isToday ? today : startDate.add(const Duration(days: 1)).subtract(const Duration(milliseconds: 1));

        try {
          double totalMinutes = 0.0;
          if (isToday) {
            final usageMap = await _fetchAccurateUsageMinutes(startDate, endDate);
            totalMinutes = usageMap.entries.where((e) => installedPackageIds.contains(e.key)).fold<double>(0.0, (sum, e) => sum + e.value);
          } else {
            // For past days, query aggregated usage stats which is extremely fast
            final List<UsageInfo> usageStats = await UsageStats.queryUsageStats(startDate, endDate);
            totalMinutes = usageStats.where((info) => installedPackageIds.contains(info.packageName)).fold<double>(0.0, (sum, info) {
              final ms = double.tryParse(info.totalTimeInForeground ?? '0') ?? 0.0;
              return sum + (ms / 1000.0 / 60.0);
            });
          }

          return DailyUsagePoint(date: startDate, totalMinutes: totalMinutes);
        } catch (e) {
          debugPrint("Error loading day usage for ${_dateKey(startDate)}: $e");
          return DailyUsagePoint(date: startDate, totalMinutes: 0.0);
        }
      }),
    );

    return points;
  }

  List<DailyUsagePoint> _buildWeeklyUsageFromMap(Map<String, double> history) {
    final today = DateTime.now();
    final start = DateTime(today.year, today.month, today.day).subtract(const Duration(days: 6));
    return List.generate(7, (index) {
      final date = start.add(Duration(days: index));
      return DailyUsagePoint(date: date, totalMinutes: history[_dateKey(date)] ?? 0.0);
    });
  }

  void _updateTodayWeeklyPoint(double totalMinutes) {
    if (weeklyUsage.isEmpty) return;

    final today = DateTime.now();
    final todayIndex = weeklyUsage.indexWhere((point) => point.date.year == today.year && point.date.month == today.month && point.date.day == today.day);
    if (todayIndex == -1) return;

    final updated = List<DailyUsagePoint>.from(weeklyUsage);
    updated[todayIndex] = DailyUsagePoint(date: updated[todayIndex].date, totalMinutes: totalMinutes);
    weeklyUsage.assignAll(updated);
  }

  List<DailyUsagePoint> _fallbackWeeklyUsage() {
    final today = DateTime.now();
    final start = DateTime(today.year, today.month, today.day).subtract(const Duration(days: 6));
    const totals = [2.4, 4.1, 3.2, 5.2, 4.2, 1.2, 0.9];

    return List.generate(7, (index) {
      final date = start.add(Duration(days: index));
      return DailyUsagePoint(date: date, totalMinutes: totals[index] * 60);
    });
  }

  String _dateKey(DateTime date) {
    return '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  Map<String, double> _decodeUsageHistory(String? raw) {
    if (raw == null || raw.isEmpty) return {};

    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map) {
        return decoded.map((key, value) => MapEntry('$key', value is num ? value.toDouble() : double.tryParse('$value') ?? 0.0));
      }
    } catch (e) {
      debugPrint("Error decoding daily usage history: $e");
    }

    return {};
  }

  Future<Map<String, _SavedLimitConfig>> _loadSavedLimits() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final limitsJson = prefs.getString('active_limits') ?? '{}';
      final Map<String, dynamic> decoded = jsonDecode(limitsJson);
      return decoded.map((key, value) => MapEntry(key, _parseSavedLimitConfig(value)));
    } catch (e) {
      debugPrint("Error loading limits from SharedPreferences: $e");
      return {};
    }
  }

  Future<void> _saveLimitsToPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final Map<String, Map<String, dynamic>> limitsMap = {};
      for (var app in apps) {
        if (app.limit != null && app.limit!.isActive) {
          limitsMap[app.id] = {'limitMinutes': app.limit!.limitMinutes, 'repeatDaily': app.limit!.repeatDaily, 'notifyAt80': app.limit!.notifyAt80};
        }
      }
      await prefs.setString('active_limits', jsonEncode(limitsMap));
    } catch (e) {
      debugPrint("Error saving limits to SharedPreferences: $e");
    }
  }

  Future<void> setLimit(String appId, double limitMinutes, bool repeatDaily, bool notifyAt80) async {
    final index = apps.indexWhere((app) => app.id == appId);
    if (index != -1) {
      final app = apps[index];
      app.limit = UsageLimit(isActive: true, limitMinutes: limitMinutes, repeatDaily: repeatDaily, notifyAt80: notifyAt80);
      apps[index] = app;
      await _saveLimitsToPrefs();

      // Reset today's notification flags so the new limit can re-trigger
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('last_notified_$appId');
      await prefs.remove('last_warned_80_$appId');

      // If overlay is active, either close it (new limit not yet exceeded) or refresh it
      try {
        final isActive = await FlutterOverlayWindow.isActive();
        final overlayPackage = prefs.getString('overlay_alert_package_name') ?? '';
        if (isActive && overlayPackage == appId) {
          if (app.elapsedMinutes < limitMinutes) {
            // User hasn't exceeded the new limit — close the overlay
            await FlutterOverlayWindow.closeOverlay();
          } else {
            // Still over limit — refresh the displayed limit
            await prefs.setInt('overlay_alert_limit_minutes', limitMinutes.toInt());
            await FlutterOverlayWindow.shareData({'action': 'refresh'});
          }
        }
      } catch (_) {}
    }
  }

  Future<void> removeLimit(String appId) async {
    final index = apps.indexWhere((app) => app.id == appId);
    if (index != -1) {
      final app = apps[index];
      app.limit = null;
      apps[index] = app;
      await _saveLimitsToPrefs();
    }
  }

  void toggleFocusMode() {
    stats.value.isFocusModeOn = !stats.value.isFocusModeOn;
    stats.refresh();
  }

  /// Load the user-saved daily screen-time goal from SharedPreferences.
  Future<void> _loadDailyGoal() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getDouble(_dailyGoalKey);
      if (saved != null && saved > 0) {
        stats.value.totalGoalMinutes = saved;
        stats.refresh();
      }
    } catch (e) {
      debugPrint('Error loading daily goal: $e');
    }
  }

  /// Persist the user's daily screen-time goal and update the reactive stats.
  Future<void> setDailyGoal(double minutes) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble(_dailyGoalKey, minutes);
      stats.value.totalGoalMinutes = minutes;
      stats.refresh();
    } catch (e) {
      debugPrint('Error saving daily goal: $e');
    }
  }

  static const Set<String> _excludedPackages = {
    'com.android.systemui',
    'com.android.launcher',
    'com.android.launcher2',
    'com.android.launcher3',
    'com.google.android.apps.nexuslauncher',
    'com.miui.home',
    'com.huawei.android.launcher',
    'com.sec.android.app.launcher',
    'com.oppo.launcher',
    'com.vivo.launcher',
    'com.oneplus.launcher',
    'com.android.inputmethod.latin',
    'com.google.android.inputmethod.latin',
    'com.samsung.android.honeyboard',
    'com.swiftkey.swiftkeyapp',
  };

  Future<List<double>> fetchHourlyBreakdown(String packageName) async {
    final List<double> hourlyMinutes = List.filled(24, 0.0);

    try {
      final now = DateTime.now();
      final startOfDay = DateTime(now.year, now.month, now.day);

      final bufferedStart = startOfDay.subtract(const Duration(minutes: 30));
      final startMs = startOfDay.millisecondsSinceEpoch;
      final endMs = now.millisecondsSinceEpoch;

      final List<EventUsageInfo> events = await UsageStats.queryEvents(bufferedStart, now);

      int? sessionStartMs;

      for (final event in events) {
        if (event.packageName != packageName) continue;

        final int? type = int.tryParse(event.eventType ?? '');
        final int? tsMs = int.tryParse(event.timeStamp ?? '');
        if (type == null || tsMs == null) continue;

        if (type == 1) {
          // MOVE_TO_FOREGROUND
          sessionStartMs = tsMs;
        } else if (type == 2) {
          // MOVE_TO_BACKGROUND
          if (sessionStartMs != null) {
            _distributeSessionToHours(hourlyMinutes: hourlyMinutes, sessionStartMs: sessionStartMs.clamp(startMs, endMs), sessionEndMs: tsMs.clamp(startMs, endMs));
            sessionStartMs = null;
          }
        }
      }

      // App still in foreground right now
      if (sessionStartMs != null) {
        _distributeSessionToHours(hourlyMinutes: hourlyMinutes, sessionStartMs: sessionStartMs.clamp(startMs, endMs), sessionEndMs: endMs);
      }
    } catch (e) {
      debugPrint('Error fetching hourly breakdown for $packageName: $e');
    }

    return hourlyMinutes;
  }

  /// Splits a single foreground session across hour buckets.
  /// e.g. a session from 2:45pm to 3:20pm contributes
  /// 15min to hour[14] and 20min to hour[15].
  void _distributeSessionToHours({required List<double> hourlyMinutes, required int sessionStartMs, required int sessionEndMs}) {
    if (sessionEndMs <= sessionStartMs) return;

    var cursor = sessionStartMs;

    while (cursor < sessionEndMs) {
      final cursorDt = DateTime.fromMillisecondsSinceEpoch(cursor);
      final hour = cursorDt.hour;

      // End of current hour slot
      final hourEndDt = DateTime(
        cursorDt.year,
        cursorDt.month,
        cursorDt.day,
        hour + 1, // rolls over correctly via DateTime
      );
      final hourEndMs = hourEndDt.millisecondsSinceEpoch;

      final sliceEndMs = hourEndMs < sessionEndMs ? hourEndMs : sessionEndMs;
      final sliceMin = (sliceEndMs - cursor) / 1000.0 / 60.0;

      if (hour >= 0 && hour < 24) {
        hourlyMinutes[hour] = (hourlyMinutes[hour] + sliceMin);
      }

      cursor = sliceEndMs;
    }
  }
}

class _SavedLimitConfig {
  final double limitMinutes;
  final bool repeatDaily;
  final bool notifyAt80;

  const _SavedLimitConfig({required this.limitMinutes, this.repeatDaily = true, this.notifyAt80 = true});
}

_SavedLimitConfig _parseSavedLimitConfig(dynamic value) {
  if (value is num) {
    return _SavedLimitConfig(limitMinutes: value.toDouble());
  }

  if (value is Map) {
    final rawLimitMinutes = value['limitMinutes'];
    final rawRepeatDaily = value['repeatDaily'];
    final rawNotifyAt80 = value['notifyAt80'];

    return _SavedLimitConfig(
      limitMinutes: rawLimitMinutes is num ? rawLimitMinutes.toDouble() : 0.0,
      repeatDaily: rawRepeatDaily is bool ? rawRepeatDaily : true,
      notifyAt80: rawNotifyAt80 is bool ? rawNotifyAt80 : true,
    );
  }

  return const _SavedLimitConfig(limitMinutes: 0.0);
}
