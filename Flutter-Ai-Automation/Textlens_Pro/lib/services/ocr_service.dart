import 'dart:io';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class OcrService {
  OcrService._internal();
  static final OcrService _instance = OcrService._internal();
  factory OcrService() => _instance;

  final TextRecognizer _recognizer = TextRecognizer(
    script: TextRecognitionScript.latin,
  );

  /// Recognize text from a file (for gallery images and captured photos).
  Future<RecognizedText> recognizeFromFile(File imageFile) async {
    final inputImage = InputImage.fromFile(imageFile);
    return _recognizer.processImage(inputImage);
  }

  /// Recognize text from a raw [InputImage] (for live camera frames).
  Future<RecognizedText?> recognizeFromInputImage(InputImage inputImage) async {
    try {
      return await _recognizer.processImage(inputImage);
    } catch (_) {
      return null;
    }
  }

  void dispose() {
    _recognizer.close();
  }
}
