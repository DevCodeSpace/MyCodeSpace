import 'dart:io';

import 'package:ai_resume_demo/model/resume_result_model.dart';
import 'package:file_picker/file_picker.dart';
import 'package:get/get.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

import '../services/resume_api_service.dart';

class ResumeController extends GetxController {
  final ResumeApiService apiService = ResumeApiService();

  RxList<PlatformFile> resumes = <PlatformFile>[].obs;
  RxList<ResumeResultModel> results = <ResumeResultModel>[].obs;
  RxBool isLoading = false.obs;

  Future<void> pickResumes() async {
    final result = await FilePicker.pickFiles(allowMultiple: true, type: FileType.custom, allowedExtensions: ['pdf'], withData: true);

    if (result != null) {
      resumes.value = result.files;
    }
  }

  Future<List<int>> _getBytes(PlatformFile file) async {
    if (file.bytes != null) return file.bytes!;
    if (file.path != null) return await File(file.path!).readAsBytes();
    throw Exception('${file.name}: bytes load nahi hue');
  }

  String _extractText(List<int> bytes) {
    final document = PdfDocument(inputBytes: bytes);
    final text = PdfTextExtractor(document).extractText();
    document.dispose();
    return text;
  }

  String _parseName(String text) {
    final lines = text.split('\n').map((l) => l.trim()).where((l) => l.isNotEmpty).toList();
    return lines.isNotEmpty ? lines.first : 'Unknown';
  }

  String _parseEmail(String text) {
    final match = RegExp(r'[\w.+-]+@[\w-]+\.\w+').firstMatch(text);
    return match?.group(0) ?? '';
  }

  String _parseSkills(String text) {
    final sectionMatch = RegExp(
      r'(?:technical\s+)?skills?(?:\s*&\s*\w+)?[:\s]*\n([\s\S]{10,500}?)(?:\n(?:[A-Z][A-Z\s]{3,}|EDUCATION|EXPERIENCE|PROJECTS?|WORK|SUMMARY|OBJECTIVE)\n|\z)',
      caseSensitive: false,
    ).firstMatch(text);
    if (sectionMatch != null) {
      return sectionMatch.group(1)!.replaceAll(RegExp(r'[\n•\-\*]'), ', ').replaceAll(RegExp(r',\s*,'), ',').trim();
    }
    final inlineMatch = RegExp(r'(?:technical\s+)?skills?[:\s]+([^\n]{5,})', caseSensitive: false).firstMatch(text);
    if (inlineMatch != null) return inlineMatch.group(1)!.trim();
    return '';
  }

  String _parseExperience(String text) {
    final explicit = RegExp(r'(\d+)\+?\s*(?:years?|yrs?)[\s\w]{0,15}?experience', caseSensitive: false).firstMatch(text);
    if (explicit != null) return '${explicit.group(1)} years';
    final yearMatches = RegExp(r'\b(20\d{2}|19\d{2})\b').allMatches(text).map((m) => int.parse(m.group(0)!)).toList();
    if (yearMatches.length >= 2) {
      yearMatches.sort();
      final yearsExp = DateTime.now().year - yearMatches.first;
      if (yearsExp > 0 && yearsExp < 40) return '$yearsExp years';
    }
    return '';
  }

  Future<void> analyzeResumes() async {
    if (resumes.isEmpty) {
      Get.snackbar('Error', 'Pehle resume select karo', snackPosition: SnackPosition.BOTTOM);
      return;
    }

    isLoading.value = true;
    results.clear();

    final List<Map<String, String>> candidates = [];

    for (var file in resumes) {
      try {
        final bytes = await _getBytes(file);
        final text = _extractText(bytes);
        candidates.add({'candidateName': _parseName(text), 'email': _parseEmail(text), 'skills': _parseSkills(text), 'experience': _parseExperience(text)});
      } catch (e) {
        Get.snackbar('Parse Error - ${file.name}', e.toString(), snackPosition: SnackPosition.BOTTOM, duration: const Duration(seconds: 4));
      }
    }

    if (candidates.isEmpty) {
      isLoading.value = false;
      return;
    }

    try {
      final responseList = await apiService.analyzeResumes(candidates);
      for (var item in responseList) {
        results.add(ResumeResultModel.fromJson(Map<String, dynamic>.from(item)));
      }
      // Get.snackbar('Done', '${results.length} resumes analyze ho gaye', snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      Get.snackbar('API Error', e.toString(), snackPosition: SnackPosition.BOTTOM, duration: const Duration(seconds: 4));
    }

    isLoading.value = false;
  }
}
