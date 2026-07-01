package com.example.codex_share

import android.content.ContentValues
import android.media.MediaScannerConnection
import android.graphics.Bitmap
import android.graphics.Canvas
import android.graphics.ImageDecoder
import android.graphics.drawable.BitmapDrawable
import android.graphics.drawable.Drawable
import android.os.Build
import android.os.Environment
import android.provider.MediaStore
import android.util.Base64
import android.util.Size
import android.util.TypedValue
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.FileInputStream
import java.io.FileOutputStream
import java.io.ByteArrayOutputStream
import java.io.File
import java.net.URLConnection

class MainActivity : FlutterActivity() {
    private val channelName = "codex_share/device_catalog"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelName)
            .setMethodCallHandler { call, result ->
                try {
                    when (call.method) {
                        "getInstalledApps" -> result.success(getInstalledApps())
                        "getImages" -> {
                            val limit = call.argument<Int>("limit") ?: 500
                            val offset = call.argument<Int>("offset") ?: 0
                            result.success(getImages(limit, offset))
                        }
                        "getVideos" -> {
                            val limit = call.argument<Int>("limit") ?: 500
                            val offset = call.argument<Int>("offset") ?: 0
                            result.success(getVideos(limit, offset))
                        }
                        "getDocuments" -> {
                            val limit = call.argument<Int>("limit") ?: 500
                            val offset = call.argument<Int>("offset") ?: 0
                            result.success(getDocuments(limit, offset))
                        }
                        "getFileSystemItems" -> {
                            val path = call.argument<String>("path")
                            result.success(getFileSystemItems(path))
                        }
                        "getThumbnail" -> {
                            val path = call.argument<String>("path")
                            val category = call.argument<String>("category")
                            if (path == null || category == null) {
                                result.error("bad_args", "Missing getThumbnail args", null)
                            } else {
                                val thumb = when (category) {
                                    "image" -> fileToBase64(path, 240)
                                    "video" -> videoThumbnailBase64(path)
                                    "app" -> {
                                        val pm = applicationContext.packageManager
                                        val info = pm.getPackageArchiveInfo(path, 0)
                                        if (info != null) {
                                            info.applicationInfo?.sourceDir = path
                                            info.applicationInfo?.publicSourceDir = path
                                            info.applicationInfo?.let { drawableToBase64(it.loadIcon(pm)) }
                                        } else {
                                            val appInfo = try {
                                                pm.getApplicationInfo(path, 0)
                                            } catch (e: Exception) { null }
                                            appInfo?.let { drawableToBase64(it.loadIcon(pm)) }
                                        }
                                    }
                                    else -> null
                                }
                                result.success(thumb)
                            }
                        }
                        "publishReceivedFile" -> {
                            val sourcePath = call.argument<String>("sourcePath")
                            val fileName = call.argument<String>("fileName")
                            val category = call.argument<String>("category")
                            if (sourcePath == null || fileName == null || category == null) {
                                result.error("bad_args", "Missing publishReceivedFile args", null)
                            } else {
                                result.success(publishReceivedFile(sourcePath, fileName, category))
                            }
                        }
                        else -> result.notImplemented()
                    }
                } catch (error: Exception) {
                    result.error("native_error", error.message, null)
                }
            }
    }

    private fun getInstalledApps(): List<Map<String, Any?>> {
        val packageManager = applicationContext.packageManager
        return packageManager.getInstalledApplications(0)
            .asSequence()
            .filter { packageManager.getLaunchIntentForPackage(it.packageName) != null }
            .filter { it.packageName != applicationContext.packageName }
            .sortedBy { packageManager.getApplicationLabel(it).toString().lowercase() }
            .map { appInfo ->
                val apkFile = File(appInfo.sourceDir)
                mapOf(
                    "id" to appInfo.packageName,
                    "name" to packageManager.getApplicationLabel(appInfo).toString(),
                    "packageName" to appInfo.packageName,
                    "path" to appInfo.sourceDir,
                    "size" to apkFile.length(),
                    "icon" to null // Load icon lazily
                )
            }
            .toList()
    }

    private fun getImages(limit: Int, offset: Int): List<Map<String, Any?>> {
        val projection = arrayOf(
            MediaStore.Images.Media._ID,
            MediaStore.Images.Media.DISPLAY_NAME,
            MediaStore.Images.Media.SIZE,
            MediaStore.Images.Media.DATA
        )

        val items = mutableListOf<Map<String, Any?>>()
        val cursor = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val queryArgs = android.os.Bundle().apply {
                putInt(android.content.ContentResolver.QUERY_ARG_LIMIT, limit)
                putInt(android.content.ContentResolver.QUERY_ARG_OFFSET, offset)
                putStringArray(
                    android.content.ContentResolver.QUERY_ARG_SORT_COLUMNS,
                    arrayOf(MediaStore.Images.Media.DATE_MODIFIED)
                )
                putInt(
                    android.content.ContentResolver.QUERY_ARG_SORT_DIRECTION,
                    android.content.ContentResolver.QUERY_SORT_DIRECTION_DESCENDING
                )
            }
            contentResolver.query(MediaStore.Images.Media.EXTERNAL_CONTENT_URI, projection, queryArgs, null)
        } else {
            contentResolver.query(
                MediaStore.Images.Media.EXTERNAL_CONTENT_URI,
                projection,
                null,
                null,
                "${MediaStore.Images.Media.DATE_MODIFIED} DESC LIMIT $limit OFFSET $offset"
            )
        }

        cursor?.use { 
            val idIndex = it.getColumnIndexOrThrow(MediaStore.Images.Media._ID)
            val nameIndex = it.getColumnIndexOrThrow(MediaStore.Images.Media.DISPLAY_NAME)
            val sizeIndex = it.getColumnIndexOrThrow(MediaStore.Images.Media.SIZE)
            val pathIndex = it.getColumnIndexOrThrow(MediaStore.Images.Media.DATA)

            while (it.moveToNext()) {
                val path = it.getString(pathIndex) ?: continue
                val file = File(path)

                items.add(
                    mapOf(
                        "id" to it.getLong(idIndex).toString(),
                        "name" to (it.getString(nameIndex) ?: file.name),
                        "path" to path,
                        "size" to it.getLong(sizeIndex),
                        "thumbnail" to null
                    )
                )
            }
        }
        return items
    }

    private fun getVideos(limit: Int, offset: Int): List<Map<String, Any?>> {
        val projection = arrayOf(
            MediaStore.Video.Media._ID,
            MediaStore.Video.Media.DISPLAY_NAME,
            MediaStore.Video.Media.SIZE,
            MediaStore.Video.Media.DATA,
            MediaStore.Video.Media.DURATION
        )

        val items = mutableListOf<Map<String, Any?>>()
        val cursor = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val queryArgs = android.os.Bundle().apply {
                putInt(android.content.ContentResolver.QUERY_ARG_LIMIT, limit)
                putInt(android.content.ContentResolver.QUERY_ARG_OFFSET, offset)
                putStringArray(
                    android.content.ContentResolver.QUERY_ARG_SORT_COLUMNS,
                    arrayOf(MediaStore.Video.Media.DATE_MODIFIED)
                )
                putInt(
                    android.content.ContentResolver.QUERY_ARG_SORT_DIRECTION,
                    android.content.ContentResolver.QUERY_SORT_DIRECTION_DESCENDING
                )
            }
            contentResolver.query(MediaStore.Video.Media.EXTERNAL_CONTENT_URI, projection, queryArgs, null)
        } else {
            contentResolver.query(
                MediaStore.Video.Media.EXTERNAL_CONTENT_URI,
                projection,
                null,
                null,
                "${MediaStore.Video.Media.DATE_MODIFIED} DESC LIMIT $limit OFFSET $offset"
            )
        }

        cursor?.use {
            val idIndex = it.getColumnIndexOrThrow(MediaStore.Video.Media._ID)
            val nameIndex = it.getColumnIndexOrThrow(MediaStore.Video.Media.DISPLAY_NAME)
            val sizeIndex = it.getColumnIndexOrThrow(MediaStore.Video.Media.SIZE)
            val pathIndex = it.getColumnIndexOrThrow(MediaStore.Video.Media.DATA)
            val durationIndex = it.getColumnIndexOrThrow(MediaStore.Video.Media.DURATION)

            while (it.moveToNext()) {
                val path = it.getString(pathIndex) ?: continue
                val file = File(path)

                items.add(
                    mapOf(
                        "id" to it.getLong(idIndex).toString(),
                        "name" to (it.getString(nameIndex) ?: file.name),
                        "path" to path,
                        "size" to it.getLong(sizeIndex),
                        "durationMillis" to it.getLong(durationIndex),
                        "thumbnail" to null
                    )
                )
            }
        }
        return items
    }

    private fun getDocuments(limit: Int, offset: Int): List<Map<String, Any?>> {
        val projection = arrayOf(
            MediaStore.Files.FileColumns._ID,
            MediaStore.Files.FileColumns.DISPLAY_NAME,
            MediaStore.Files.FileColumns.SIZE,
            MediaStore.Files.FileColumns.MIME_TYPE,
            MediaStore.Files.FileColumns.DATA,
            MediaStore.Files.FileColumns.MEDIA_TYPE
        )

        val items = mutableListOf<Map<String, Any?>>()
        
        val cursor = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val queryArgs = android.os.Bundle().apply {
                putInt(android.content.ContentResolver.QUERY_ARG_LIMIT, limit)
                putInt(android.content.ContentResolver.QUERY_ARG_OFFSET, offset)
                putStringArray(
                    android.content.ContentResolver.QUERY_ARG_SORT_COLUMNS,
                    arrayOf(MediaStore.Files.FileColumns.DATE_MODIFIED)
                )
                putInt(
                    android.content.ContentResolver.QUERY_ARG_SORT_DIRECTION,
                    android.content.ContentResolver.QUERY_SORT_DIRECTION_DESCENDING
                )
            }
            contentResolver.query(MediaStore.Files.getContentUri("external"), projection, queryArgs, null)
        } else {
            contentResolver.query(
                MediaStore.Files.getContentUri("external"),
                projection,
                null,
                null,
                "${MediaStore.Files.FileColumns.DATE_MODIFIED} DESC LIMIT $limit OFFSET $offset"
            )
        }

        cursor?.use {
            val idIndex = it.getColumnIndexOrThrow(MediaStore.Files.FileColumns._ID)
            val nameIndex = it.getColumnIndexOrThrow(MediaStore.Files.FileColumns.DISPLAY_NAME)
            val sizeIndex = it.getColumnIndexOrThrow(MediaStore.Files.FileColumns.SIZE)
            val mimeIndex = it.getColumnIndexOrThrow(MediaStore.Files.FileColumns.MIME_TYPE)
            val pathIndex = it.getColumnIndexOrThrow(MediaStore.Files.FileColumns.DATA)
            val mediaTypeIndex = it.getColumnIndexOrThrow(MediaStore.Files.FileColumns.MEDIA_TYPE)

            while (it.moveToNext()) {
                val mediaType = it.getInt(mediaTypeIndex)
                if (mediaType == MediaStore.Files.FileColumns.MEDIA_TYPE_IMAGE || 
                    mediaType == MediaStore.Files.FileColumns.MEDIA_TYPE_VIDEO) continue

                val path = it.getString(pathIndex) ?: continue
                val file = File(path)
                val name = it.getString(nameIndex) ?: file.name ?: "Unknown File"
                val mimeType = it.getString(mimeIndex) ?: "application/octet-stream"
                
                if (file.isDirectory) continue

                items.add(
                    mapOf(
                        "id" to it.getLong(idIndex).toString(),
                        "name" to name,
                        "path" to path,
                        "size" to it.getLong(sizeIndex),
                        "mimeType" to mimeType
                    )
                )
            }
        }
        return items
    }

    private fun getFileSystemItems(path: String?): List<Map<String, Any?>> {
        val root = if (path != null) File(path) else Environment.getExternalStorageDirectory()
        if (!root.exists() || !root.isDirectory) return emptyList()

        return root.listFiles()?.map { file ->
            mapOf(
                "id" to file.absolutePath,
                "name" to file.name,
                "path" to file.absolutePath,
                "size" to if (file.isDirectory) 0L else file.length(),
                "isFolder" to file.isDirectory,
                "mimeType" to if (file.isDirectory) "inode/directory" else URLConnection.guessContentTypeFromName(file.name)
            )
        }?.sortedWith(compareBy({ !(it["isFolder"] as Boolean) }, { (it["name"] as String).lowercase() }))
            ?: emptyList()
    }

    private fun drawableToBase64(drawable: Drawable): String {
        val size = dpToPx(56f)
        val bitmap = when (drawable) {
            is BitmapDrawable -> Bitmap.createScaledBitmap(drawable.bitmap, size, size, true)
            else -> {
                val bitmap = Bitmap.createBitmap(size, size, Bitmap.Config.ARGB_8888)
                val canvas = Canvas(bitmap)
                drawable.setBounds(0, 0, canvas.width, canvas.height)
                drawable.draw(canvas)
                bitmap
            }
        }
        return bitmapToBase64(bitmap)
    }

    private fun fileToBase64(path: String, targetSize: Int): String? {
        return try {
            val bitmap = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
                val source = ImageDecoder.createSource(File(path))
                ImageDecoder.decodeBitmap(source) { decoder, info, _ ->
                    val width = info.size.width.coerceAtLeast(1)
                    val height = info.size.height.coerceAtLeast(1)
                    val scale = maxOf(width, height).toFloat() / targetSize.toFloat()
                    if (scale > 1f) {
                        decoder.setTargetSize(
                            (width / scale).toInt().coerceAtLeast(1),
                            (height / scale).toInt().coerceAtLeast(1)
                        )
                    }
                }
            } else {
                @Suppress("DEPRECATION")
                MediaStore.Images.Thumbnails.getThumbnail(
                    contentResolver,
                    File(path).hashCode().toLong(),
                    MediaStore.Images.Thumbnails.MINI_KIND,
                    null
                )
            } ?: return null
            bitmapToBase64(bitmap)
        } catch (_: Exception) {
            null
        }
    }

    private fun videoThumbnailBase64(path: String): String? {
        return try {
            val bitmap = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                android.media.ThumbnailUtils.createVideoThumbnail(
                    File(path),
                    Size(240, 240),
                    null
                )
            } else {
                @Suppress("DEPRECATION")
                android.media.ThumbnailUtils.createVideoThumbnail(
                    path,
                    MediaStore.Video.Thumbnails.MINI_KIND
                )
            } ?: return null
            bitmapToBase64(bitmap)
        } catch (_: Exception) {
            null
        }
    }

    private fun bitmapToBase64(bitmap: Bitmap): String {
        val outputStream = ByteArrayOutputStream()
        bitmap.compress(Bitmap.CompressFormat.PNG, 100, outputStream)
        return Base64.encodeToString(outputStream.toByteArray(), Base64.NO_WRAP)
    }

    private fun publishReceivedFile(
        sourcePath: String,
        fileName: String,
        category: String
    ): Map<String, Any?> {
        val sourceFile = File(sourcePath)
        if (!sourceFile.exists()) {
            throw IllegalStateException("Downloaded file not found")
        }

        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            publishWithMediaStore(sourceFile, fileName, category)
        } else {
            publishToPublicDirectory(sourceFile, fileName, category)
        }
    }

    private fun publishWithMediaStore(
        sourceFile: File,
        fileName: String,
        category: String
    ): Map<String, Any?> {
        val (collection, relativePath, fallbackPath) = mediaTargetFor(category)
        val mimeType = guessMimeType(fileName, category)
        val storedName = uniqueDisplayName(fileName)

        val values = ContentValues().apply {
            put(MediaStore.MediaColumns.DISPLAY_NAME, storedName)
            put(MediaStore.MediaColumns.MIME_TYPE, mimeType)
            put(MediaStore.MediaColumns.RELATIVE_PATH, relativePath)
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                put(MediaStore.MediaColumns.IS_PENDING, 1)
            }
        }

        val resolver = contentResolver
        val uri = resolver.insert(collection, values)
            ?: throw IllegalStateException("Unable to create MediaStore entry")

        resolver.openOutputStream(uri)?.use { output ->
            FileInputStream(sourceFile).use { input ->
                input.copyTo(output)
            }
        } ?: throw IllegalStateException("Unable to open MediaStore output stream")

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            values.clear()
            values.put(MediaStore.MediaColumns.IS_PENDING, 0)
            resolver.update(uri, values, null, null)
        }

        sourceFile.delete()
        return mapOf(
            "uri" to uri.toString(),
            "path" to "$fallbackPath/$storedName"
        )
    }

    private fun publishToPublicDirectory(
        sourceFile: File,
        fileName: String,
        category: String
    ): Map<String, Any?> {
        @Suppress("DEPRECATION")
        val baseDir = when (category) {
            "image" -> Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_PICTURES)
            "video" -> Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_MOVIES)
            else -> Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_DOWNLOADS)
        }

        val targetDir = File(baseDir, "ShareSphere")
        if (!targetDir.exists()) {
            targetDir.mkdirs()
        }

        val targetFile = uniqueFile(targetDir, fileName)
        FileInputStream(sourceFile).use { input ->
            FileOutputStream(targetFile).use { output ->
                input.copyTo(output)
            }
        }
        MediaScannerConnection.scanFile(
            applicationContext,
            arrayOf(targetFile.absolutePath),
            arrayOf(guessMimeType(fileName, category)),
            null
        )
        sourceFile.delete()

        return mapOf(
            "uri" to targetFile.toURI().toString(),
            "path" to targetFile.absolutePath
        )
    }

    private fun mediaTargetFor(category: String): Triple<android.net.Uri, String, String> {
        return when (category) {
            "image" -> Triple(
                MediaStore.Images.Media.EXTERNAL_CONTENT_URI,
                "${Environment.DIRECTORY_PICTURES}/ShareSphere",
                "/storage/emulated/0/${Environment.DIRECTORY_PICTURES}/ShareSphere"
            )
            "video" -> Triple(
                MediaStore.Video.Media.EXTERNAL_CONTENT_URI,
                "${Environment.DIRECTORY_MOVIES}/ShareSphere",
                "/storage/emulated/0/${Environment.DIRECTORY_MOVIES}/ShareSphere"
            )
            else -> Triple(
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) MediaStore.Downloads.EXTERNAL_CONTENT_URI else MediaStore.Files.getContentUri("external"),
                "${Environment.DIRECTORY_DOWNLOADS}/ShareSphere",
                "/storage/emulated/0/${Environment.DIRECTORY_DOWNLOADS}/ShareSphere"
            )
        }
    }

    private fun guessMimeType(fileName: String, category: String): String {
        return URLConnection.guessContentTypeFromName(fileName)
            ?: when (category) {
                "image" -> "image/*"
                "video" -> "video/*"
                "audio" -> "audio/*"
                "app" -> "application/vnd.android.package-archive"
                else -> "application/octet-stream"
            }
    }

    private fun uniqueDisplayName(fileName: String): String {
        val dotIndex = fileName.lastIndexOf('.')
        val base = if (dotIndex > 0) fileName.substring(0, dotIndex) else fileName
        val ext = if (dotIndex > 0) fileName.substring(dotIndex) else ""
        return "${base}_${System.currentTimeMillis()}$ext"
    }

    private fun uniqueFile(directory: File, fileName: String): File {
        val dotIndex = fileName.lastIndexOf('.')
        val base = if (dotIndex > 0) fileName.substring(0, dotIndex) else fileName
        val ext = if (dotIndex > 0) fileName.substring(dotIndex) else ""

        var candidate = File(directory, fileName)
        var index = 1
        while (candidate.exists()) {
            candidate = File(directory, "${base}_$index$ext")
            index += 1
        }
        return candidate
    }

    private fun dpToPx(dp: Float): Int {
        return TypedValue.applyDimension(
            TypedValue.COMPLEX_UNIT_DIP,
            dp,
            resources.displayMetrics
        ).toInt()
    }
}
