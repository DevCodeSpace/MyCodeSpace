import 'dart:io';

import 'package:ai_omr_check/configuration/rest_service.dart';
import 'package:ai_omr_check/model/omr_result_model.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class OmrController extends GetxController {
  final OmrApiService api = OmrApiService();

  TextEditingController examController = TextEditingController(text: 'Class 10 Maths Test');

  TextEditingController answerKeyController = TextEditingController(
    text:
        '{"1": "D","2": "B","3": "A","4": "C","5": "B","6": "B","7": "C","8": "D","9": "A","10": "B","11": "D","12": "C","13": "A","14": "B","15": "D","16": "A","17": "C","18": "B","19": "D","20": "A","21": "B","22": "C","23": "D","24": "A","25": "C","26": "B","27": "A","28": "D","29": "C","30": "B","31": "A","32": "D","33": "B","34": "C","35": "A",  "36": "D","37": "B","38": "C","39": "A","40": "D","41": "B","42": "A","43": "C","44": "D","45": "B","46": "A","47": "C","48": "D","49": "B","50": "A"}',
  );

  RxList<File> selectedFiles = <File>[].obs;

  RxBool isLoading = false.obs;

  RxList<OMRResultResponse> results = <OMRResultResponse>[].obs;

  Future<void> pickFiles() async {
    FilePickerResult? picked = await FilePicker.pickFiles(
      allowMultiple: true,
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png', 'webp', 'bmp', 'heic'],
    );

    if (picked != null) {
      selectedFiles.value = picked.paths.map((e) => File(e!)).toList();
    }
  }

  Future<void> addMoreFiles() async {
    FilePickerResult? picked = await FilePicker.pickFiles(
      allowMultiple: true,
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png', 'webp', 'bmp', 'heic'],
    );

    if (picked != null) {
      final newFiles = picked.paths.map((e) => File(e!)).toList();
      selectedFiles.addAll(newFiles);
    }
  }

  void removeFile(int index) {
    selectedFiles.removeAt(index);
  }

  Future<void> uploadSheets() async {
    if (selectedFiles.isEmpty) {
      Get.snackbar('Error', 'Please select OMR sheets');

      return;
    }

    isLoading.value = true;
    results.clear();

    try {
      final response = await api.uploadOmrSheets(files: selectedFiles, examName: examController.text, answerKey: answerKeyController.text);

      results.value = response;

      Get.snackbar('Success', 'OMR sheets uploaded successfully');
    } catch (e) {
      Get.snackbar('Error', e.toString());
    }

    isLoading.value = false;
  }
}
