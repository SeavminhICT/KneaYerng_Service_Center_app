import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart'
    show kIsWeb, defaultTargetPlatform, TargetPlatform, debugPrint;
import 'package:shared_preferences/shared_preferences.dart';
import 'local_host_resolver_stub.dart'
    if (dart.library.io) 'local_host_resolver_io.dart'
    as local_host_resolver;
import '../models/product.dart';
import '../models/search_results.dart';
import '../models/search_suggestion.dart';
import '../models/category.dart';
import '../models/banner_item.dart';
import '../models/order_tracking_notification.dart';
import '../models/support_chat.dart';
import '../models/user_profile.dart';
import '../models/pickup_ticket.dart';

class ApiService {
  static const String _baseUrlOverride = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: '',
  );
  static const String _baseUrlPreferenceKey = 'api_base_url';
  static const String _loopbackApi = 'http://127.0.0.1:8000/api';
  static const String _androidEmulatorApi = 'http://10.0.2.2:8000/api';
  static String? _runtimeBaseUrl;
  static String? _autoDetectedBaseUrl;

  static Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString(_baseUrlPreferenceKey);
    if (stored == null || stored.trim().isEmpty) {
      _runtimeBaseUrl = null;
    } else {
      _runtimeBaseUrl = _normalizeBaseUrl(stored);
    }

    _autoDetectedBaseUrl = await _resolveAutoDetectedBaseUrl();
  }

  static String get baseUrl {
    if (_runtimeBaseUrl != null && _runtimeBaseUrl!.isNotEmpty) {
      return _runtimeBaseUrl!;
    }

    if (_baseUrlOverride.isNotEmpty) {
      return _normalizeBaseUrl(_baseUrlOverride);
    }

    if (kIsWeb) {
      final webOrigin = Uri.base;
      if (webOrigin.host.isNotEmpty &&
          webOrigin.host != 'localhost' &&
          webOrigin.host != '127.0.0.1') {
        final inferred = webOrigin.replace(
          path: '/api',
          query: null,
          fragment: null,
        );
        return inferred.toString();
      }
      return _loopbackApi;
    }

    if (defaultTargetPlatform == TargetPlatform.android) {
      return _androidEmulatorApi;
    }

    if (_autoDetectedBaseUrl != null && _autoDetectedBaseUrl!.isNotEmpty) {
      return _autoDetectedBaseUrl!;
    }

    return _loopbackApi;
  }

  static bool get hasConfiguredBaseUrl =>
      _runtimeBaseUrl != null && _runtimeBaseUrl!.isNotEmpty;

  static String get serverOrigin {
    final uri = Uri.tryParse(baseUrl);
    if (uri == null || uri.scheme.isEmpty || uri.host.isEmpty) {
      return baseUrl;
    }

    final port = uri.hasPort ? ':${uri.port}' : '';
    return '${uri.scheme}://${uri.host}$port';
  }

  static String get mediaBaseUrl => '$baseUrl/media';

  static const String _tokenKey = 'token';
  static const String _userProfileKey = 'user_profile';

  static Future<String?> configureBaseUrl(
    String raw, {
    bool verifyConnection = true,
  }) async {
    final normalized = _normalizeBaseUrl(raw);
    if (normalized.isEmpty) {
      return 'Server URL is required.';
    }

    if (verifyConnection) {
      final error = await testBaseUrl(normalized);
      if (error != null) {
        return error;
      }
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_baseUrlPreferenceKey, normalized);
    _runtimeBaseUrl = normalized;
    return null;
  }

  static Future<void> clearConfiguredBaseUrl() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_baseUrlPreferenceKey);
    _runtimeBaseUrl = null;
  }

  static Future<String?> testBaseUrl(String raw) async {
    final normalized = _normalizeBaseUrl(raw);
    if (normalized.isEmpty) {
      return 'Server URL is required.';
    }

    final probeUri = Uri.parse('$normalized/categories');

    try {
      final response = await http
          .get(probeUri, headers: const {'Accept': 'application/json'})
          .timeout(const Duration(seconds: 8));

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return null;
      }

      return 'Server responded with status ${response.statusCode}. '
          'Check that the URL points to your Laravel backend.';
    } on TimeoutException {
      return 'Timed out while connecting to $normalized.';
    } catch (error) {
      return 'Cannot connect to $normalized.';
    }
  }

  // ================= REGISTER =================
  static Future<String?> register({
    required String firstName,
    required String lastName,
    String? email,
    String? phone,
    required String password,
    required String confirmPassword,
  }) async {
    http.Response res;
    try {
      res = await http
          .post(
            Uri.parse('$baseUrl/auth/register'),
            headers: const {
              'Accept': 'application/json',
              'Content-Type': 'application/json',
            },
            body: jsonEncode({
              'first_name': firstName,
              'last_name': lastName,
              if (email != null && email.trim().isNotEmpty)
                'email': email.trim(),
              if (phone != null && phone.trim().isNotEmpty)
                'phone': phone.trim(),
              'password': password,
              'password_confirmation': confirmPassword,
            }),
          )
          .timeout(const Duration(seconds: 15));
    } on TimeoutException {
      return _buildNetworkErrorMessage();
    } catch (error) {
      debugPrint('Register failed: $error');
      return _buildNetworkErrorMessage();
    }

    dynamic data;
    try {
      data = jsonDecode(res.body);
    } catch (_) {}

    if (res.statusCode == 200 || res.statusCode == 201) {
      final token = data is Map
          ? (data['token'] ?? data['access_token'])
          : null;
      if (token != null) {
        await _saveToken(token);
      }

      final profile = _extractUserProfile(
        data is Map
            ? Map<String, dynamic>.from(data)
            : const <String, dynamic>{},
        fallbackFirstName: firstName,
        fallbackLastName: lastName,
        fallbackEmail: email,
      );

      if (profile != null) {
        await _saveUserProfile(profile);
      }
      return null;
    }

    if (data is Map && data['message'] is String) {
      return data['message'] as String;
    }
    return 'Register failed';
  }

  // ================= OTP =================
  static Future<OtpRequestResult> requestOtp({
    required String destination,
    required String type,
    required String purpose,
    String? deviceId,
  }) async {
    http.Response res;
    try {
      res = await http
          .post(
            Uri.parse('$baseUrl/otp/request'),
            headers: const {
              'Accept': 'application/json',
              'Content-Type': 'application/json',
            },
            body: jsonEncode({
              'destination': destination,
              'type': type,
              'purpose': purpose,
              if (deviceId != null && deviceId.trim().isNotEmpty)
                'device_id': deviceId.trim(),
            }),
          )
          .timeout(const Duration(seconds: 15));
    } catch (_) {
      return const OtpRequestResult(
        ok: false,
        message: 'Unable to request OTP. Please try again.',
      );
    }

    dynamic decoded;
    try {
      decoded = jsonDecode(res.body);
    } catch (_) {}

    if (decoded is! Map) {
      return const OtpRequestResult(
        ok: false,
        message: 'Invalid OTP response.',
      );
    }

    final map = Map<String, dynamic>.from(decoded);
    return OtpRequestResult(
      ok: res.statusCode >= 200 && res.statusCode < 300,
      message: map['message']?.toString() ?? 'OTP request completed.',
      expiresInSec: _parseInt(map['expires_in_sec']),
      resendInSec: _parseInt(map['resend_in_sec']),
    );
  }

  static Future<OtpVerifyResult> verifyOtp({
    required String destination,
    required String type,
    required String purpose,
    required String otp,
  }) async {
    http.Response res;
    try {
      res = await http
          .post(
            Uri.parse('$baseUrl/otp/verify'),
            headers: const {
              'Accept': 'application/json',
              'Content-Type': 'application/json',
            },
            body: jsonEncode({
              'destination': destination,
              'type': type,
              'purpose': purpose,
              'otp': otp,
            }),
          )
          .timeout(const Duration(seconds: 15));
    } catch (_) {
      return const OtpVerifyResult(
        ok: false,
        message: 'Unable to verify OTP right now.',
      );
    }

    dynamic decoded;
    try {
      decoded = jsonDecode(res.body);
    } catch (_) {}

    if (decoded is! Map) {
      return const OtpVerifyResult(
        ok: false,
        message: 'Invalid OTP verification response.',
      );
    }

    final map = Map<String, dynamic>.from(decoded);
    final token = map['token']?.toString();
    if (token != null && token.isNotEmpty) {
      await _saveToken(token);
    }

    final profile = _extractUserProfile(map, fallbackEmail: destination);
    if (profile != null) {
      await _saveUserProfile(profile);
    }

    return OtpVerifyResult(
      ok: res.statusCode >= 200 && res.statusCode < 300,
      message: map['message']?.toString() ?? 'OTP verification completed.',
      token: token,
      resetToken: map['reset_token']?.toString(),
    );
  }

  static Future<OtpVerifyResult> verifyFirebasePhone({
    required String idToken,
    required String purpose,
    String? destination,
  }) async {
    http.Response res;
    try {
      res = await http
          .post(
            Uri.parse('$baseUrl/otp/firebase/verify'),
            headers: const {
              'Accept': 'application/json',
              'Content-Type': 'application/json',
            },
            body: jsonEncode({
              'id_token': idToken,
              'purpose': purpose,
              if (destination != null && destination.trim().isNotEmpty)
                'destination': destination.trim(),
            }),
          )
          .timeout(const Duration(seconds: 15));
    } catch (_) {
      return const OtpVerifyResult(
        ok: false,
        message: 'Unable to verify OTP right now.',
      );
    }

    dynamic decoded;
    try {
      decoded = jsonDecode(res.body);
    } catch (_) {}

    if (decoded is! Map) {
      return const OtpVerifyResult(
        ok: false,
        message: 'Invalid OTP verification response.',
      );
    }

    final map = Map<String, dynamic>.from(decoded);
    final token = map['token']?.toString();
    if (token != null && token.isNotEmpty) {
      await _saveToken(token);
    }

    final profile = _extractUserProfile(map, fallbackEmail: destination);
    if (profile != null) {
      await _saveUserProfile(profile);
    }

    return OtpVerifyResult(
      ok: res.statusCode >= 200 && res.statusCode < 300,
      message: map['message']?.toString() ?? 'OTP verification completed.',
      token: token,
      resetToken: map['reset_token']?.toString(),
    );
  }

  static Future<String?> resetPasswordWithOtp({
    required String resetToken,
    required String password,
    required String confirmPassword,
  }) async {
    http.Response res;
    try {
      res = await http
          .post(
            Uri.parse('$baseUrl/password/reset-with-otp'),
            headers: const {
              'Accept': 'application/json',
              'Content-Type': 'application/json',
            },
            body: jsonEncode({
              'reset_token': resetToken,
              'password': password,
              'password_confirmation': confirmPassword,
            }),
          )
          .timeout(const Duration(seconds: 15));
    } catch (_) {
      return 'Unable to reset password right now.';
    }

    if (res.statusCode >= 200 && res.statusCode < 300) {
      return null;
    }

    try {
      final decoded = jsonDecode(res.body);
      if (decoded is Map && decoded['message'] is String) {
        return decoded['message'] as String;
      }
    } catch (_) {}

    return 'Unable to reset password.';
  }

  // ================= LOGIN =================
  static Future<String?> login({
    required String identifier,
    required String password,
  }) async {
    http.Response res;
    try {
      res = await http
          .post(
            Uri.parse('$baseUrl/auth/login'),
            headers: const {
              'Accept': 'application/json',
              'Content-Type': 'application/json',
            },
            body: jsonEncode({'email': identifier, 'password': password}),
          )
          .timeout(const Duration(seconds: 15));
    } on TimeoutException {
      return _buildNetworkErrorMessage();
    } catch (error) {
      debugPrint('Login failed: $error');
      return _buildNetworkErrorMessage();
    }

    dynamic data;
    try {
      data = jsonDecode(res.body);
    } catch (_) {}

    if (res.statusCode == 200) {
      final token = data is Map
          ? (data['token'] ?? data['access_token'])
          : null;
      if (token != null) {
        await _saveToken(token);
      }

      final profile = _extractUserProfile(
        data is Map
            ? Map<String, dynamic>.from(data)
            : const <String, dynamic>{},
        fallbackEmail: identifier.contains('@') ? identifier : null,
      );

      if (profile != null) {
        await _saveUserProfile(profile);
      }
      return null;
    }

    if (data is Map && data['message'] is String) {
      return data['message'] as String;
    }
    return 'Login failed';
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
    if (value == null) return null;

    if (value is List) {
      for (final entry in value) {
        final normalized = normalizeMediaUrl(entry);
        if (normalized != null && normalized.isNotEmpty) return normalized;
      }
      return null;
    }

    if (value is Map) {
      final map = Map<String, dynamic>.from(value);
      final candidate =
          map['image'] ??
          map['image_url'] ??
          map['image_path'] ??
          map['imagePath'] ??
          map['url'] ??
          map['path'] ??
          map['file_path'] ??
          map['filePath'] ??
          map['src'];
      return normalizeMediaUrl(candidate);
    }

    if (value is! String) return null;

    var normalized = value.trim();
    if (normalized.isEmpty) return null;

    final lowered = normalized.toLowerCase();
    if (lowered == 'null' || lowered == 'undefined') return null;

    if (normalized.startsWith('[') && normalized.endsWith(']')) {
      try {
        final decoded = jsonDecode(normalized);
        if (decoded is List) {
          return normalizeMediaUrl(decoded);
        }
      } catch (_) {
        final fallback = normalized.substring(1, normalized.length - 1);
        final list = fallback
            .split(RegExp(r'[|,;]'))
            .map((item) => item.trim().replaceAll("'", '').replaceAll('"', ''))
            .where((item) => item.isNotEmpty)
            .toList();
        if (list.isNotEmpty) {
          return normalizeMediaUrl(list.first);
        }
      }
    }

    if ((normalized.startsWith('"') && normalized.endsWith('"')) ||
        (normalized.startsWith("'") && normalized.endsWith("'"))) {
      normalized = normalized.substring(1, normalized.length - 1).trim();
    }

    if (normalized.isEmpty) return null;

    normalized = normalized.replaceAll(r'\/', '/').replaceAll('\\', '/');
    normalized = _trimTrailingSlashFromFilePath(normalized);

    if (normalized.startsWith('http://') || normalized.startsWith('https://')) {
      try {
        final uri = Uri.parse(normalized);
        final host = uri.host.toLowerCase();
        if (host == 'localhost' || host == '127.0.0.1' || host == '10.0.2.2') {
          final normalizedPath = uri.path.replaceAll('\\', '/');
          if (normalizedPath.startsWith('/storage/') ||
              normalizedPath.startsWith('/public/storage/')) {
            final mediaPath = normalizedPath
                .replaceFirst('/public/storage/', '')
                .replaceFirst('/storage/', '');
            return _trimTrailingSlashFromFilePath(
              Uri.encodeFull('$mediaBaseUrl/$mediaPath'),
            );
          }

          final baseRoot = baseUrl.replaceFirst('/api', '');
          final baseUri = Uri.parse(baseRoot);
          final rebased = uri.replace(
            scheme: baseUri.scheme,
            host: baseUri.host,
            port: baseUri.hasPort ? baseUri.port : null,
          );
          return _trimTrailingSlashFromFilePath(
            Uri.encodeFull(rebased.toString()),
          );
        }
      } catch (_) {}
      return _trimTrailingSlashFromFilePath(Uri.encodeFull(normalized));
    }

    final baseRoot = baseUrl.replaceFirst('/api', '');
    var clean = normalized.replaceAll('\\', '/');
    if (clean.startsWith('/')) {
      clean = clean.substring(1);
    }
    if (clean.startsWith('storage/')) {
      final mediaPath = clean.substring('storage/'.length);
      return _trimTrailingSlashFromFilePath(
        Uri.encodeFull('$mediaBaseUrl/$mediaPath'),
      );
    }
    if (clean.startsWith('public/storage/')) {
      final mediaPath = clean.substring('public/storage/'.length);
      return _trimTrailingSlashFromFilePath(
        Uri.encodeFull('$mediaBaseUrl/$mediaPath'),
      );
    }
    return _trimTrailingSlashFromFilePath(Uri.encodeFull('$baseRoot/$clean'));
  }

  static String _trimTrailingSlashFromFilePath(String input) {
    var value = input;
    while (value.endsWith('/')) {
      value = value.substring(0, value.length - 1);
    }
    if (value.isEmpty) return input;
    return value;
  }

  static Future<String?> _resolveAutoDetectedBaseUrl() async {
    if (kIsWeb) {
      return null;
    }

    if (defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS) {
      return null;
    }

    return local_host_resolver.detectLocalServerBaseUrl();
  }

  static String _normalizeBaseUrl(String raw) {
    var trimmed = raw.trim();
    if (trimmed.isEmpty) return trimmed;

    if (!trimmed.contains('://')) {
      final scheme = _shouldDefaultToHttp(trimmed) ? 'http' : 'https';
      trimmed = '$scheme://$trimmed';
    }

    final uri = Uri.parse(trimmed);
    final segments = uri.pathSegments
        .where((segment) => segment.isNotEmpty)
        .toList();
    if (!segments.contains('api')) {
      segments.add('api');
    }
    return uri
        .replace(path: '/${segments.join('/')}', query: null, fragment: null)
        .toString()
        .replaceFirst(RegExp(r'/$'), '');
  }

  static bool _shouldDefaultToHttp(String raw) {
    final host = _extractHost(raw);
    if (host.isEmpty) {
      return true;
    }

    if (host == 'localhost' ||
        host == '127.0.0.1' ||
        host == '10.0.2.2' ||
        host.endsWith('.local')) {
      return true;
    }

    final parts = host.split('.');
    if (parts.length == 4) {
      final octets = parts.map(int.tryParse).toList();
      if (octets.every((octet) => octet != null)) {
        final first = octets[0]!;
        final second = octets[1]!;
        if (first == 10 || first == 127 || first == 192 && second == 168) {
          return true;
        }
        if (first == 172 && second >= 16 && second <= 31) {
          return true;
        }
      }
    }

    return false;
  }

  static String _extractHost(String raw) {
    var value = raw.trim();
    if (value.isEmpty) {
      return '';
    }

    if (value.contains('://')) {
      final uri = Uri.tryParse(value);
      return uri?.host.toLowerCase() ?? '';
    }

    final slashIndex = value.indexOf('/');
    if (slashIndex >= 0) {
      value = value.substring(0, slashIndex);
    }

    if (value.startsWith('[')) {
      final closing = value.indexOf(']');
      if (closing > 0) {
        return value.substring(1, closing).toLowerCase();
      }
    }

    final lastColon = value.lastIndexOf(':');
    if (lastColon > 0 && value.indexOf(':') == lastColon) {
      value = value.substring(0, lastColon);
    }

    return value.toLowerCase();
  }

  static int? _parseInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '');
  }

  static double? _parseDouble(dynamic value) {
    if (value is double) return value;
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '');
  }

  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    final raw = value.toString().trim();
    if (raw.isEmpty) return null;
    try {
      return DateTime.parse(raw).toLocal();
    } catch (_) {
      return null;
    }
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

    final sanitizedEmail = email.trim();

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
      });
      if (sanitizedEmail.isNotEmpty) {
        request.fields['email'] = sanitizedEmail;
      }
      if (birth != null && birth.isNotEmpty) {
        request.fields['birth'] = birth;
      }
      if (gender != null && gender.isNotEmpty) {
        request.fields['gender'] = gender;
      }
      request.files.add(
        await http.MultipartFile.fromPath('avatar', avatarPath),
      );
      final streamed = await request.send();
      res = await http.Response.fromStream(streamed);
    } else {
      final body = <String, dynamic>{
        'first_name': firstName,
        'last_name': lastName,
      };
      if (sanitizedEmail.isNotEmpty) {
        body['email'] = sanitizedEmail;
      }
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
          fallbackEmail: sanitizedEmail.isNotEmpty ? sanitizedEmail : null,
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
  static Future<List<SearchSuggestion>> fetchSearchSuggestions(
    String query, {
    int limit = 8,
  }) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return [];

    final uri = Uri.parse('$baseUrl/search/suggestions').replace(
      queryParameters: {
        'q': trimmed,
        'limit': limit.clamp(1, 12).toString(),
      },
    );

    http.Response res;
    try {
      res = await http
          .get(uri, headers: const {'Accept': 'application/json'})
          .timeout(const Duration(seconds: 12));
    } catch (_) {
      return [];
    }

    if (res.statusCode != 200) {
      return [];
    }

    try {
      final decoded = jsonDecode(res.body);
      final rawList = decoded is Map ? decoded['data'] : null;
      if (rawList is! List) return [];
      return rawList
          .whereType<Map>()
          .map(
            (item) =>
                SearchSuggestion.fromJson(Map<String, dynamic>.from(item)),
          )
          .toList();
    } catch (_) {
      return [];
    }
  }

  static Future<SearchResults> searchCatalog(String query) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) {
      return const SearchResults(query: '');
    }

    final uri = Uri.parse('$baseUrl/search/results').replace(
      queryParameters: {'q': trimmed},
    );

    final res = await http
        .get(uri, headers: const {'Accept': 'application/json'})
        .timeout(const Duration(seconds: 18));

    if (res.statusCode != 200) {
      throw Exception('Failed to load search results');
    }

    final decoded = jsonDecode(res.body);
    if (decoded is! Map<String, dynamic>) {
      return SearchResults(query: trimmed);
    }

    return SearchResults.fromJson(decoded);
  }

  static Future<SupportConversation> fetchSupportConversation({
    String? contextType,
    int? contextId,
    String? subject,
    bool includeMessages = true,
  }) async {
    final token = await getToken();
    if (token == null || token.isEmpty) {
      throw Exception('Authentication required');
    }

    final uri = Uri.parse('$baseUrl/support/conversation').replace(
      queryParameters: {
        if (contextType != null && contextType.trim().isNotEmpty)
          'context_type': contextType.trim(),
        if (contextId != null) 'context_id': contextId.toString(),
        if (subject != null && subject.trim().isNotEmpty) 'subject': subject.trim(),
        'include_messages': includeMessages ? '1' : '0',
      },
    );

    final res = await http
        .get(
          uri,
          headers: {
            'Accept': 'application/json',
            'Authorization': 'Bearer $token',
          },
        )
        .timeout(const Duration(seconds: 18));

    if (res.statusCode != 200) {
      throw Exception('Failed to load support conversation');
    }

    final decoded = jsonDecode(res.body);
    if (decoded is! Map) {
      throw Exception('Invalid support conversation response');
    }

    final normalized = Map<String, dynamic>.from(decoded);
    final data = normalized['data'] is Map
        ? Map<String, dynamic>.from(decoded['data'])
        : normalized;
    return SupportConversation.fromJson(data);
  }

  static Future<SupportChatMessage> sendSupportMessage({
    required int conversationId,
    required String body,
    String messageType = 'text',
  }) async {
    final token = await getToken();
    if (token == null || token.isEmpty) {
      throw Exception('Authentication required');
    }

    final res = await http
        .post(
          Uri.parse('$baseUrl/support/messages'),
          headers: {
            'Accept': 'application/json',
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: jsonEncode({
            'conversation_id': conversationId,
            'message_type': messageType,
            'body': body.trim(),
          }),
        )
        .timeout(const Duration(seconds: 18));

    dynamic decoded;
    try {
      decoded = jsonDecode(res.body);
    } catch (_) {}

    if (res.statusCode != 201) {
      if (decoded is Map && decoded['message'] is String) {
        throw Exception(decoded['message']);
      }
      throw Exception('Failed to send support message');
    }

    final payload = decoded is Map &&
            decoded['data'] is Map &&
            decoded['data']['message'] is Map
        ? Map<String, dynamic>.from(decoded['data']['message'])
        : null;
    if (payload == null) {
      throw Exception('Invalid support message response');
    }

    return SupportChatMessage.fromJson(payload);
  }

  static Future<void> markSupportConversationRead(int conversationId) async {
    final token = await getToken();
    if (token == null || token.isEmpty) {
      return;
    }

    try {
      await http
          .post(
            Uri.parse('$baseUrl/support/read'),
            headers: {
              'Accept': 'application/json',
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
            body: jsonEncode({'conversation_id': conversationId}),
          )
          .timeout(const Duration(seconds: 12));
    } catch (_) {}
  }

  static Future<int> fetchSupportUnreadCount() async {
    final token = await getToken();
    if (token == null || token.isEmpty) {
      return 0;
    }

    try {
      final res = await http
          .get(
            Uri.parse('$baseUrl/support/unread-count'),
            headers: {
              'Accept': 'application/json',
              'Authorization': 'Bearer $token',
            },
          )
          .timeout(const Duration(seconds: 12));

      if (res.statusCode != 200) {
        return 0;
      }

      final decoded = jsonDecode(res.body);
      if (decoded is Map) {
        final raw = decoded['count'];
        if (raw is int) return raw;
        if (raw is num) return raw.toInt();
        return int.tryParse(raw?.toString() ?? '') ?? 0;
      }
    } catch (_) {}

    return 0;
  }

  static Future<List<Product>> fetchProducts({
    int? categoryId,
    String? categoryName,
    String? status,
    int perPage = 20,
    String? queryText,
  }) async {
    final query = <String, String>{};
    if (status != null && status.isNotEmpty) {
      query['status'] = status;
    }
    if (queryText != null && queryText.trim().isNotEmpty) {
      query['q'] = queryText.trim();
    }
    if (categoryId != null && categoryId > 0) {
      query['category_id'] = categoryId.toString();
    } else if (categoryName != null && categoryName.trim().isNotEmpty) {
      query['category'] = categoryName.trim();
    }
    query['per_page'] = perPage.clamp(1, 100).toString();
    final uri = Uri.parse(
      '$baseUrl/products',
    ).replace(queryParameters: query.isEmpty ? null : query);
    final res = await http.get(
      uri,
      headers: const {'Accept': 'application/json'},
    );

    if (res.statusCode != 200) {
      throw Exception('Failed to load products');
    }

    dynamic decoded;
    try {
      decoded = jsonDecode(res.body);
    } catch (_) {
      return [];
    }

    final rawList = decoded is Map
        ? decoded['data'] ?? decoded['products'] ?? decoded['items']
        : decoded;
    if (rawList is! List) return [];

    final products = rawList
        .whereType<Map>()
        .map((item) => Product.fromJson(Map<String, dynamic>.from(item)))
        .toList();

    if (categoryId == null &&
        (categoryName == null || categoryName.trim().isEmpty)) {
      return products;
    }

    if (categoryId != null && categoryId > 0) {
      return products
          .where((product) => product.categoryId == categoryId)
          .toList();
    }

    final target = categoryName!.trim().toLowerCase();
    return products.where((product) {
      final name = (product.categoryName ?? '').trim().toLowerCase();
      return name == target;
    }).toList();
  }

  // ================= CATEGORIES =================
  static Future<List<Category>> fetchCategories({
    String? status = 'active',
    int perPage = 100,
    String? query,
  }) async {
    final params = <String, String>{
      'per_page': perPage.clamp(1, 100).toString(),
      if (status != null && status.trim().isNotEmpty) 'status': status.trim(),
      if (query != null && query.trim().isNotEmpty) 'q': query.trim(),
    };
    final res = await http.get(
      Uri.parse('$baseUrl/categories').replace(queryParameters: params),
      headers: const {'Accept': 'application/json'},
    );

    if (res.statusCode != 200) {
      throw Exception('Failed to load categories');
    }

    dynamic decoded;
    try {
      decoded = jsonDecode(res.body);
    } catch (_) {
      return [];
    }

    List<dynamic>? rawList;
    if (decoded is List) {
      rawList = decoded;
    } else if (decoded is Map) {
      final direct =
          decoded['data'] ?? decoded['categories'] ?? decoded['items'];
      if (direct is List) {
        rawList = direct;
      } else if (direct is Map) {
        final nested =
            direct['data'] ?? direct['categories'] ?? direct['items'];
        if (nested is List) {
          rawList = nested;
        }
      }
    }
    if (rawList == null) return [];

    return rawList
        .whereType<Map>()
        .map((item) => Category.fromJson(Map<String, dynamic>.from(item)))
        .where((item) => item.name.trim().isNotEmpty)
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
        '[ApiService] banners status=${res.statusCode} body=${res.body}',
      );
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

  // ================= VOUCHER =================
  static Future<VoucherValidation> validateVoucher({
    required String code,
    required double subtotal,
  }) async {
    final trimmed = code.trim();
    if (trimmed.isEmpty) {
      return const VoucherValidation(
        isValid: false,
        message: 'Please enter a promo code.',
      );
    }

    final token = await getToken();
    http.Response? res;
    try {
      final headers = {
        'Accept': 'application/json',
        if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
      };
      final payload = <String, dynamic>{
        'code': trimmed,
        'subtotal': subtotal.toStringAsFixed(2),
      };
      final baseUri = Uri.parse('$baseUrl/vouchers/validate');
      final getUri = baseUri.replace(
        queryParameters: payload.map((key, value) => MapEntry(key, '$value')),
      );

      res = await http
          .get(getUri, headers: headers)
          .timeout(const Duration(seconds: 12));
    } catch (_) {
      return const VoucherValidation(
        isValid: false,
        message: 'Unable to reach the server.',
      );
    }

    dynamic decoded;
    try {
      decoded = jsonDecode(res.body);
    } catch (_) {}

    if (res.statusCode == 401) {
      return const VoucherValidation(
        isValid: false,
        message: 'Please log in to apply a promo code.',
      );
    }

    if (res.statusCode == 404) {
      return const VoucherValidation(
        isValid: false,
        message:
            'Promo code service not found. Check API base URL and backend routes.',
      );
    }

    if (res.statusCode != 200) {
      final message = decoded is Map && decoded['message'] is String
          ? decoded['message']
          : null;
      return VoucherValidation(
        isValid: false,
        message: message ?? 'Promo code is not valid.',
      );
    }

    final data = _extractVoucherData(decoded);
    final bool isValid = _parseVoucherValid(decoded, data);
    if (!isValid) {
      final message = decoded is Map && decoded['message'] is String
          ? decoded['message']
          : null;
      return VoucherValidation(
        isValid: false,
        message: message ?? 'Promo code is not valid.',
      );
    }

    final parsed = VoucherValidation.fromApi(
      data ?? (decoded is Map ? Map<String, dynamic>.from(decoded) : const {}),
      fallbackCode: trimmed,
    );

    if (parsed.minOrder != null && subtotal < parsed.minOrder!) {
      return VoucherValidation(
        isValid: false,
        message:
            'Minimum order is \$${parsed.minOrder!.toStringAsFixed(2)} for this code.',
      );
    }

    return parsed.copyWith(
      message: parsed.message ?? 'Promo code applied successfully.',
    );
  }

  static Map<String, dynamic>? _extractVoucherData(dynamic decoded) {
    if (decoded is Map<String, dynamic>) {
      if (decoded['data'] is Map) {
        return Map<String, dynamic>.from(decoded['data']);
      }
      if (decoded['voucher'] is Map) {
        return Map<String, dynamic>.from(decoded['voucher']);
      }
    }
    if (decoded is Map) {
      return Map<String, dynamic>.from(decoded);
    }
    return null;
  }

  static bool _parseVoucherValid(dynamic decoded, Map<String, dynamic>? data) {
    final rawValid = decoded is Map
        ? decoded['valid'] ?? decoded['success']
        : null;
    if (rawValid is bool) return rawValid;
    if (rawValid is num) return rawValid == 1;
    if (data == null) return false;
    final status = data['status']?.toString().toLowerCase();
    if (status != null) return status == 'active';
    return true;
  }

  // ================= CHECKOUT OPTIONS =================
  static Future<CheckoutOptions> fetchCheckoutOptions() async {
    http.Response? res;
    try {
      res = await http
          .get(
            Uri.parse('$baseUrl/checkout/options'),
            headers: const {'Accept': 'application/json'},
          )
          .timeout(const Duration(seconds: 12));
    } catch (_) {
      return CheckoutOptions.fallback();
    }

    if (res.statusCode != 200) {
      return CheckoutOptions.fallback();
    }

    try {
      final decoded = jsonDecode(res.body);
      if (decoded is Map<String, dynamic>) {
        return CheckoutOptions.fromApi(decoded);
      }
      if (decoded is Map) {
        return CheckoutOptions.fromApi(Map<String, dynamic>.from(decoded));
      }
      return CheckoutOptions.fallback();
    } catch (_) {
      return CheckoutOptions.fallback();
    }
  }

  // ================= ORDERS =================
  static Future<OrderCreateResult> createOrder({
    required String customerName,
    String? customerEmail,
    required List<Map<String, dynamic>> items,
    String orderType = 'pickup',
    String paymentMethod = 'wallet',
    String paymentStatus = 'processing',
    String? deliveryAddress,
    String? deliveryPhone,
    String? deliveryNote,
    double? deliveryLat,
    double? deliveryLng,
    String? voucherCode,
  }) async {
    final token = await getToken();

    if (token == null || token.isEmpty) {
      return const OrderCreateResult(
        errorMessage: 'Please log in to place an order.',
      );
    }

    if (items.isEmpty) {
      return const OrderCreateResult(errorMessage: 'Your cart is empty.');
    }

    final body = <String, dynamic>{
      'customer_name': customerName,
      'customer_email': customerEmail,
      'order_type': orderType,
      'payment_method': paymentMethod,
      'payment_status': paymentStatus,
      'items': items,
    };

    if (deliveryAddress != null && deliveryAddress.isNotEmpty) {
      body['delivery_address'] = deliveryAddress;
    }
    if (deliveryPhone != null && deliveryPhone.isNotEmpty) {
      body['delivery_phone'] = deliveryPhone;
    }
    if (deliveryNote != null && deliveryNote.isNotEmpty) {
      body['delivery_note'] = deliveryNote;
    }
    if (deliveryLat != null) {
      body['delivery_lat'] = deliveryLat;
    }
    if (deliveryLng != null) {
      body['delivery_lng'] = deliveryLng;
    }

    if (voucherCode != null && voucherCode.isNotEmpty) {
      body['voucher_code'] = voucherCode;
    }

    http.Response res;
    try {
      res = await http
          .post(
            Uri.parse('$baseUrl/user/orders'),
            headers: {
              'Accept': 'application/json',
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 18));
    } catch (_) {
      return const OrderCreateResult(
        errorMessage: 'Unable to reach the server. Please try again.',
      );
    }

    if (res.statusCode == 200 || res.statusCode == 201) {
      try {
        final decoded = jsonDecode(res.body);
        final raw = decoded is Map && decoded['data'] is Map
            ? Map<String, dynamic>.from(decoded['data'])
            : (decoded is Map
                  ? Map<String, dynamic>.from(decoded)
                  : <String, dynamic>{});
        return OrderCreateResult(
          orderId: _parseInt(raw['id']),
          orderNumber: raw['order_number']?.toString(),
          totalAmount: _parseDouble(raw['total_amount']),
          orderStatus:
              raw['status']?.toString() ?? raw['order_status']?.toString(),
          deliveryAddress: raw['delivery_address']?.toString(),
          placedAt: _parseDateTime(raw['placed_at'] ?? raw['created_at']),
        );
      } catch (_) {
        return const OrderCreateResult(
          errorMessage: 'Order created, but response was invalid.',
        );
      }
    }

    try {
      final decoded = jsonDecode(res.body);
      if (decoded is Map && decoded['message'] is String) {
        return OrderCreateResult(errorMessage: decoded['message']);
      }
      if (decoded is Map && decoded['errors'] is Map) {
        final firstError = decoded['errors'].values
            .where((value) => value is List && value.isNotEmpty)
            .cast<List>()
            .map((value) => value.first)
            .whereType<String>()
            .toList();
        if (firstError.isNotEmpty) {
          return OrderCreateResult(errorMessage: firstError.first);
        }
      }
    } catch (_) {}

    return const OrderCreateResult(
      errorMessage: 'Unable to create order. Please try again.',
    );
  }

  // ================= KHQR =================
  static Future<KhqrGenerateResult> generateKhqr({
    required int orderId,
    required double amount,
    String currency = 'USD',
  }) async {
    final token = await getToken();
    if (token == null || token.isEmpty) {
      return const KhqrGenerateResult(
        errorMessage: 'Please log in to continue.',
      );
    }

    http.Response res;
    try {
      res = await http
          .post(
            Uri.parse('$baseUrl/generate-qr'),
            headers: {
              'Accept': 'application/json',
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
            body: jsonEncode({
              'order_id': orderId,
              'amount': amount.toStringAsFixed(2),
              'currency': currency,
            }),
          )
          .timeout(const Duration(seconds: 18));
    } catch (_) {
      return const KhqrGenerateResult(
        errorMessage: 'Unable to reach QR service.',
      );
    }

    dynamic decoded;
    try {
      decoded = jsonDecode(res.body);
    } catch (_) {}

    if (res.statusCode != 200) {
      final message = decoded is Map && decoded['message'] is String
          ? decoded['message']
          : null;
      return KhqrGenerateResult(
        errorMessage: message ?? 'Unable to generate QR.',
      );
    }

    if (decoded is! Map) {
      return const KhqrGenerateResult(errorMessage: 'Invalid QR response.');
    }

    final map = Map<String, dynamic>.from(decoded);
    final transactionId =
        map['transaction_id']?.toString() ?? map['md5']?.toString();
    final qrString = map['qr_string']?.toString();
    final status = map['status']?.toString();

    if (transactionId == null ||
        transactionId.isEmpty ||
        qrString == null ||
        qrString.isEmpty) {
      return const KhqrGenerateResult(
        errorMessage: 'QR response missing transaction data.',
      );
    }

    return KhqrGenerateResult(
      transactionId: transactionId,
      qrString: qrString,
      status: status,
      expiresAt: map['expires_at']?.toString(),
    );
  }

  static Future<KhqrCheckResult> checkKhqrTransaction({
    required String transactionId,
  }) async {
    final token = await getToken();
    if (token == null || token.isEmpty) {
      return const KhqrCheckResult(
        status: 'INVALID_TRANSACTION',
        message: 'Please log in to continue.',
      );
    }

    http.Response res;
    try {
      res = await http
          .post(
            Uri.parse('$baseUrl/check-transaction'),
            headers: {
              'Accept': 'application/json',
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
            body: jsonEncode({'md5': transactionId}),
          )
          .timeout(const Duration(seconds: 18));
    } catch (_) {
      return const KhqrCheckResult(
        status: 'PENDING',
        message: 'Unable to reach transaction checker.',
      );
    }
    debugPrint('[KHQR][RAW] ${res.body}');

    dynamic decoded;
    try {
      decoded = jsonDecode(res.body);
    } catch (_) {}

    if (decoded is! Map) {
      return const KhqrCheckResult(
        status: 'PENDING',
        message: 'Invalid status response.',
      );
    }

    final map = Map<String, dynamic>.from(decoded);
    final success = map['success'];
    final rawStatus = map['status']?.toString();
    final message = map['message']?.toString();
    final data = map['data'];

    String status;
    if (success is bool) {
      status = success ? 'SUCCESS' : 'PENDING';
      if (!success &&
          message != null &&
          message.toLowerCase().contains('expired')) {
        status = 'EXPIRED';
      }
    } else if (rawStatus != null && rawStatus.isNotEmpty) {
      status = rawStatus;
    } else if (res.statusCode >= 400) {
      status = 'PENDING';
    } else {
      status = 'PENDING';
    }

    final normalized = status.toUpperCase();
    if (normalized == 'TIMEOUT') {
      status = 'EXPIRED';
    } else if (normalized == 'NOT_FOUND') {
      status = 'PENDING';
    }

    double? amount;
    String? currency;
    String? fromAccountId;
    String? toAccountId;
    String? paidAtIso;
    String? bakongHash;
    if (data is Map) {
      final dataMap = Map<String, dynamic>.from(data);
      final rawAmount = dataMap['amount'];
      if (rawAmount is num) {
        amount = rawAmount.toDouble();
      } else if (rawAmount != null) {
        amount = double.tryParse(rawAmount.toString());
      }
      currency = dataMap['currency']?.toString();
      fromAccountId = dataMap['fromAccountId']?.toString();
      toAccountId = dataMap['toAccountId']?.toString();
      paidAtIso = dataMap['paid_at']?.toString();
      bakongHash =
          dataMap['bakongHash']?.toString() ??
          dataMap['transaction_id']?.toString();
    }

    return KhqrCheckResult(
      status: status,
      message: message,
      amount: amount,
      currency: currency,
      fromAccountId: fromAccountId,
      toAccountId: toAccountId,
      paidAtIso: paidAtIso,
      bakongHash: bakongHash,
    );
  }

  static String _buildNetworkErrorMessage() {
    final currentBase = baseUrl;
    if (defaultTargetPlatform == TargetPlatform.android &&
        currentBase.contains('10.0.2.2')) {
      return 'Cannot reach the server. If you are on a real device, set '
          'API_BASE_URL to your computer IP (example: http://192.168.1.10:8000/api) '
          'or use adb reverse to expose your local server.';
    }
    return 'Cannot reach the server at $currentBase. Please check your '
        'connection, server URL, or switch the app server in login settings.';
  }

  static Future<List<PickupTicket>> fetchPickupTickets() async {
    final token = await getToken();
    if (token == null || token.isEmpty) {
      return [];
    }

    http.Response res;
    try {
      res = await http
          .get(
            Uri.parse('$baseUrl/user/tickets'),
            headers: {
              'Accept': 'application/json',
              'Authorization': 'Bearer $token',
            },
          )
          .timeout(const Duration(seconds: 18));
    } catch (_) {
      return [];
    }

    if (res.statusCode != 200) {
      return [];
    }

    dynamic decoded;
    try {
      decoded = jsonDecode(res.body);
    } catch (_) {
      return [];
    }

    final rawList = decoded is Map ? decoded['data'] : decoded;
    if (rawList is! List) return [];

    return rawList
        .whereType<Map>()
        .map((item) => PickupTicket.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }

  static Future<List<PickupTicket>> fetchUserOrders({String? orderType}) async {
    final token = await getToken();
    if (token == null || token.isEmpty) {
      return [];
    }

    final uri = Uri.parse('$baseUrl/user/orders').replace(
      queryParameters: {
        if (orderType != null && orderType.trim().isNotEmpty)
          'order_type': orderType.trim(),
      },
    );

    http.Response res;
    try {
      res = await http
          .get(
            uri,
            headers: {
              'Accept': 'application/json',
              'Authorization': 'Bearer $token',
            },
          )
          .timeout(const Duration(seconds: 18));
    } catch (_) {
      return [];
    }

    if (res.statusCode != 200) {
      return [];
    }

    dynamic decoded;
    try {
      decoded = jsonDecode(res.body);
    } catch (_) {
      return [];
    }

    final rawList = decoded is Map ? decoded['data'] : decoded;
    if (rawList is! List) return [];

    return rawList
        .whereType<Map>()
        .map((item) => PickupTicket.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }

  static Future<PickupTicket?> fetchUserOrder({
    int? orderId,
    String? orderNumber,
  }) async {
    final token = await getToken();
    if (token == null || token.isEmpty || orderId == null) {
      return null;
    }

    http.Response res;
    try {
      res = await http
          .get(
            Uri.parse('$baseUrl/user/orders/$orderId'),
            headers: {
              'Accept': 'application/json',
              'Authorization': 'Bearer $token',
            },
          )
          .timeout(const Duration(seconds: 18));
    } catch (_) {
      return null;
    }

    if (res.statusCode != 200) {
      return null;
    }

    try {
      final decoded = jsonDecode(res.body);
      final raw = decoded is Map ? decoded['data'] : decoded;
      if (raw is Map<String, dynamic>) {
        final order = PickupTicket.fromJson(raw);
        if (orderNumber != null &&
            orderNumber.trim().isNotEmpty &&
            order.orderNumber != orderNumber.trim()) {
          return null;
        }
        return order;
      }
    } catch (_) {}

    return null;
  }

  static Future<List<OrderTrackingNotificationItem>>
  fetchOrderTrackingNotifications() async {
    final token = await getToken();
    if (token == null || token.isEmpty) {
      return [];
    }

    http.Response res;
    try {
      res = await http
          .get(
            Uri.parse('$baseUrl/order-notifications'),
            headers: {
              'Accept': 'application/json',
              'Authorization': 'Bearer $token',
            },
          )
          .timeout(const Duration(seconds: 18));
    } catch (_) {
      return [];
    }

    if (res.statusCode != 200) {
      return [];
    }

    try {
      final decoded = jsonDecode(res.body);
      final rawList = decoded is Map ? decoded['data'] : decoded;
      if (rawList is! List) return [];
      return rawList
          .whereType<Map>()
          .map(
            (item) => OrderTrackingNotificationItem.fromJson(
              Map<String, dynamic>.from(item),
            ),
          )
          .toList();
    } catch (_) {
      return [];
    }
  }

  static Future<void> markOrderTrackingNotificationRead(
    int notificationId,
  ) async {
    final token = await getToken();
    if (token == null || token.isEmpty) {
      return;
    }

    try {
      await http
          .post(
            Uri.parse('$baseUrl/order-notifications/$notificationId/read'),
            headers: {
              'Accept': 'application/json',
              'Authorization': 'Bearer $token',
            },
          )
          .timeout(const Duration(seconds: 12));
    } catch (_) {}
  }

  static Future<void> registerMobileDeviceToken({
    required String token,
    required String platform,
  }) async {
    final authToken = await getToken();
    if (authToken == null || authToken.isEmpty || token.trim().isEmpty) {
      return;
    }

    try {
      await http
          .post(
            Uri.parse('$baseUrl/mobile-devices/token'),
            headers: {
              'Accept': 'application/json',
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $authToken',
            },
            body: jsonEncode({
              'token': token.trim(),
              'platform': platform.trim(),
            }),
          )
          .timeout(const Duration(seconds: 12));
    } catch (error) {
      debugPrint('Register mobile device token failed: $error');
    }
  }

  static Future<void> unregisterMobileDeviceToken(String token) async {
    final authToken = await getToken();
    if (authToken == null || authToken.isEmpty || token.trim().isEmpty) {
      return;
    }

    try {
      await http
          .post(
            Uri.parse('$baseUrl/mobile-devices/token/remove'),
            headers: {
              'Accept': 'application/json',
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $authToken',
            },
            body: jsonEncode({'token': token.trim()}),
          )
          .timeout(const Duration(seconds: 12));
    } catch (error) {
      debugPrint('Unregister mobile device token failed: $error');
    }
  }
}

class OrderCreateResult {
  const OrderCreateResult({
    this.orderId,
    this.orderNumber,
    this.totalAmount,
    this.orderStatus,
    this.deliveryAddress,
    this.placedAt,
    this.errorMessage,
  });

  final int? orderId;
  final String? orderNumber;
  final double? totalAmount;
  final String? orderStatus;
  final String? deliveryAddress;
  final DateTime? placedAt;
  final String? errorMessage;

  bool get isSuccess => errorMessage == null;
}

class VoucherValidation {
  const VoucherValidation({
    required this.isValid,
    this.code,
    this.discountType,
    this.discountValue,
    this.percent,
    this.maxDiscount,
    this.minOrder,
    this.message,
  });

  final bool isValid;
  final String? code;
  final String? discountType;
  final double? discountValue;
  final double? percent;
  final double? maxDiscount;
  final double? minOrder;
  final String? message;

  VoucherValidation copyWith({
    bool? isValid,
    String? code,
    String? discountType,
    double? discountValue,
    double? percent,
    double? maxDiscount,
    double? minOrder,
    String? message,
  }) {
    return VoucherValidation(
      isValid: isValid ?? this.isValid,
      code: code ?? this.code,
      discountType: discountType ?? this.discountType,
      discountValue: discountValue ?? this.discountValue,
      percent: percent ?? this.percent,
      maxDiscount: maxDiscount ?? this.maxDiscount,
      minOrder: minOrder ?? this.minOrder,
      message: message ?? this.message,
    );
  }

  double discountFor(double subtotal) {
    if (!isValid) return 0;
    double amount;
    if ((discountType ?? '').toLowerCase().contains('percent') ||
        percent != null) {
      final pct = percent ?? 0;
      amount = subtotal * pct / 100;
    } else {
      amount = discountValue ?? 0;
    }
    if (maxDiscount != null && amount > maxDiscount!) {
      amount = maxDiscount!;
    }
    if (amount.isNaN || amount.isInfinite || amount < 0) return 0;
    return amount;
  }

  static VoucherValidation fromApi(
    Map<String, dynamic> data, {
    String? fallbackCode,
  }) {
    final type =
        data['discount_type'] ??
        data['type'] ??
        data['discountType'] ??
        data['discount_type_id'];
    final rawCode = data['code'] ?? data['voucher_code'] ?? data['promo_code'];
    final rawValue =
        data['discount'] ??
        data['discount_value'] ??
        data['value'] ??
        data['amount'];
    final rawPercent =
        data['percent'] ??
        data['percentage'] ??
        data['discount_percent'] ??
        data['discount_percentage'];
    final rawMax =
        data['max_discount'] ??
        data['max'] ??
        data['max_value'] ??
        data['maximum_discount'];
    final rawMin =
        data['min_order'] ??
        data['min'] ??
        data['minimum_order'] ??
        data['min_order_value'] ??
        data['min_order_amount'];

    final parsedPercent = _parsePercent(rawPercent ?? rawValue, type);
    final parsedValue = parsedPercent != null
        ? null
        : _parseDoubleValue(rawValue);

    return VoucherValidation(
      isValid: true,
      code: rawCode?.toString() ?? fallbackCode,
      discountType: type?.toString(),
      discountValue: parsedValue,
      percent: parsedPercent,
      maxDiscount: _parseDoubleValue(rawMax),
      minOrder: _parseDoubleValue(rawMin),
      message: data['message']?.toString(),
    );
  }

  static double? _parseDoubleValue(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    if (value is String) {
      final cleaned = value.replaceAll('%', '').trim();
      return double.tryParse(cleaned);
    }
    return double.tryParse(value.toString());
  }

  static double? _parsePercent(dynamic value, dynamic type) {
    final typeText = type?.toString().toLowerCase() ?? '';
    if (typeText.contains('percent')) {
      return _parseDoubleValue(value);
    }
    if (value is String && value.contains('%')) {
      return _parseDoubleValue(value);
    }
    return null;
  }
}

class CheckoutOptions {
  const CheckoutOptions({
    required this.deliveryFee,
    required this.taxRate,
    required this.paymentMethods,
    required this.deliverySlots,
  });

  final double deliveryFee;
  final double taxRate;
  final List<CheckoutPaymentMethod> paymentMethods;
  final List<CheckoutDeliverySlot> deliverySlots;

  factory CheckoutOptions.fromApi(Map<String, dynamic> map) {
    final data = map['data'] is Map<String, dynamic>
        ? Map<String, dynamic>.from(map['data'])
        : map;

    final rawPayments = data['payment_methods'];
    final paymentMethods = rawPayments is List
        ? rawPayments
              .whereType<Map>()
              .map(
                (item) => CheckoutPaymentMethod.fromApi(
                  Map<String, dynamic>.from(item),
                ),
              )
              .toList()
        : <CheckoutPaymentMethod>[];

    final rawSlots = data['delivery_slots'];
    final deliverySlots = rawSlots is List
        ? rawSlots
              .whereType<Map>()
              .map(
                (item) => CheckoutDeliverySlot.fromApi(
                  Map<String, dynamic>.from(item),
                ),
              )
              .toList()
        : <CheckoutDeliverySlot>[];

    return CheckoutOptions(
      deliveryFee: _toDouble(data['delivery_fee']) ?? 5.0,
      taxRate: _toDouble(data['tax_rate']) ?? 0.0,
      paymentMethods: paymentMethods.isEmpty
          ? CheckoutPaymentMethod.fallbackList()
          : paymentMethods,
      deliverySlots: deliverySlots.isEmpty
          ? CheckoutDeliverySlot.fallbackList()
          : deliverySlots,
    );
  }

  factory CheckoutOptions.fallback() {
    return CheckoutOptions(
      deliveryFee: 5.0,
      taxRate: 0.0,
      paymentMethods: CheckoutPaymentMethod.fallbackList(),
      deliverySlots: CheckoutDeliverySlot.fallbackList(),
    );
  }

  static double? _toDouble(dynamic value) {
    if (value is double) return value;
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '');
  }
}

class CheckoutPaymentMethod {
  const CheckoutPaymentMethod({
    required this.code,
    required this.label,
    required this.description,
  });

  final String code;
  final String label;
  final String description;

  factory CheckoutPaymentMethod.fromApi(Map<String, dynamic> map) {
    final code = map['code']?.toString().trim();
    final label = map['label']?.toString().trim();
    final description = map['description']?.toString().trim();

    return CheckoutPaymentMethod(
      code: (code == null || code.isEmpty) ? 'cash' : code,
      label: (label == null || label.isEmpty) ? 'Cash on Delivery' : label,
      description: description ?? '',
    );
  }

  static List<CheckoutPaymentMethod> fallbackList() {
    return const [
      CheckoutPaymentMethod(
        code: 'aba',
        label: 'ABA Pay',
        description: 'Fast payment with ABA mobile app',
      ),
      CheckoutPaymentMethod(
        code: 'cash',
        label: 'Cash on Delivery',
        description: 'Pay in cash when your order arrives',
      ),
      CheckoutPaymentMethod(
        code: 'card',
        label: 'Card Payment',
        description: 'Visa / MasterCard',
      ),
    ];
  }
}

class CheckoutDeliverySlot {
  const CheckoutDeliverySlot({
    required this.code,
    required this.label,
    required this.description,
  });

  final String code;
  final String label;
  final String description;

  factory CheckoutDeliverySlot.fromApi(Map<String, dynamic> map) {
    final code = map['code']?.toString().trim();
    final label = map['label']?.toString().trim();
    final description = map['description']?.toString().trim();

    return CheckoutDeliverySlot(
      code: (code == null || code.isEmpty) ? 'slot_morning' : code,
      label: (label == null || label.isEmpty)
          ? 'Today, 9:00 AM - 5:00 PM'
          : label,
      description: description ?? '',
    );
  }

  static List<CheckoutDeliverySlot> fallbackList() {
    return const [
      CheckoutDeliverySlot(
        code: 'slot_0900_1700',
        label: 'Today, 9:00 AM - 5:00 PM',
        description: 'Available',
      ),
      CheckoutDeliverySlot(
        code: 'slot_1800_2100',
        label: 'Today, 6:00 PM - 9:00 PM',
        description: 'Limited',
      ),
      CheckoutDeliverySlot(
        code: 'slot_tomorrow',
        label: 'Tomorrow, 10:00 AM - 2:00 PM',
        description: 'Available',
      ),
    ];
  }
}

class KhqrGenerateResult {
  const KhqrGenerateResult({
    this.transactionId,
    this.qrString,
    this.status,
    this.expiresAt,
    this.errorMessage,
  });

  final String? transactionId;
  final String? qrString;
  final String? status;
  final String? expiresAt;
  final String? errorMessage;

  bool get isSuccess =>
      errorMessage == null &&
      transactionId != null &&
      transactionId!.isNotEmpty &&
      qrString != null &&
      qrString!.isNotEmpty;
}

class KhqrCheckResult {
  const KhqrCheckResult({
    required this.status,
    this.message,
    this.amount,
    this.currency,
    this.fromAccountId,
    this.toAccountId,
    this.paidAtIso,
    this.bakongHash,
  });

  final String status;
  final String? message;
  final double? amount;
  final String? currency;
  final String? fromAccountId;
  final String? toAccountId;
  final String? paidAtIso;
  final String? bakongHash;

  bool get isSuccess => status.toUpperCase() == 'SUCCESS';
}

class OtpRequestResult {
  const OtpRequestResult({
    required this.ok,
    required this.message,
    this.expiresInSec,
    this.resendInSec,
  });

  final bool ok;
  final String message;
  final int? expiresInSec;
  final int? resendInSec;
}

class OtpVerifyResult {
  const OtpVerifyResult({
    required this.ok,
    required this.message,
    this.token,
    this.resetToken,
  });

  final bool ok;
  final String message;
  final String? token;
  final String? resetToken;
}
