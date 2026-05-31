# ជំពូកទី ៥ — Input – Process – Output (IPO)
## KneaYerng Service Center Application

---

## ៥.១ និយមន័យ Input – Process – Output

**Input – Process – Output (IPO)** គឺជាគំរូ (Model) ដែលប្រើសម្រាប់ពណ៌នា និងរៀបរាប់អំពីដំណើរការរបស់ប្រព័ន្ធ ។ IPO បែងចែកទិន្នន័យជា ៣ ដំណាក់កាល:

- **Input (ទិន្នន័យចូល)** — ព័ត៌មានដែលអ្នកប្រើប្រាស់ ឬប្រព័ន្ធផ្ញើចូល
- **Process (ការដំណើរការ)** — ការគណនា ពិនិត្យ ឬដំណើរការដែល Backend ធ្វើ
- **Output (ទិន្នន័យចេញ)** — លទ្ធផលដែលប្រព័ន្ធបង្ហាញ ឬបញ្ជូនត្រឡប់

ក្នុងប្រព័ន្ធ KneaYerng Service Center Application ត្រូវបានបែងចែកជា **២ ផ្នែក** ដូចខាងក្រោម:

- **ផ្នែកទី ១** — **User App (Flutter Mobile Application)** — ប្រើដោយ Customer
- **ផ្នែកទី ២** — **Admin Panel (Web Application)** — ប្រើដោយ Admin, Staff, Technician

---

# ផ្នែកទី ១ — USER APP (Flutter Mobile Application)

---

## ៥.២ Module Authentication (ការផ្ទៀងផ្ទាត់អត្តសញ្ញាណ)

### ៥.២.១ ការចុះឈ្មោះ (Register)

ការចុះឈ្មោះ ជាដំណើរការដំបូងដែល Customer ថ្មីត្រូវធ្វើ ដើម្បីបង្កើតគណនី ចូលប្រើប្រាស់ Application ។

| Input (ទិន្នន័យចូល) | Process (ការដំណើរការ) | Output (ទិន្នន័យចេញ) |
|---|---|---|
| ឈ្មោះដំបូង (First Name) | ពិនិត្យ Field ត្រូវបំពេញ | Bearer Token (Sanctum) |
| ឈ្មោះចុងក្រោយ (Last Name) | Hash Password ដោយ bcrypt | User Profile JSON |
| Email Address | ពិនិត្យ Email មិនត្រួតគ្នា | Registration Success Screen |
| Phone Number | ពិនិត្យ Phone មិនត្រួតគ្នា | ចូលកម្មវិធីដោយស្វ័យប្រវត្តិ |
| Password | រក្សាទុក User ក្នុង Database | |
| Confirm Password | Generate Sanctum Token | |

**Flutter Screen:** `RegisterScreen` → POST `/auth/register`

**Laravel:** `AuthController@register` → `users` table → Return Token

---

### ៥.២.២ ការចូលប្រើប្រាស់ (Login)

| Input (ទិន្នន័យចូល) | Process (ការដំណើរការ) | Output (ទិន្នន័យចេញ) |
|---|---|---|
| Email ឬ Phone | ស្វែងរក User ក្នុង Database | Bearer Token |
| Password | ពិនិត្យ Password ជាមួយ Hash | User Profile (name, email, role) |
| | ពិនិត្យ Account Active | MainNavigationScreen |
| | Generate Sanctum Token | Error Message ប្រសិនបើ Login ខុស |

**Flutter Screen:** `LoginScreen` → POST `/auth/login`

**Laravel:** `AuthController@login` → `personal_access_tokens` table

---

### ៥.២.៣ ការចូលតាម Google (Google Sign-In)

| Input (ទិន្នន័យចូល) | Process (ការដំណើរការ) | Output (ទិន្នន័យចេញ) |
|---|---|---|
| Google Account (click) | Firebase Google Auth | Bearer Token |
| Firebase ID Token | Backend Verify ID Token | User Profile |
| | Upsert User ទៅ Database | MainNavigationScreen |
| | Generate Sanctum Token | |

**Flutter:** `google_sign_in` Package → POST `/auth/google`

**Laravel:** `AuthController@googleLogin` → `FirebaseAuthService` → Upsert `users`

---

### ៥.២.៤ ការផ្ទៀងផ្ទាត់ OTP

| Input (ទិន្នន័យចូល) | Process (ការដំណើរការ) | Output (ទិន្នន័យចេញ) |
|---|---|---|
| Phone Number | Generate OTP Code 6 digits | SMS ផ្ញើទៅ Phone |
| | Hash OTP → Save ទៅ Database | OTP Screen បង្ហាញ |
| | ផ្ញើ SMS តាម Infobip/Unimatrix | |
| **---** | **---** | **---** |
| OTP Code ដែលបានទទួល | ពិនិត្យ OTP Hash | Bearer Token |
| | ពិនិត្យ OTP មិនផុតកំណត់ | Error ប្រសិនបើ OTP ខុស/ផុត |
| | ពិនិត្យ Attempts < Max | Account Locked ប្រសិនបើ Attempts ច្រើន |

**Flutter Screen:** `OtpScreen` / `OtpVerifyScreen`

**Laravel:** `AuthOtpController` → `OtpService` → `otp_verifications` table

---

### ៥.២.៥ ភ្លេចលេខសម្ងាត់ (Forgot Password)

| Input (ទិន្នន័យចូល) | Process (ការដំណើរការ) | Output (ទិន្នន័យចេញ) |
|---|---|---|
| Email Address | ពិនិត្យ Email មាននៅ Database | Email OTP ផ្ញើ |
| | Generate OTP → Hash → Save | OTP Verify Screen |
| | ផ្ញើ Email OTP (SMTP) | |
| **---** | **---** | **---** |
| OTP Code | ពិនិត្យ OTP ត្រឹមត្រូវ | Reset Password Screen |
| **---** | **---** | **---** |
| Password ថ្មី | Hash Password ថ្មី | Login Screen |
| Confirm Password | Update `users` table | Success Message |
| | លុប OTP Record | |

**Flutter Screen:** `ForgotPasswordScreen` → `OtpVerifyScreen` → `ResetPasswordScreen`

**Laravel:** `ForgotPasswordController` → `email_otps` table → `OtpMail`

---

## ៥.៣ Module Home & Catalog (ទំព័រដើម និងផលិតផល)

### ៥.៣.១ ទំព័រដើម (Home Screen)

| Input (ទិន្នន័យចូល) | Process (ការដំណើរការ) | Output (ទិន្នន័យចេញ) |
|---|---|---|
| Token (optional) | Query `banners` table | Banner Slideshow |
| App Start | Query `categories` table | Category Icons |
| | Query `products` (featured) | Product Cards |
| | Check App Update Version | Update Prompt (if new version) |

**Flutter Screen:** `HomeScreen`

**Laravel:** GET `/banners`, GET `/public/categories`, GET `/public/products`, GET `/updates`

---

### ៥.៣.២ ការមើលប្រភេទ (Categories)

| Input (ទិន្នន័យចូល) | Process (ការដំណើរការ) | Output (ទិន្នន័យចេញ) |
|---|---|---|
| (ចូលទំព័រ Categories) | Query `categories` table | Category List + Images |
| Category ID (click) | Query `products` WHERE `category_id` | Products in Category |
| Filter / Sort | Apply Filter | Filtered Product List |

**Flutter Screen:** `CategoriesScreen` → `CategoryProductsScreen`

**Laravel:** GET `/public/categories`, GET `/public/products?category_id=X`

---

### ៥.៣.៣ ការមើលផលិតផល (Product Detail)

| Input (ទិន្នន័យចូល) | Process (ការដំណើរការ) | Output (ទិន្នន័យចេញ) |
|---|---|---|
| Product ID | Query `products` + `product_variants` | Product Name, Price |
| | Load Product Gallery | Image Gallery |
| | Load Category Info | Product Variants (Color, Storage) |
| | Check Stock | Specifications |
| | | Add to Cart Button (disabled if no stock) |

**Flutter Screen:** `ProductDetailScreen`

**Laravel:** GET `/public/products/{product}`

---

### ៥.៣.៤ ការស្វែងរកផលិតផល (Search)

| Input (ទិន្នន័យចូល) | Process (ការដំណើរការ) | Output (ទិន្នន័យចេញ) |
|---|---|---|
| Keywords (Search Text) | LIKE Query ក្នុង `products`, `accessories` | Auto Suggestions |
| | Save to Search History (local) | Search Results |
| | Paginate Results | History List |

**Flutter Screen:** `SearchResultsScreen`

**Laravel:** GET `/search/suggestions`, GET `/search/results`

---

## ៥.៤ Module Cart & Checkout (កន្ត្រក និងការទូទាត់)

### ៥.៤.១ ការដាក់ទំនិញក្នុងកន្ត្រក (Add to Cart)

| Input (ទិន្នន័យចូល) | Process (ការដំណើរការ) | Output (ទិន្នន័យចេញ) |
|---|---|---|
| Product ID | ពិនិត្យ Auth Token | Cart Updated |
| Variant ID (optional) | ស្វែងរក ឬ បង្កើត Cart | CartItem Added |
| Quantity | ពិនិត្យ Stock គ្រប់គ្រាន់ | Cart Total គណនា |
| | Save ទៅ `cart_items` | CartService Notify (ValueNotifier) |
| | | CartAddedBottomBar បង្ហាញ |

**Flutter Screen:** `ProductDetailScreen` → POST `/cart/items`

**Laravel:** `CartController@addItem` → `carts` + `cart_items` tables

---

### ៥.៤.២ ការគ្រប់គ្រងកន្ត្រក (Cart Management)

| Input (ទិន្នន័យចូល) | Process (ការដំណើរការ) | Output (ទិន្នន័យចេញ) |
|---|---|---|
| (ចូលទំព័រ Cart) | Load Cart + CartItems + Products | CartItems List |
| Quantity Change | Update `cart_items.quantity` | Updated Line Total |
| Delete Item | Delete from `cart_items` | Cart Refreshed |
| | | Total Amount |

**Flutter Screen:** `CartScreen`

**Laravel:** GET `/cart`, PATCH `/cart/items/{id}`, DELETE `/cart/items/{id}`

---

### ៥.៤.៣ ការប្រើ Voucher (Apply Voucher)

| Input (ទិន្នន័យចូល) | Process (ការដំណើរការ) | Output (ទិន្នន័យចេញ) |
|---|---|---|
| Voucher Code | ពិនិត្យ Code មាននៅ Database | Discount Amount |
| Order Amount | ពិនិត្យ Code មិនផុតកំណត់ | Updated Order Total |
| | ពិនិត្យ Min Order Amount | Error ប្រសិនបើ Invalid/Used |
| | ពិនិត្យ Usage Limit | |
| | គណនា Discount | |

**Flutter Screen:** `CheckoutFlowScreen` → GET `/vouchers/validate?code=XXX`

**Laravel:** `VoucherValidationController` → `VoucherService` → `vouchers` table

---

### ៥.៤.៤ ការជ្រើសរើសទីតាំង Delivery (Location Picker)

| Input (ទិន្នន័យចូល) | Process (ការដំណើរការ) | Output (ទិន្នន័យចេញ) |
|---|---|---|
| GPS Permission | Get Current Location (geolocator) | Map with Pin |
| Map Drag / Click | Update Lat/Lng | Address Confirmed |
| Address Text | Reverse Geocoding | Delivery Address + Coordinates |

**Flutter Screen:** `DeliveryLocationPicker` (flutter_map + OpenStreetMap)

---

### ៥.៤.៥ ការបញ្ជាទិញ (Place Order)

| Input (ទិន្នន័យចូល) | Process (ការដំណើរការ) | Output (ទិន្នន័យចេញ) |
|---|---|---|
| Order Type (delivery/pickup) | Validate CartItems | Order Number បង្កើត |
| Delivery Address + GPS | គណនា Delivery Fee | `orders` Record Save |
| Customer Name, Phone | Apply Voucher Discount | `order_items` Records Save |
| Payment Method | Save Order ទៅ Database | Order Confirmation |
| Voucher Code (optional) | Notify Admin (Telegram) | Telegram Alert ជូន Admin |
| Delivery Note (optional) | ផ្ញើ FCM Notification | |

**Flutter Screen:** `CheckoutFlowScreen` → POST `/user/orders`

**Laravel:** `OrderController@store` → `orders` + `order_items` → `TelegramOrderService`

---

## ៥.៥ Module Payment (ការទូទាត់ប្រាក់)

### ៥.៥.១ KHQR (Bakong) Payment

| Input (ទិន្នន័យចូល) | Process (ការដំណើរការ) | Output (ទិន្នន័យចេញ) |
|---|---|---|
| Order ID | KhqrGenerator បង្កើត QR String | QR Code Image |
| Amount | Save Transaction ទៅ `khqr_transactions` | Transaction ID |
| Currency (KHR/USD) | POST Request ទៅ Bakong API | QR Screen បង្ហាញ |
| **---** | **---** | **---** |
| Transaction ID | POST ទៅ Bakong API Check Status | Status: `paid` / `pending` |
| | Update `khqr_transactions.status` | Payment Status Update |
| | Update `orders.payment_status` = paid | Order Confirmed Screen |

**Flutter Screen:** `BakongCheckoutSheet`

**Laravel:** POST `/generate-qr` → POST `/check-transaction` → `KhqrPaymentController`

---

## ៥.៦ Module Orders (ការបញ្ជាទិញ)

### ៥.៦.១ ការមើលបញ្ជី Order (My Orders)

| Input (ទិន្នន័យចូល) | Process (ការដំណើរការ) | Output (ទិន្នន័យចេញ) |
|---|---|---|
| Bearer Token | Query `orders` WHERE `user_id` | Order List |
| | Load OrderItems | Order Status, Amount |
| | Order by `placed_at` DESC | Order Cards |

**Flutter Screen:** `OrdersScreen` → GET `/user/orders`

---

### ៥.៦.២ ការតាមដាន Order (Delivery Tracking)

| Input (ទិន្នន័យចូល) | Process (ការដំណើរការ) | Output (ទិន្នន័យចេញ) |
|---|---|---|
| Order ID | Query `order_tracking_histories` | Status Timeline |
| | ពិនិត្យ Owner | Current Status |
| | Format Timestamps | Staff Name + Action |

**Flutter Screen:** `DeliveryTrackingScreen` → GET `/user/orders/{id}/tracking`

---

### ៥.៦.៣ Pickup Ticket (QR Code)

| Input (ទិន្នន័យចូល) | Process (ការដំណើរការ) | Output (ទិន្នន័យចេញ) |
|---|---|---|
| Order ID | Query `orders.pickup_qr_token` | QR Code Display |
| | ពិនិត្យ Token + Expiry | Ticket Info (Order No, Date) |

**Flutter Screen:** `TicketsScreen` → `TicketDetailScreen`

---

## ៥.៧ Module Repair Service (សេវាជួសជុល)

### ៥.៧.១ ការស្នើជួសជុល (Submit Repair Request)

| Input (ទិន្នន័យចូល) | Process (ការដំណើរការ) | Output (ទិន្នន័យចេញ) |
|---|---|---|
| Device Model | Save ទៅ `repair_requests` | Repair Request ID |
| Issue Type | Set Status = `submitted` | Ticket Number |
| Service Type | Notify Admin | Tickets Screen |
| Appointment DateTime | ផ្ញើ FCM Notification | Push Notification |
| Bearer Token | | |

**Flutter Screen:** `RepairScreen` → POST `/repairs`

**Laravel:** `RepairRequestController@store` → `repair_requests` → `RepairNotificationService`

---

### ៥.៧.២ ការមើល Repair Status

| Input (ទិន្នន័យចូល) | Process (ការដំណើរការ) | Output (ទិន្នន័យចេញ) |
|---|---|---|
| Repair ID | Query `repair_requests` | Current Status |
| | Load `repair_status_logs` | Status Timeline |
| | Load Quotation (if any) | Quotation Details |
| | Load Chat Messages | Chat History |
| | Load Warranty (if complete) | Warranty Info |

**Flutter Screen:** `TicketDetailScreen`

**Laravel:** GET `/repairs/{id}`, GET `/repairs/{id}/status-timeline`

---

### ៥.៧.៣ ការ Approve/Reject Quotation

| Input (ទិន្នន័យចូល) | Process (ការដំណើរការ) | Output (ទិន្នន័យចេញ) |
|---|---|---|
| Quotation ID | Update `quotations.status` | Status Updated |
| Action (approve/reject) | Update Repair Status | Notification ជូន Technician |
| | ផ្ញើ FCM Push | Repair Continues/Closed |

**Flutter Screen:** `TicketDetailScreen` → POST `/quotations/{id}/approve` ឬ `/reject`

---

### ៥.៧.៤ Repair Chat (ជជែកជាមួយ Technician)

| Input (ទិន្នន័យចូល) | Process (ការដំណើរការ) | Output (ទិន្នន័យចេញ) |
|---|---|---|
| Repair ID | Load `chat_messages` | Chat History |
| Message Text | Save Message | Message Displayed |
| | Broadcast Event | FCM Push ជូន Technician |

**Flutter Screen:** Chat ក្នុង `TicketDetailScreen` → GET/POST `/repairs/{id}/chat`

---

## ៥.៨ Module Notifications (ការជូនដំណឹង)

### ៥.៨.១ Notification Inbox

| Input (ទិន្នន័យចូល) | Process (ការដំណើរការ) | Output (ទិន្នន័យចេញ) |
|---|---|---|
| Bearer Token | Query `order_tracking_notifications` | Notification List |
| | Query `repair_notifications` | Unread Count Badge |
| Mark as Read | Update `read_at` | Notification Cleared |

**Flutter Screen:** `NotificationScreen`

**Laravel:** GET `/notifications`, POST `/order-notifications/{id}/read`

---

### ៥.៨.២ Push Notification Handler

| Input (ទិន្នន័យចូល) | Process (ការដំណើរការ) | Output (ទិន្នន័យចេញ) |
|---|---|---|
| FCM Token | Register Token ទៅ Server | Token Saved |
| | | |
| Incoming FCM Message | AppNotificationService ដំណើរការ | Banner Notification |
| (Foreground) | Show Local Notification | |
| Incoming FCM Message | System handles | System Notification |
| (Background/Terminated) | User taps → Navigate | Navigate to Target Screen |

**Flutter:** `AppNotificationService` → POST `/mobile-devices/token`

---

## ៥.៩ Module Support Chat (ជជែកជាមួយបុគ្គលិក)

| Input (ទិន្នន័យចូល) | Process (ការដំណើរការ) | Output (ទិន្នន័យចេញ) |
|---|---|---|
| (ចូលទំព័រ Support) | GET or Create Conversation | Conversation ID |
| | Load `support_messages` | Chat History |
| Message Text | Save ទៅ `support_messages` | Message Displayed |
| Media (optional) | Broadcast Event | FCM Push ជូន Staff |
| | | Unread Count Update |

**Flutter Screen:** `SupportChatScreen`

**Laravel:** GET `/support/conversation`, POST `/support/messages`

---

## ៥.១០ Module Profile (ព័ត៌មានគណនី)

### ៥.១០.១ ការកែប្រែ Profile

| Input (ទិន្នន័យចូល) | Process (ការដំណើរការ) | Output (ទិន្នន័យចេញ) |
|---|---|---|
| First Name, Last Name | Validate Input | Profile Updated |
| Email, Phone | Update `users` table | Profile Screen Refresh |
| Avatar Image | Upload Image → Store | New Avatar Displayed |

**Flutter Screen:** `EditProfileScreen` / `PersonalInfoScreen` → PUT `/auth/user/update`

---

### ៥.១០.២ ការគ្រប់គ្រងអាសយដ្ឋាន (Address Management)

| Input (ទិន្នន័យចូល) | Process (ការដំណើរការ) | Output (ទិន្នន័យចេញ) |
|---|---|---|
| Address Label | Save ទៅ SharedPreferences (Local) | Address List |
| Full Address | Load on Checkout | Address Selectable |
| GPS Coordinates | | |

**Flutter Screen:** `AddressManagementScreen` → `AddressFormScreen`

**Note:** អាសយដ្ឋានត្រូវបានរក្សាទុក **Locally** (SharedPreferences) មិនមែន Server

---

### ៥.១០.៣ ប្រវត្តិការបញ្ជាទិញ (Order History)

| Input (ទិន្នន័យចូល) | Process (ការដំណើរការ) | Output (ទិន្នន័យចេញ) |
|---|---|---|
| Bearer Token | Query `orders` + `order_items` | Order History List |
| | Filter by Status | Order Status, Date, Amount |

**Flutter Screen:** `OrderHistoryScreen`

---

### ៥.១០.៤ ការប្ដូរ Theme & Language

| Input (ទិន្នន័យចូល) | Process (ការដំណើរការ) | Output (ទិន្នន័យចេញ) |
|---|---|---|
| Theme Toggle (Light/Dark) | ThemeService Save (SharedPreferences) | UI Theme Changed |
| Language Toggle (KM/EN) | LanguageService Save (SharedPreferences) | App Language Changed |

---

## ៥.១១ Module Favorites (ផលិតផលពេញចិត្ត)

| Input (ទិន្នន័យចូល) | Process (ការដំណើរការ) | Output (ទិន្នន័យចេញ) |
|---|---|---|
| Product ID (Heart click) | Save Product ID ទៅ SharedPreferences | Heart Icon Filled |
| | | Favorites List Updated |
| (ចូលទំព័រ Favorites) | Load IDs ពី SharedPreferences | Favorite Products Screen |
| | Query Products from API | Product Cards |

**Flutter Screen:** `FavoriteScreen` → `FavoriteService`

---

---

# ផ្នែកទី ២ — ADMIN PANEL (Web Application)

Admin Panel គឺជា Web Application ដែលបង្កើតដោយ **Laravel Blade + TailwindCSS** ។ Admin, Staff, Technician ចូលប្រើប្រាស់តាម Browser ។

---

## ៥.១២ Module Admin Authentication

### ៥.១២.១ Admin Login

| Input (ទិន្នន័យចូល) | Process (ការដំណើរការ) | Output (ទិន្នន័យចេញ) |
|---|---|---|
| Email Address | ពិនិត្យ Credentials | Session Created |
| Password | ពិនិត្យ `is_admin` = true | Redirect Admin Dashboard |
| | Create Laravel Session | Error ប្រសិនបើ Login ខុស |

**Route:** POST `/login` → `AuthenticatedSessionController`

---

## ៥.១៣ Module Dashboard

| Input (ទិន្នន័យចូល) | Process (ការដំណើរការ) | Output (ទិន្នន័យចេញ) |
|---|---|---|
| Admin Session | Count `orders` | Total Orders |
| Date Filter (optional) | Sum `orders.total_amount` | Total Revenue |
| | Count `users` (customers) | Total Customers |
| | Count `repair_requests` | Total Repairs |
| | Count Pending Orders | Pending Orders Count |
| | Count Active Repairs | Active Repairs Count |

**Route:** GET `/admin/dashboard` → `admin.dashboard` Blade View

**API:** GET `/admin/metrics` → `AdminMetricsController`

---

## ៥.១៤ Module Catalog Management (ការគ្រប់គ្រងផលិតផល)

### ៥.១៤.១ ការគ្រប់គ្រង Categories

| Input (ទិន្នន័យចូល) | Process (ការដំណើរការ) | Output (ទិន្នន័យចេញ) |
|---|---|---|
| Category Name | Save ទៅ `categories` table | Category Created/Updated |
| Category Image | Upload Image → Storage | Category List |
| Sort Order | Slugify Name | Success Message |
| Status (active/inactive) | | |

**Admin Page:** `/admin/categories`

**API:** POST/PUT/DELETE `/categories` → `CategoryController`

---

### ៥.១៤.២ ការគ្រប់គ្រង Products

| Input (ទិន្នន័យចូល) | Process (ការដំណើរការ) | Output (ទិន្នន័យចេញ) |
|---|---|---|
| Product Name, SKU | Validate Input | Product Created/Updated |
| Category ID | Upload Images → Storage | Product List |
| Price, Stock, Discount | Save ទៅ `products` table | Stock Updated |
| Brand, Warranty | | |
| Specifications (RAM, Storage, CPU) | | |
| Product Variants (Color, Storage, Price) | Save ទៅ `product_variants` | Variants List |
| Status Toggle (active/inactive) | Update `products.status` | Product Hidden/Shown |

**Admin Page:** `/admin/products`

**API:** POST/PUT/DELETE `/products`, PATCH `/products/{id}/status` → `ProductController`

---

### ៥.១៤.៣ ការគ្រប់គ្រង Accessories

| Input (ទិន្នន័យចូល) | Process (ការដំណើរការ) | Output (ទិន្នន័យចេញ) |
|---|---|---|
| Name, Brand, Price | Validate Input | Accessory Created/Updated |
| Stock, Discount | Upload Image → Storage | Accessory List |
| Warranty | Save ទៅ `accessories` table | |
| Description | | |

**Admin Page:** `/admin/accessories`

**API:** POST/PUT/DELETE `/accessories` → `AccessoryController`

---

### ៥.១៤.៤ ការគ្រប់គ្រង Product Attributes

| Input (ទិន្នន័យចូល) | Process (ការដំណើរការ) | Output (ទិន្នន័យចេញ) |
|---|---|---|
| Attribute Type (color, storage, ram) | Save ទៅ `product_attribute_options` | Attribute Option Created |
| Attribute Value (e.g. "256GB") | | Attribute List |

**Admin Page:** `/admin/product-attributes`

**API:** `/product-attributes` → `ProductAttributeOptionController`

---

### ៥.១៤.៥ ការគ្រប់គ្រង Banners

| Input (ទិន្នន័យចូល) | Process (ការដំណើរការ) | Output (ទិន្នន័យចេញ) |
|---|---|---|
| Banner Image | Upload Image → Storage | Banner Created/Updated |
| Badge Label | Save ទៅ `banners` table | Banner List |
| Title, Subtitle | | |
| CTA Button Label | | |

**Admin Page:** `/admin/banners`

**API:** POST/PUT/DELETE `/admin/banners` → `BannerController`

---

## ៥.១៥ Module Order Management (ការគ្រប់គ្រងការបញ្ជាទិញ)

### ៥.១៥.១ ការ Approve/Reject Order

| Input (ទិន្នន័យចូល) | Process (ការដំណើរការ) | Output (ទិន្នន័យចេញ) |
|---|---|---|
| Order ID | Update `orders.status` | Order Status Updated |
| Action (approve/reject) | ដក Stock (`OrderInventoryService`) | FCM Push ជូន Customer |
| Reject Reason (optional) | Save `order_tracking_histories` | Telegram Alert |
| | ផ្ញើ FCM Notification | |

**Admin Page:** `/admin/orders`

**API:** POST `/admin/orders/{id}/approve` , POST `/admin/orders/{id}/reject`

---

### ៥.១៥.២ ការ Assign Staff ទៅ Order

| Input (ទិន្នន័យចូល) | Process (ការដំណើរការ) | Output (ទិន្នន័យចេញ) |
|---|---|---|
| Order ID | Update `orders.assigned_staff_id` | Staff Assigned |
| Staff User ID | Save Tracking History | FCM Notification ជូន Staff |
| | ផ្ញើ Notification | Order Appears in Staff App |

**API:** POST `/admin/orders/{id}/assign` → `OrderTrackingController@assign`

---

### ៥.១៥.៣ ការ Update Order Status

| Input (ទិន្នន័យចូល) | Process (ការដំណើរការ) | Output (ទិន្នន័យចេញ) |
|---|---|---|
| Order ID | Update `orders.status` | Status Updated |
| New Status | Save `order_tracking_histories` | FCM Push ជូន Customer |
| Note (optional) | ផ្ញើ FCM Notification | Customer App Timeline Update |

**API:** POST `/admin/orders/{id}/tracking-status`

---

### ៥.១៥.៤ ការ Generate Pickup QR

| Input (ទិន្នន័យចូល) | Process (ការដំណើរការ) | Output (ទិន្នន័យចេញ) |
|---|---|---|
| Order ID | `PickupTicketService` Generate Signed Token | QR Code Image |
| | Save Token + Expiry ទៅ `orders` | QR Displayed |
| **---** | **---** | **---** |
| QR Token (Scan) | Verify Token ត្រឹមត្រូវ | Order Marked Delivered |
| | ពិនិត្យ Token Expiry | `pickup_verified_at` Stamped |
| | Update Order Status | Confirmation Message |

**Admin Page:** `/admin/orders/pickup`

**API:** POST `/admin/orders/{id}/qr`, POST `/admin/orders/verify-qr`

---

### ៥.១៥.៥ Telegram Order Notification

| Input (ទិន្នន័យចូល) | Process (ការដំណើរការ) | Output (ទិន្នន័យចេញ) |
|---|---|---|
| Order ID | Load Order Details | Telegram Message ផ្ញើ |
| Telegram Chat ID | Format Message | Admin ឃើញ Order Alert |
| | POST ទៅ Telegram Bot API | |

**API:** POST `/admin/orders/{id}/notify-telegram` → `TelegramOrderService`

---

## ៥.១៦ Module Repair Management (ការគ្រប់គ្រងជួសជុល)

### ៥.១៦.១ ការ Assign Technician

| Input (ទិន្នន័យចូល) | Process (ការដំណើរការ) | Output (ទិន្នន័យចេញ) |
|---|---|---|
| Repair ID | Update `repair_requests.technician_id` | Technician Assigned |
| Technician ID | Update `technicians.active_jobs_count` | Notification ជូន Technician |
| | ផ្ញើ FCM Notification | |

**Admin Page:** `/admin/repairs/{id}`

**API:** POST `/repairs/{id}/assign-technician`

---

### ៥.១៦.២ Auto-Assign Technician

| Input (ទិន្នន័យចូល) | Process (ការដំណើរការ) | Output (ទិន្នន័យចេញ) |
|---|---|---|
| Repair ID | Query `technicians` WHERE available | Technician Selected Automatically |
| | ជ្រើស Technician Load តិចបំផុត | `repair_requests.technician_id` Update |
| | Update `active_jobs_count` | FCM Notification |

**API:** POST `/repairs/{id}/auto-assign`

---

### ៥.១៦.៣ Intake (ការទទួលឧបករណ៍)

| Input (ទិន្នន័យចូល) | Process (ការដំណើរការ) | Output (ទិន្នន័យចេញ) |
|---|---|---|
| Repair ID | Save ទៅ `intakes` table | Intake Record |
| IMEI / Serial Number | Update Repair Status = `intake` | Status Timeline Update |
| Device Condition Checklist | Upload Photos → Storage | Customer Notified |
| Intake Photos | ផ្ញើ FCM Notification | |
| Notes | | |

**API:** POST `/repairs/{id}/intake` → `RepairIntakeController@store`

---

### ៥.១៦.៤ Diagnostic (ការវិភាគបញ្ហា)

| Input (ទិន្នន័យចូល) | Process (ការដំណើរការ) | Output (ទិន្នន័យចេញ) |
|---|---|---|
| Repair ID | Save ទៅ `diagnostics` table | Diagnostic Record |
| Problem Description | Update Repair Status = `diagnosed` | Status Update |
| Parts Required | | Customer Notified |
| Labor Cost | | |
| Notes | | |

**API:** POST `/repairs/{id}/diagnostic` → `RepairDiagnosticController@store`

---

### ៥.១៦.៥ Quotation (តម្លៃប៉ាន់ស្មាន)

| Input (ទិន្នន័យចូល) | Process (ការដំណើរការ) | Output (ទិន្នន័យចេញ) |
|---|---|---|
| Repair ID | Save ទៅ `quotations` table | Quotation Record |
| Parts Cost | Update Repair Status = `quoted` | FCM Push ជូន Customer |
| Labor Cost | គណនា Total | Customer Sees Quotation in App |
| | ផ្ញើ Notification | |

**API:** POST `/repairs/{id}/quotation` → `RepairQuotationController@store`

---

### ៥.១៦.៦ Invoice & Repair Payment

| Input (ទិន្នន័យចូល) | Process (ការដំណើរការ) | Output (ទិន្នន័យចេញ) |
|---|---|---|
| Repair ID | Generate Invoice Number | Invoice Created |
| Subtotal, Tax | Save ទៅ `invoices` | Invoice Page |
| **---** | **---** | **---** |
| Invoice ID | Save ទៅ `repair_payments` | Payment Record |
| Type (deposit/final) | Update `invoices.payment_status` | Customer Notified |
| Amount, Method | ផ្ញើ Notification | |

**Admin Page:** `/admin/finance/invoices`

**API:** POST `/repairs/{id}/invoice`, POST `/payments/deposit`, POST `/payments/final`

---

### ៥.១៦.៧ Warranty (ការធានា)

| Input (ទិន្នន័យចូល) | Process (ការដំណើរការ) | Output (ទិន្នន័យចេញ) |
|---|---|---|
| Repair ID | Save ទៅ `warranties` table | Warranty Record |
| Duration (days) | គណនា Start/End Date | FCM Push ជូន Customer |
| Covered Issues | Update Repair Status = `delivered` | Warranty Card in App |

**Admin Page:** `/admin/inventory/warranties`

**API:** POST `/repairs/{id}/warranty` → `RepairWarrantyController@store`

---

## ៥.១៧ Module Technician Management

| Input (ទិន្នន័យចូល) | Process (ការដំណើរការ) | Output (ទិន្នន័យចេញ) |
|---|---|---|
| Name | Save ទៅ `technicians` table | Technician Created/Updated |
| Skill Set | | Technician List |
| Availability Status | | |

**Admin Page:** `/admin/technicians`

**API:** CRUD `/technicians` → `TechnicianController`

---

## ៥.១៨ Module Parts Inventory (ស្ទុំ គ្រឿងជួសជុល)

| Input (ទិន្នន័យចូល) | Process (ការដំណើរការ) | Output (ទិន្នន័យចេញ) |
|---|---|---|
| Part Name, Brand, SKU | Save ទៅ `parts` table | Part Created/Updated |
| Unit Cost, Stock | | Parts List |
| Status (available/out_of_stock) | | Low Stock Alert |
| Tag | | |

**Admin Page:** `/admin/parts`

**API:** CRUD `/parts` → `PartController`

---

## ៥.១៩ Module Voucher Management (ការគ្រប់គ្រង Voucher)

| Input (ទិន្នន័យចូល) | Process (ការដំណើរការ) | Output (ទិន្នន័យចេញ) |
|---|---|---|
| Voucher Code | Validate Unique Code | Voucher Created/Updated |
| Discount Type (fixed/percent) | Save ទៅ `vouchers` table | Voucher List |
| Discount Value | | |
| Min Order Amount | | |
| Start/Expiry Date | | |
| Usage Limit (total/per user) | | |
| Is Active Toggle | Update `vouchers.is_active` | Voucher Enabled/Disabled |

**Admin Page:** `/admin/vouchers`

**API:** CRUD `/vouchers` → `VoucherController`

---

## ៥.២០ Module Customer Management

| Input (ទិន្នន័យចូល) | Process (ការដំណើរការ) | Output (ទិន្នន័យចេញ) |
|---|---|---|
| (ចូលទំព័រ Customers) | Query `users` WHERE role = customer | Customer List |
| | `withCount('orders')` | Total Orders per Customer |
| | `withSum('orders', 'total_amount')` | Total Spent per Customer |
| Search (name/email/phone) | LIKE Query | Filtered Customer List |

**Admin Page:** `/admin/customers`

---

## ៥.២១ Module Staff/User Management

| Input (ទិន្នន័យចូល) | Process (ការដំណើរការ) | Output (ទិន្នន័យចេញ) |
|---|---|---|
| First Name, Last Name | Validate Unique Email | Staff User Created |
| Email, Phone | Hash Password | Staff List |
| Role (staff/technician) | Save ទៅ `users` table | |
| Password | | |

**Admin Page:** `/admin/users`

**API:** GET/POST `/admin/users` → `AdminUserController`

---

## ៥.២២ Module Support Chat (Admin Side)

| Input (ទិន្នន័យចូល) | Process (ការដំណើរការ) | Output (ទិន្នន័យចេញ) |
|---|---|---|
| (ចូលទំព័រ Support) | Query `support_conversations` | Conversation List |
| | Load Unread Count | Unread Badge |
| Conversation ID (click) | Load `support_messages` | Chat History |
| Message Text | Save ទៅ `support_messages` | Message Sent |
| | FCM Push ជូន Customer | Customer Notified |
| Assign to Staff | Update `support_conversations.assigned_to` | Staff Assigned |
| Status Update (open/resolved) | Update `support_conversations.status` | Conversation Closed/Opened |

**Admin Page:** `/admin/support`

**API:** GET `/admin/support/conversations`, POST `/admin/support/conversations/{id}/messages`

---

## ៥.២៣ Module Notification Campaign

| Input (ទិន្នន័យចូល) | Process (ការដំណើរការ) | Output (ទិន្នន័យចេញ) |
|---|---|---|
| Title, Message | Save ទៅ `admin_notification_campaigns` | Campaign Created |
| Audience (all / specific users) | ស្វែងរក FCM Tokens | Push Notification ផ្ញើ |
| Custom User IDs (optional) | FCM Batch Send | Delivery Summary |
| Deep Link (optional) | Update Campaign Status | |

**Admin Page:** `/admin/notifications`

**API:** POST `/admin/notifications/send`, GET `/admin/notifications/history`

---

## ៥.២៤ Module Finance & Reports

### ៥.២៤.១ ការមើល Payments

| Input (ទិន្នន័យចូល) | Process (ការដំណើរការ) | Output (ទិន្នន័យចេញ) |
|---|---|---|
| (ចូលទំព័រ Payments) | Query `payments` + `khqr_transactions` | Payment List |
| | Sum `paid_at` = today | Today Revenue |
| | Count pending payments | Pending Count |
| | Detect Reconciliation Issues | Reconciliation Alert |

**Admin Page:** `/admin/payments`

---

### ៥.២៤.២ Reports (Sales / Inventory / Customers)

| Input (ទិន្នន័យចូល) | Process (ការដំណើរការ) | Output (ទិន្នន័យចេញ) |
|---|---|---|
| Report Type | Query ទិន្នន័យ | Report Charts / Tables |
| Date Range | Format Data | |
| | | |
| Export Click | Generate CSV/Excel File | Download Link |
| | Save Export Record | File Downloaded |

**Admin Page:** `/admin/reports`, `/admin/finance/reports`

**API:** GET `/admin/reports/sales`, GET `/admin/reports/inventory`, POST `/admin/reports/export`

---

## ៥.២៥ IPO Summary Table — User App & Admin Panel

### ៥.២៥.១ User App (Flutter) — Summary

| # | Module | Input ចំបង | Process ចំបង | Output ចំបង |
|---|--------|-----------|------------|------------|
| 1 | Register | Name, Email, Password | Hash Password, Save | Bearer Token |
| 2 | Login | Email, Password | Verify Credentials | Bearer Token |
| 3 | Google Login | Firebase Token | Verify, Upsert User | Bearer Token |
| 4 | OTP | Phone, OTP Code | Hash, SMS Send, Verify | Bearer Token |
| 5 | Forgot Password | Email, OTP, New Password | Verify OTP, Hash | Login Access |
| 6 | Home Screen | App Start | Query Banners, Products | Home Content |
| 7 | Browse Products | Category, Filter | Query Database | Product List |
| 8 | Product Detail | Product ID | Load Product + Variants | Product Info |
| 9 | Search | Keywords | LIKE Query | Search Results |
| 10 | Add to Cart | Product ID, Qty | Check Stock, Save Cart | Cart Updated |
| 11 | Voucher | Voucher Code | Validate Rules | Discount |
| 12 | Location Picker | GPS | Get Coordinates | Map + Address |
| 13 | Place Order | Address, Payment | Save Order, Notify | Order Number |
| 14 | KHQR Payment | Amount, Order | Generate QR, Verify | Paid / Pending |
| 15 | My Orders | Bearer Token | Query Orders | Order List |
| 16 | Track Order | Order ID | Query History | Status Timeline |
| 17 | Pickup Ticket | Order ID | Load QR Token | QR Code |
| 18 | Repair Request | Device, Issue, Date | Save Request | Ticket ID |
| 19 | Repair Status | Repair ID | Load Status Logs | Timeline |
| 20 | Approve Quotation | Quotation ID | Update Status | Status Update |
| 21 | Repair Chat | Message | Save, Notify | Chat Updated |
| 22 | Notifications | Bearer Token | Query Notifications | Inbox |
| 23 | Support Chat | Message | Save, Push Notify | Chat Updated |
| 24 | Edit Profile | Name, Avatar | Update Users | Profile Updated |
| 25 | Address Book | Address Details | Local Storage | Address List |
| 26 | Order History | Bearer Token | Query Orders | History List |
| 27 | Favorites | Product ID | Local Storage | Favorites List |
| 28 | Theme/Language | Toggle | Save Preference | UI Changed |

### ៥.២៥.២ Admin Panel (Web) — Summary

| # | Module | Input ចំបង | Process ចំបង | Output ចំបង |
|---|--------|-----------|------------|------------|
| 1 | Admin Login | Email, Password | Verify, Create Session | Dashboard Access |
| 2 | Dashboard | Date Filter | Multi-table Query | Metrics Charts |
| 3 | Categories | Name, Image | Save, Upload | Category List |
| 4 | Products | Name, Price, Stock | Save, Upload | Product Catalog |
| 5 | Product Attributes | Type, Value | Save Attributes | Attribute Options |
| 6 | Accessories | Name, Price, Stock | Save, Upload | Accessory List |
| 7 | Banners | Image, Title | Upload, Save | Banner Slideshow |
| 8 | Approve/Reject Order | Order ID, Action | Update Status, Deduct Stock | Customer Notified |
| 9 | Assign Staff | Order ID, Staff ID | Update Order | Staff Notified |
| 10 | Order Status | Order ID, Status | Update, History Log | Customer Notified |
| 11 | Pickup QR | Order ID | Generate Token | QR Code |
| 12 | Verify QR | QR Token | Validate Token | Order Delivered |
| 13 | Telegram Notify | Order ID | Send to Telegram Bot | Admin Alert |
| 14 | Assign Technician | Repair ID, Tech ID | Update Repair | Tech Notified |
| 15 | Auto-Assign | Repair ID | Load Balance Select | Tech Assigned |
| 16 | Repair Intake | IMEI, Photos | Save Intake | Intake Recorded |
| 17 | Diagnostic | Problem, Parts | Save Diagnostic | Diagnostic Done |
| 18 | Quotation | Parts, Labor | Save, Notify | Customer Sees Quote |
| 19 | Invoice | Repair ID | Generate Invoice | Invoice Created |
| 20 | Repair Payment | Invoice ID, Amount | Save Payment | Invoice Paid |
| 21 | Warranty | Duration, Issues | Save Warranty | Warranty Issued |
| 22 | Technicians | Name, Skill | CRUD | Technician List |
| 23 | Parts Inventory | Name, Stock, Cost | CRUD | Parts List |
| 24 | Vouchers | Code, Discount | CRUD | Voucher List |
| 25 | Customers | (View only) | Query with Stats | Customer List |
| 26 | Staff/Users | Name, Role | Create Staff Account | User List |
| 27 | Support Chat | Message, Status | Save, Push Notify | Customer Notified |
| 28 | Notification Campaign | Title, Audience | Send FCM Batch | Push Sent |
| 29 | Payments View | (View only) | Query + Reconcile | Payment List |
| 30 | Reports | Type, Date Range | Query + Format | Charts + Export |

---

*ឯកសារ IPO នេះ ពណ៌នាអំពីដំណើរការ Input, Process, Output នៃ Module ទាំងអស់ ក្នុង User App (Flutter) ចំនួន ២៨ Module និង Admin Panel (Web) ចំនួន ៣០ Module ។*
