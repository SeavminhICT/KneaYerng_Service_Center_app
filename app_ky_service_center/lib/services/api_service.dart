import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String baseUrl = 'https://seavminh.com/api';

  // REGISTER
  static Future<String?> register({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required String confirmPassword,
  }) async {
    final res = await http.post(
      Uri.parse('$baseUrl/auth/register'),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'first_name': firstName,
        'last_name': lastName,
        'email': email,
        'password': password,
        'password_confirmation': confirmPassword,
      }),
    );

    final data = jsonDecode(res.body);

    if (res.statusCode == 200 || res.statusCode == 201) {
      if (data['token'] != null) {
        await _saveToken(data['token']);
      }
      return null; // ✅ success
    }

    // ❌ return backend error message
    return data['message'] ?? 'Register failed';
  }

  static Future<String?> login({
    required String email,
    required String password,

  }) async {
    final res = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );
    print('LOGIN API CALLED');
    print('EMAIL: $email');
    print('PASSWORD: $password');
    print('LOGIN STATUS: ${res.statusCode}');
    print('LOGIN BODY: ${res.body}');

    final data = jsonDecode(res.body);

    if (res.statusCode == 200) {
      await _saveToken(data['token']);
      return null; // ✅ success
    }

    // ❌ backend error message
    return data['message'] ?? 'Login failed';
  }

  static Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }
}
