# ឯកសារផែនការអនុវត្ន / Implementation Plan
# KneaYerng Service Center - Action Plan & Solutions

**ថ្ងៃកាលបរិច្ឆេទ / Date:** June 19, 2026  
**ស្ថាប័ន / Team:** Development Team

---

## I. ការដោះស្រាយបញ្ហាលម្អិត / Detailed Issue Resolution

### Issue #1: Git Line Ending Configuration ⚠️ CRITICAL

**ផលវិបាក / Impact:** Medium  
**ពេលវេលាដោះស្រាយ / Estimated Time:** 30 minutes

#### Steps to Fix:

```bash
# Step 1: Create .gitattributes for Flutter app
cd app_ky_service_center
cat > .gitattributes << 'EOF'
* text=auto eol=lf
*.dart diff=dart
*.yaml diff=yaml
*.lock text eol=lf
*.json text eol=lf
EOF

# Step 2: Reset repository
git rm --cached -r .
git reset --hard

# Step 3: Add and commit
git add .gitattributes
git add -A
git commit -m "fix: add git attributes for consistent line endings"

# Step 4: Verify
git diff --cached
```

#### Verification:
```bash
# Check if warnings are gone
git status
# Should show no CRLF warnings
```

---

### Issue #2: Firebase Credentials Missing ⚠️ CRITICAL

**ផលវិបាក / Impact:** High - All Firebase features broken  
**ពេលវេលាដោះស្រាយ / Estimated Time:** 1 hour

#### iOS Setup:

```bash
# Step 1: Get GoogleService-Info.plist from Firebase Console
# https://console.firebase.google.com/
# Project Settings -> Download GoogleService-Info.plist

# Step 2: Copy to iOS project
cp GoogleService-Info.plist \
  app_ky_service_center/ios/Runner/GoogleService-Info.plist

# Step 3: Update iOS build settings
cd app_ky_service_center/ios
pod deintegrate
pod install

# Step 4: Rebuild
cd ..
flutter clean
flutter pub get
flutter build ios
```

#### Android Setup:

```bash
# Step 1: Get google-services.json from Firebase Console
# Project Settings -> Download google-services.json

# Step 2: Copy to Android project
cp google-services.json \
  app_ky_service_center/android/app/google-services.json

# Step 3: Verify android/build.gradle has Firebase plugin
# Should contain:
# classpath 'com.google.gms:google-services:4.3.15'

# Step 4: Rebuild
flutter clean
flutter pub get
flutter build apk
```

#### Verification:

```dart
// Test in main.dart or create test file
void testFirebaseInit() async {
  try {
    await Firebase.initializeApp();
    print('Firebase initialized successfully');
  } catch (e) {
    print('Firebase init error: $e');
  }
}
```

---

### Issue #3: Large Component Refactoring 🟡 HIGH

**ផលវិបាក / Impact:** High - Maintainability  
**ពេលវេលាដោះស្រាយ / Estimated Time:** 1-2 weeks

#### Cart Screen Refactoring Example:

**Original Structure:**
```
cart_screen.dart (1441 lines) - Too large
```

**New Structure:**
```
screens/cart/
├── cart_screen.dart (main, 200 lines)
├── widgets/
│   ├── cart_items_list.dart (300 lines)
│   ├── cart_item_card.dart (150 lines)
│   ├── cart_summary.dart (200 lines)
│   ├── discount_section.dart (100 lines)
│   └── checkout_button.dart (100 lines)
└── services/
    └── cart_calculation_service.dart
```

#### Implementation Steps:

```dart
// Step 1: Create cart_items_list.dart
class CartItemsList extends StatelessWidget {
  final List<CartItem> items;
  final Function(CartItem) onRemove;
  final Function(CartItem, int) onQuantityChange;

  const CartItemsList({
    required this.items,
    required this.onRemove,
    required this.onQuantityChange,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (context, index) {
        return CartItemCard(
          item: items[index],
          onRemove: () => onRemove(items[index]),
          onQuantityChange: (qty) => 
            onQuantityChange(items[index], qty),
        );
      },
    );
  }
}

// Step 2: Create cart_summary.dart
class CartSummary extends StatelessWidget {
  final List<CartItem> items;
  final double discount;

  const CartSummary({
    required this.items,
    this.discount = 0,
  });

  @override
  Widget build(BuildContext context) {
    final subtotal = items.fold(0.0, 
      (sum, item) => sum + (item.price * item.quantity));
    final tax = subtotal * 0.05;
    final total = subtotal + tax - discount;

    return Column(
      children: [
        _buildSummaryRow('Subtotal', subtotal),
        _buildSummaryRow('Tax', tax),
        if (discount > 0)
          _buildSummaryRow('Discount', -discount),
        Divider(),
        _buildSummaryRow('Total', total, isBold: true),
      ],
    );
  }

  Widget _buildSummaryRow(String label, double amount, 
    {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(
          fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
        )),
        Text('\$${amount.toStringAsFixed(2)}', style: TextStyle(
          fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
        )),
      ],
    );
  }
}

// Step 3: Update cart_screen.dart
class CartScreen extends StatefulWidget {
  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  late CartService _cartService;

  @override
  void initState() {
    super.initState();
    _cartService = CartService();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Shopping Cart')),
      body: Column(
        children: [
          Expanded(
            child: CartItemsList(
              items: _cartService.items,
              onRemove: (item) => 
                setState(() => _cartService.removeItem(item)),
              onQuantityChange: (item, qty) => 
                setState(() => _cartService.updateQuantity(item, qty)),
            ),
          ),
          CartSummary(items: _cartService.items),
          CheckoutButton(
            onPressed: () => _handleCheckout(),
          ),
        ],
      ),
    );
  }

  void _handleCheckout() {
    // Navigation logic
  }
}
```

#### Testing the Refactored Code:

```dart
// cart_items_list_test.dart
void main() {
  group('CartItemsList', () {
    testWidgets('displays cart items', (WidgetTester tester) async {
      final items = [
        CartItem(id: '1', name: 'Item 1', price: 10, quantity: 1),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: CartItemsList(
            items: items,
            onRemove: (_) {},
            onQuantityChange: (_, __) {},
          ),
        ),
      );

      expect(find.text('Item 1'), findsOneWidget);
    });
  });
}
```

---

### Issue #4: OTP Service Verification 🟡 HIGH

**ផលវិបាក / Impact:** High - User Registration  
**ពេលវេលាដោះស្រាយ / Estimated Time:** 2 hours

#### Testing Checklist:

```bash
# 1. Test OTP Generation
php artisan tinker
> \App\Models\Otp::create(['phone' => '85512345678', 'code' => '123456'])

# 2. Test OTP Verification
> \App\Services\OtpService::verify('85512345678', '123456')

# 3. Test Rate Limiting
# Send 5 OTPs in quick succession - should fail on 5th

# 4. Test Expiration
# Create OTP, wait 6 minutes, verify - should fail

# 5. Test SMS Delivery (Infobip)
# Verify SMS was sent to phone number
```

#### Backend Test Code:

```php
// tests/Feature/OtpServiceTest.php
namespace Tests\Feature;

use Tests\TestCase;
use App\Services\OtpService;
use App\Models\Otp;

class OtpServiceTest extends TestCase
{
    public function test_otp_generation()
    {
        $phone = '85512345678';
        $otp = OtpService::generate($phone);
        
        $this->assertNotNull($otp);
        $this->assertDatabaseHas('otps', [
            'phone' => $phone,
            'code' => $otp,
        ]);
    }

    public function test_otp_verification()
    {
        $phone = '85512345678';
        $code = OtpService::generate($phone);
        
        $isValid = OtpService::verify($phone, $code);
        
        $this->assertTrue($isValid);
    }

    public function test_otp_expiration()
    {
        $phone = '85512345678';
        $code = OtpService::generate($phone);
        
        // Move time forward 6 minutes
        $this->travel(6)->minutes();
        
        $isValid = OtpService::verify($phone, $code);
        
        $this->assertFalse($isValid);
    }

    public function test_rate_limiting()
    {
        $phone = '85512345678';
        
        // Generate first OTP - should succeed
        $first = OtpService::generate($phone);
        $this->assertNotNull($first);
        
        // Try to generate second immediately - should fail
        $second = OtpService::generate($phone);
        $this->assertNull($second);
    }
}
```

---

### Issue #5: API Error Handling 🟡 HIGH

**ផលវិបាក / Impact:** High - System Reliability  
**ពេលវេលាដោះស្រាយ / Estimated Time:** 3 hours

#### Improved API Service:

```dart
// lib/services/api_service.dart
import 'package:http/http.dart' as http;

class ApiService {
  static const int _timeoutSeconds = 30;
  static const int _maxRetries = 3;
  
  static late String baseUrl;
  static late http.Client _client;
  static VoidCallback? onUnauthorized;
  
  static Future<void> initialize() async {
    baseUrl = 'https://api.example.com';
    _client = http.Client();
  }

  static Future<dynamic> get(String endpoint) async {
    return _makeRequest(
      () => _client.get(
        Uri.parse('$baseUrl$endpoint'),
        headers: _buildHeaders(),
      ),
    );
  }

  static Future<dynamic> post(
    String endpoint,
    Map<String, dynamic> body,
  ) async {
    return _makeRequest(
      () => _client.post(
        Uri.parse('$baseUrl$endpoint'),
        headers: _buildHeaders(),
        body: jsonEncode(body),
      ),
    );
  }

  static Future<dynamic> _makeRequest(
    Future<http.Response> Function() request,
  ) async {
    int attempt = 0;
    
    while (attempt < _maxRetries) {
      try {
        final response = await request().timeout(
          Duration(seconds: _timeoutSeconds),
          onTimeout: () => throw TimeoutException('API timeout'),
        );

        return _handleResponse(response);
      } catch (e) {
        attempt++;
        
        if (attempt >= _maxRetries) {
          rethrow;
        }
        
        // Exponential backoff: 1s, 2s, 4s
        await Future.delayed(Duration(seconds: 1 << (attempt - 1)));
      }
    }
  }

  static dynamic _handleResponse(http.Response response) {
    switch (response.statusCode) {
      case 200:
      case 201:
        return jsonDecode(response.body);
        
      case 400:
        throw BadRequestException(
          jsonDecode(response.body)['message'] ?? 'Bad request',
        );
        
      case 401:
        onUnauthorized?.call();
        throw UnauthorizedException('Unauthorized');
        
      case 404:
        throw NotFoundException('Resource not found');
        
      case 500:
        throw ServerException('Internal server error');
        
      default:
        throw Exception('HTTP ${response.statusCode}');
    }
  }

  static Map<String, String> _buildHeaders() {
    final token = _getToken(); // Get from SharedPreferences
    
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  static String? _getToken() {
    // Implementation to retrieve token
    return null;
  }
}
```

#### Custom Exceptions:

```dart
// lib/exceptions/api_exceptions.dart
class ApiException implements Exception {
  final String message;
  
  ApiException(this.message);

  @override
  String toString() => message;
}

class BadRequestException extends ApiException {
  BadRequestException(String message) : super(message);
}

class UnauthorizedException extends ApiException {
  UnauthorizedException(String message) : super(message);
}

class NotFoundException extends ApiException {
  NotFoundException(String message) : super(message);
}

class ServerException extends ApiException {
  ServerException(String message) : super(message);
}

class TimeoutException extends ApiException {
  TimeoutException(String message) : super(message);
}
```

---

## II. Testing Implementation Guide

### Unit Tests

```bash
# Run all tests
flutter test

# Run specific test file
flutter test test/services/cart_service_test.dart

# Run with coverage
flutter test --coverage
```

#### Example Service Test:

```dart
// test/services/cart_service_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:app_ky_service_center/services/cart_service.dart';

void main() {
  group('CartService', () {
    late CartService cartService;

    setUp(() {
      cartService = CartService();
    });

    test('should add item to cart', () {
      final item = CartItem(
        id: '1',
        name: 'Test Item',
        price: 10.0,
        quantity: 1,
      );

      cartService.addItem(item);

      expect(cartService.items.length, equals(1));
      expect(cartService.items.first.id, equals('1'));
    });

    test('should calculate total correctly', () {
      cartService.addItem(CartItem(
        id: '1',
        name: 'Item 1',
        price: 10.0,
        quantity: 2,
      ));

      cartService.addItem(CartItem(
        id: '2',
        name: 'Item 2',
        price: 20.0,
        quantity: 1,
      ));

      expect(cartService.total, equals(40.0));
    });
  });
}
```

### Widget Tests

```dart
// test/screens/cart_screen_test.dart
void main() {
  testWidgets('CartScreen displays items', 
    (WidgetTester tester) async {
    
    await tester.pumpWidget(const MyApp());
    
    // Navigate to cart
    await tester.tap(find.byIcon(Icons.shopping_cart));
    await tester.pumpAndSettle();
    
    // Verify items are displayed
    expect(find.byType(CartItemCard), findsWidgets);
  });
}
```

---

## III. Performance Optimization

### Image Optimization

```dart
// lib/widgets/optimized_network_image.dart
class OptimizedNetworkImage extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;

  const OptimizedNetworkImage({
    required this.imageUrl,
    this.width = 200,
    this.height = 200,
    this.fit = BoxFit.cover,
  });

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: imageUrl,
      width: width,
      height: height,
      fit: fit,
      memCacheHeight: (height ?? 200).toInt() * 2,
      memCacheWidth: (width ?? 200).toInt() * 2,
      maxHeightDiskCache: 2000,
      maxWidthDiskCache: 2000,
      placeholder: (context, url) => Center(
        child: CircularProgressIndicator(),
      ),
      errorWidget: (context, url, error) => Container(
        color: Colors.grey[300],
        child: Icon(Icons.broken_image),
      ),
    );
  }
}
```

### List Optimization

```dart
// Use ListView.builder instead of ListView
ListView.builder(
  itemCount: items.length,
  itemBuilder: (context, index) => ListTile(
    title: Text(items[index].name),
  ),
)

// Add caching with AutomaticKeepAliveClientMixin
class CachedItemWidget extends StatefulWidget {
  final Item item;

  @override
  State<CachedItemWidget> createState() => _CachedItemWidgetState();
}

class _CachedItemWidgetState extends State<CachedItemWidget>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return ListTile(
      title: Text(widget.item.name),
    );
  }
}
```

---

## IV. Deployment Checklist

### Pre-Deployment

```markdown
## Flutter App
- [ ] Run flutter analyze - no errors
- [ ] Run flutter test - all tests passing
- [ ] Code review completed
- [ ] Performance profiling done
- [ ] Security audit passed
- [ ] Firebase config added
- [ ] Tested on real devices
- [ ] Updated version number

## Backend
- [ ] All migrations applied: php artisan migrate
- [ ] .env configured correctly
- [ ] API keys added to .env
- [ ] Cache cleared: php artisan cache:clear
- [ ] Tests passing: php artisan test
- [ ] Logs checked for errors
```

### Build Commands

```bash
# Flutter iOS Build
flutter build ios --release

# Flutter Android Build
flutter build apk --release
flutter build appbundle --release

# Backend Deployment
php artisan migrate --force
php artisan cache:clear
php artisan config:cache
php artisan route:cache
```

---

## V. Monitoring & Logging

### Add Error Logging Service

```dart
// lib/services/error_logging_service.dart
class ErrorLoggingService {
  static void logError(Object error, StackTrace stackTrace) {
    // Log to file
    _logToFile(error, stackTrace);
    
    // Log to remote service (e.g., Sentry)
    _logToRemote(error, stackTrace);
    
    // Log to console in debug mode
    if (kDebugMode) {
      print('ERROR: $error\n$stackTrace');
    }
  }

  static Future<void> _logToFile(
    Object error,
    StackTrace stackTrace,
  ) async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/error_log.txt');
    
    final timestamp = DateTime.now().toIso8601String();
    await file.writeAsString(
      '[$timestamp] $error\n$stackTrace\n\n',
      mode: FileMode.append,
    );
  }

  static void _logToRemote(Object error, StackTrace stackTrace) {
    // TODO: Implement Sentry or similar
  }
}

// Usage
void main() async {
  FlutterError.onError = (FlutterErrorDetails details) {
    ErrorLoggingService.logError(
      details.exception,
      details.stack ?? StackTrace.current,
    );
  };

  PlatformDispatcher.instance.onError = (error, stack) {
    ErrorLoggingService.logError(error, stack);
    return true;
  };
}
```

---

## VI. Timeline & Milestones

### Week 1: Critical Fixes
```
Monday:    Fix git configuration
           Verify Firebase setup
Tuesday:   Complete OTP testing
           Complete API error handling tests
Wednesday: Refactor cart screen (part 1)
Thursday:  Refactor cart screen (part 2)
Friday:    Code review + testing
```

### Week 2-3: Quality Improvements
```
Week 2:
- Add unit tests for all services
- Refactor search results screen
- Performance optimization
- Security audit

Week 3:
- Add widget tests
- Integration testing
- Documentation
- Deployment preparation
```

---

## VII. Success Metrics

```
✅ All critical issues resolved
✅ 80%+ code test coverage
✅ Zero critical bugs
✅ All UI/UX tests passing
✅ Performance: < 2s app startup
✅ Performance: < 1s screen navigation
✅ 0 unhandled exceptions in production
```

---

**ឯកសារនេះ​គួរ​ឱ្យ​ប្រើប្រាស់ / How to Use:**
1. Print this document
2. Check off completed items
3. Update status weekly
4. Reference during code reviews
5. Use as deployment checklist

**Last Updated:** June 19, 2026
