import 'dart:async';
import 'dart:convert';
import 'dart:io' show Platform;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:installed_apps/installed_apps.dart';
import 'package:usage_stats/usage_stats.dart';

// Unique channel for alerts
const AndroidNotificationChannel alertChannel = AndroidNotificationChannel(
  'app_limits_alerts',
  'App Limits Alerts',
  description: 'Notifications sent when screen time limit is reached',
  importance: Importance.max,
  playSound: true,
  enableVibration: true,
);

// Native plugin instance
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

Future<void> initializeBackgroundService() async {
  if (!Platform.isAndroid) return;

  final service = FlutterBackgroundService();

  // Create notification channel for system alerts
  final AndroidFlutterLocalNotificationsPlugin? androidImplementation = flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
  if (androidImplementation != null) {
    await androidImplementation.createNotificationChannel(alertChannel);
  }

  await service.configure(
    androidConfiguration: AndroidConfiguration(
      onStart: onStart,
      autoStart: true,
      autoStartOnBoot: true,
      isForegroundMode: true,
      notificationChannelId: 'app_limits_alerts', // reuse or default
      initialNotificationTitle: 'StayOnTrack Screen Tracker',
      initialNotificationContent: 'Monitoring screen time active',
      foregroundServiceTypes: const [AndroidForegroundType.dataSync],
    ),
    iosConfiguration: IosConfiguration(autoStart: true, onForeground: onStart),
  );

  final prefs = await SharedPreferences.getInstance();
  await prefs.setBool('background_service_initialized', true);
  debugPrint('[BG] background_service_initialized set to true');

  final started = await service.startService();
  debugPrint('[BG] startService returned: $started');
  debugPrint('[BG] service running after start: ${await service.isRunning()}');
}

Future<void> requestNotificationPermissionIfNeeded() async {
  if (!Platform.isAndroid) return;

  final AndroidFlutterLocalNotificationsPlugin? androidImplementation = flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
  await androidImplementation?.requestNotificationsPermission();
}

@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  DartPluginRegistrant.ensureInitialized();
  debugPrint("[BG] onStart called — background service started");

  service.on('stopService').listen((event) {
    debugPrint('[BG] stopService signal received: $event');
    service.stopSelf();
  });

  // Initialize notifications inside the isolate
  const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
  const InitializationSettings initializationSettings = InitializationSettings(android: initializationSettingsAndroid);
  await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  debugPrint("[BG] Notifications initialized");

  // Periodic loop running every 5 seconds to track app limits
  Timer.periodic(const Duration(seconds: 5), (timer) async {
    debugPrint("[BG] Timer tick #${timer.tick}");
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.reload();

      // Load limits stored as a map of {packageName: config}
      final limitsJson = prefs.getString('active_limits') ?? '{}';
      final Map<String, dynamic> limitsMap = jsonDecode(limitsJson);
      if (limitsMap.isEmpty) {
        debugPrint("[BG] No active limits set, skipping (prefs key active_limits: $limitsJson)");
        return;
      }
      debugPrint("[BG] Active limits: ${limitsMap.keys.toList()}");

      final now = DateTime.now();
      final startDate = DateTime(now.year, now.month, now.day);
      final endDate = now;

      // Query usage from Android UsageStatsManager
      final List<UsageInfo> usageList = await UsageStats.queryUsageStats(startDate, endDate);
      debugPrint("[BG] Usage stats fetched: ${usageList.length} entries");

      // queryUsageStats() does NOT include the currently running foreground session —
      // Android only commits time when the app moves to background. We use queryEvents()
      // to find which apps are currently in the foreground and add that live session
      // time so the limit fires while the user is still inside the app.
      String? currentForegroundPackage;
      final Map<String, int> activeForegroundStartMs = {};
      try {
        final List<EventUsageInfo> events = await UsageStats.queryEvents(startDate, endDate);
        for (final event in events) {
          final pkg = event.packageName;
          if (pkg == null) continue;
          final int type = int.tryParse(event.eventType ?? '0') ?? 0;
          final int ts = int.tryParse(event.timeStamp ?? '0') ?? 0;
          if (type == 1) {
            // MOVE_TO_FOREGROUND
            activeForegroundStartMs[pkg] = ts;
            currentForegroundPackage = pkg;
          } else if (type == 2) {
            // MOVE_TO_BACKGROUND
            activeForegroundStartMs.remove(pkg);
            if (currentForegroundPackage == pkg) {
              currentForegroundPackage = null;
            }
          }
        }
        if (currentForegroundPackage == null && activeForegroundStartMs.isNotEmpty) {
          currentForegroundPackage = activeForegroundStartMs.keys.last;
        }
        debugPrint("[BG] Active foreground apps: ${activeForegroundStartMs.keys.toList()}");
        debugPrint("[BG] Current foreground app: $currentForegroundPackage");
      } catch (e) {
        debugPrint("[BG] queryEvents failed: $e (proceeding without live session adjustment)");
      }

      // Build committed-time map from usageList for quick lookup
      final Map<String, double> committedMsMap = {};
      for (final usage in usageList) {
        final pkg = usage.packageName;
        if (pkg != null) {
          committedMsMap[pkg] = double.tryParse(usage.totalTimeInForeground ?? '0') ?? 0.0;
        }
      }

      for (final limitEntry in limitsMap.entries) {
        final packageName = limitEntry.key;

        final _StoredLimitConfig config = _parseStoredLimitConfig(limitEntry.value);
        final double limitMinutes = config.limitMinutes;

        // Start with committed historical time for today
        double totalTimeMs = committedMsMap[packageName] ?? 0.0;

        // Add live foreground session time (not yet committed to UsageStats)
        final int? fgStartMs = activeForegroundStartMs[packageName];
        if (fgStartMs != null) {
          final int sessionStartMs = fgStartMs < startDate.millisecondsSinceEpoch ? startDate.millisecondsSinceEpoch : fgStartMs;
          final int currentSessionMs = now.millisecondsSinceEpoch - sessionStartMs;
          if (currentSessionMs > 0) {
            totalTimeMs += currentSessionMs;
            debugPrint("[BG] $packageName — live session: ${(currentSessionMs / 60000).toStringAsFixed(2)}m added");
          }
        }

        final double elapsedMinutes = totalTimeMs / 1000.0 / 60.0;
        final String todayStr = "${now.year}-${now.month}-${now.day}";

        debugPrint("[BG] $packageName — elapsed: ${elapsedMinutes.toStringAsFixed(2)}m / limit: ${limitMinutes}m");

        if (config.notifyAt80 && elapsedMinutes >= (limitMinutes * 0.8) && elapsedMinutes < limitMinutes) {
          final lastWarnedDate = prefs.getString('last_warned_80_$packageName');
          if (lastWarnedDate != todayStr) {
            debugPrint("[BG] $packageName — at 80%, showing warning notification");
            await _showWarningNotification(packageName, limitMinutes);
            await prefs.setString('last_warned_80_$packageName', todayStr);
          } else {
            debugPrint("[BG] $packageName — 80% warning already sent today");
          }
        }

        if (elapsedMinutes >= limitMinutes) {
          debugPrint("[BG] $packageName — LIMIT EXCEEDED");

          // Check snooze FIRST
          final snoozeUntilStr = prefs.getString('snooze_until_$packageName');
          final snoozeUntil = snoozeUntilStr != null ? DateTime.tryParse(snoozeUntilStr) : null;
          final isSnoozed = snoozeUntil != null && snoozeUntil.isAfter(now);
          debugPrint("[BG] $packageName — isSnoozed: $isSnoozed (snoozeUntil: $snoozeUntilStr)");

          if (isSnoozed) {
            debugPrint("[BG] $packageName — snoozed, skipping");
          } else {
            // Snooze expired — reset last_notified so overlay re-triggers
            if (snoozeUntil != null) {
              await prefs.remove('last_notified_$packageName');
              await prefs.remove('snooze_until_$packageName');
              debugPrint("[BG] $packageName — snooze expired, cleared last_notified");
            }

            if (currentForegroundPackage == 'com.example.track_app_usage') {
              debugPrint("[BG] StayOnTrack is currently in the foreground. Ignoring overlay trigger for $packageName.");
            } else if (currentForegroundPackage != packageName) {
              debugPrint("[BG] $packageName limit exceeded, but it is not in the foreground (foreground is $currentForegroundPackage). Skipping overlay.");
            } else {
              final hasOverlay = await FlutterOverlayWindow.isPermissionGranted();
              debugPrint("[BG] $packageName — overlay permission: $hasOverlay");
              if (hasOverlay) {
                final isOverlayActive = await FlutterOverlayWindow.isActive();
                final activeOverlayPkg = prefs.getString('overlay_alert_package_name');
                if (isOverlayActive && activeOverlayPkg == packageName) {
                  debugPrint("[BG] $packageName — overlay is already active for this package, skipping trigger");
                } else {
                  debugPrint("[BG] $packageName — calling _showLimitOverlay");
                  await _showLimitOverlay(packageName, limitMinutes, prefs);
                }
              } else {
                final lastNotifiedDate = prefs.getString('last_notified_$packageName');
                if (lastNotifiedDate == todayStr) {
                  debugPrint("[BG] $packageName — already notified today via notification, skipping");
                } else {
                  debugPrint("[BG] $packageName — no overlay permission, showing notification");
                  await _showLimitNotification(packageName, limitMinutes);
                  await prefs.setString('last_notified_$packageName', todayStr);
                  debugPrint("[BG] $packageName — last_notified saved for today");
                }
              }
            }
          }
        }
      }
    } catch (e, stack) {
      debugPrint("[BG] ERROR in timer: $e");
      debugPrint("[BG] Stack: $stack");
    }
  });
}

Future<String> _getAppName(String packageName) async {
  final info = await InstalledApps.getAppInfo(packageName);
  if (info != null && info.name.isNotEmpty) return info.name;
  final last = packageName.split('.').last;
  return last.length > 1 ? last[0].toUpperCase() + last.substring(1) : last;
}

Future<void> _showLimitNotification(String packageName, double limitMinutes) async {
  final String appName = await _getAppName(packageName);

  await flutterLocalNotificationsPlugin.show(
    packageName.hashCode,
    'Limit Reached: $appName',
    'You have reached your daily limit of ${limitMinutes.toInt()}m.',
    NotificationDetails(
      android: AndroidNotificationDetails(
        alertChannel.id,
        alertChannel.name,
        channelDescription: alertChannel.description,
        importance: Importance.max,
        priority: Priority.high,
        playSound: true,
        enableVibration: true,
      ),
    ),
  );
}

Future<void> _showWarningNotification(String packageName, double limitMinutes) async {
  final String appName = await _getAppName(packageName);

  await flutterLocalNotificationsPlugin.show(
    packageName.hashCode ^ 0x80,
    'Usage warning: $appName',
    'You are at 80% of your daily limit of ${limitMinutes.toInt()}m.',
    NotificationDetails(
      android: AndroidNotificationDetails(
        alertChannel.id,
        alertChannel.name,
        channelDescription: alertChannel.description,
        importance: Importance.max,
        priority: Priority.high,
        playSound: true,
        enableVibration: true,
      ),
    ),
  );
}

// Returns true if showOverlay() was actually called (caller should save last_notified).
// Returns false if overlay was already active for this same app (no action needed).
Future<bool> _showLimitOverlay(String packageName, double limitMinutes, SharedPreferences prefs) async {
  final String appName = await _getAppName(packageName);

  // Save data for the overlay widget to read via SharedPreferences
  await prefs.setString('overlay_alert_app_name', appName);
  await prefs.setString('overlay_alert_package_name', packageName);
  await prefs.setInt('overlay_alert_limit_minutes', limitMinutes.toInt());
  debugPrint("[BG] Overlay prefs saved — appName: $appName, package: $packageName, limit: ${limitMinutes.toInt()}m");

  final isAlreadyActive = await FlutterOverlayWindow.isActive();
  debugPrint("[BG] Overlay isAlreadyActive: $isAlreadyActive");

  if (isAlreadyActive) {
    // Close stale overlay so we can reopen with fresh data for this package
    debugPrint("[BG] Closing stale overlay before reopening");
    await FlutterOverlayWindow.closeOverlay();
  }

  debugPrint("[BG] Calling FlutterOverlayWindow.showOverlay()");
  try {
    await FlutterOverlayWindow.showOverlay(
      height: WindowSize.fullCover,
      width: WindowSize.matchParent,
      alignment: OverlayAlignment.center,
      flag: OverlayFlag.defaultFlag,
      overlayTitle: 'Limit Reached: $appName',
      overlayContent: 'Daily limit of ${limitMinutes.toInt()}m reached',
      enableDrag: false,
      startPosition: const OverlayPosition(0, 0),
      appName: appName,
      packageName: packageName,
      limitMinutes: limitMinutes.toInt(),
    );
    debugPrint("[BG] showOverlay() completed (OverlayService startService scheduled)");

    // isRunning in OverlayService is now set AFTER windowManager.addView(), so
    // isActive() returning true guarantees the view is in the WindowManager.
    // Poll for up to 5 seconds, then call moveOverlay() multiple times to nudge
    // the hardware compositor into showing our overlay over the foreground app.
    bool windowForced = false;
    for (int i = 0; i < 20; i++) {
      await Future.delayed(const Duration(milliseconds: 250));
      final isActive = await FlutterOverlayWindow.isActive();
      if (isActive) {
        // Dense burst of nudges in the first 2s — this is when the compositor
        // needs to be triggered to render the new TYPE_APPLICATION_OVERLAY
        // surface above the currently active foreground app.
        for (final delayMs in [0, 200, 400, 700, 1100, 1600, 2200]) {
          await Future.delayed(Duration(milliseconds: delayMs == 0 ? 0 : 200));
          await FlutterOverlayWindow.moveOverlay(const OverlayPosition(0, 0));
          debugPrint("[BG] moveOverlay() nudge at +${(i + 1) * 250 + delayMs}ms");
        }
        windowForced = true;
        break;
      }
    }
    if (!windowForced) {
      debugPrint("[BG] WARNING: overlay never became active within 3s");
    }

    // Push data to the overlay isolate. SharedPreferences.apply() is async at the
    // OS level, so the overlay may open before prefs are flushed to disk. We send
    // shareData multiple times because the overlay Flutter engine can take >400ms to
    // start on slower devices, causing the listener to miss an early shareData call.
    final payload = {'appName': appName, 'packageName': packageName, 'limitMinutes': limitMinutes.toInt()};
    await Future.delayed(const Duration(milliseconds: 200));
    await FlutterOverlayWindow.shareData(payload);
    debugPrint("[BG] shareData sent (1st) — appName: $appName");
    await Future.delayed(const Duration(milliseconds: 800));
    await FlutterOverlayWindow.shareData(payload);
    debugPrint("[BG] shareData sent (2nd) — appName: $appName");
    await Future.delayed(const Duration(milliseconds: 1200));
    await FlutterOverlayWindow.shareData(payload);
    debugPrint("[BG] shareData sent (3rd) — appName: $appName");
    return true;
  } catch (e, stack) {
    debugPrint("[BG] showOverlay failed: $e");
    debugPrint("[BG] Stack: $stack");
    await _showLimitNotification(packageName, limitMinutes);
    return false;
  }
}

_StoredLimitConfig _parseStoredLimitConfig(dynamic value) {
  if (value is num) {
    return _StoredLimitConfig(limitMinutes: value.toDouble());
  }

  if (value is Map) {
    final rawLimitMinutes = value['limitMinutes'];
    final rawRepeatDaily = value['repeatDaily'];
    final rawNotifyAt80 = value['notifyAt80'];

    return _StoredLimitConfig(
      limitMinutes: rawLimitMinutes is num ? rawLimitMinutes.toDouble() : 0.0,
      repeatDaily: rawRepeatDaily is bool ? rawRepeatDaily : true,
      notifyAt80: rawNotifyAt80 is bool ? rawNotifyAt80 : true,
    );
  }

  return const _StoredLimitConfig(limitMinutes: 0.0);
}

class _StoredLimitConfig {
  final double limitMinutes;
  final bool repeatDaily;
  final bool notifyAt80;

  const _StoredLimitConfig({required this.limitMinutes, this.repeatDaily = true, this.notifyAt80 = true});
}
