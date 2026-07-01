import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/services/storage_service.dart';
import '../../routes/app_routes.dart';

class ProfileController extends GetxController {
  final StorageService _storage = Get.find<StorageService>();
  final ImagePicker _picker = ImagePicker();
  
  final nameController = TextEditingController();
  final bioController = TextEditingController();
  final imagePath = ''.obs;

  @override
  void onInit() {
    super.onInit();
    nameController.text = _storage.getUserName();
    bioController.text = _storage.getUserBio();
    imagePath.value = _storage.getUserImagePath();
  }

  Future<void> pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      imagePath.value = image.path;
    }
  }

  void saveProfile() async {
    if (nameController.text.trim().isEmpty) {
      Get.snackbar('Error', 'Please enter your name',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.redAccent,
          colorText: Colors.white);
      return;
    }

    await _storage.setUserName(nameController.text.trim());
    await _storage.setUserBio(bioController.text.trim());
    await _storage.setUserImagePath(imagePath.value);
    await _storage.setProfileComplete(true);

    Get.offAllNamed(AppRoutes.HOME);
  }
}
