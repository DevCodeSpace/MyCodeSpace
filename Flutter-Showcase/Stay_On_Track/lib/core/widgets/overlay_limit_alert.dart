import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OverlayLimitAlert extends StatefulWidget {
  const OverlayLimitAlert({super.key});

  @override
  State<OverlayLimitAlert> createState() => _OverlayLimitAlertState();
}

class _OverlayLimitAlertState extends State<OverlayLimitAlert> {
  static const _appNameKey = 'overlay_alert_app_name';
  static const _packageNameKey = 'overlay_alert_package_name';
  static const _limitMinutesKey = 'overlay_alert_limit_minutes';
  static const _overlayChannel = MethodChannel('x-slayer/overlay');

  String _appName = '';
  String _packageName = '';
  int _limitMinutes = 0;
  StreamSubscription? _overlaySub;

  @override
  void initState() {
    super.initState();
    _loadAlertData();
    // Retry reading SharedPreferences to cover the case where Android's async apply()
    // hasn't flushed to disk before the overlay opens.
    Future.delayed(const Duration(milliseconds: 700), () {
      if (mounted) _loadAlertData();
    });
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) _loadAlertData();
    });
    _overlaySub = FlutterOverlayWindow.overlayListener.listen((data) {
      debugPrint("[Overlay] Received shareData payload: $data");
      if (data is Map) {
        final name = data['appName'] as String?;
        final pkg = data['packageName'] as String?;
        final limitVal = data['limitMinutes'];
        final limit = limitVal is num ? limitVal.toInt() : null;
        if (!mounted) return;
        setState(() {
          if (name != null && name.isNotEmpty) _appName = name;
          if (pkg != null && pkg.isNotEmpty) _packageName = pkg;
          if (limit != null) _limitMinutes = limit;
        });
      } else {
        _loadAlertData();
      }
    });
  }

  @override
  void dispose() {
    _overlaySub?.cancel();
    super.dispose();
  }

  Future<void> _loadAlertData() async {
    try {
      final Map<dynamic, dynamic>? data = await _overlayChannel.invokeMapMethod<String, dynamic>('getOverlayData');
      debugPrint("[Overlay] Loaded alert data from method channel: $data");
      if (data != null) {
        final name = data['appName'] as String?;
        final pkg = data['packageName'] as String?;
        final limit = data['limitMinutes'] as int?;
        if (!mounted) return;
        setState(() {
          if (name != null && name.isNotEmpty) _appName = name;
          if (pkg != null && pkg.isNotEmpty) _packageName = pkg;
          if (limit != null) _limitMinutes = limit;
        });
        return;
      }
    } catch (e) {
      debugPrint("[Overlay] Error invoking getOverlayData: $e");
    }

    // Fallback to SharedPreferences if method channel fails or returns null
    final prefs = await SharedPreferences.getInstance();
    await prefs.reload(); // overlay runs in a separate isolate — force fresh read from disk
    final appName = prefs.getString(_appNameKey);
    final packageName = prefs.getString(_packageNameKey);
    final limitMinutes = prefs.getInt(_limitMinutesKey);

    if (!mounted) return;
    setState(() {
      _appName = appName ?? 'App';
      if (packageName != null && packageName.isNotEmpty) {
        _packageName = packageName;
      }
      _limitMinutes = limitMinutes ?? 0;
    });
  }

  Future<String> _getPackageNameForSnooze() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.reload();
    final persistedPackageName = prefs.getString(_packageNameKey);
    if (persistedPackageName != null && persistedPackageName.isNotEmpty) {
      _packageName = persistedPackageName;
      return persistedPackageName;
    }
    return _packageName;
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF0A0E1A), Color(0xFF0D1221), Color(0xFF0A0E1A)]),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28.0, vertical: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Spacer(),

                // Alert icon ring
                Center(
                  child: Container(
                    width: 130,
                    height: 130,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFFEF4444).withValues(alpha: 0.4), width: 2),
                      boxShadow: [BoxShadow(color: const Color(0xFFEF4444).withValues(alpha: 0.15), blurRadius: 30, spreadRadius: 5)],
                    ),
                    child: Center(
                      child: Container(
                        width: 96,
                        height: 96,
                        decoration: BoxDecoration(shape: BoxShape.circle, color: const Color(0xFFEF4444).withValues(alpha: 0.1)),
                        child: const Icon(Icons.warning_amber_rounded, color: Color(0xFFEF4444), size: 52),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 36),

                Text(
                  '$_appName Limit Reached',
                  style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: -0.5),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  "You've used $_appName for $_limitMinutes minutes today.\nTime to take a break.",
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.65), fontSize: 15, height: 1.5),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 20),

                // Limit badge
                Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      color: const Color(0xFFEF4444).withValues(alpha: 0.12),
                      border: Border.all(color: const Color(0xFFEF4444).withValues(alpha: 0.2)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.timer, color: Color(0xFFEF4444), size: 14),
                        const SizedBox(width: 6),
                        Text(
                          'Daily limit: ${_limitMinutes}m',
                          style: const TextStyle(color: Color(0xFFEF4444), fontSize: 13, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),

                const Spacer(flex: 2),

                // Close button
                SizedBox(
                  height: 54,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFEF4444),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    onPressed: () async {
                      try {
                        await _overlayChannel.invokeMethod('goHome');
                      } catch (e) {
                        debugPrint("[Overlay] goHome error: $e");
                      }
                      await FlutterOverlayWindow.closeOverlay();
                    },
                    child: const Text('Got it, Close', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),

                const SizedBox(height: 14),

                // Snooze 15m
                SizedBox(
                  height: 54,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF7DD3FC),
                      side: BorderSide(color: const Color(0xFF7DD3FC).withValues(alpha: 0.3)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    onPressed: () async {
                      final prefs = await SharedPreferences.getInstance();
                      final packageName = await _getPackageNameForSnooze();
                      if (packageName.isNotEmpty) {
                        final now = DateTime.now();
                        final snoozeUntil = now.add(const Duration(minutes: 1));
                        await prefs.setString('snooze_until_$packageName', snoozeUntil.toIso8601String());
                        await prefs.remove('last_notified_$packageName');
                      }
                      await FlutterOverlayWindow.closeOverlay();
                    },
                    child: const Text('Snooze 15 minutes', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                  ),
                ),

                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
