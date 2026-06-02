# ជំពូកទី ៤ — ការរចនា និងការអនុវត្តប្រព័ន្ធ
## KneaYerng Service Center Application

---

## ៤.១ ទិដ្ឋភាពទូទៅនៃប្រព័ន្ធ (System Overview)

KneaYerng Service Center Application គឺជាប្រព័ន្ធគ្រប់គ្រងមជ្ឈមណ្ឌលសេវាកម្ម ដែលត្រូវបានអភិវឌ្ឍឡើងដើម្បីសម្រួលដល់ការទំនាក់ទំនងរវាងអ្នកប្រើប្រាស់ (Customer) និងអ្នកគ្រប់គ្រង (Admin) តាមរយៈ Mobile Application ។ ប្រព័ន្ធនេះផ្ដោតលើមុខងារចំនួន ៦ ដូចខាងក្រោម:

- **E-Commerce** សម្រាប់ការទិញ-លក់ផលិតផល ដូចជាទូរស័ព្ទ និងគ្រឿងបន្ថែម
- **Repair Service** ដើម្បីផ្ដល់សេវាជួសជុលឧបករណ៍ ចាប់ពីការទទួល (Intake) រហូតដល់ការធានា (Warranty)
- **Order Tracking** សម្រាប់តាមដានការបញ្ជាទិញជា Real-time
- **Payment** ដើម្បីសម្រួលការទូទាត់ប្រាក់តាម KHQR (Bakong) ឬ Cash
- **Support Chat** ដើម្បីអនុញ្ញាតឱ្យអ្នកប្រើប្រាស់ជជែកបានផ្ទាល់ជាមួយបុគ្គលិក
- **Push Notification** ដើម្បីជូនដំណឹងទៅអ្នកប្រើប្រាស់នូវវិការផ្សេងៗ

---

## ៤.២ ស្ថាបត្យកម្មប្រព័ន្ធ (System Architecture)

### ៤.២.១ ជ្រើសរើសប្រភេទស្ថាបត្យកម្ម

ដើម្បីបំពេញតម្រូវការប្រព័ន្ធ KneaYerng Service Center Application បានជ្រើសរើសប្រើ **3-Tier Architecture** ដែលមាន ៣ Layer ចំបងៗ:

- **Presentation Layer** ជាផ្នែក Mobile Application ដែលអ្នកប្រើប្រាស់ប្រាស្រ័យទាក់ទង
- **Application Layer** ជាផ្នែក Backend API ដែលដំណើរការ Business Logic ទាំងអស់
- **Data Layer** ជា Database ដែលផ្ទុក និងគ្រប់គ្រងទិន្នន័យប្រព័ន្ធ

### ៤.២.២ តម្រូវការរបស់ប្រព័ន្ធ (System Requirements)

ប្រព័ន្ធ KneaYerng Service Center Application ប្រើ Architecture បែប Client–Server ដែលទំនាក់ទំនងគ្នារវាង Mobile Application (Flutter) និង Backend Server (Laravel) តាម Internet ។ ដើម្បីឱ្យប្រព័ន្ធ KneaYerng Service Center ដំណើរការបានគ្រប់ Function ត្រឹមត្រូវ ទាំងការ Login, ការ Order ផលិតផល, ការ Repair, ការ Payment ដោយ KHQR, ការ Chat Real-time, និងការ Push Notification គឺតម្រូវឱ្យមាន Resources ដូចខាងក្រោម ៖

- **Web Hosting** : ជាកន្លែងរក្សាទុក File ប្រព័ន្ធ Laravel (Back-end API), Admin Panel (Front-end), និង Database (MySQL) ដើម្បីឱ្យអ្នកប្រើប្រាស់ (Customer) និង Admin អាចភ្ជាប់ប្រើប្រាស់ប្រព័ន្ធបាន ។

- **Domain Name** : គឺជា URL (Uniform Resource Locator) ឬជាអាស័យដ្ឋាន ដែលជាឈ្មោះសម្គាល់ប្រព័ន្ធ (ឧ. `https://api.kneayerng.com`) ហើយត្រូវ Configure SSL Certificate ដើម្បីដំណើរការ HTTPS ។ Mobile App ប្រើ Domain Name ជា Base URL ដើម្បី Call API Backend ។

- **Internet Connection** : ជាស្ពានភ្ជាប់ User (Customer, Admin, Staff, Technician) ជាមួយ Server ដើម្បីអនុញ្ញាតការ Upload/Download ទិន្នន័យ, API Call Real-time ។ ចំណែក Server ផ្ទាល់ក៏ត្រូវការ Internet ដើម្បីភ្ជាប់ External Services ដូចជា Firebase, Pusher, Bakong, SMS Gateway ។

- **Web Server (Nginx)** : សម្រាប់ដំណើរការ File ប្រភេទ Server Side Script, ទទួល HTTP/HTTPS Request ហើយ Forward ទៅ PHP-FPM ដើម្បីដំណើរការ Laravel Application ។

- **MySQL Server** : គឺជា Database ចម្បងនៃប្រព័ន្ធ KneaYerng, សម្រាប់ធ្វើការរក្សាទុកទិន្នន័យទាំងអស់ ដូចជា Product, Order, Customer, Repair, Payment, Chat, Voucher, Warranty ។

ដើម្បីឱ្យប្រព័ន្ធ KneaYerng Service Center ដំណើរការបានគ្រប់ជ្រុងជ្រោយ ត្រូវការ Component ចំបងៗ ដូចខាងក្រោម ៖

- **Server ចម្បង (Cloud VPS / Web Hosting)**

  ប្រើដំណើរការ Laravel Backend API, Admin Panel, MySQL Database, Redis Queue ។ Server ត្រូវ ៖

  - ដំណើរការ Linux OS (Ubuntu/Debian) 24/7 ដោយ​មិនផ្អាក ។
  - ប្រើ Nginx Web Server ជាមួយ PHP-FPM ដើម្បីដំណើរការ Laravel Application ។
  - Authenticate (Login/Register) ដោយ Laravel Sanctum (Session Admin + API Token) ។
  - គ្រប់គ្រងបញ្ជូន Background Job (Queue Worker) ដូចជា Notification, SMS, Email ។
  - Backup Database ប្រចាំថ្ងៃ ទៅ Cloudflare R2 ស្វ័យប្រវត្តិ ។
  - ដំណើរការ Cron Scheduler (Artisan Schedule) ប្រចាំ ១ នាទី ។

- **Mobile Application (Flutter)**

  ប្រើជា Client Interface ជូន Customer ដំណើរការ Android និង iOS ។ Mobile App ត្រូវ ៖

  - Login ដោយ Firebase Auth (Phone OTP + Google Sign-In) ។
  - ស្វែងរក, Order ផលិតផល, Accessories, ដំណើរការ Checkout ។
  - ទូទាត់ប្រាក់ ដោយ Scan KHQR (ABA, Wing, ACLEDA, Bakong App) ។
  - តាមដាន Order Status, Repair Status Real-time ។
  - Chat ជាមួយ Support Staff Real-time ។
  - ទទួល Push Notification ពី Firebase Cloud Messaging (FCM) ។

- **Admin Panel (Web Browser Dashboard)**

  ប្រើជា Control Panel ជូន Admin, Staff, Technician ដំណើរការតាម Browser ។ Admin Panel ត្រូវ ៖

  - គ្រប់គ្រង Product, Category, Accessories, Banner, Voucher, Attributes ។
  - Approve, Reject, Track Order, Assign Staff ។
  - គ្រប់គ្រង Repair Workflow (Intake → Diagnostic → Quotation → Invoice → Warranty) ។
  - Reply Support Chat Real-time, Monitor Payment, Revenue Report ។
  - គ្រប់គ្រង User, Staff, Technician Account ។

- **External Services (ភាគីទីបី)**

  ប្រព័ន្ធ KneaYerng ភ្ជាប់ Service ខាងក្រៅ ដើម្បីបំពេញ Function ខ្ពស់ ។ Service ទាំងនោះ ៖

  - **Firebase Auth + FCM** — OTP Phone Login, Google Login, Push Notification ។
  - **Cloudflare R2** — Cloud Storage រក្សា Image, File Product, Repair Photo ។
  - **Pusher WebSocket** — Real-time Chat Support, Order Alert, Repair Notification ។
  - **KHQR / Bakong API** — Cambodia QR Payment Processing ។
  - **SMS Gateway (UniMTX / Infobip / Twilio)** — ផ្ញើ OTP SMS ជូន Customer ។
  - **Gmail SMTP** — ផ្ញើ Email Confirmation, Order, Repair Invoice ។
  - **Telegram Bot API** — ផ្ញើ Alert Order ថ្មី, Payment ជូន Admin Group ។

### ៤.២.៣ ការផ្តោត System Architecture

ប្រព័ន្ធប្រើ **Client–Server Architecture** ដែលបែងចែកជា ៣ ផ្នែក ដូចរូបខាងក្រោម:

```
┌─────────────────────────────────────────────────────────────────┐
│                   EXTERNAL SERVICES (ភាគីទីបី)                  │
│                                                                 │
│  Firebase Auth  │  FCM Push Notification  │  Bakong KHQR API   │
│  Google Sign-In │  Infobip/Unimatrix SMS   │  Telegram Bot API  │
│  SMTP Email     │  OpenStreetMap           │                    │
└────────┬──────────────┬──────────┬─────────────────┬───────────┘
         │              │          │                 │
         ▼              ▼          ▼                 ▼
┌────────────────────────────────────────────────────────────────┐
│              PRESENTATION LAYER (Flutter Mobile App)           │
│                                                                │
│   Screens  │  Services  │  Models  │  Widgets  │  Theme/L10n  │
└────────────────────────┬───────────────────────────────────────┘
                         │  HTTP REST API  (JSON Format)
                         │  Authorization: Bearer Token
                         ▼
┌────────────────────────────────────────────────────────────────┐
│             APPLICATION LAYER (Laravel PHP Backend)            │
│                                                                │
│  Routes  │  Controllers  │  Services  │  Models  │  Events    │
│  Middleware (auth:sanctum, admin)  │  Jobs / Queue            │
└────────────────────────┬───────────────────────────────────────┘
                         │  Eloquent ORM
                         ▼
┌────────────────────────────────────────────────────────────────┐
│                  DATA LAYER  (MySQL Database)                  │
│                                                                │
│          ៤៥ Tables  │  Migrations  │  Relationships           │
└────────────────────────────────────────────────────────────────┘
```

---

## ៤.៣ ស្ថាបត្យកម្ម Flutter Application (Frontend Architecture)

### ៤.៣.១ បច្ចេកវិទ្យា Frontend

Flutter គឺជា Open-source UI Toolkit ដែលបង្កើតដោយ Google ។ វាអនុញ្ញាតឱ្យ Developer សរសេរ Code មួយដង ហើយអាច Build ឱ្យដំណើរការបានលើ Android, iOS, Web, និង Desktop ។ ការជ្រើសរើស Flutter ក្នុងគម្រោងនេះ ផ្ដល់នូវ:

- **Hot Reload** ធ្វើឱ្យការអភិវឌ្ឍ (Development) រហ័ស
- **Single Codebase** សម្រាប់ Android និង iOS ក្នុងពេលតែមួយ
- **Rich Widget Library** ផ្ដល់ UI ស្អាត និងអាចប្រើជាមួយ Material Design

### ៤.៣.២ រចនាសម្ព័ន្ធ Folder

```
lib/
├── main.dart                       ← Entry point — Firebase init, API init
├── l10n/
│   └── app_localizations.dart      ← ការគ្រប់គ្រងភាសា (ខ្មែរ + English)
├── theme/
│   ├── app_palette.dart            ← Color scheme
│   └── app_theme.dart              ← Light/Dark Theme
├── models/                         ← Data Model (Plain Dart Objects)
│   ├── product.dart
│   ├── cart_item.dart
│   ├── user_profile.dart
│   ├── order_tracking_notification.dart
│   ├── pickup_ticket.dart
│   ├── support_chat.dart
│   ├── banner_item.dart
│   └── ...
├── services/                       ← Business Logic & HTTP Calls
│   ├── api_service.dart            ← HTTP Client, Token management
│   ├── app_notification_service.dart ← FCM Push Notification handler
│   ├── bakong_payment_service.dart ← KHQR payment integration
│   ├── cart_service.dart           ← Cart state management
│   ├── favorite_service.dart       ← Local favorite products
│   ├── address_book_service.dart   ← Local saved addresses
│   ├── language_service.dart       ← Language switching
│   └── theme_service.dart          ← Theme switching
├── screens/                        ← UI Screens
│   ├── Auth/                       ← Login, Register, OTP, Forgot Password
│   ├── home/                       ← Home Screen, Banner, Products
│   ├── products/                   ← Product list, Product detail
│   ├── categories/                 ← Category list, Category products
│   ├── cart/                       ← Cart, Checkout, KHQR Payment
│   ├── orders/                     ← Order list, Delivery tracking
│   ├── repair/                     ← Repair request submission
│   ├── tickets/                    ← Repair ticket detail
│   ├── notifications/              ← Notification inbox
│   ├── support/                    ← Live support chat
│   ├── search/                     ← Search results
│   └── profile/                    ← User profile, Order history
└── widgets/                        ← Reusable UI Components
    ├── auth_guard.dart
    ├── cart_added_bottom_bar.dart
    └── page_transitions.dart
```

### ៤.៣.៣ Navigation Flow

ការ Navigate រវាង Screen ក្នុង Application ត្រូវបានរៀបចំដូចខាងក្រោម:

```
កម្មវិធីចាប់ផ្ដើម (App Start)
         │
         ▼
  SplashScreen (បង្ហាញ ២ វិនាទី)
         │
         ├── [Token ត្រឹមត្រូវ] ──────────► MainNavigationScreen
         │                                       ├── Tab 0 : Home
         │                                       ├── Tab 1 : Categories
         │                                       ├── Tab 2 : Orders
         │                                       ├── Tab 3 : Favorites
         │                                       └── Tab 4 : Profile
         │
         └── [គ្មាន Token] ─────────────► OnboardingScreen
                                                ├── LoginScreen
                                                │      └── OTP Verify
                                                └── RegisterScreen
                                                       └── Registration Success
```

### ៤.៣.៤ State Management

ប្រព័ន្ធប្រើ **ValueNotifier + Singleton Service Pattern** ដើម្បីគ្រប់គ្រង State ទូទាំង Application:

- **ApiService** — Singleton ដំណើរការ HTTP Request ទាំងអស់ និង Auth Token
- **CartService** — Singleton + `ValueNotifier<List<CartItem>>` ធ្វើ UI Update ស្វ័យប្រវត្តិ
- **ThemeService** — Singleton + `ValueNotifier<ThemeMode>` ប្ដូររវាង Light/Dark
- **LanguageService** — Singleton + `ValueNotifier<Locale>` ប្ដូររវាង ខ្មែរ/English
- **AppNotificationService** — Singleton ដំណើរការ FCM Push Notification
- **FavoriteService** — ផ្ទុកជា Local SharedPreferences
- **AddressBookService** — ផ្ទុកជា Local SharedPreferences

### ៤.៣.៥ ការគ្រប់គ្រងភាសា (Localization)

Application ក្នុងគម្រោងនេះ គ្រប់គ្រងភាសាចំនួន ២ គឺ **ភាសាខ្មែរ** និង **ភាសាអង់គ្លេស** ។ ការប្ដូរភាសាអាចធ្វើបានភ្លាមៗ តាមរយៈ `LanguageService` ដោយប្រើ `flutter_localizations` Package ។

---

## ៤.៤ ស្ថាបត្យកម្ម Laravel Backend (Backend Architecture)

### ៤.៤.១ បច្ចេកវិទ្យា Backend

**Laravel** គឺជា PHP Framework ដ៏ពេញនិយម ។ វាផ្ដល់នូវ:

- **MVC Architecture** (Model–View–Controller) ធ្វើឱ្យ Code ស្អាត និងងាយគ្រប់គ្រង
- **Eloquent ORM** ដើម្បីទំនាក់ទំនងជាមួយ Database ដោយប្រើ PHP Object
- **Sanctum** ដើម្បីគ្រប់គ្រង API Authentication ដោយ Token
- **Queue / Jobs** ដើម្បីដំណើរការការងារ Background ដូចជា Email, SMS

### ៤.៤.២ Request Processing Flow

```
HTTP Request ពី Flutter App
         │
         ▼
┌─────────────────────┐
│    Middleware        │  — ពិនិត្យ Token (auth:sanctum) ឬ Admin Role
└──────────┬──────────┘
           │
           ▼
┌─────────────────────┐
│    Controller        │  — ទទួល Request, Validate Input
└──────────┬──────────┘
           │
           ▼
┌─────────────────────┐
│    Service           │  — Business Logic (Calculation, Rules)
└──────────┬──────────┘
           │
           ▼
┌─────────────────────┐
│  Eloquent Model      │  — ទំនាក់ទំនង Database
└──────────┬──────────┘
           │
           ▼
┌─────────────────────┐
│  MySQL Database      │  — ផ្ទុក / ទាញ ទិន្នន័យ
└─────────────────────┘
           │
           ▼
     JSON Response ➜ Flutter App
```

### ៤.៤.៣ ការបែងចែក API Route

| Route Group | Middleware | គោលបំណង |
|-------------|-----------|---------|
| `/auth/*` | Public | Login, Register, OTP, Forgot Password |
| `/public/*` , `/banners`, `/search` | Public | មើល Product, Category — គ្មាន Login |
| `/cart`, `/user/orders`, `/repairs/*`, `/support/*` | `auth:sanctum` | Customer Actions |
| `/admin/*`, `/orders`, `/technicians`, `/repairs` | `admin` | Admin/Staff Only |

### ៤.៤.៤ Services Layer

Services Layer ដើរតួជាស្រទាប់ Business Logic ដំណើរការការងារដូចជា:

- **BakongOpenApiService** — Generate QR Code KHQR និង Check Transaction Status
- **FirebasePushNotificationService** — បញ្ជូន Push Notification តាម FCM
- **OtpService / OtpDeliveryService** — គ្រប់គ្រងការបញ្ជូន OTP តាម Email ឬ SMS
- **OrderInventoryService** — ដក Stock ចេញពី Inventory បន្ទាប់ពី Order ត្រូវបាន Approve
- **OrderTrackingService** — Update Order Status ហើយ Notify អ្នកប្រើប្រាស់
- **PickupTicketService** — Generate QR Code សម្រាប់ Pickup Order
- **RepairNotificationService** — បញ្ជូនការជូនដំណឹង Repair Events
- **TelegramOrderService** — Notify Admin តាម Telegram Bot
- **VoucherService** — Validate និង Apply Discount Voucher

---

## ៤.៥ ស្ថាបត្យកម្មទិន្នន័យ (Database Architecture)

### ៤.៥.១ ទិដ្ឋភាពទូទៅ

ប្រព័ន្ធប្រើ **MySQL Database** ដែលមានតារាង (Table) ចំនួន **៤៥** ។ ត្រូវបានបែងចែកជា ៥ Domain ដូចខាងក្រោម:

| Domain | ចំនួន Table | ខ្លឹមសារ |
|--------|:-----------:|---------|
| Laravel Auth & Infrastructure | ៩ | Users, Sessions, Tokens, Jobs |
| Catalog & Content | ៦ | Products, Categories, Banners, Accessories |
| Orders, Cart & Payments | ៩ | Orders, Cart, Vouchers, Payments, KHQR |
| Repair Service Management | ១៣ | Repair, Intake, Diagnostic, Invoice, Warranty |
| Tracking, Support & Notifications | ៨ | OTP, Notifications, Support Chat, FCM Tokens |
| **សរុប** | **៤៥** | |

### ៤.៥.២ ความসম্পর্ক Core Entities (Entity Relationship)

**Domain E-Commerce:**
```
users ──────┬──── carts ──── cart_items ──── products / accessories
            ├──── orders ─── order_items ─── products / accessories
            │        ├────── payments
            │        └────── khqr_transactions
            └──── voucher_redemptions ────── vouchers
```

**Domain Repair Service:**
```
users ────── repair_requests ──── technicians
                    │
                    ├── intakes              (IMEI, photos, device condition)
                    ├── diagnostics          (problem, parts needed, labor cost)
                    ├── quotations           (total cost, approval status)
                    ├── parts_usages ─────── parts  (inventory)
                    ├── repair_status_logs   (audit trail)
                    ├── chat_messages        (customer ↔ technician)
                    ├── invoices ──────────── repair_payments
                    └── warranties           (duration, covered issues)
```

**Domain Tracking & Notifications:**
```
users ────── order_tracking_notifications
        ├─── order_tracking_histories ──── orders
        ├─── support_conversations ─────── support_messages
        ├─── mobile_device_tokens          (FCM tokens)
        └─── otp_verifications / email_otps
```

### ៤.៥.៣ រចនាសម្ព័ន្ធតារាងចំបង (Key Table Schemas)

**តារាង `users` — អ្នកប្រើប្រាស់:**

តារាងនេះផ្ទុកព័ត៌មានអ្នកប្រើប្រាស់ទាំងអស់ ទាំង Customer, Staff, Technician, និង Admin ។ ភាពខុសគ្នា Role ត្រូវបានកំណត់ដោយ Column `role` ។

| Column | Type | គោលបំណង |
|--------|------|---------|
| `id` | INT | Primary Key |
| `first_name`, `last_name` | VARCHAR | ឈ្មោះ |
| `email`, `phone` | VARCHAR (unique) | ព័ត៌មានទំនាក់ទំនង |
| `role` | ENUM | `customer` / `staff` / `technician` / `admin` |
| `password` | VARCHAR | Hashed Password |
| `avatar` | VARCHAR | Profile Image |
| `otp_code`, `otp_expires_at` | VARCHAR/TIMESTAMP | OTP Verification |

**តារាង `orders` — ការបញ្ជាទិញ:**

| Column | Type | គោលបំណង |
|--------|------|---------|
| `order_number` | VARCHAR | លេខ Order |
| `user_id` | FK | Customer |
| `order_type` | ENUM | `delivery` / `pickup` |
| `payment_method` | ENUM | `cash` / `bakong` |
| `status` | VARCHAR | `pending` → `approved` → `processing` → `delivered` |
| `payment_status` | ENUM | `pending` / `paid` / `failed` |
| `delivery_lat`, `delivery_lng` | DECIMAL | ទីតាំង GPS |
| `pickup_qr_token` | VARCHAR | QR Token សម្រាប់ Pickup |
| `total_amount` | DECIMAL | ថ្លៃសរុប |

**តារាង `repair_requests` — ការស្នើជួសជុល:**

| Column | Type | គោលបំណង |
|--------|------|---------|
| `customer_id` | FK | អ្នកស្នើ |
| `technician_id` | FK | ជាងបច្ចេកទេស |
| `device_model` | VARCHAR | ម៉ូដែលឧបករណ៍ |
| `issue_type` | VARCHAR | ប្រភេទបញ្ហា |
| `service_type` | VARCHAR | ប្រភេទសេវា |
| `status` | VARCHAR | `submitted` → `intake` → `diagnosed` → `quoted` → `in_repair` → `completed` |
| `appointment_datetime` | TIMESTAMP | ពេលវេលាណាត់ |

---

## ៤.៦ ប្រព័ន្ធ Authentication និង Authorization

### ៤.៦.១ វិធីសាស្ត្រ Authentication

ប្រព័ន្ធអនុញ្ញាតឱ្យ Login ដោយ ៣ វិធី:

**វិធីទី ១ — Email/Password:**
```
Register ──► Login ──► Bearer Token (Laravel Sanctum) ──► API Access
```

**វិធីទី ២ — Phone OTP:**
```
បញ្ចូលលេខទូរស័ព្ទ ──► ទទួល SMS OTP ──► Verify OTP ──► Bearer Token
```

**វិធីទី ៣ — Google Sign-In:**
```
Google Auth (Firebase) ──► ID Token ──► Backend Verify ──► Bearer Token
```

### ៤.៦.២ ការបែងចែកសិទ្ធ (Role-Based Access Control)

| Role | សិទ្ធអនុញ្ញាត |
|------|-------------|
| Guest | មើល Products, Categories, Banners |
| Customer | Cart, Orders, Repair, Support Chat, Notifications |
| Staff | ចូលមើល Assigned Orders, Update Delivery Status |
| Technician | Repair Workflow (Intake → Diagnostic → In Repair) |
| Admin | Full Access: Users, Reports, All Orders, Campaigns |

---

## ៤.៧ ប្រព័ន្ធទូទាត់ប្រាក់ (Payment System)

### ៤.៧.១ KHQR (Bakong) Payment

KHQR គឺជា QR Payment Standard របស់ **ធនាគារជាតិកម្ពុជា (NBC)** ។ ក្នុងប្រព័ន្ធ KneaYerng Service Center ការ Integrate KHQR ដំណើរការដូចខាងក្រោម:

```
Flutter App              Laravel Backend           Bakong API
     │                         │                       │
     ├─ POST /generate-qr ─────►                        │
     │                         ├── KhqrGenerator ───────►
     │                         │◄── QR String ──────────┤
     │◄── QR String + txnId ───┤                       │
     │                         │                       │
     │  [បង្ហាញ QR ជូន User]   │                       │
     │                         │                       │
     ├─ POST /check-transaction►                        │
     │                         ├── BakongOpenApiService ►
     │                         │◄── Transaction Status ─┤
     │◄── paid / pending ───────┤                       │
```

---

## ៤.៨ ប្រព័ន្ធ Repair Service Workflow

### ៤.៨.១ Repair Lifecycle

ដំណើរការ Repair Service ចាប់ពីដើម រហូតដល់ចប់ មាន ១០ ជំហាន:

```
[១] Customer ស្នើ Repair Request (device model, issue, appointment)
         │
         ▼
[២] Staff ធ្វើ Intake (IMEI, condition checklist, photos)
         │
         ▼
[៣] Technician ធ្វើ Diagnostic (problem found, parts needed)
         │
         ▼
[៤] Staff បង្កើត Quotation (ថ្លៃ parts + labor)
         │
         ├── [Customer Approve] ──────►
         │                            │
         │                            ▼
         │                    [៥] Technician ជួសជុល (in_repair)
         │                            │
         │                            ▼
         │                    [៦] ជួសជុលរួច (completed)
         │                            │
         │                            ▼
         │                    [៧] Invoice Generated
         │                            │
         │                            ▼
         │                    [៨] Customer បង់ប្រាក់
         │                            │
         │                            ▼
         │                    [៩] ផ្ដល់ Warranty
         │
         └── [Customer Reject] ──────► បិទ Case
```

---

## ៤.៩ ប្រព័ន្ធជូនដំណឹង (Notification System)

### ៤.៩.១ Push Notification Architecture

ប្រព័ន្ធប្រើ **Firebase Cloud Messaging (FCM)** ដើម្បីបញ្ជូន Push Notification ទៅ Mobile ។ Device Token ត្រូវបានរក្សាទុកក្នុងតារាង `mobile_device_tokens` ។

```
Backend Event កើតឡើង
       │
       ▼
FirebasePushNotificationService
       │
       ├── ស្វែងរក Token ពី mobile_device_tokens
       │
       ▼
Firebase Cloud Messaging (FCM)
       │
       ▼
Flutter AppNotificationService
       │
       ├── [Foreground] ─────► បង្ហាញ Banner Notification
       └── [Background] ─────► System Notification
                                    └── Tap ─► Navigate ទៅ Screen ត្រូវគ្នា
```

### ៤.៩.២ ប្រភេទការជូនដំណឹង

ក្នុងប្រព័ន្ធ KneaYerng Service Center មានការជូនដំណឹងចំនួន ៦ ប្រភេទ:

- **Order Status** — នៅពេល Admin Approve ឬ Ship Order
- **Repair Status** — នៅពេល Technician Update ជំហាន Repair
- **Quotation Ready** — នៅពេល Quotation ថ្មីត្រូវបានបង្កើត
- **Payment Confirmed** — នៅពេល KHQR Payment ត្រូវបាន Verify
- **Support Message** — នៅពេល Staff Reply ក្នុង Support Chat
- **Admin Campaign** — នៅពេល Admin Broadcast Notification ជូន User

---

## ៤.១០ External Services Integration

ប្រព័ន្ធ KneaYerng Service Center Integrate ជាមួយ Service ភាគីទីបីចំនួន ៩:

| Service | Package / SDK | គោលបំណង |
|---------|--------------|---------|
| **Firebase Auth** | `firebase_auth` | Google Login Verification |
| **Firebase FCM** | `firebase_messaging` | Push Notification |
| **Google Sign-In** | `google_sign_in` | Social Login |
| **KHQR / Bakong** | `khqr_sdk` | QR Payment |
| **OpenStreetMap** | `flutter_map` | ជ្រើសរើសទីតាំង Delivery |
| **GPS** | `geolocator` | ទាញទីតាំង GPS |
| **Infobip / Unimatrix** | Custom Service | OTP SMS |
| **Telegram Bot** | Bot API | Order Alert ជូន Admin |
| **SMTP Email** | Laravel Mail | Email OTP |

---

## ៤.១១ Project Statistics

| Metric | ចំនួន |
|--------|:------:|
| Database Tables | ៤៥ |
| Flutter Screens | ៣០+ |
| Flutter Services | ១២ |
| Laravel Controllers | ៥០+ |
| Laravel Services | ១៤ |
| API Route Groups | ៣ (Public, Auth, Admin) |
| External Integrations | ៩ |
| ភាសាដែល Support | ២ (ខ្មែរ, English) |

---

*ឯកសារស្ថាបត្យកម្មនេះ ពណ៌នាអំពីការរចនា និងការអនុវត្តប្រព័ន្ធ KneaYerng Service Center Application ចាប់ពី Presentation Layer (Flutter) រហូតដល់ Application Layer (Laravel) និង Data Layer (MySQL) ព្រមទាំង External Services Integration ទាំងអស់ ។*
