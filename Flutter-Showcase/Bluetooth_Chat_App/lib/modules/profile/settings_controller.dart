import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/services/storage_service.dart';

class SettingsController extends GetxController {
  final StorageService _storage = Get.find<StorageService>();
  final ImagePicker _picker = ImagePicker();

  final name = ''.obs;
  final bio = ''.obs;
  final imagePath = ''.obs;
  final readReceiptsEnabled = true.obs;

  @override
  void onInit() {
    super.onInit();
    name.value = _storage.getUserName();
    bio.value = _storage.getUserBio();
    imagePath.value = _storage.getUserImagePath();
  }

  Future<void> pickImage() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 30,
    );
    if (image != null) {
      imagePath.value = image.path;
      await _storage.setUserImagePath(image.path);
    }
  }

  void updateName(String newName) async {
    if (newName.trim().isEmpty) return;
    name.value = newName.trim();
    await _storage.setUserName(name.value);
  }

  void updateBio(String newBio) async {
    bio.value = newBio.trim();
    await _storage.setUserBio(bio.value);
  }
}
