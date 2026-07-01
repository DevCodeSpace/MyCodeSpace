import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:mouse_demo/controllers/trackpad_controller.dart';
import 'package:mouse_demo/helper/preference_helper.dart';
import 'package:mouse_demo/theme/app_colors.dart';

enum KeyType { character, number, function, modifier, special, arrow }

class KeyboardScreen extends StatefulWidget {
  const KeyboardScreen({super.key});

  @override
  State<KeyboardScreen> createState() => _KeyboardScreenState();
}

class _KeyboardScreenState extends State<KeyboardScreen> {
  final controller = Get.find<TrackpadController>();
  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(title: Obx(() => Text(controller.desktopName.value.toUpperCase())), toolbarHeight: isLandscape ? 35 : kToolbarHeight, automaticallyImplyLeading: false),
      resizeToAvoidBottomInset: false,
      body: Container(
        color: PreferenceHelper.isDarkMode ? AppColors.backgroundDark : AppColors.backgroundLight,
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      // --- FIXED F-KEYS SECTION ---
                      Wrap(
                        alignment: WrapAlignment.center,
                        children: [
                          'F1',
                          'F2',
                          'F3',
                          'F4',
                          'F5',
                          'F6',
                          'F7',
                          'F8',
                          'F9',
                          'F10',
                          'F11',
                          'F12',
                        ].map((f) => _buildPCKey(f, width: (constraints.maxWidth / (isLandscape ? 12 : 6)) - 6, color: Colors.indigo.shade900)).toList(),
                      ),
                      const SizedBox(height: 8),

                      // --- STANDARD ROWS ---
                      _buildKeyboardRow(['Esc', '1', '2', '3', '4', '5', '6', '7', '8', '9', '0', '⌫'], flexMap: {'Esc': 1.5, '⌫': 2.0}),

                      _buildKeyboardRow(['Tab', 'q', 'w', 'e', 'r', 't', 'y', 'u', 'i', 'o', 'p'], flexMap: {'Tab': 1.5}),

                      _buildKeyboardRow(['Caps', 'a', 's', 'd', 'f', 'g', 'h', 'j', 'k', 'l', 'Enter'], flexMap: {'Caps': 1.5, 'Enter': 2.0}),

                      _buildKeyboardRow(['Shift', 'z', 'x', 'c', 'v', 'b', 'n', 'm', ',', '.', 'Up'], flexMap: {'Shift': 2.5}),

                      // --- CONTROL ROW ---
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            _buildPCKey('Ctrl', flex: 15, color: Colors.red[900]),
                            _buildPCKey('Win', flex: 12, color: Colors.blueGrey[700]),
                            _buildPCKey('Alt', flex: 12, color: Colors.red[900]),
                            _buildPCKey('Space', flex: 40),
                            _buildPCKey('Left', flex: 10),
                            _buildPCKey('Down', flex: 10),
                            _buildPCKey('Right', flex: 10),
                          ],
                        ),
                      ),

                      // Bottom padding for vertical mode to avoid gesture bars
                      if (!isLandscape) const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildKeyboardRow(List<String> keys, {Map<String, double> flexMap = const {}, Color color = AppColors.surfaceDark}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: keys.map((key) {
          double flexValue = flexMap[key] ?? 1.0;
          return _buildPCKey(key, flex: (flexValue * 10).toInt(), color: color);
        }).toList(),
      ),
    );
  }

  Widget _buildPCKey(String label, {int? flex, Color? color, double? width}) {
    final String apiKey = _mapLabelToKey(label);
    final keyType = _getKeyType(label);

    Widget keyWidget = Obx(() {
      bool isUppercase = controller.shift.value || controller.caps.value;
      String displayLabel = (label.length == 1 && isUppercase) ? label.toUpperCase() : label;

      bool isPressed = false;
      switch (apiKey) {
        case 'control':
          isPressed = controller.ctrl.value;
          break;
        case 'shift':
          isPressed = controller.shift.value;
          break;
        case 'alt':
          isPressed = controller.alt.value;
          break;
        case 'meta':
          isPressed = controller.cmd.value;
          break;
        case 'capslock':
          isPressed = controller.caps.value;
          break;
      }

      Color keyColor;
      switch (keyType) {
        case KeyType.function:
          keyColor = AppColors.primary;
          break;

        case KeyType.modifier:
        case KeyType.special:
        case KeyType.arrow:
          keyColor = PreferenceHelper.isDarkMode ? Colors.teal.shade900 : Colors.teal.shade200;
          break;

        case KeyType.number:
        default:
          keyColor = PreferenceHelper.isDarkMode ? AppColors.surfaceDark : AppColors.surfaceLight;
      }

      return GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          if (keyType == KeyType.modifier) {
            controller.toggleModifier(apiKey);
          } else {
            controller.pressLetter(apiKey);
          }
        },
        child: Container(
          height: 42,
          width: width,
          margin: const EdgeInsets.all(2),
          alignment: Alignment.center,
          decoration: BoxDecoration(color: isPressed ? Colors.green : keyColor, borderRadius: BorderRadius.circular(4)),
          child: Text(
            displayLabel,
            style: TextStyle(color: PreferenceHelper.isDarkMode ? AppColors.textLight : AppColors.textDark, fontSize: 11, fontWeight: FontWeight.bold),
          ),
        ),
      );
    });

    if (flex != null) {
      return Expanded(flex: flex, child: keyWidget);
    }
    return keyWidget;
  }

  String _mapLabelToKey(String label) {
    switch (label) {
      case 'Ctrl':
        return 'control';
      case 'Shift':
        return 'shift';
      case 'Alt':
        return 'alt';
      case 'Win':
        return 'meta';
      case 'Caps':
        return 'capslock';
      case 'Enter':
        return 'enter';
      case 'Tab':
        return 'tab';
      case 'Esc':
        return 'escape';
      case 'Space':
        return 'space';
      case '⌫':
        return 'backspace';
      case 'Up':
        return 'up';
      case 'Down':
        return 'down';
      case 'Left':
        return 'left';
      case 'Right':
        return 'right';
      default:
        return label.toLowerCase();
    }
  }

  KeyType _getKeyType(String label) {
    if (label.startsWith('F')) return KeyType.function;

    if (['Ctrl', 'Shift', 'Alt', 'Win', 'Caps'].contains(label)) {
      return KeyType.modifier;
    }

    if (['Enter', 'Tab', '⌫', 'Space'].contains(label)) {
      return KeyType.special;
    }

    if (['Up', 'Down', 'Left', 'Right'].contains(label)) {
      return KeyType.arrow;
    }

    if (RegExp(r'^[0-9]$').hasMatch(label)) {
      return KeyType.number;
    }

    return KeyType.character;
  }
}
