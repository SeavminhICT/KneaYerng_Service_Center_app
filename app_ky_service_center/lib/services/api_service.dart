import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/product.dart';
import '../models/banner_item.dart';
import '../models/user_profile.dart';

class ApiService {
  static const String baseUrl = 'https://kneayerng.seavminh.com/api';
  static const String _tokenKey = 'token';
  static const String _userProfileKey = 'user_profile';

  // ================= REGISTER =================
  static Future<String?> register({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required String confirmPassword,
  }) async {
    final res = await http.post(
      Uri.parse('$baseUrl/auth/register'),
      headers: const {
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

  // ================= LOGIN =================
  static Future<String?> login({
    required String email,
    required String password,
  }) async {
    final res = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: const {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );

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

  // ================= TOKEN =================
  static Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  // ================= PROFILE CACHE =================
  static Future<void> _saveUserProfile(UserProfile profile) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _userProfileKey,
      jsonEncode(profile.toMap()),
    );
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

  // ================= LOGOUT =================
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

    if (res.statusCode == 200 ||
        res.statusCode == 204 ||
        res.statusCode == 401) {
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

  // ================= EXTRACT PROFILE =================
  static UserProfile? _extractUserProfile(
    Map<String, dynamic> data, {
    String? fallbackFirstName,
    String? fallbackLastName,
    String? fallbackEmail,
  }) {
    Map<String, dynamic> user = {};

    if (data['user'] is Map) {
      user = Map<String, dynamic>.from(data['user']);
    } else if (data['data'] is Map && data['data']['user'] is Map) {
      user = Map<String, dynamic>.from(data['data']['user']);
    } else {
      user = data;
    }

    final avatarValue = user['avatar_url'] ?? user['avatar'];
    return UserProfile(
      firstName: user['first_name'] ?? fallbackFirstName,
      lastName: user['last_name'] ?? fallbackLastName,
      email: user['email'] ?? fallbackEmail,
      phone: user['phone'],
      birth: user['birth'],
      gender: user['gender'],
      avatarUrl: normalizeMediaUrl(avatarValue),
    );
  }

  static String? normalizeMediaUrl(dynamic value) {
    if (value is! String || value.isEmpty) return null;
    if (value.startsWith('http://') || value.startsWith('https://')) {
      return value;
    }
    final baseRoot = baseUrl.replaceFirst('/api', '');
    final clean = value.startsWith('/') ? value.substring(1) : value;
    return '$baseRoot/$clean';
  }

  // ================= UPDATE PROFILE =================
  static Future<String?> updateProfile({
    required String firstName,
    required String lastName,
    required String email,
    String? birth,
    String? gender,
    String? avatarPath,
  }) async {
    final token = await getToken();

    if (token == null || token.isEmpty) {
      return 'Not authenticated';
    }

    http.Response res;
    if (avatarPath != null && avatarPath.isNotEmpty) {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/auth/user/update'),
      );
      request.headers['Authorization'] = 'Bearer $token';
      request.headers['Accept'] = 'application/json';
      request.fields.addAll({
        '_method': 'PUT',
        'first_name': firstName,
        'last_name': lastName,
        'email': email,
      });
      if (birth != null && birth.isNotEmpty) {
        request.fields['birth'] = birth;
      }
      if (gender != null && gender.isNotEmpty) {
        request.fields['gender'] = gender;
      }
      request.files.add(await http.MultipartFile.fromPath('avatar', avatarPath));
      final streamed = await request.send();
      res = await http.Response.fromStream(streamed);
    } else {
      final body = <String, dynamic>{
        'first_name': firstName,
        'last_name': lastName,
        'email': email,
      };
      if (birth != null && birth.isNotEmpty) {
        body['birth'] = birth;
      }
      if (gender != null && gender.isNotEmpty) {
        body['gender'] = gender;
      }
      res = await http.put(
        Uri.parse('$baseUrl/auth/user/update'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(body),
      );
    }

    if (res.statusCode == 200 || res.statusCode == 201) {
      try {
        final data = jsonDecode(res.body);
        final profile = _extractUserProfile(
          data,
          fallbackFirstName: firstName,
          fallbackLastName: lastName,
          fallbackEmail: email,
        );
        if (profile != null) {
          await _saveUserProfile(profile);
        }
      } catch (_) {}
      return null;
    }
    try {
      final data = jsonDecode(res.body);
      return data['message'] ?? 'Failed to update profile';
    } catch (_) {
      return 'Failed to update profile';
    }
  }

  // ================= PRODUCTS =================
  static Future<List<Product>> fetchProducts({
    String? categoryName,
    String? status,
  }) async {
    final query = <String, String>{};
    if (status != null && status.isNotEmpty) {
      query['status'] = status;
    }
    final uri = Uri.parse('$baseUrl/products')
        .replace(queryParameters: query.isEmpty ? null : query);
    final res = await http.get(
      uri,
      headers: const {'Accept': 'application/json'},
    );

    if (res.statusCode != 200) {
      throw Exception('Failed to load products');
    }

    final decoded = jsonDecode(res.body);
    final rawList = decoded['data'];
    if (rawList is! List) return [];

    final products = rawList
        .whereType<Map>()
        .map((item) => Product.fromJson(Map<String, dynamic>.from(item)))
        .toList();

    if (categoryName == null || categoryName.isEmpty) return products;

    final target = categoryName.toLowerCase();
    return products
        .where((product) => (product.categoryName ?? '').toLowerCase() == target)
        .toList();
  }

  // ================= BANNERS =================
  static Future<List<BannerItem>> fetchBanners() async {
    final res = await http
        .get(
          Uri.parse('$baseUrl/banners'),
          headers: const {'Accept': 'application/json'},
        )
        .timeout(const Duration(seconds: 12));

    if (res.statusCode != 200) {
      debugPrint(
          '[ApiService] banners status=${res.statusCode} body=${res.body}');
      throw Exception('Failed to load banners');
    }

    final decoded = jsonDecode(res.body);
    final rawList = decoded['data'] ?? decoded['banners'] ?? decoded;
    if (rawList is! List) return [];

    return rawList
        .whereType<Map>()
        .map((item) => BannerItem.fromJson(Map<String, dynamic>.from(item)))
        .where((item) => item.isActive && (item.imageUrl?.isNotEmpty ?? false))
        .toList();
  }
}
