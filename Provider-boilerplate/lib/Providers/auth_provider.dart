import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:provider_boiler_plate/Model/user_model.dart';
import 'package:provider_boiler_plate/Services/api_services.dart';


class AuthProvider with ChangeNotifier {
  final ApiService _apiService = GetIt.instance<ApiService>();

  UserModel? _user;
  bool _isLoading = false;
  String? _errorMessage;

  UserModel? get user => _user;
  bool get isAuthenticated => _user != null;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      String token = await _apiService.login(email, password);
      _user = UserModel(email: email, token: token);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void logout() {
    _user = null;
    notifyListeners();
  }
}
