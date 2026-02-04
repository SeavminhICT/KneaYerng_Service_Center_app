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
    final payload = jsonEncode({
      'code': trimmed,
      'subtotal': subtotal,
    });
    http.Response? res;
    try {
      final uri = Uri.parse('$baseUrl/vouchers/validate')
          .replace(queryParameters: {
        'code': trimmed,
        'subtotal': subtotal.toStringAsFixed(2),
      });
      res = await http.get(
        uri,
        headers: {
          'Accept': 'application/json',
          if (token != null && token.isNotEmpty)
            'Authorization': 'Bearer $token',
        },
      );
      if (res.statusCode == 404 || res.statusCode == 405) {
        res = await http
            .post(
              Uri.parse('$baseUrl/vouchers/validate'),
              headers: {
                'Accept': 'application/json',
                'Content-Type': 'application/json',
                if (token != null && token.isNotEmpty)
                  'Authorization': 'Bearer $token',
              },
              body: payload,
            )
            .timeout(const Duration(seconds: 12));
      }
    } catch (_) {
      return const VoucherValidation(
        isValid: false,
        message: 'Unable to reach the server.',
      );
    }

    if (res == null) {
      return const VoucherValidation(
        isValid: false,
        message: 'Unable to validate the promo code.',
      );
    }

    dynamic decoded;
    try {
      decoded = jsonDecode(res.body);
    } catch (_) {}

    if (res.statusCode != 200) {
      final message =
          decoded is Map && decoded['message'] is String ? decoded['message'] : null;
      return VoucherValidation(
        isValid: false,
        message: message ?? 'Promo code is not valid.',
      );
    }

    final data = _extractVoucherData(decoded);
    final bool isValid = _parseVoucherValid(decoded, data);
    if (!isValid) {
      final message =
          decoded is Map && decoded['message'] is String ? decoded['message'] : null;
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

  static bool _parseVoucherValid(
    dynamic decoded,
    Map<String, dynamic>? data,
  ) {
    final rawValid = decoded is Map ? decoded['valid'] ?? decoded['success'] : null;
    if (rawValid is bool) return rawValid;
    if (rawValid is num) return rawValid == 1;
    if (data == null) return false;
    final status = data?['status']?.toString().toLowerCase();
    if (status != null) return status == 'active';
    return true;
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
      return const OrderCreateResult(
        errorMessage: 'Your cart is empty.',
      );
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
            : (decoded is Map ? Map<String, dynamic>.from(decoded) : <String, dynamic>{});
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
    final type = data['discount_type'] ??
        data['type'] ??
        data['discountType'] ??
        data['discount_type_id'];
    final rawCode = data['code'] ?? data['voucher_code'] ?? data['promo_code'];
    final rawValue = data['discount'] ??
        data['discount_value'] ??
        data['value'] ??
        data['amount'];
    final rawPercent = data['percent'] ??
        data['percentage'] ??
        data['discount_percent'] ??
        data['discount_percentage'];
    final rawMax = data['max_discount'] ??
        data['max'] ??
        data['max_value'] ??
        data['maximum_discount'];
    final rawMin = data['min_order'] ??
        data['min'] ??
        data['minimum_order'] ??
        data['min_order_value'];

    final parsedPercent = _parsePercent(rawPercent ?? rawValue, type);
    final parsedValue =
        parsedPercent != null ? null : _parseDoubleValue(rawValue);

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
