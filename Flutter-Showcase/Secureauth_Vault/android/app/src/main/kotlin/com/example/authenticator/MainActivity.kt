package com.secureAuthVault

import android.app.AlarmManager
import android.app.PendingIntent
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.ComponentName
import android.content.pm.PackageManager
import android.os.Build
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.util.Calendar
import androidx.core.content.edit

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.secureAuthVault/icon_changer"
    private var queuedIcon: String? = null // Holds the pending icon swap safely

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "syncFirebaseTimeWindows" -> {
                    val morningTime = call.argument<String>("morning_time") ?: "6:05"
                    val nightTime = call.argument<String>("night_time") ?: "16:17"

                    val prefs = applicationContext.getSharedPreferences("IconSettings", Context.MODE_PRIVATE)
                    prefs.edit {
                        putString("morning_time", morningTime)
                        putString("night_time", nightTime)
                    }

                    // 🔑 CALCULATE THE TARGET ICON STATE
                    val calculatedTarget = IconAlarmReceiver.calculateTargetIcon(applicationContext)

                    // Get the currently active icon component layout
                    val pm = applicationContext.packageManager
                    val purpleAlias = ComponentName(applicationContext, "com.secureAuthVault.MainActivityPurple")
                    val isCurrentlyPurple = pm.getComponentEnabledSetting(purpleAlias) == PackageManager.COMPONENT_ENABLED_STATE_ENABLED
                    val currentIcon = if (isCurrentlyPurple) "purple" else "default"

                    // If a change is needed, queue it instead of changing it instantly in the foreground!
                    if (calculatedTarget != currentIcon) {
                        queuedIcon = calculatedTarget
                    }

                    IconAlarmReceiver.scheduleNextAlarms(applicationContext)
                    result.success(true)
                }
                "changeAppIcon" -> {
                    val iconName = call.argument<String>("iconName") ?: "default"
                    try {
                        IconAlarmReceiver.switchIconConfig(applicationContext, iconName)
                        result.success(true)
                    } catch (e: Exception) {
                        result.error("FAILED", e.message, null)
                    }
                }
//                else -> {
//                    result.notImplemented()
//                }
                "getActiveIcon" -> {
                    val pm = applicationContext.packageManager
                    val purpleAlias = ComponentName(applicationContext, "com.secureAuthVault.MainActivityPurple")

                    // Check if purple alias component is enabled on the device hardware layer
                    val isPurpleEnabled = pm.getComponentEnabledSetting(purpleAlias) == PackageManager.COMPONENT_ENABLED_STATE_ENABLED

                    if (isPurpleEnabled) {
                        result.success("purple")
                    } else {
                        result.success("default")
                    }
                }
            }
        }
    }

    // 🔑 THE SECRET SAUCE: Triggers exactly when the user presses the home button or swaps apps
    override fun onStop() {
        super.onStop()
        queuedIcon?.let { iconToApply ->
            // Apply the change silently now that the app is in the background
            IconAlarmReceiver.switchIconConfig(applicationContext, iconToApply)
            queuedIcon = null // Clear queue
        }
    }
}

// ── NATIVE BACKGROUND WAKEUP RECEIVER ENGINE ─────────────────────────────────
class IconAlarmReceiver : BroadcastReceiver() {

    override fun onReceive(context: Context, intent: Intent) {
        // Runs cleanly here because alarms only fire when the app is closed!
        val targetIcon = calculateTargetIcon(context)
        switchIconConfig(context, targetIcon)
        scheduleNextAlarms(context)
    }

    companion object {
        private fun parseTimeToMinutes(timeStr: String): Int {
            return try {
                val parts = timeStr.trim().split(":")
                (parts[0].toInt() * 60) + parts[1].toInt()
            } catch (e: Exception) {
                (6 * 60) + 5
            }
        }

        // Helper calculation block extracted for general framework reuse
        fun calculateTargetIcon(context: Context): String {
            val prefs = context.getSharedPreferences("IconSettings", Context.MODE_PRIVATE)
            val morningStr = prefs.getString("morning_time", "06:05") ?: "06:05"
            val nightStr = prefs.getString("night_time", "16:17") ?: "16:17"

            val calendar = Calendar.getInstance()
            val currentMinutes = (calendar.get(Calendar.HOUR_OF_DAY) * 60) + calendar.get(Calendar.MINUTE)

            val morningMinutes = parseTimeToMinutes(morningStr)
            val nightMinutes = parseTimeToMinutes(nightStr)

            return if (morningMinutes < nightMinutes) {
                if (currentMinutes in morningMinutes until nightMinutes) "default" else "purple"
            } else {
                if (currentMinutes >= morningMinutes || currentMinutes < nightMinutes) "default" else "purple"
            }
        }

        fun switchIconConfig(context: Context, targetIcon: String) {
            val pm = context.packageManager
            val root = ComponentName(context, "com.secureAuthVault.MainActivity")
            val defaultAlias = ComponentName(context, "com.secureAuthVault.MainActivityDefault")
            val purpleAlias = ComponentName(context, "com.secureAuthVault.MainActivityPurple")

            val activeElement = if (targetIcon == "purple") purpleAlias else defaultAlias
            val inactiveElement = if (targetIcon == "purple") defaultAlias else purpleAlias

            try {
                if (pm.getComponentEnabledSetting(activeElement) != PackageManager.COMPONENT_ENABLED_STATE_ENABLED) {
                    pm.setComponentEnabledSetting(activeElement, PackageManager.COMPONENT_ENABLED_STATE_ENABLED, PackageManager.DONT_KILL_APP)
                    pm.setComponentEnabledSetting(inactiveElement, PackageManager.COMPONENT_ENABLED_STATE_DISABLED, PackageManager.DONT_KILL_APP)
                    pm.setComponentEnabledSetting(root, PackageManager.COMPONENT_ENABLED_STATE_DISABLED, PackageManager.DONT_KILL_APP)
                }
            } catch (e: Exception) {
                e.printStackTrace()
            }
        }

        fun scheduleNextAlarms(context: Context) {
            val alarmManager = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager
            val prefs = context.getSharedPreferences("IconSettings", Context.MODE_PRIVATE)

            val times = listOf(
                prefs.getString("morning_time", "06:05") ?: "06:05",
                prefs.getString("night_time", "16:17") ?: "16:17"
            )

            times.forEachIndexed { index, timeStr ->
                val parts = timeStr.split(":")
                val targetCal = Calendar.getInstance().apply {
                    set(Calendar.HOUR_OF_DAY, parts[0].toInt())
                    set(Calendar.MINUTE, parts[1].toInt())
                    set(Calendar.SECOND, 0)
                    set(Calendar.MILLISECOND, 0)
                    if (before(Calendar.getInstance())) {
                        add(Calendar.DATE, 1)
                    }
                }

                val intent = Intent(context, IconAlarmReceiver::class.java).apply {
                    action = "com.secureAuthVault.ACTION_UPDATE_ICON"
                }

                val pendingIntent = PendingIntent.getBroadcast(
                    context, index, intent,
                    PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
                )

                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                    alarmManager.setExactAndAllowWhileIdle(AlarmManager.RTC_WAKEUP, targetCal.timeInMillis, pendingIntent)
                } else {
                    alarmManager.setExact(AlarmManager.RTC_WAKEUP, targetCal.timeInMillis, pendingIntent)
                }
            }
        }
    }
}