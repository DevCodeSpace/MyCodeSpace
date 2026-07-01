import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class LoginController extends ChangeNotifier {
  final AuthService _authService;

  LoginController(this._authService);

  Future<void> signIn() async {
    await _authService.signInWithGoogle();
  }
}
