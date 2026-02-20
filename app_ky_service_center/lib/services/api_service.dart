import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart'
    show kIsWeb, defaultTargetPlatform, TargetPlatform, debugPrint;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/product.dart';
import '../models/category.dart';
import '../models/banner_item.dart';
import '../models/user_profile.dart';

class ApiService {
  static const String _baseUrlOverride = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: '',
  );
  static const String _localApi = 'http://127.0.0.1:8000/api';
  static const String _androidEmulatorApi = 'http://10.0.2.2:8000/api';

  static String get baseUrl {
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
      return _localApi;
    }

    if (defaultTargetPlatform == TargetPlatform.android) {
      return _androidEmulatorApi;
    }

    return _localApi;
  }

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
    required String email,
    required String password,
  }) async {
    final res = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: const {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'email': email, 'password': password}),
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
    if (value is! String || value.trim().isEmpty) return null;
    final normalized = _trimTrailingSlashFromFilePath(value.trim());
    if (normalized.startsWith('http://') || normalized.startsWith('https://')) {
      try {
        final uri = Uri.parse(normalized);
        final host = uri.host.toLowerCase();
        if (host == 'localhost' || host == '127.0.0.1' || host == '10.0.2.2') {
          final baseRoot = baseUrl.replaceFirst('/api', '');
          final baseUri = Uri.parse(baseRoot);
          final rebased = uri.replace(
            scheme: baseUri.scheme,
            host: baseUri.host,
            port: baseUri.hasPort ? baseUri.port : null,
          );
          return _trimTrailingSlashFromFilePath(rebased.toString());
        }
      } catch (_) {}
      return _trimTrailingSlashFromFilePath(normalized);
    }
    final baseRoot = baseUrl.replaceFirst('/api', '');
    var clean = normalized.replaceAll('\\', '/');
    if (clean.startsWith('/')) {
      clean = clean.substring(1);
    }
    if (clean.startsWith('storage/')) {
      return _trimTrailingSlashFromFilePath('$baseRoot/$clean');
    }
    if (clean.startsWith('public/storage/')) {
      clean = clean.replaceFirst('public/', '');
      return _trimTrailingSlashFromFilePath('$baseRoot/$clean');
    }
    return _trimTrailingSlashFromFilePath('$baseRoot/$clean');
  }

  static String _trimTrailingSlashFromFilePath(String input) {
    var value = input;
    while (value.endsWith('/')) {
      value = value.substring(0, value.length - 1);
    }
    if (value.isEmpty) return input;
    return value;
  }

  static String _normalizeBaseUrl(String raw) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) return trimmed;
    final uri = Uri.parse(trimmed);
    final segments = uri.pathSegments
        .where((segment) => segment.isNotEmpty)
        .toList();
    if (!segments.contains('api')) {
      segments.add('api');
    }
    return uri.replace(path: '/${segments.join('/')}').toString();
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
      request.files.add(
        await http.MultipartFile.fromPath('avatar', avatarPath),
      );
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
        .where(
          (product) => (product.categoryName ?? '').toLowerCase() == target,
        )
        .toList();
  }

  // ================= CATEGORIES =================
  static Future<List<Category>> fetchCategories() async {
    final res = await http.get(
      Uri.parse('$baseUrl/categories'),
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
    String? requestTransactionId,
    String? requestQrString,
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
              if (requestTransactionId != null &&
                  requestTransactionId.trim().isNotEmpty)
                'transaction_id': requestTransactionId.trim(),
              if (requestQrString != null && requestQrString.trim().isNotEmpty)
                'qr_string': requestQrString.trim(),
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
    final transactionId = map['transaction_id']?.toString();
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
      bakongHash = dataMap['bakongHash']?.toString() ??
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
}

class OrderCreateResult {
  const OrderCreateResult({
    this.orderId,
    this.orderNumber,
    this.totalAmount,
    this.errorMessage,
  });

  final int? orderId;
  final String? orderNumber;
  final double? totalAmount;
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
