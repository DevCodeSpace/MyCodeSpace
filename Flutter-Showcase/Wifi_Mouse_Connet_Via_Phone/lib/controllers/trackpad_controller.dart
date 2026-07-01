import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:mouse_demo/helper/preference_helper.dart';
import 'package:mouse_demo/models/device.dart';
import 'package:mouse_demo/routes/app_routes.dart';
import 'package:mouse_demo/screens/keyboard_screen.dart';
import 'package:mouse_demo/screens/media_control_screen.dart';
import 'package:mouse_demo/theme/app_colors.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:volume_controller/volume_controller.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class TrackpadController extends GetxController {
  // State variables moved from UI to Controller for better architecture
  var desktopName = "".obs;
  var ipAddress = "".obs;
  var currentAction = "".obs;
  FocusNode keyboardFocus = FocusNode();
  StreamSubscription<GyroscopeEvent>? gyroSubscription;

  WebSocketChannel? _channel;
  bool get isConnected => _channel != null;

  /// KEYBOARD TOGGLES
  final caps = false.obs;
  final shift = false.obs;
  final ctrl = false.obs;
  final cmd = false.obs;
  final alt = false.obs;
  var activeModifiers = <String>[].obs;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args != null && args is Map) {
      setupConnection(args['ip'] ?? "", args['name'] ?? "Unknown");
      initGyroscope();
      listenVolumeButtons();
    } else {
      debugPrint("⚠️ No arguments found for TrackpadController!");
    }
  }

  // Initialize with the device details passed from the previous screen
  Future<void> setupConnection(String ip, String name) async {
    desktopName.value = name;
    ipAddress.value = ip;
    _channel = WebSocketChannel.connect(Uri.parse('ws://$ip:3000'));
    await PreferenceHelper.addDevice(Device(ip: ip, name: name));
  }

  void send(Map<String, dynamic> data) {
    if (_channel == null) return;
    _channel!.sink.add(jsonEncode(data));
  }

  // Mouse Actions
  void move(double dx, double dy) => send({"type": "move", "dx": dx, "dy": dy});
  void scroll(double dx, double dy) => send({"type": "scroll", "dx": dx, "dy": dy});
  void click() => send({"type": "click"});
  void rightClick() => send({"type": "right_click"});
  void doubleClick() => send({"type": "double_click"});
  void mouseDown() => send({"type": "mouse_down"});
  void mouseUp() => send({"type": "mouse_up"});
  void zoomIn() => send({"type": "zoom_in"});
  void zoomOut() => send({"type": "zoom_out"});

  void setAction(String action) {
    currentAction.value = action;
    if (action.isNotEmpty) {
      Future.delayed(const Duration(milliseconds: 500), () {
        if (currentAction.value == action) currentAction.value = "";
      });
    }
  }

  void toggleModifier(String key) {
    if (activeModifiers.contains(key)) {
      activeModifiers.remove(key);
      _updateUiVariable(key, false);
      send({"type": "key_up", "key": key});
    } else {
      activeModifiers.add(key);
      _updateUiVariable(key, true);
      send({"type": "key_down", "key": key});
    }
  }

  void pressLetter(String apiKey) {
    if (activeModifiers.contains("capslock") && apiKey != 'backspace') {
      send({"type": "key_tap", "key": apiKey.toUpperCase(), "modifiers": activeModifiers.toList()});
    } else {
      send({"type": "key_tap", "key": apiKey, "modifiers": activeModifiers.toList()});
    }

    for (var mod in activeModifiers.toList()) {
      if (mod != 'capslock') {
        send({"type": "key_up", "key": mod});
        _updateUiVariable(mod, false);
        activeModifiers.remove(mod);
      }
    }
  }

  void _updateUiVariable(String key, bool value) {
    if (key == 'shift') shift.value = value;
    if (key == 'control' || key == 'ctrl') ctrl.value = value;
    if (key == 'alt') alt.value = value;
    if (key == 'meta' || key == 'win') cmd.value = value;
    if (key == 'capslock') caps.value = value;
  }

  void disconnect() {
    _channel?.sink.close();
    _channel = null;
    Get.back(); // Dismiss bottom sheet
    Get.back(); // Navigate back to Device List
  }

  void openKeyboardControl() {
    Get.back();
    Get.to(() => KeyboardScreen())?.then((_) async {
      await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    });
  }

  void openMediaControl() {
    Get.back();
    Get.to(() => MediaControlScreen());
  }

  void openSettings() {
    Get.back();
    Get.toNamed(AppRoutes.settings);
  }

  @override
  void onClose() {
    _channel?.sink.close();
    VolumeController.instance.removeListener();
    super.onClose();
  }

  void openMoreSheet() {
    Get.bottomSheet(
      Container(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: PreferenceHelper.isDarkMode ? AppColors.backgroundDark : AppColors.backgroundLight,
          border: Border(top: BorderSide(color: PreferenceHelper.isDarkMode ? AppColors.surfaceDark : AppColors.surfaceLight)),
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Text("More Actions", style: TextStyle(fontSize: 16, fontWeight: FontWeight(700))),
            ListTile(title: Text('Disconnect'), leading: Icon(Icons.link_off_outlined), onTap: disconnect),
            ListTile(title: Text('Keyboard'), leading: Icon(Icons.keyboard), onTap: openKeyboardControl),
            ListTile(title: Text('Media Control'), leading: Icon(Icons.play_arrow_rounded), onTap: openMediaControl),
            ListTile(title: Text('Settings'), leading: Icon(Icons.settings), onTap: openSettings),
          ],
        ),
      ),
    );
  }

  /// KEYBOARD
  final FocusNode focusNode = FocusNode();
  final TextEditingController textController = TextEditingController();

  /// GYRO INIT METHOD
  void initGyroscope() {
    gyroSubscription = gyroscopeEventStream().listen(
      (GyroscopeEvent event) {
        double dx = event.y * PreferenceHelper.gyroSensitivity;
        double dy = event.x * PreferenceHelper.gyroSensitivity;
        if (PreferenceHelper.isGyroEnabled) {
          move(dx, dy);
        }
      },
      onError: (error) {
        debugPrint("Gyroscope not available: $error");
      },
    );
  }

  /// CONTROL VOLUME INIT METHOD
  Future<void> listenVolumeButtons() async {
    VolumeController.instance.showSystemUI = false;
    double lockVolume = await VolumeController.instance.getVolume();
    if (PreferenceHelper.isControlVolumeEnabled) {
      VolumeController.instance.setVolume(lockVolume);
    }

    VolumeController.instance.addListener((volume) {
      if (PreferenceHelper.isControlVolumeEnabled) {
        if (volume > lockVolume) {
          send({"type": "key_tap", "key": "audio_vol_up"});
        } else if (volume < lockVolume) {
          send({"type": "key_tap", "key": "audio_vol_down"});
        }
        VolumeController.instance.setVolume(lockVolume);
      }
    }, fetchInitialVolume: false);
  }
}
