# 📱 ឯកសារលម្អិតបច្ចេកទេស - KneaYerng Service Center App

**កាលបរិច្ឆេទ:** ២០២៦ ខែមិថុនា  
**ភាសា:** Flutter + Dart  
**ប្ល័តហ្វម:** iOS, Android, Web  

---

## 📚 តារាងលម្អិត

1. [ទិដ្ឋភាពទូទៅ](#ទិដ្ឋភាពទូទៅ)
2. [ក្របខ័ណ្ឋប្រព័ន្ធ](#ក្របខ័ណ្ឋប្រព័ន្ធ)
3. [ម៉ូឌុលសេវាកម្ម](#ម៉ូឌុលសេវាកម្ម)
4. [ម៉ូឌុលទិន្នន័យ](#ម៉ូឌុលទិន្នន័យ)
5. [ឯកសារលាក់](#ឯកសារលាក់)
6. [ផ្លូវលំហូរទិន្នន័យ](#ផ្លូវលំហូរទិន្នន័យ)

---

## ទិដ្ឋភាពទូទៅ

**KneaYerng Service Center App** គឺជា **Flutter Mobile Application** សម្រាប់ Khmer Service Center ដែលផ្តល់:

### ✨ លក្ខណៈពិសេស
- 🏠 **ទំព័រដើម** - បង្ហាញផលិតផល, ផ្ទាល់ក្តាលប់ទាក់ទងដែលពេញនិយម
- 🛒 **រូបថត់ទិញលក់** - ដែលរក្សាទុក, កែប្រែបរិមាណផលិតផល
- 📦 **ការបង្គាប់របស់ខ្ញុំ** - ដែលបង្ហាញលក្ខណៈថ្មីនៃការបង្គាប់, ការតាមដាន
- ❤️ **ផលិតផលដែលបានរក្សាទុក** - ដែលរក្សាទុក, ធ្វើការលុបលោកទៅហើយ
- 👤 **គណនីប្រូហ្វាល់** - ដែលកែប្រែលម្អិតខ្លួនឯង, អាសយដ្ឋាន, សោភន័ណ
- 🔧 **ការបង្កើតស្ដាប់ឡើងវិញ** - សម្រាប់ការទាក់ទងលទ្ធផល
- 💬 **ការគាំទ័រ** - ការថាន់ធានាលម្អិតផ្សេងៗ
- 🎫 **ប័ណ្ណលំនងលក្ខណៈងាប់** - ដែលផ្តល់ឱ្យលោក QR code

### 📱 ការគាំទ័ររបស់ការរចនា
- **ភាសា:** ខ្មែរ (km), английский (en)
- **ពន្លឺ/ងងឹត:** Dark Mode, Light Mode
- **ក្របក្របកម្មវិធី:** iOS (14+), Android (21+)

---

## ក្របខ័ណ្ឋប្រព័ន្ធ

### 🏗️ ក្របខ័ណ្ឋ

```
┌─────────────────────────────────────────┐
│      FLUTTER UI LAYER (Presentation)   │
├─────────────────────────────────────────┤
│ • Screens    (ឯកសារលាក់)
│ • Widgets    (សមាសភាគកម្មវិធី)
│ • Theme      (រូបរាង)
└──────────────┬──────────────────────────┘
               │
┌──────────────▼──────────────────────────┐
│    BUSINESS LOGIC LAYER (Services)     │
├─────────────────────────────────────────┤
│ • CartService         (រូបថត់ទិញលក់)
│ • ApiService          (API HTTP)
│ • NotificationService (ការបង្ដាប់)
│ • ThemeService        (រូបរាង)
│ • LanguageService     (ភាសា)
│ • FavoriteService     (ដែលបានរក្សាទុក)
└──────────────┬──────────────────────────┘
               │
┌──────────────▼──────────────────────────┐
│      DATA LAYER (Models & Cache)       │
├─────────────────────────────────────────┤
│ • Models         (ទិន្នន័យក្រឹង)
│ • SharedPref     (ក្របក្របលក្ខណៈក្នុងម៉ាស៊ីន)
│ • API Response   (JSON Data)
└──────────────┬──────────────────────────┘
               │
┌──────────────▼──────────────────────────┐
│     EXTERNAL SERVICES (Backend)        │
├─────────────────────────────────────────┤
│ • REST API         (ដែលផ្ថាប់ប័ណ្ណ)
│ • Firebase Auth    (ការផ្ទៀងផ្ទាត់)
│ • Firebase Cloud   (Push Notifications)
│ • Database         (ទិន្នន័យលម្អិត)
└─────────────────────────────────────────┘
```

---

## ម៉ូឌុលសេវាកម្ម

### 1️⃣ **ApiService** (`api_service.dart`)

ឥទ្ធិយដែលគ្រប់គ្រងការប្រើប្រាស់ HTTP រវាង app និង backend server។

#### 📋 មុខងារសំខាន់ៗ:

```dart
// ការយកមកផលិតផល
Future<List<Product>> getProducts({int page = 1})

// ការយកមកក្តាលប់
Future<OrderTrackingNotification?> getOrderTracking(int orderId)

// ការបន្ថែមទៅក៉ាត
Future<CartResult> addCartItem({
  required Product product,
  required int quantity,
  String? variant,
  int? variantId,
})

// ការលុបក៉ាត
Future<bool> removeCartItem({required int cartItemId})

// ការផ្ទៀងផ្ទាត់ token
Future<bool> validateToken()
```

#### 🔐 ការគាំទ័ររបស់Token:

- **Token Storage**: SharedPreferences
- **Header Authorization**: `Bearer {token}`
- **Token Refresh**: 401 errors ត្រឡប់ទៅ onboarding

#### 💾 Cache Strategy:

```dart
// Server Updates Cache (30 វិនាទី)
Map<String, String> _serverUpdatesCache;
DateTime _serverUpdatesFetchTime;

// ក្របក្របលក្ខណៈក្នុងម៉ាស៊ីន
SharedPreferences._getCachedData(String key)
```

---

### 2️⃣ **CartService** (`cart_service.dart`)

គ្រប់គ្រងរូបថត់ទិញលក់ខាងក្នុង app។

#### 📋 មុខងារសំខាន់ៗ:

```dart
// ដែលបន្ថែមផលិតផល
void add(
  Product product, {
  int quantity = 1,
  String? variant,
  int? variantId,
})

// កែប្រែបរិមាណ
void updateQuantity(CartItem item, int quantity)

// លុប item
void remove(CartItem item)

// លុប្ប័ណ្ណទាំងអស់
void clear()

// ដែលយកមក subtotal
double get subtotal => _items.fold(0, (sum, item) => sum + item.subtotal)

// ដែលយកមកចំនួនលេខ items
int get totalItems => _items.fold(0, (sum, item) => sum + item.quantity)
```

#### 🔄 Sync Strategy:

- **Local Changes**: State updates immediately
- **Remote Sync**: Queued & sent to API asynchronously
- **Optimistic Updates**: UI updates before server confirmation
- **Conflict Resolution**: Local version wins if synced

---

### 3️⃣ **NotificationService** (`app_notification_service.dart`)

គ្រប់គ្រងការដាក់ក្តាប់ (Notifications)។

#### 📋 មុខងារសំខាន់ៗ:

```dart
// ដែលពិលដូលក្តាប់
Future<void> initialize()

// ដែលស្នើសុំលិខិតឯកសារ
Future<void> requestNotificationPermission()

// ដែលផ្ញើក្តាប់
Future<void> sendNotification({
  required String title,
  required String body,
})

// ដែលតាមដាន push notification
void handlePushNotification(RemoteMessage message)
```

#### 🔔 Integration:

- **Firebase Messaging**: Remote push notifications
- **Local Notifications**: In-app alerts
- **Deep Linking**: Navigation from notifications

---

### 4️⃣ **ThemeService** (`theme_service.dart`)

គ្រប់គ្រងក្របក្របលាក់ (Dark/Light Mode)។

#### 📋 មុខងារសំខាន់ៗ:

```dart
// ដែលផ្លាស់ប្តូរក្របក្របលាក់
void toggleTheme()

// ដែលទាក់ទងក្របក្របលាក់
ThemeMode get themeMode

// ដែលរក្សាទុកលក្ខណៈក្របក្របលាក់
Future<void> _saveThemePreference()
```

#### 💾 Persistence:

- **Storage Key**: `theme`
- **Values**: `light` / `dark` / `system`

---

### 5️⃣ **LanguageService** (`language_service.dart`)

គ្រប់គ្រងភាសារបស់កម្មវិធី។

#### 📋 មុខងារសំខាន់ៗ:

```dart
// ដែលស្វីចភាសា
void setLocale(Locale locale)

// ដែលទាក់ទងភាសាបច្ចុប្បន្ន
Locale get locale

// ដែលរក្សាទុកលក្ខណៈភាសា
Future<void> _saveLanguagePreference()
```

#### 🌍 Supported Languages:

- **English**: `Locale('en')`
- **Khmer**: `Locale('km')`

---

### 6️⃣ **FavoriteService** (`favorite_service.dart`)

គ្រប់គ្រងផលិតផលដែលបានរក្សាទុក។

#### 📋 មុខងារសំខាន់ៗ:

```dart
// ដែលបន្ថែមទៅ favorites
void addFavorite(int productId)

// ដែលលុបចេញពីfavorites
void removeFavorite(int productId)

// ដែលឆ្លង់ថាវាបានរក្សាទុក
bool isFavorite(int productId)

// ដែលយកមកគោលចម្រើនលម្អិត
List<int> get favoriteIds
```

---

## ម៉ូឌុលទិន្នន័យ

### 📊 Models Structure

#### 1. **Product.dart**

```dart
class Product {
  final int id;
  final String name;
  final double price;
  final double? salePriceOverride;
  final String? imageUrl;
  final String? thumbnailUrl;
  final List<String> imageGallery;
  final String? categoryName;
  final int? categoryId;
  final String? brand;
  final String? description;
  final double? discount;
  final double rating;
  final int ratingCount;
  final int? stock;
  final List<ProductVariant> variants;
  
  // Getters
  bool get hasDiscount => (discount ?? 0) > 0
  double get salePrice => salePriceOverride ?? (price - (discount ?? 0))
  
  // JSON Serialization
  factory Product.fromJson(Map<String, dynamic> json)
  Map<String, dynamic> toJson()
}

class ProductVariant {
  final int id;
  final String storageCapacity;
  final String color;
  final String condition;
  final double price;
  final int stock;
  final String? ram;
  final String? ssd;
}
```

#### 2. **CartItem.dart**

```dart
class CartItem {
  final Product product;
  final int? remoteId;      // Server-assigned ID
  int quantity;
  final String? variant;
  final int? variantId;
  final String? variantImageUrl;
  final int? variantStock;
  final double? unitPrice;
  
  // Getters
  double get subtotal => (unitPrice ?? product.salePrice) * quantity
  bool get isUnsynced => remoteId == null
}
```

#### 3. **UserProfile.dart**

```dart
class UserProfile {
  final int? id;
  final String? firstName;
  final String? lastName;
  final String? email;
  final String? phoneNumber;
  final String? profileImageUrl;
  final String? address;
  final String? city;
  final String? country;
}
```

#### 4. **Order Models**

```dart
class OrderTrackingNotification {
  final int orderId;
  final String orderNumber;
  final String status;           // pending, shipped, delivered, etc.
  final String? address;
  final double? amount;
  final DateTime? placedAt;
  final DateTime? estimatedDelivery;
}

class PickupTicket {
  final int id;
  final String ticketNumber;
  final String status;
  final String? qrCode;
  final DateTime createdAt;
}
```

#### 5. **Category.dart**

```dart
class Category {
  final int id;
  final String name;
  final String? imageUrl;
  final int? productCount;
}
```

#### 6. **Search Models**

```dart
class SearchSuggestion {
  final String text;
  final String type;  // product, category, brand
}

class SearchResults {
  final List<Product> products;
  final List<Category> categories;
  final int totalCount;
}
```

---

## ឯកសារលាក់

### 📂 Screens Organization

```
screens/
├── Auth/
│   ├── onboarding_screen.dart        # Welcome screen
│   ├── login_screen.dart              # Login form
│   ├── register_screen.dart           # Registration
│   ├── otp_verify_screen.dart        # OTP verification
│   ├── forgot_password_screen.dart   # Password recovery
│   └── reset_password_screen.dart    # Reset password
│
├── home/
│   └── home_screen.dart               # HomePage with banners & products
│
├── products/
│   ├── all_products_screen.dart       # Products listing
│   ├── product_detail_screen.dart    # Product details
│   └── categories/
│       ├── categories_screen.dart     # Category listing
│       └── category_products_screen.dart
│
├── cart/
│   ├── cart_screen.dart               # Shopping cart view
│   ├── checkout_flow_screen.dart     # Checkout process
│   ├── delivery_location_picker.dart # Map location picker
│   └── bakong_checkout_sheet.dart    # Payment integration
│
├── orders/
│   ├── orders_screen.dart             # User's orders list
│   ├── order_history_screen.dart     # Order history
│   ├── delivery_tracking_screen.dart # Real-time tracking
│   └── order_history.dart             # Order history model
│
├── favorites/
│   └── favorite_screen.dart           # Wishlist/Favorites
│
├── profile/
│   ├── profile_screen.dart            # User profile
│   ├── edit_profile_screen.dart       # Edit profile
│   ├── personal_info_screen.dart     # Personal information
│   ├── address_management_screen.dart# Address book
│   ├── address_form_screen.dart      # Add/edit address
│   ├── help_center_screen.dart       # Help & support
│   ├── privacy_screen.dart            # Privacy policy
│   ├── reviews_preview_screen.dart   # User reviews
│   └── order_history_screen.dart     # Order history
│
├── repair/
│   └── repair_screen.dart             # Repair service booking
│
├── support/
│   └── support_chat_screen.dart       # Customer support chat
│
├── search/
│   └── search_results_screen.dart    # Search results
│
├── tickets/
│   ├── tickets_screen.dart            # Support tickets
│   └── ticket_detail_screen.dart     # Ticket details
│
├── warranty/
│   └── warranty_screen.dart           # Warranty information
│
├── notifications/
│   ├── notification_screen.dart       # Notifications list
│   └── admin_notification_panel_screen.dart
│
└── main_navigation_screen.dart        # Bottom tab navigation
```

### 🎯 Main Navigation Structure

```dart
class MainNavigationScreen extends StatefulWidget {
  final int initialIndex;
  final PickupTicket? initialPickupTicket;
  final int? initialDeliveryOrderId;
  
  // 5 main tabs:
  final List<Widget> _screens = [
    HomeScreen(),           // Index 0
    RepairScreen(),         // Index 1
    OrdersScreen(),         // Index 2
    FavoriteScreen(),       // Index 3
    ProfileScreen(),        // Index 4
  ];
}
```

---

## ផ្លូវលំហូរទិន្នន័យ

### 🔄 ឧទាហរណ៍: ដំណើរការទិញលក់

```
┌─────────────────────────────────────────────────┐
│ 1. ប្រើប្រាស់ចុច "ទិញ" នៅលើផលិតផល              │
└────────────────┬────────────────────────────────┘
                 │
                 ▼
┌─────────────────────────────────────────────────┐
│ 2. ProductDetailScreen បង្ហាញលម្អិត             │
│    - រូបភាព gallery                             │
│    - ការពិពណ៌នា, ថ្លៃ, ផ្នែក variant           │
└────────────────┬────────────────────────────────┘
                 │
                 ▼
┌─────────────────────────────────────────────────┐
│ 3. ប្រើប្រាស់ជ្រើសរើស variant ហើយចុច "Add to Cart" │
└────────────────┬────────────────────────────────┘
                 │
                 ▼
┌─────────────────────────────────────────────────┐
│ 4. CartService.add(product, quantity, variant) │
│    - Update UI immediately (optimistic)        │
│    - Enqueue sync to API                       │
└────────────────┬────────────────────────────────┘
                 │
                 ▼
┌─────────────────────────────────────────────────┐
│ 5. Background: ApiService.addCartItem()        │
│    - HTTP POST /api/cart                       │
│    - Server returns remoteId                   │
└────────────────┬────────────────────────────────┘
                 │
                 ▼
┌─────────────────────────────────────────────────┐
│ 6. CartService._mergeRemoteIds()               │
│    - Store server-assigned ID locally          │
│    - notifyListeners() → UI updates            │
└────────────────┬────────────────────────────────┘
                 │
                 ▼
┌─────────────────────────────────────────────────┐
│ 7. ប្រើប្រាស់ចុច "Checkout"                     │
└────────────────┬────────────────────────────────┘
                 │
                 ▼
┌─────────────────────────────────────────────────┐
│ 8. CheckoutFlowScreen                          │
│    - ជ្រើសរើស address                           │
│    - ជ្រើសរើស delivery method                    │
│    - ជ្រើសរើស payment method                    │
└────────────────┬────────────────────────────────┘
                 │
                 ▼
┌─────────────────────────────────────────────────┐
│ 9. ApiService.createOrder()                    │
│    - HTTP POST /api/orders                     │
│    - Send cart items, address, payment info    │
└────────────────┬────────────────────────────────┘
                 │
                 ▼
┌─────────────────────────────────────────────────┐
│ 10. Server processes & returns orderId         │
└────────────────┬────────────────────────────────┘
                 │
                 ▼
┌─────────────────────────────────────────────────┐
│ 11. App receives success                       │
│    - CartService.clear()                       │
│    - Navigate to OrderSuccessScreen            │
│    - Display order number & QR code            │
└────────────────┬────────────────────────────────┘
                 │
                 ▼
┌─────────────────────────────────────────────────┐
│ 12. Server sends notification                  │
│    - Firebase Messaging                        │
│    - App receives & displays alert             │
└─────────────────────────────────────────────────┘
```

### 🔐 Authentication Flow

```
┌─────────────────────────────────────┐
│ 1. ប្រើប្រាស់ Enter Credentials        │
└────────────┬────────────────────────┘
             │
             ▼
┌─────────────────────────────────────┐
│ 2. LoginScreen                      │
│    - POST /api/auth/login           │
│    - Returns: token, user data      │
└────────────┬────────────────────────┘
             │
             ▼
┌─────────────────────────────────────┐
│ 3. Store Token                      │
│    - SharedPreferences              │
│    - Key: 'auth_token'              │
└────────────┬────────────────────────┘
             │
             ▼
┌─────────────────────────────────────┐
│ 4. Validate Token on App Start      │
│    - _StartupGate._bootstrap()      │
│    - ApiService.validateToken()     │
└────────────┬────────────────────────┘
             │
        Yes  │  No
        ┌────┴─────┐
        │           │
        ▼           ▼
    ┌───────┐   ┌──────────┐
    │ Home  │   │ Onboard  │
    └───────┘   │ (Logout) │
                └──────────┘
```

### 🛡️ Token Refresh Strategy

```
┌─────────────────────────────┐
│ API Call with Token         │
│ Headers: Bearer {token}     │
└────────────┬────────────────┘
             │
      ┌──────┴──────┐
      │             │
    200 OK         401 Unauthorized
      │             │
      ▼             ▼
  ┌────────┐   ┌──────────────────┐
  │Success │   │ onUnauthorized() │
  └────────┘   │ - Clear token    │
               │ - Navigate to    │
               │   Onboarding     │
               └──────────────────┘
```

---

## 🎨 Theme System

### Light Theme Palette

```dart
class AppPalette {
  static const Color primary = Color(0xFF1E40AF);      // Blue
  static const Color secondary = Color(0xFF06B6D4);   // Cyan
  static const Color accent = Color(0xFFEA580C);      // Orange
  static const Color background = Color(0xFFFFFFFF);  // White
  static const Color surface = Color(0xFFF3F4F6);     // Light Gray
  static const Color error = Color(0xFFDC2626);       // Red
  static const Color success = Color(0xFF16A34A);     // Green
  static const Color warning = Color(0xFFF97316);     // Orange
}
```

### Font System

```dart
class AppFonts {
  static const String primary = 'KantumruyPro';      // Custom Khmer font
  static const String fallback = 'Roboto';           // System font
  
  static const TextStyle heading1 = TextStyle(
    fontFamily: primary,
    fontSize: 32,
    fontWeight: FontWeight.bold,
  );
  
  static const TextStyle body = TextStyle(
    fontFamily: primary,
    fontSize: 16,
    fontWeight: FontWeight.normal,
  );
}
```

---

## 🔗 Dependencies

| Package | Version | ឆ្នាប់ |
|---------|---------|--------|
| `flutter` | SDK | Core framework |
| `firebase_core` | 4.5.0 | Firebase initialization |
| `firebase_auth` | 6.2.0 | Authentication |
| `firebase_messaging` | 16.0.2 | Push notifications |
| `http` | 1.6.0 | REST API calls |
| `shared_preferences` | 2.5.4 | Local storage |
| `image_picker` | 1.1.2 | Image selection |
| `qr_flutter` | 4.1.0 | QR code generation |
| `flutter_map` | 6.1.0 | Interactive maps |
| `geolocator` | 10.1.0 | GPS location |
| `intl` | 0.20.2 | Internationalization |
| `cached_network_image` | 3.4.1 | Image caching |
| `lottie` | 3.1.0 | Animations |
| `google_fonts` | 6.2.1 | Google fonts |
| `hugeicons` | 0.0.7 | Icon library |
| `khqr_sdk` | 2.0.0 | Bakong QR payment |

---

## 📊 Database Schema (Backend Reference)

### Users Table
```sql
CREATE TABLE users (
  id INT PRIMARY KEY,
  email VARCHAR(255) UNIQUE,
  phone_number VARCHAR(20),
  first_name VARCHAR(100),
  last_name VARCHAR(100),
  profile_image_url VARCHAR(500),
  address TEXT,
  city VARCHAR(100),
  country VARCHAR(100),
  created_at TIMESTAMP,
  updated_at TIMESTAMP
);
```

### Products Table
```sql
CREATE TABLE products (
  id INT PRIMARY KEY,
  name VARCHAR(255),
  description TEXT,
  price DECIMAL(10, 2),
  sale_price DECIMAL(10, 2),
  category_id INT,
  brand VARCHAR(100),
  stock INT,
  rating DECIMAL(3, 2),
  image_url VARCHAR(500),
  created_at TIMESTAMP
);
```

### Orders Table
```sql
CREATE TABLE orders (
  id INT PRIMARY KEY,
  user_id INT,
  order_number VARCHAR(50),
  status VARCHAR(50),
  total_amount DECIMAL(10, 2),
  delivery_address TEXT,
  created_at TIMESTAMP,
  delivered_at TIMESTAMP
);
```

### Cart Items Table
```sql
CREATE TABLE cart_items (
  id INT PRIMARY KEY,
  user_id INT,
  product_id INT,
  quantity INT,
  variant VARCHAR(255),
  created_at TIMESTAMP
);
```

---

## 🚀 Building & Deployment

### Build for Android
```bash
flutter build apk --release
flutter build appbundle --release
```

### Build for iOS
```bash
flutter build ios --release
```

### Build for Web
```bash
flutter build web --release
```

---

## 🧪 Testing Strategy

### Unit Tests
```dart
test('CartService adds item correctly', () {
  final service = CartService.instance;
  final product = Product(id: 1, name: 'Phone', price: 500);
  
  service.add(product, quantity: 2);
  
  expect(service.totalItems, 2);
  expect(service.subtotal, 1000);
});
```

### Widget Tests
```dart
testWidgets('ProductDetailScreen displays product', (WidgetTester tester) async {
  await tester.pumpWidget(const MyApp());
  
  expect(find.text('Product Name'), findsOneWidget);
  expect(find.byType(ElevatedButton), findsWidgets);
});
```

---

## 🔒 Security Best Practices

1. **Token Management**
   - Store tokens in secure storage (SharedPreferences)
   - Clear tokens on logout
   - Validate tokens on app start

2. **API Communication**
   - Use HTTPS only
   - Validate SSL certificates
   - Add request signing if needed

3. **Data Validation**
   - Validate user input
   - Sanitize API responses
   - Handle errors gracefully

4. **Permissions**
   - Request runtime permissions (Android 6+)
   - Handle permission denials gracefully

---

## 📝 API Endpoints

### Authentication
```
POST   /api/auth/login              - User login
POST   /api/auth/register           - User registration
POST   /api/auth/logout             - User logout
POST   /api/auth/refresh            - Refresh token
POST   /api/auth/verify-otp         - Verify OTP
```

### Products
```
GET    /api/products                - Get all products
GET    /api/products/{id}           - Get product details
GET    /api/categories              - Get all categories
GET    /api/search                  - Search products
GET    /api/products/category/{id}  - Products by category
```

### Cart
```
GET    /api/cart                    - Get cart items
POST   /api/cart                    - Add to cart
PUT    /api/cart/{id}               - Update cart item
DELETE /api/cart/{id}               - Remove from cart
```

### Orders
```
GET    /api/orders                  - Get user orders
POST   /api/orders                  - Create order
GET    /api/orders/{id}             - Get order details
GET    /api/orders/{id}/tracking    - Get order tracking
```

### Profile
```
GET    /api/profile                 - Get user profile
PUT    /api/profile                 - Update profile
POST   /api/profile/avatar          - Upload avatar
GET    /api/addresses               - Get addresses
POST   /api/addresses               - Add address
```

---

## 🐛 Error Handling

### HTTP Error Codes

```dart
// 400 - Bad Request
// 401 - Unauthorized (Token invalid/expired)
// 403 - Forbidden (No permission)
// 404 - Not Found
// 500 - Server Error
// 503 - Service Unavailable
```

### Exception Handling

```dart
try {
  final result = await ApiService.getProducts();
} on SocketException catch (e) {
  // Network error
} on TimeoutException catch (e) {
  // Request timeout
} catch (e) {
  // Generic error
}
```

---

## 📞 Support

សូមបង្ហាញលម្អិតលម្អិតលម្អិតលម្អិតលម្អិតលម្អិត!

---

**ឯកសារលម្អិត:** ២០២៦ ខែមិថុនា  
**ក្រុមអភិវឌ្ឍន៍:** Khmer Service Center  
