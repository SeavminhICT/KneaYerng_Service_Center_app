import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class UserProfile {
  final String? firstName;
  final String? lastName;
  final String? email;
  final String? avatarUrl;

  const UserProfile({
    this.firstName,
    this.lastName,
    this.email,
    this.avatarUrl,
  });

  String get displayName {
    final parts = [
      if (firstName != null && firstName!.trim().isNotEmpty) firstName!.trim(),
      if (lastName != null && lastName!.trim().isNotEmpty) lastName!.trim(),
    ];
    if (parts.isNotEmpty) {
      return parts.join(' ');
    }
    return '';
  }

  Map<String, dynamic> toMap() {
    return {
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
      'avatar_url': avatarUrl,
    };
  }

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      firstName: map['first_name'] as String?,
      lastName: map['last_name'] as String?,
      email: map['email'] as String?,
      avatarUrl: map['avatar_url'] as String?,
    );
  }
}

class ApiService {
  static const String baseUrl = 'https://seavminh.com/api';
  static const String _tokenKey = 'token';
  static const String _userProfileKey = 'user_profile';

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
      final token = data['token'] ?? data['access_token'];
      if (token != null) {
        await _saveToken(token);
      }
      final profile = _extractUserProfile(
        data,
        fallbackFirstName: firstName,
        fallbackLastName: lastName,
        fallbackEmail: email,
      );
      if (profile != null) {
        await _saveUserProfile(profile);
      }
      return null;
    }

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
      body: jsonEncode({'email': email, 'password': password}),
    );
    print('LOGIN API CALLED');
    print('EMAIL: $email');
    print('PASSWORD: $password');
    print('LOGIN STATUS: ${res.statusCode}');
    print('LOGIN BODY: ${res.body}');

    final data = jsonDecode(res.body);

    if (res.statusCode == 200) {
      final token = data['token'] ?? data['access_token'];
      if (token != null) {
        await _saveToken(token);
      }
      final profile = _extractUserProfile(data, fallbackEmail: email);
      if (profile != null) {
        await _saveUserProfile(profile);
      }
      return null;
    }

    return data['message'] ?? 'Login failed';
  }

  static Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  static Future<void> _saveUserProfile(UserProfile profile) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userProfileKey, jsonEncode(profile.toMap()));
  }

  static Future<UserProfile?> getUserProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_userProfileKey);
    if (raw == null || raw.isEmpty) return null;
    final decoded = jsonDecode(raw);
    if (decoded is Map<String, dynamic>) {
      return UserProfile.fromMap(decoded);
    }
    return null;
  }

  static Future<String?> logout() async {
    final token = await getToken();
    if (token == null || token.isEmpty) {
      await _clearSession();
      return null;
    }

    final res = await http.post(
      Uri.parse('$baseUrl/auth/logout'),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (res.statusCode == 200 || res.statusCode == 204) {
      await _clearSession();
      return null;
    }

    if (res.statusCode == 401) {
      await _clearSession();
      return null;
    }

    final data = jsonDecode(res.body);
    return data['message'] ?? 'Logout failed';
  }

  static Future<void> _clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userProfileKey);
  }

  static UserProfile? _extractUserProfile(
    Map<String, dynamic> data, {
    String? fallbackFirstName,
    String? fallbackLastName,
    String? fallbackEmail,
  }) {
    Map<String, dynamic> userData = {};
    if (data['user'] is Map) {
      userData = Map<String, dynamic>.from(data['user']);
    } else if (data['data'] is Map) {
      final dataMap = Map<String, dynamic>.from(data['data']);
      if (dataMap['user'] is Map) {
        userData = Map<String, dynamic>.from(dataMap['user']);
      } else {
        userData = dataMap;
      }
    } else {
      userData = data;
    }

    String? firstName =
        _asString(userData['first_name']) ?? _asString(userData['firstName']);
    String? lastName =
        _asString(userData['last_name']) ?? _asString(userData['lastName']);
    final name = _asString(userData['name']);
    final email = _asString(userData['email']) ?? fallbackEmail;
    final avatarUrl =
        _asString(userData['avatar']) ??
        _asString(userData['avatar_url']) ??
        _asString(userData['profile_photo_url']) ??
        _asString(userData['image']);

    if ((firstName == null || firstName.isEmpty) &&
        (lastName == null || lastName.isEmpty) &&
        name != null &&
        name.isNotEmpty) {
      final parts = name.trim().split(RegExp(r'\s+'));
      if (parts.length == 1) {
        firstName = parts.first;
      } else {
        firstName = parts.first;
        lastName = parts.sublist(1).join(' ');
      }
    }

    firstName ??= fallbackFirstName;
    lastName ??= fallbackLastName;

    final hasAnyValue =
        (firstName != null && firstName.isNotEmpty) ||
        (lastName != null && lastName.isNotEmpty) ||
        (email != null && email.isNotEmpty) ||
        (avatarUrl != null && avatarUrl.isNotEmpty);
    if (!hasAnyValue) return null;

    return UserProfile(
      firstName: firstName,
      lastName: lastName,
      email: email,
      avatarUrl: avatarUrl,
    );
  }

  static String? _asString(dynamic value) {
    if (value is String && value.trim().isNotEmpty) {
      return value.trim();
    }
    return null;
  }
}
