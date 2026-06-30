import 'package:ai_avtar_chat/core/helpers/settings.dart';
import 'package:ai_avtar_chat/modules/assistant/controller/assistant_controller.dart';
import 'package:ai_avtar_chat/modules/assistant/controller/conversation_controller.dart';
import 'package:ai_avtar_chat/modules/assistant/view/avatar_chat_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

Future<void> main() async {
  // Ensure plugins (SharedPreferences etc.) initialise before controllers read state.
  WidgetsFlutterBinding.ensureInitialized();
  await Settings.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (_, child) => GetMaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'AI Avatar Chat',
        theme: ThemeData(
          // Keeps system widgets (dialogs, snackbars) on a dark base.
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF6C3CE1), brightness: Brightness.dark),
          useMaterial3: true,
        ),

        // AssistantController and ConversationController are kept alive for the
        // entire app session — they own the WebSocket, mic stream, and gift state.
        initialBinding: BindingsBuilder(() {
          Get.lazyPut<AssistantController>(() => AssistantController());
          Get.lazyPut<ConversationController>(() => ConversationController());
        }),

        // Single entry point — the AI gift chat screen.
        home: const AvatarChatScreen(),
      ),
    );
  }
}
