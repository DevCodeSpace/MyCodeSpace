package com.example.track_app_usage

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.os.Build
import id.flutter.flutter_background_service.BackgroundService

// Restarts the background service when the device boots or when the app is killed
// and Android sends a restart signal. Handles both standard BOOT_COMPLETED and
// Qualcomm/HTC QUICKBOOT_POWERON (same boot event on some devices).
class BootReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent?) {
        val action = intent?.action ?: return
        if (action == Intent.ACTION_BOOT_COMPLETED ||
            action == "android.intent.action.QUICKBOOT_POWERON" ||
            action == "com.htc.intent.action.QUICKBOOT_POWERON"
        ) {
            val prefs = context.getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)
            val isInitialized = prefs.getBoolean("flutter.background_service_initialized", false)
            if (isInitialized) {
                val serviceIntent = Intent(context, BackgroundService::class.java)
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                    context.startForegroundService(serviceIntent)
                } else {
                    context.startService(serviceIntent)
                }
            }
            // Re-schedule the watchdog after every reboot so it stays active
            // even if the user never opens the app again after a restart.
            ServiceWatchdogWorker.schedule(context)
        }
    }
}
