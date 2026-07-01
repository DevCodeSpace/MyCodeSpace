import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:web_rtc/services/auth_service.dart';

import '../controllers/login_controller.dart';

class LoginDialog extends StatefulWidget {
  final AuthService authProvider;

  const LoginDialog({super.key, required this.authProvider});

  @override
  State<LoginDialog> createState() => _LoginDialogState();
}

class _LoginDialogState extends State<LoginDialog> {
  late final LoginController controller;

  @override
  void initState() {
    super.initState();
    controller = LoginController(widget.authProvider);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      backgroundColor: Colors.white,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 360),
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset('assets/image/logo.png', width: 60),
            Text(
              "Sign in",
              style: GoogleFonts.googleSans(fontSize: 24, fontWeight: FontWeight.w400, color: const Color(0xFF1F1F1F)),
            ),
            const SizedBox(height: 8),
            Text(
              "to continue to CodeX Meet",
              style: GoogleFonts.googleSans(fontSize: 16, fontWeight: FontWeight.w400, color: const Color(0xFF444746)),
            ),
            const SizedBox(height: 28),

            Text(
              "To secure our video infrastructure and enter the meeting room, please authenticate using your Google account.",
              textAlign: TextAlign.center,
              style: GoogleFonts.googleSans(fontSize: 14, color: const Color(0xFF444746), height: 1.4),
            ),
            const SizedBox(height: 36),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton.icon(
                icon: SvgPicture.network('https://upload.wikimedia.org/wikipedia/commons/c/c1/Google_%22G%22_logo.svg', height: 20),
                label: Text("Sign in with Google", style: GoogleFonts.googleSans(fontWeight: FontWeight.w500, fontSize: 16)),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF1F1F1F),
                  backgroundColor: Colors.white,
                  side: const BorderSide(color: Color(0xFF747775), width: 1),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                ),
                onPressed: () async {
                  final scaffoldMessenger = ScaffoldMessenger.of(context);
                  final navigator = Navigator.of(context);

                  try {
                    await controller.signIn();
                  } catch (e) {
                    scaffoldMessenger.showSnackBar(
                      SnackBar(
                        content: Text("Authentication Failed: $e", style: const TextStyle(color: Colors.white)),
                        backgroundColor: Colors.redAccent,
                      ),
                    );
                  } finally {
                    if (navigator.canPop()) {
                      navigator.pop();
                    }
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
