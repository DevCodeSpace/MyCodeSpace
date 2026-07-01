import 'dart:io';
import 'dart:math';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

class FaceRecognitionService {
  static const _modelAsset = 'assets/ffl_mobile_face_net_v1.tflite';

  FaceDetector? _detector;
  Interpreter? _interpreter;
  int _inputSize = 112;
  int _outputSize = 192;
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    _detector = FaceDetector(
      options: FaceDetectorOptions(
        performanceMode:
            FaceDetectorMode.fast, // accurate stream ke liye slow hota hai
        enableLandmarks: true,
        enableClassification: true,
        enableTracking: true,
      ),
    );
    await _loadModel();
    _initialized = true;
  }

  Future<void> _loadModel() async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final modelFile = File('${dir.path}/ffl_mobile_face_net_v1.tflite');
      if (!await modelFile.exists() || await modelFile.length() < 512 * 1024) {
        final data = await rootBundle.load(_modelAsset);
        await modelFile.writeAsBytes(data.buffer.asUint8List());
      }
      _interpreter = await Interpreter.fromFile(modelFile);
      final inShape = _interpreter!.getInputTensor(0).shape;
      final outShape = _interpreter!.getOutputTensor(0).shape;
      _inputSize = inShape[1];
      _outputSize = outShape.last;
      debugPrint(
        '[FRS] Model ready — input: ${_inputSize}x$_inputSize, output: $_outputSize',
      );
    } catch (e) {
      debugPrint('[FRS] Model load error: $e');
    }
  }

  /// Detect faces from a live camera stream frame (used for liveness checks).
  Future<List<Face>> detectFacesFromStream(
    CameraImage image,
    CameraDescription camera,
  ) async {
    if (!_initialized) await init();
    final inputImage = _streamToInputImage(image, camera);
    if (inputImage == null) {
      debugPrint(
        '[FRS] _streamToInputImage returned null — format/platform issue',
      );
      return [];
    }
    return _detector!.processImage(inputImage);
  }

  /// Detect faces from a still JPEG file (used after capture for embedding).
  Future<List<Face>> detectFacesFromFile(String filePath) async {
    if (!_initialized) await init();
    return _detector!.processImage(InputImage.fromFilePath(filePath));
  }

  /// Extract a face embedding vector from a still JPEG using the given bounding box.
  Future<List<double>?> extractEmbeddingFromFile(
    String filePath,
    Rect faceBounds,
  ) async {
    if (_interpreter == null) return null;
    try {
      final bytes = await File(filePath).readAsBytes();
      final decoded = img.decodeImage(bytes);
      if (decoded == null) return null;
      final full = img.bakeOrientation(decoded);

      final faceCenterX = faceBounds.center.dx;
      final faceCenterY = faceBounds.center.dy;
      final paddedSide = max(faceBounds.width, faceBounds.height) * 1.35;
      final halfSide = paddedSide / 2;

      final left = (faceCenterX - halfSide).round().clamp(0, full.width - 1);
      final top = (faceCenterY - halfSide).round().clamp(0, full.height - 1);
      final right = (faceCenterX + halfSide).round().clamp(
        left + 1,
        full.width,
      );
      final bottom = (faceCenterY + halfSide).round().clamp(
        top + 1,
        full.height,
      );

      final cropped = img.copyCrop(
        full,
        x: left,
        y: top,
        width: right - left,
        height: bottom - top,
      );
      return _runModel(cropped);
    } catch (e) {
      debugPrint('[FRS] Embedding error: $e');
      return null;
    }
  }

  InputImage? _streamToInputImage(CameraImage image, CameraDescription camera) {
    try {
      final rotation = _sensorRotation(camera.sensorOrientation);

      if (Platform.isAndroid) {
        final bytes = _androidImageBytes(image);
        return InputImage.fromBytes(
          bytes: bytes,
          metadata: InputImageMetadata(
            size: Size(image.width.toDouble(), image.height.toDouble()),
            rotation: rotation,
            format: InputImageFormat.nv21,
            bytesPerRow: image.planes[0].bytesPerRow,
          ),
        );
      } else {
        return InputImage.fromBytes(
          bytes: image.planes[0].bytes,
          metadata: InputImageMetadata(
            size: Size(image.width.toDouble(), image.height.toDouble()),
            rotation: rotation,
            format: InputImageFormat.bgra8888,
            bytesPerRow: image.planes[0].bytesPerRow,
          ),
        );
      }
    } catch (e) {
      debugPrint('[FRS] Stream image conversion error: $e');
      return null;
    }
  }

  Uint8List _androidImageBytes(CameraImage image) {
    if (image.planes.length == 1) return image.planes[0].bytes;

    if (image.planes.length == 2) {
      final width = image.width;
      final height = image.height;
      final ySize = width * height;
      final uvSize = ySize ~/ 2;
      final nv21 = Uint8List(ySize + uvSize);

      final yPlane = image.planes[0];
      var outputOffset = 0;
      for (var row = 0; row < height; row++) {
        final rowStart = row * yPlane.bytesPerRow;
        nv21.setRange(
          outputOffset,
          outputOffset + width,
          yPlane.bytes,
          rowStart,
        );
        outputOffset += width;
      }

      final vuPlane = image.planes[1];
      final uvHeight = height ~/ 2;
      for (var row = 0; row < uvHeight; row++) {
        final rowStart = row * vuPlane.bytesPerRow;
        nv21.setRange(
          outputOffset,
          outputOffset + width,
          vuPlane.bytes,
          rowStart,
        );
        outputOffset += width;
      }

      return nv21;
    }

    // CameraX may still provide YUV_420_888 planes. ML Kit's Flutter bridge
    // expects NV21 bytes on Android, so pack Y + interleaved VU manually.
    final width = image.width;
    final height = image.height;
    final ySize = width * height;
    final uvWidth = width ~/ 2;
    final uvHeight = height ~/ 2;
    final nv21 = Uint8List(ySize + uvWidth * uvHeight * 2);

    final yPlane = image.planes[0];
    var outputOffset = 0;
    for (var row = 0; row < height; row++) {
      final rowStart = row * yPlane.bytesPerRow;
      nv21.setRange(outputOffset, outputOffset + width, yPlane.bytes, rowStart);
      outputOffset += width;
    }

    final uPlane = image.planes[1];
    final vPlane = image.planes[2];
    final uPixelStride = uPlane.bytesPerPixel ?? 1;
    final vPixelStride = vPlane.bytesPerPixel ?? 1;

    for (var row = 0; row < uvHeight; row++) {
      final uRowStart = row * uPlane.bytesPerRow;
      final vRowStart = row * vPlane.bytesPerRow;
      for (var col = 0; col < uvWidth; col++) {
        nv21[outputOffset++] = vPlane.bytes[vRowStart + col * vPixelStride];
        nv21[outputOffset++] = uPlane.bytes[uRowStart + col * uPixelStride];
      }
    }

    return nv21;
  }

  InputImageRotation _sensorRotation(int sensorOrientation) {
    return switch (sensorOrientation) {
      90 => InputImageRotation.rotation90deg,
      180 => InputImageRotation.rotation180deg,
      270 => InputImageRotation.rotation270deg,
      _ => InputImageRotation.rotation0deg,
    };
  }

  List<double>? _runModel(img.Image faceImage) {
    if (_interpreter == null) return null;
    final resized = img.copyResize(
      faceImage,
      width: _inputSize,
      height: _inputSize,
    );

    // Normalize pixels to [-1, 1] and build [1, H, W, 3] input tensor
    final input = List.generate(
      1,
      (_) => List.generate(
        _inputSize,
        (y) => List.generate(
          _inputSize,
          (x) => [
            resized.getPixel(x, y).rNormalized * 2 - 1,
            resized.getPixel(x, y).gNormalized * 2 - 1,
            resized.getPixel(x, y).bNormalized * 2 - 1,
          ],
        ),
      ),
    );

    final output = List.generate(
      1,
      (_) => List<double>.filled(_outputSize, 0.0),
    );
    _interpreter!.run(input, output);
    return _l2Normalize(output[0]);
  }

  List<double> _l2Normalize(List<double> v) {
    final norm = sqrt(v.fold(0.0, (s, x) => s + x * x));
    return norm > 0 ? v.map((x) => x / norm).toList() : v;
  }

  /// Returns cosine similarity in [0, 1]. Higher = more similar faces.
  double cosineSimilarity(List<double> a, List<double> b) {
    if (a.length != b.length) return 0;
    double dot = 0;
    for (int i = 0; i < a.length; i++) {
      dot += a[i] * b[i];
    }
    return dot.clamp(0.0, 1.0);
  }

  void dispose() {
    _detector?.close();
    _interpreter?.close();
    _initialized = false;
  }
}
