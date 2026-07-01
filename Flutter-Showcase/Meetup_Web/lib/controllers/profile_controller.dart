import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';

class ProfileController extends ChangeNotifier {
  late final AuthService _authService;

  void attach(BuildContext context) {
    _authService = context.read<AuthService>();
  }

  Future<void> signOut() async {
    await _authService.signOut();
  }
}
