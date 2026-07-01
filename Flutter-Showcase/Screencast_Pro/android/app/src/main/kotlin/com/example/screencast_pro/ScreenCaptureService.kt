package com.example.screencast_pro

import android.app.*
import android.content.Intent
import android.content.pm.ServiceInfo
import android.graphics.Bitmap
import android.graphics.PixelFormat
import android.hardware.display.DisplayManager
import android.hardware.display.VirtualDisplay
import android.media.ImageReader
import android.media.projection.MediaProjection
import android.media.projection.MediaProjectionManager
import android.os.*
import android.util.DisplayMetrics
import android.view.WindowManager
import androidx.core.app.NotificationCompat
import java.io.ByteArrayOutputStream
import java.nio.ByteBuffer

/**
 * ForegroundService that captures the device screen using Android's MediaProjection API
 * and delivers JPEG frames to Flutter via [frameCallback].
 *
 * Why a ForegroundService?
 *   Android requires screen-capture to run inside a ForegroundService so the OS
 *   keeps the process alive even when the user switches to another app or the
 *   home screen. A regular Service or background task would be killed, stopping
 *   the cast. The persistent notification is mandatory — it's the OS's way of
 *   telling the user that their screen is being recorded.
 *
 * Why MediaProjection instead of RepaintBoundary?
 *   Flutter's RepaintBoundary.toImage() only captures Flutter's own widget tree.
 *   When the user leaves the app, Flutter pauses rendering and no frames are
 *   produced. MediaProjection is an OS-level API: it mirrors the physical display
 *   into a [VirtualDisplay], so every visible pixel — home screen, other apps,
 *   notifications — is captured regardless of what is on screen.
 *
 * Frame flow:
 *   MediaProjection → VirtualDisplay → ImageReader (RGBA buffer)
 *     → Bitmap → JPEG bytes → [frameCallback] → EventChannel → Flutter → WebSocket
 *
 * Lifecycle:
 *   MainActivity calls startForegroundService() with the MediaProjection token
 *   (resultCode + resultData from the system permission dialog).
 *   The service starts capture in [onStartCommand] and runs until [stopSelf] or
 *   [stopService] is called from MainActivity on the "stopCapture" MethodChannel call.
 */
class ScreenCaptureService : Service() {

    companion object {
        /** Intent extra key carrying the MediaProjection result code from the activity. */
        const val EXTRA_RESULT_CODE = "resultCode"

        /** Intent extra key carrying the MediaProjection result data (permission token). */
        const val EXTRA_RESULT_DATA = "resultData"

        private const val CHANNEL_ID = "ScreenCastChannel"
        private const val NOTIF_ID   = 1

        /**
         * Callback invoked on every captured JPEG frame.
         * Set by MainActivity's EventChannel StreamHandler so frames flow:
         *   ScreenCaptureService → frameCallback → EventChannel sink → Dart.
         * Nullable: cleared in [onDestroy] so no frames leak after the service stops.
         */
        var frameCallback: ((ByteArray) -> Unit)? = null

        /** True while the service is running; read by MainActivity to guard double-starts. */
        var isRunning = false

        /**
         * Minimum gap between consecutive frames sent to Flutter (milliseconds).
         * Matches the original RepaintBoundary interval for ~6–7 FPS.
         * The ImageReader fires at display refresh rate (60 Hz); this throttle
         * drops intermediate frames to keep WiFi bandwidth reasonable.
         */
        private const val MIN_FRAME_INTERVAL_MS = 150L
    }

    // ── MediaProjection components ────────────────────────────────────────────

    /** Grants access to the screen content; obtained from the system permission dialog. */
    private var mediaProjection: MediaProjection? = null

    /**
     * Virtual display backed by the MediaProjection. Mirrors the physical display
     * at [captureWidth] × [captureHeight] pixels into [imageReader]'s surface.
     */
    private var virtualDisplay: VirtualDisplay? = null

    /**
     * Receives raw RGBA frames from the VirtualDisplay.
     * Buffer count of 2 means we hold at most two frames at once — enough to
     * always have the latest frame available without building a large queue.
     */
    private var imageReader: ImageReader? = null

    // ── Background thread ─────────────────────────────────────────────────────

    /**
     * Dedicated thread for ImageReader callbacks and Bitmap encoding.
     * Image processing is CPU-intensive; doing it off the main thread prevents
     * janking the Flutter UI and keeps the notification responsive.
     */
    private var handlerThread: HandlerThread? = null
    private var handler: Handler? = null

    // ── Capture resolution ────────────────────────────────────────────────────

    /** Capture at half the physical display width to keep JPEG files small. */
    private var captureWidth  = 0

    /** Capture at half the physical display height. */
    private var captureHeight = 0

    /** Half the screen DPI — passed to VirtualDisplay so content scales correctly. */
    private var captureDpi    = 0

    /** Timestamp (elapsedRealtime ms) of the last frame delivered to Flutter. */
    private var lastFrameMs = 0L

    // ── Service lifecycle ─────────────────────────────────────────────────────

    override fun onCreate() {
        super.onCreate()
        createNotificationChannel()

        // Determine half-resolution capture dimensions.
        // Half width/height = quarter the pixels = significantly smaller JPEG files
        // with no meaningful quality loss on a Mac display.
        val wm = getSystemService(WINDOW_SERVICE) as WindowManager
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
            val bounds = wm.currentWindowMetrics.bounds
            captureWidth  = bounds.width()  / 2
            captureHeight = bounds.height() / 2
        } else {
            val metrics = DisplayMetrics()
            @Suppress("DEPRECATION")
            wm.defaultDisplay.getMetrics(metrics)
            captureWidth  = metrics.widthPixels  / 2
            captureHeight = metrics.heightPixels / 2
        }
        captureDpi = resources.displayMetrics.densityDpi / 2

        // Start the background thread before onStartCommand so the Handler
        // is ready when we attach the ImageReader listener.
        handlerThread = HandlerThread("ScreenCaptureBg").also {
            it.start()
            handler = Handler(it.looper)
        }
    }

    /**
     * Called by Android when [startForegroundService] is invoked from MainActivity.
     * Extracts the MediaProjection token from the Intent, starts the foreground
     * notification (required before any other work), then begins screen capture.
     */
    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        // Foreground notification must be shown immediately — Android enforces a
        // 10-second limit between startForegroundService() and startForeground().
        val notification = buildNotification()
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            // Android 10+ requires us to declare the foreground service type.
            // FOREGROUND_SERVICE_TYPE_MEDIA_PROJECTION is mandatory for screen capture.
            startForeground(NOTIF_ID, notification,
                ServiceInfo.FOREGROUND_SERVICE_TYPE_MEDIA_PROJECTION)
        } else {
            startForeground(NOTIF_ID, notification)
        }

        // Extract the MediaProjection permission token passed from MainActivity.
        // These come from the system "Allow screen recording?" dialog result.
        val resultCode = intent?.getIntExtra(EXTRA_RESULT_CODE, Activity.RESULT_CANCELED)
            ?: return START_NOT_STICKY
        @Suppress("DEPRECATION")
        val resultData = intent.getParcelableExtra<Intent>(EXTRA_RESULT_DATA)
            ?: return START_NOT_STICKY

        val pm = getSystemService(MEDIA_PROJECTION_SERVICE) as MediaProjectionManager
        mediaProjection = pm.getMediaProjection(resultCode, resultData)

        // On Android 14+, register a callback so we stop cleanly if the user
        // revokes the capture permission from the quick-settings tile.
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.UPSIDE_DOWN_CAKE) {
            mediaProjection?.registerCallback(object : MediaProjection.Callback() {
                override fun onStop() { stopSelf() }
            }, handler)
        }

        startCapture()
        isRunning = true

        // START_NOT_STICKY: do not restart automatically if the process is killed.
        // The user must explicitly start a new cast session.
        return START_NOT_STICKY
    }

    // ── Capture setup ─────────────────────────────────────────────────────────

    /**
     * Creates the [VirtualDisplay] backed by [imageReader] and wires up the
     * [ImageReader.OnImageAvailableListener] that encodes and delivers frames.
     */
    private fun startCapture() {
        // ImageReader buffers incoming RGBA frames from the VirtualDisplay.
        // PixelFormat.RGBA_8888 matches what createVirtualDisplay produces.
        imageReader = ImageReader.newInstance(
            captureWidth, captureHeight,
            PixelFormat.RGBA_8888, 2   // 2 buffers: always read the latest
        )

        // VirtualDisplay mirrors the physical screen into imageReader's surface.
        // VIRTUAL_DISPLAY_FLAG_AUTO_MIRROR copies exactly what is on screen,
        // including the status bar, navigation bar, and any overlay app.
        virtualDisplay = mediaProjection?.createVirtualDisplay(
            "ScreenCast",
            captureWidth, captureHeight, captureDpi,
            DisplayManager.VIRTUAL_DISPLAY_FLAG_AUTO_MIRROR,
            imageReader!!.surface,
            null, handler   // null callback; handler = background thread for callbacks
        )

        // Called by Android on the background [handler] thread each time a new
        // frame lands in the ImageReader queue.
        imageReader!!.setOnImageAvailableListener({ reader ->
            val now = SystemClock.elapsedRealtime()

            // Throttle: drop frames that arrive faster than MIN_FRAME_INTERVAL_MS.
            // The display refreshes at 60 Hz; we only want ~6.7 FPS over WiFi.
            if (now - lastFrameMs < MIN_FRAME_INTERVAL_MS) {
                reader.acquireLatestImage()?.close() // Must close to free the buffer
                return@setOnImageAvailableListener
            }

            // acquireLatestImage() discards any older queued frame and gives us
            // the most recent one — important so we never show stale content.
            val image = reader.acquireLatestImage() ?: return@setOnImageAvailableListener
            try {
                val plane  = image.planes[0]
                val buffer: ByteBuffer = plane.buffer
                val ps     = plane.pixelStride  // bytes per pixel (4 for RGBA_8888)
                val rs     = plane.rowStride    // bytes per row (may include padding)

                // rowStride can be larger than width * pixelStride due to GPU alignment.
                // We must account for this padding when creating the Bitmap.
                val pad = (rs - ps * image.width) / ps

                val bmp = Bitmap.createBitmap(
                    image.width + pad, image.height,
                    Bitmap.Config.ARGB_8888
                )
                bmp.copyPixelsFromBuffer(buffer)

                // Crop off the right-padding columns so the Bitmap is exactly
                // image.width × image.height before we compress it.
                val cropped = Bitmap.createBitmap(bmp, 0, 0, image.width, image.height)
                bmp.recycle() // Free the padded intermediate immediately

                // JPEG at quality 70 gives good visual fidelity at ~3× smaller file
                // size than PNG. The Mac receiver's Image.memory() handles JPEG natively.
                val out = ByteArrayOutputStream()
                cropped.compress(Bitmap.CompressFormat.JPEG, 70, out)
                cropped.recycle()

                lastFrameMs = now
                // Deliver the JPEG bytes to the Flutter EventChannel sink
                // (wired up in MainActivity's EventChannel StreamHandler).
                frameCallback?.invoke(out.toByteArray())
            } catch (_: Exception) {
                // Silently skip malformed frames rather than crashing the service.
            } finally {
                image.close() // Always release the ImageReader buffer
            }
        }, handler) // Run listener on background thread, not the main thread
    }

    // ── Notification ──────────────────────────────────────────────────────────

    /**
     * Builds the persistent notification shown while casting is active.
     * Android requires this for ForegroundServices — it informs the user that
     * their screen is being shared and provides a tap target to return to the app.
     */
    private fun buildNotification(): Notification {
        val tapIntent = packageManager.getLaunchIntentForPackage(packageName)
        val pi = PendingIntent.getActivity(
            this, 0, tapIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )
        return NotificationCompat.Builder(this, CHANNEL_ID)
            .setContentTitle("Screen Casting")
            .setContentText("Your screen is being shared to the Mac")
            .setSmallIcon(android.R.drawable.ic_menu_share)
            .setContentIntent(pi)
            .setOngoing(true)  // Prevents the user from swiping it away
            .build()
    }

    /** Creates the NotificationChannel required on Android 8+ (Oreo+). */
    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val ch = NotificationChannel(
                CHANNEL_ID, "Screen Casting",
                NotificationManager.IMPORTANCE_LOW  // Low = no sound, no heads-up
            )
            ch.description = "Shown while the screen is being cast to a Mac"
            getSystemService(NotificationManager::class.java).createNotificationChannel(ch)
        }
    }

    // ── Cleanup ───────────────────────────────────────────────────────────────

    /**
     * Called when the service is stopped (by [stopService] from MainActivity
     * or by the OS). Releases all MediaProjection resources in order:
     * VirtualDisplay → MediaProjection → ImageReader → background thread.
     */
    override fun onDestroy() {
        isRunning     = false
        frameCallback = null   // Prevent any in-flight callback from delivering after stop
        virtualDisplay?.release()
        mediaProjection?.stop()
        imageReader?.close()
        handlerThread?.quitSafely() // Drain queue then stop; safer than quit()
        super.onDestroy()
    }

    // ScreenCaptureService does not support binding — it is started/stopped
    // via explicit Intent from MainActivity.
    override fun onBind(intent: Intent?) = null
}
