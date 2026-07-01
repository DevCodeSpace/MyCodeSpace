package com.example.aadhar_demo_app

import android.graphics.Bitmap
import android.graphics.BitmapFactory
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.ByteArrayOutputStream
import java.nio.ByteBuffer

class MainActivity : FlutterActivity() {

    companion object {
        init {
            System.loadLibrary("jp2decoder")
        }
    }

    external fun decodeJp2Native(jp2Bytes: ByteArray): ByteArray?

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "jp2_decoder").setMethodCallHandler { call, result ->
            if (call.method == "decodeJp2") {
                val jp2Bytes = call.arguments as? ByteArray
                if (jp2Bytes == null) {
                    result.error("INVALID_ARGS", "jp2Bytes is null", null)
                    return@setMethodCallHandler
                }
                try {
                    val jpegBytes = decodeJp2ToJpeg(jp2Bytes)
                    if (jpegBytes != null) result.success(jpegBytes)
                    else result.error("DECODE_FAILED", "Could not decode JP2", null)
                } catch (e: Exception) {
                    result.error("ERROR", e.message, null)
                }
            } else {
                result.notImplemented()
            }
        }
    }

    private fun decodeJp2ToJpeg(jp2Bytes: ByteArray): ByteArray? {
        // Try standard BitmapFactory first (works on some OEM devices)
        BitmapFactory.decodeByteArray(jp2Bytes, 0, jp2Bytes.size)?.let { bmp ->
            return bmpToJpeg(bmp)
        }

        // Use native OpenJPEG decoder
        val raw = decodeJp2Native(jp2Bytes) ?: return null

        // raw = [4B width][4B height][RGBA bytes]
        val buf = ByteBuffer.wrap(raw)
        val w = buf.int
        val h = buf.int
        if (w <= 0 || h <= 0 || raw.size < 8 + w * h * 4) return null

        val pixels = IntArray(w * h)
        for (i in pixels.indices) {
            val offset = 8 + i * 4
            val r = raw[offset].toInt() and 0xFF
            val g = raw[offset + 1].toInt() and 0xFF
            val b = raw[offset + 2].toInt() and 0xFF
            pixels[i] = (0xFF shl 24) or (r shl 16) or (g shl 8) or b
        }

        val bmp = Bitmap.createBitmap(pixels, w, h, Bitmap.Config.ARGB_8888)
        return bmpToJpeg(bmp)
    }

    private fun bmpToJpeg(bmp: Bitmap): ByteArray {
        val out = ByteArrayOutputStream()
        bmp.compress(Bitmap.CompressFormat.JPEG, 90, out)
        return out.toByteArray()
    }
}
