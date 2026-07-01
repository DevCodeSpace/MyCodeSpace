import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mouse_demo/helper/preference_helper.dart';

class SettingsController extends GetxController {
  RxBool isDarkMode = true.obs;
  RxBool isAutoConnectEnabled = true.obs;
  RxBool isControlVolumeEnabled = false.obs;

  RxBool isMoveEnabled = true.obs;
  RxDouble moveSensitivity = 4.0.obs;

  RxBool isDragEnabled = true.obs;
  RxDouble dragSensitivity = 2.0.obs;

  RxBool isVerticalScrollEnabled = true.obs;
  RxBool isHorizontalScrollEnabled = true.obs;
  RxDouble scrollSensitivity = 2.0.obs;

  RxBool isGyroEnabled = false.obs;
  RxDouble gyroSensitivity = 1.0.obs;

  @override
  void onInit() {
    super.onInit();
    isDarkMode.value = PreferenceHelper.isDarkMode;

    isAutoConnectEnabled.value = PreferenceHelper.isAutoConnectEnabled;
    isControlVolumeEnabled.value = PreferenceHelper.isControlVolumeEnabled;

    isMoveEnabled.value = PreferenceHelper.isMoveEnabled;
    moveSensitivity.value = PreferenceHelper.moveSensitivity;

    isDragEnabled.value = PreferenceHelper.isDragEnabled;
    dragSensitivity.value = PreferenceHelper.dragSensitivity;

    isVerticalScrollEnabled.value = PreferenceHelper.isVerticalScrollEnabled;
    isHorizontalScrollEnabled.value = PreferenceHelper.isHorizontalScrollEnabled;
    scrollSensitivity.value = PreferenceHelper.scrollSensitivity;

    isGyroEnabled.value = PreferenceHelper.isGyroEnabled;
    gyroSensitivity.value = PreferenceHelper.gyroSensitivity;
  }

  // Toggles
  void toggleDarkMode(bool value) {
    isDarkMode.value = value;
    PreferenceHelper.isDarkMode = value;
    Get.changeThemeMode(isDarkMode.value ? ThemeMode.dark : ThemeMode.light);
  }

  void toggleIsAutoConnectEnabled(bool value) {
    isAutoConnectEnabled.value = value;
    PreferenceHelper.isAutoConnectEnabled = value;
  }

  void toggleIsControlVolumeEnabled(bool value) {
    isControlVolumeEnabled.value = value;
    PreferenceHelper.isControlVolumeEnabled = value;
  }

  void toggleIsMoveEnabled(bool value) {
    isMoveEnabled.value = value;
    PreferenceHelper.isMoveEnabled = value;
  }

  void toggleIsDragEnabled(bool value) {
    isDragEnabled.value = value;
    PreferenceHelper.isDragEnabled = value;
  }

  void toggleIsVerticalScrollEnabled(bool value) {
    isVerticalScrollEnabled.value = value;
    PreferenceHelper.isVerticalScrollEnabled = value;
  }

  void toggleIsHorizontalScrollEnabled(bool value) {
    isHorizontalScrollEnabled.value = value;
    PreferenceHelper.isHorizontalScrollEnabled = value;
  }

  void toggleIsGyroEnabled(bool value) {
    isGyroEnabled.value = value;
    PreferenceHelper.isGyroEnabled = value;
  }

  /// Sliders / sensitivity
  void changeMoveSensitivity(double value) {
    moveSensitivity.value = value;
    PreferenceHelper.moveSensitivity = value;
  }

  void changeDragSensitivity(double value) {
    dragSensitivity.value = value;
    PreferenceHelper.dragSensitivity = value;
  }

  void changeScrollSensitivity(double value) {
    scrollSensitivity.value = value;
    PreferenceHelper.scrollSensitivity = value;
  }

  void changeGyroSensitivity(double value) {
    gyroSensitivity.value = value;
    PreferenceHelper.gyroSensitivity = value;
  }
}
