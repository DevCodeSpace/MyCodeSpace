class ApiService {
  Future<String> login(String email, String password) async {
    // Simulate a network request
    await Future.delayed(const Duration(seconds: 2));
    if (email == 'user@example.com' && password == 'password') {
      return 'UserToken';
    } else {
      throw Exception('Invalid credentials');
    }
  }
}
