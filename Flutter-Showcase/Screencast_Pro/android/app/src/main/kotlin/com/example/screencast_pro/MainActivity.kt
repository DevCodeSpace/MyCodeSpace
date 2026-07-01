package com.example.screencast_pro

import android.app.Activity
import android.content.Intent
import android.media.projection.MediaProjectionManager
import android.os.Build
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel

/**
 * Entry-point Activity for the Flutter app on Android.
 *
 * Bridges Flutter (Dart) ↔ native Android for screen capture:
 *
 *   MethodChannel "screen_capture/control"
 *     "requestCapture" → shows the system "Allow recording?" dialog.
 *                        On approval, starts [ScreenCaptureService].
 *                        Returns Boolean true/false to the Dart caller.
 *     "stopCapture"    → stops [ScreenCaptureService], dismisses notification.
 *
 *   EventChannel "screen_capture/frames"
 *     Streams raw JPEG byte arrays from [ScreenCaptureService.frameCallback]
 *     to Flutter. Each event is a Uint8List that CastStreamService forwards
 *     directly over the WebSocket to the Mac receiver.
 *
 * Why channels instead of a plugin?
 *   This project has no separate plugin package — the bridge lives entirely
 *   in MainActivity to keep the repo self-contained and dependency-free.
 */
class MainActivity : FlutterActivity() {

    companion object {
        /** Request code used to identify the MediaProjection permission result. */
        private const val CAPTURE_REQUEST = 1001

        // Channel names must match exactly the constants in cast_stream_service.dart.
        private const val METHOD_CH = "screen_capture/control"
        private const val EVENT_CH  = "screen_capture/frames"
    }

    /**
     * Holds the pending Dart MethodChannel result while the system permission
     * dialog is open. Completed in [onActivityResult] with true/false.
     * Null when no dialog is currently showing.
     */
    private var pendingResult: MethodChannel.Result? = null

    // ── Flutter engine configuration ──────────────────────────────────────────

    /**
     * Called once when the FlutterEngine is attached to this activity.
     * This is the correct place to register MethodChannel and EventChannel
     * handlers — the engine (and its binaryMessenger) is fully ready here.
     *
     * IMPORTANT: Native channel handlers registered here are not picked up by
     * Flutter hot-reload or hot-restart. After any change to this file or
     * ScreenCaptureService.kt, run "flutter clean && flutter run" to force
     * a full Gradle rebuild.
     */
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // ── MethodChannel: control commands from Dart ─────────────────────────
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, METHOD_CH)
            .setMethodCallHandler { call, result ->
                when (call.method) {

                    // Dart calls this when the user taps a receiver device and
                    // casting is about to begin. We show the OS permission dialog;
                    // the actual result (true/false) is delivered in onActivityResult.
                    "requestCapture" -> {
                        pendingResult = result
                        val pm = getSystemService(MEDIA_PROJECTION_SERVICE)
                                as MediaProjectionManager
                        // createScreenCaptureIntent() produces the standard Android
                        // "Screen Recording" consent dialog.
                        startActivityForResult(
                            pm.createScreenCaptureIntent(),
                            CAPTURE_REQUEST
                        )
                    }

                    // Dart calls this when the user taps "Stop Casting".
                    // Stopping the service also dismisses the persistent notification.
                    "stopCapture" -> {
                        stopService(Intent(this, ScreenCaptureService::class.java))
                        result.success(null)
                    }

                    else -> result.notImplemented()
                }
            }

        // ── EventChannel: JPEG frame stream from native → Dart ────────────────
        EventChannel(flutterEngine.dartExecutor.binaryMessenger, EVENT_CH)
            .setStreamHandler(object : EventChannel.StreamHandler {

                /**
                 * Called when Dart subscribes to the EventChannel
                 * (_event.receiveBroadcastStream().listen(...)).
                 * We wire [ScreenCaptureService.frameCallback] to the sink so
                 * every JPEG frame the service produces is forwarded to Dart.
                 * runOnUiThread is required: the callback fires on the background
                 * capture thread, but sink.success() must be called on the main thread.
                 */
                override fun onListen(args: Any?, sink: EventChannel.EventSink?) {
                    ScreenCaptureService.frameCallback = { bytes ->
                        runOnUiThread { sink?.success(bytes) }
                    }
                }

                /**
                 * Called when Dart cancels the EventChannel subscription
                 * (e.g. _frameSub.cancel() in CastStreamService.stopStreaming()).
                 * Clear the callback so the service does not deliver frames to a
                 * cancelled sink.
                 */
                override fun onCancel(args: Any?) {
                    ScreenCaptureService.frameCallback = null
                }
            })
    }

    // ── MediaProjection permission result ─────────────────────────────────────

    /**
     * Receives the result of the "Allow screen recording?" system dialog.
     * On approval (RESULT_OK), starts [ScreenCaptureService] with the
     * MediaProjection token so it can call MediaProjectionManager.getMediaProjection().
     * The pending Dart result is resolved here so Dart's await returns.
     */
    @Deprecated("Required for older APIs; still the correct pattern without Activity Result API")
    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        @Suppress("DEPRECATION")
        super.onActivityResult(requestCode, resultCode, data)

        if (requestCode != CAPTURE_REQUEST) return

        if (resultCode == Activity.RESULT_OK && data != null) {
            // Pass the MediaProjection token (resultCode + data) to the service.
            // The service MUST receive the original data Intent — it cannot be
            // reused across sessions; a new dialog must be shown each time.
            val serviceIntent = Intent(this, ScreenCaptureService::class.java).apply {
                putExtra(ScreenCaptureService.EXTRA_RESULT_CODE, resultCode)
                putExtra(ScreenCaptureService.EXTRA_RESULT_DATA, data)
            }
            // startForegroundService is required on Android 8+ (Oreo) to ensure
            // the service has time to call startForeground() within 10 seconds.
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                startForegroundService(serviceIntent)
            } else {
                startService(serviceIntent)
            }
            pendingResult?.success(true)  // Tell Dart: capture approved, service started
        } else {
            // User tapped "Cancel" or dismissed the dialog.
            pendingResult?.success(false) // Tell Dart: capture denied
        }
        pendingResult = null
    }
}
