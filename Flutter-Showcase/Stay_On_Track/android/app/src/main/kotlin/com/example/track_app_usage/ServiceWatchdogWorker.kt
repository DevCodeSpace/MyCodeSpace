package com.example.track_app_usage

import android.app.ActivityManager
import android.content.Context
import android.content.Intent
import android.os.Build
import androidx.work.ExistingPeriodicWorkPolicy
import androidx.work.PeriodicWorkRequestBuilder
import androidx.work.Worker
import androidx.work.WorkerParameters
import androidx.work.WorkManager
import id.flutter.flutter_background_service.BackgroundService
import java.util.concurrent.TimeUnit

// Runs every 15 minutes and restarts the background tracking service only when
// it is actually dead. We must NOT call startForegroundService() on an already-
// running service: flutter_background_service re-initialises Flutter on every
// onStartCommand(), which can take > 5 s and trigger
// ForegroundServiceDidNotStartInTimeException.
class ServiceWatchdogWorker(context: Context, params: WorkerParameters) : Worker(context, params) {

    override fun doWork(): Result {
        val prefs = applicationContext.getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)
        val isInitialized = prefs.getBoolean("flutter.background_service_initialized", false)
        if (!isInitialized) {
            return Result.success()
        }

        if (!isServiceRunning()) {
            try {
                val intent = Intent(applicationContext, BackgroundService::class.java)
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                    applicationContext.startForegroundService(intent)
                } else {
                    applicationContext.startService(intent)
                }
            } catch (e: Exception) {
                // Swallow — the next periodic tick will try again.
            }
        }
        return Result.success()
    }

    // getRunningServices() is deprecated on API 26+ but still returns this app's
    // own services, which is all we need.
    @Suppress("DEPRECATION")
    private fun isServiceRunning(): Boolean {
        val manager = applicationContext.getSystemService(Context.ACTIVITY_SERVICE) as ActivityManager
        return manager.getRunningServices(Integer.MAX_VALUE).any {
            it.service.className == BackgroundService::class.java.name
        }
    }

    companion object {
        private const val WORK_NAME = "stayontrack_service_watchdog"

        fun schedule(context: Context) {
            val request = PeriodicWorkRequestBuilder<ServiceWatchdogWorker>(
                15, TimeUnit.MINUTES
            ).build()

            WorkManager.getInstance(context).enqueueUniquePeriodicWork(
                WORK_NAME,
                ExistingPeriodicWorkPolicy.KEEP,
                request
            )
        }
    }
}
