# ឯកសារការគ្រោងប្រព័ន្ធ — KneaYerng Service Center App

---

## ១. ការគ្រោងប្រព័ន្ធ

### ១.១ ទិដ្ឋភាពទូទៅ

KneaYerng Service Center App គឺជាប្រព័ន្ធព័ត៌មានវិទ្យាដែលត្រូវបានបង្កើតឡើងដើម្បីគ្រប់គ្រងហាងលក់ និងថែទាំទូរស័ព្ទ។ ប្រព័ន្ធនេះរួមបញ្ចូលទាំងការលក់ផលិតផលតាម Mobile App ការគ្រប់គ្រងការជួសជុលទូរស័ព្ទ ការតាមដានការធានាផលិតផល និងការជូនដំណឹងដល់អតិថិជនតាម Push Notification, SMS, និង Telegram។

ប្រព័ន្ធនេះត្រូវបានរចនាឡើងដើម្បីបម្រើអ្នកប្រើប្រាស់ ៤ ប្រភេទ គឺ អតិថិជន (Customer) ដែលអាចទិញទំនិញ ស្នើសុំជួសជុល និងមើលការធានា, បុគ្គលិក (Staff) ដែលទទួលខុសត្រូវក្នុងការដំណើរការការបញ្ជាទិញ និងការដឹកជញ្ជូន, ជាងជួសជុល (Technician) ដែលធ្វើ Diagnostic ជួសជុល និងចេញវិក្កយបត្រ, និងអ្នកគ្រប់គ្រង (Admin) ដែលគ្រប់គ្រងប្រព័ន្ធទាំងមូល ពិនិត្យការបញ្ជាទិញ និងចេញរបាយការណ៍ជាប្រចាំ។

### ១.២ គោលបំណងប្រព័ន្ធ

ប្រព័ន្ធ KneaYerng Service Center ត្រូវបានបង្កើតឡើងដើម្បីបំពេញគោលដៅដូចខាងក្រោម។ ទីមួយ ប្រព័ន្ធធ្វើឱ្យការលក់ងាយស្រួល ដោយអតិថិជនអាចទិញផលិតផលបានគ្រប់ពេល គ្រប់ទីកន្លែងតាម Mobile App ដោយមិនចាំបាច់មករកហាងផ្ទាល់។ ទីពីរ ប្រព័ន្ធធ្វើឱ្យការគ្រប់គ្រងការជួសជុលក្លាយជាប្រព័ន្ធ ដោយមានដំណើរការច្បាស់លាស់ពី Intake រហូតដល់ Diagnostic, Quotation, Repair, Invoice, និង Warranty។ ទីបី ប្រព័ន្ធបន្ថែមមធ្យោបាយការទូទាត់ប្រាក់ច្រើនប្រភេទ ដូចជា Cash, ABA, Bakong, KHQR QR Code ដើម្បីបំពេញតម្រូវការអតិថិជន។ ទីបួន ប្រព័ន្ធអនុញ្ញាតឱ្យអ្នកប្រើប្រាស់តាមដានស្ថានភាពការបញ្ជាទិញ ការជួសជុល និងការដឹកជញ្ជូនក្នុងពេលវេលាជាក់ស្ដែង (Real-time)។ ទីប្រាំ ប្រព័ន្ធមានមុខងារតាមដានការធានាផលិតផល ដើម្បីឱ្យអតិថិជនដឹងថាការធានារបស់ពួកគេនៅសល់ប៉ុន្មានថ្ងៃ។ ទីប្រាំមួយ Admin អាចរាប់យករបាយការណ៍ការលក់ ស្តុក និងអតិថិជន ហើយ Export ជា CSV ឬ PDF បាន។

### ១.៣ ដំណើរការអាជីវកម្មសំខាន់

ដំណើរការទិញ-លក់ ចាប់ផ្ដើមពីអតិថិជនស្វែងរកផលិតផល ដាក់ក្នុង Cart ជ្រើសរើសរបៀប Checkout ជ្រើសរើសវិធីបង់ប្រាក់ ហើយ Admin អនុម័ត។ បន្ទាប់ពីអនុម័ត បុគ្គលិកដឹកជញ្ជូន ឬអតិថិជនមកទទួលនៅហាង។ ភ្លាមៗពេលទទួលទំនិញ ប្រព័ន្ធ Activate ការធានាអូតូម៉ាទិច។

ដំណើរការជួសជុល ចាប់ផ្ដើមពីអតិថិជនបំពេញពាក្យស្នើសុំជួសជុលតាម App ឬមកឱ្យហាងផ្ទាល់។ ជាងជួសជុលធ្វើការ Intake ពិនិត្យទូរស័ព្ទ ថតរូបភាព និងចូលក្នុងប្រព័ន្ធ។ បន្ទាប់មក ជាងជួសជុលធ្វើ Diagnostic វិភាគបញ្ហា ហើយបន្ទាប់ Admin ចេញ Quotation ជូនអតិថិជន។ ប្រសិនបើអតិថិជន Approve ជាងជួសជុលបន្ត Repair រហូតដល់ QC Ready សម្រាប់ Pickup ហើយ Completed ចុងក្រោយ Invoice និង Warranty ត្រូវបានចេញ។

---

## ២. ការគ្រោងលើ Input Design

### ២.១ ប្រភេទ Input

ប្រព័ន្ធ KneaYerng Service Center ទទួល Input ពី ៦ ប្រភេទ។ ទីមួយ គឺ Form Input ដែលជា Input ធម្មតាដែល User បំពេញដោយខ្លួនឯង ដូចជា ទម្រង់ Register, Login, ការស្នើសុំជួសជុល, ការបញ្ចូលអាសយដ្ឋាន។ ទីពីរ គឺ File Upload ដែលជាការ Upload រូបភាព ឬឯកសារ ដូចជា រូបភាពផលិតផល រូបភាព Intake ទូរស័ព្ទ។ ទីបី គឺ QR Scan ដែលបុគ្គលិក Scan QR Code ដើម្បីបញ្ជាក់ការ Pickup ។ ទីបួន គឺ GPS Location ដែល App ប្រើ GPS ពី Device ដើម្បីជ្រើសរើសទីតាំងដឹកជញ្ជូន។ ទីប្រាំ គឺ Selection Input ដូចជា Dropdown, Radio Button សម្រាប់ជ្រើស Payment Method, Order Type, Product Variant។ ទីប្រាំមួយ គឺ OTP Code ដែលជាលេខ ៦ ខ្ទង់ ដែលបានផ្ញើតាម SMS ឬ Email ដើម្បីបញ្ជាក់អត្តសញ្ញាណ។

### ២.២ Input Design — ទម្រង់ Register

ទម្រង់ Register ទាមទារឱ្យ User បំពេញ ឈ្មោះ, នាមត្រកូល, Email ឬ Phone, ពាក្យសម្ងាត់, បញ្ជាក់ពាក្យសម្ងាត់, និង Upload រូបភាពប្រសិនបើចង់។ ច្បាប់ Validation ដែលប្រព័ន្ធពិនិត្យ ឈ្មោះត្រូវតែ Required, Email ត្រូវតែ Unique និងត្រូវ Format, Phone ត្រូវ Format +855XXXXXXXXX, Password ត្រូវ Min 8 Characters, ហើយ Password ត្រូវ Match គ្នាជាមួយ Confirm Password។

### ២.៣ Input Design — OTP

ទម្រង់ OTP ត្រូវការ User បញ្ចូល OTP ៦ ខ្ទង់ ដែលបានផ្ញើ។ OTP Valid ១០ នាទី, Max Attempts ៥ ដង, Rate Limit ១០ Request ក្នុង ១ IP ក្នុង ១០ នាទី, ហើយ ៥ Request ក្នុង ១ Phone/Email ក្នុង ១ ម៉ោង។ ប្រសិនបើ Exceed ប្រព័ន្ធ Lock OTP ហើយ User ត្រូវ Wait។

### ២.៤ Input Design — ការបន្ថែមផលិតផល (Admin)

Admin ត្រូវបំពេញ ឈ្មោះផលិតផល, Category, SKU, តម្លៃ, តម្លៃបញ្ចុះ, ចំនួនស្តុក, Variants (Storage, Color, RAM, Price per Variant), ការធានា (No Warranty, ៣ ខែ, ៦ ខែ, ១ ឆ្នាំ), Tag (Hot Sale, Top Seller, Promotion), Upload រូបភាព (JPG/PNG Max 5MB), និង Specifications (Rich Text)។ SKU ត្រូវ Unique, Price ត្រូគ Numeric Min 0, Image ត្រូ MIME Type + Size Validate។

### ២.៥ Input Design — Checkout

Checkout Flow ចែកជា ៣ ជំហាន។ ជំហានទី ១ User ជ្រើស Order Type ថាជា Delivery, Pickup, ឬ On-Site។ ជំហានទី ២ ប្រសិនបើ Delivery User បំពេញ ឈ្មោះ, Phone, អាសយដ្ឋាន, ឬ Pin Location លើ Map ដោយ GPS។ ជំហានទី ៣ User ជ្រើស Payment Method (Cash, ABA, Bakong KHQR), អាចបន្ថែម Voucher Code, ហើយបញ្ជាក់ Order។ ប្រសិនបើ Bakong KHQR ប្រព័ន្ធ Generate QR Code ហើយ Check Payment Status ដោយ Auto។

### ២.៦ Input Design — ទម្រង់ស្នើសុំជួសជុល

User ត្រូវបំពេញ ម៉ាកទូរស័ព្ទ, ម៉ូដែល, IMEI (Optional), ការពន្យល់បញ្ហា, ប្រភេទ (Drop-off, Pickup, On-site), ថ្ងៃដែល Schedule, និង Upload រូបភាពទូរស័ព្ទ (Max 5 Files)។

### ២.៧ Input Design — Intake & Diagnostic (Technician)

ជំហាន Intake ជាងជួសជុលបំពេញ Checklist ពិនិត្យស្ថានភាពអេក្រង់, គ្រាប់, ស្ទ្រាក់ (Physical Damage), អាគុយ, Camera, Charging Port, ហើយថតរូបភាពខាងមុខ និងខាងក្រោយ។ ជំហាន Diagnostic ជាងជួសជុលកត់ត្រា បញ្ហារកឃើញ, ថ្លៃការងារ, Parts ដែល​ប្រើ (ជ្រើស Part ពី Inventory ដោយ Qty + Unit Price), និង Notes បន្ថែម។

### ២.៨ Input Design — KHQR Payment

ប្រព័ន្ធ Backend ទទួល Input merchant_id, amount, currency (USD ឬ KHR), order_id ហើយ Call API ទៅ Bakong ដើម្បី Generate QR String + MD5 Hash។ Flutter App បង្ហាញ QR Code ហើយ Polling Check Payment Status ជារៀងរហូតរហូតដល់ SUCCESS ឬ User Cancel។

---

## ៣. ការគ្រោងលើ Output Design

### ៣.១ ប្រភេទ Output

ប្រព័ន្ធ KneaYerng Service Center ផ្ដល់ Output ជា ៧ ប្រភេទ។ ទីមួយ គឺ Screen Display ដែលបង្ហាញព័ត៌មាន Order, Repair Status, Warranty, Map Tracking នៅក្នុង App។ ទីពីរ គឺ Push Notification ដែលជូនដំណឹងដល់ Device ពី Order Update, Repair Status Change, Messages។ ទីបី គឺ PDF Documents ដូចជា Invoice, Quotation, Report Export។ ទីបួន គឺ CSV Export ដូចជា Sales Report, Inventory Report សម្រាប់ Admin Download។ ទីប្រាំ គឺ QR Code ដូចជា Pickup Ticket QR, KHQR Payment QR។ ទីប្រាំមួយ គឺ SMS/OTP Message ដំណើរការតាម Infobip ឬ Unimatrix។ ទីប្រាំពីរ គឺ Telegram Message ដែល Bot ផ្ញើ Order Notification ទៅ Group Chat ដោយ Auto។

### ៣.២ Output Design — Home Screen

Home Screen បង្ហាញ Search Bar នៅខាងលើ, Banner/Promotion Slider ដែល Admin Upload, Category Grid ដូចជា Phones, Battery, Laptop, Parts, និង Product List (Hot Sale, Top Seller) ជា Card មាន រូបភាព, ឈ្មោះ, តម្លៃ, ប៊ូតុង Add to Cart។ Navigation Bar នៅខាងក្រោមមាន Home, Orders, Repair, Profile។

### ៣.៣ Output Design — Order Detail Screen

Order Detail Screen បង្ហាញ Order Number, Status (Pending/Approved/Delivering/Completed), List ផលិតផល, Subtotal, Voucher Discount, Delivery Fee, Total, Payment Method និង Status (Paid/Unpaid), Status Timeline ជា Vertical Stepper (Pending → Approved → Assigned → Delivering → Completed), ហើយ Button ទៅ Delivery Tracking Map ប្រសិនបើជា Delivery Order។

### ៣.៤ Output Design — Repair Status Screen

Repair Status Screen បង្ហាញ ឈ្មោះទូរស័ព្ទ, បញ្ហា, Current Status, Repair Timeline (Received → Diagnosing → Waiting Approval → In Repair → QC → Ready → Completed), Quotation Details (Parts, Labor, Total), Deposit Paid, Remaining Balance, ហើយ Button Chat ដើម្បីទំនាក់ទំនងជាមួយជាងជួសជុល។

### ៣.៥ Output Design — Warranty Screen

Warranty Screen បង្ហាញ Card ការធានានីមួយៗ មាន ឈ្មោះផលិតផល/ការជួសជុល, ថ្ងៃចាប់ផ្ដើម, ថ្ងៃផុតកំណត, Progress Bar (ពណ៌ Green ប្រសិនបើ OK, Orange ប្រសិនបើ Expiring Soon), ចំនួនថ្ងៃនៅសល់, និង Status (Active/Expired/Voided)។

### ៣.៦ Output Design — Invoice PDF

Invoice PDF មាន Header ជាមួយ Logo, ឈ្មោះហាង, Phone, Email, Invoice Number, Date, ឈ្មោះអតិថិជន, Table ផ្នែក Description, Qty, Price, Amount, Subtotal, Discount, Total, Deposit Paid, Balance Due, ហើយចុងក្រោយ បញ្ជាក់ Warranty Period (ប្រសិនបើមាន) និង Thank You Message។

### ៣.៧ Output Design — Admin Dashboard

Admin Panel (Browser) បង្ហាញ Sidebar (Products, Orders, Repairs, Customers, Reports, Vouchers, Notifications), KPI Cards ៤ (Orders, Revenue, Repairs, Customers) ជាមួយ Percentage Change, Sales Chart Monthly, Recent Orders Table ជាមួយ Order ID, Customer, Amount, Status, ហើយ Admin អាច Filter, Sort, Approve, Reject, Assign ពី Dashboard ផ្ទាល់។

### ៣.៨ Output Design — Push Notification

Push Notification ផ្ញើ Title "KneaYerng Service Center" ជាមួយ Body ដូចជា "ការបញ្ជាទិញ #001 បានអនុម័ត!" ឬ "ការជួសជុល Ready សម្រាប់ Pickup" ។ Notification ទាំងនេះ Store ក្នុង Database ដើម្បីអ្នកប្រើប្រាស់ Scroll ឡើងវិញ ហើយ Mark as Read បាន។

### ៣.៩ Output Design — Telegram Notification

Telegram Order Notification ផ្ញើដូចនេះ ៖ New Order Received! Order ID, Customer Name, Phone, Items (Name, Qty, Price), Payment Method + Paid Status, Order Type (Delivery/Pickup), Address, Total Amount ។ Bot ផ្ញើ Auto ពេល Order ថ្មីបន្ទាប់ពី Admin Submit ឬ User Checkout។

### ៣.១០ Output Design — Reports

Admin Reports មាន Sales Report (Order ID, Customer, Amount, Payment, Status, Date) Export ជា CSV ឬ PDF, Inventory Report (Product, Variants, Stock Level, Sales Count), Customer Report (Customer Name, Phone, Total Orders, Total Spent, Last Order Date)។ Report Filter បាន By Date Range, Category, Payment Method, Status ។

---

## ៤. ការគ្រោង System Architecture

### ៤.១ ទិដ្ឋភាពទូទៅ

ប្រព័ន្ធ KneaYerng Service Center ត្រូវបានរចនាក្នុង Architecture ៣ ស្រទាប់ (3-Tier Architecture) គឺ Presentation Layer, Application Layer, និង Data Layer ។

Presentation Layer ចែកជា ២ ផ្នែក គឺ Flutter Mobile App (Android/iOS) ដែលអតិថិជនប្រើ ហើយ Admin Panel (Browser) ដែល Admin ប្រើ។ Flutter App ទំនាក់ទំនងជាមួយ Backend តាម REST API (HTTP/HTTPS), ហើយ Admin Panel ដំណើរការ Blade Views ដោយ Laravel Server-side Rendering ។

Application Layer គឺ Laravel 12.42 PHP 8.5 Backend ដែលដំណើរការ Logic ទាំងអស់ ដូចជាការ Validate Input, ដំណើរការ Order, គ្រប់គ្រង Repair Workflow, Generate Invoice, Call API Payment, ផ្ញើ Notification ។ Layer នេះក៏ដំណើរការ Queue Worker ក្រោម Supervisor សម្រាប់ Background Jobs ដូចជា ការផ្ញើ Email, Push Notification ។

Data Layer គឺ MySQL 8.0 Database ដែលស្ដុករក្សា Data ទាំងអស់ ២ Volume ផ្សេងគ្នា គឺ Database ខ្លួនឯង និង AWS S3 Cloud Storage សម្រាប់ File Upload (Product Images, Intake Photos)។

### ៤.២ Backend Layer Architecture

Backend ត្រូវបានរចនាក្នុង N-Tier Pattern ដែលមាន Route Layer (api.php ជាមួយ 157 API Endpoints, web.php ជា Admin Routes), Controller Layer (37 API Controllers), Service Layer (16 Services ដែល Handle Business Logic), Model/ORM Layer (36 Eloquent Models), ហើយ Database Layer (MySQL 45 Tables, 54 Migrations)។

Controllers ដំណើរការ HTTP Request Validation ហើយ Delegate ការងារទៅ Services។ Services ដំណើរការ Business Logic ហើយ Call Models ដើម្បីទំនាក់ទំនងជាមួយ Database ។ Pattern នេះធ្វើឱ្យ Code Clean, Testable, ហើយ Maintainable ។

### ៤.៣ Database Architecture

Database ចែកជា ៥ Domain ផ្ទៃ ។

Domain ទីមួយ Auth & Users មាន ៩ Tables ដូចជា users, personal_access_tokens, password_reset_tokens, sessions, otp_verifications, email_otps ។ Domain ទីពីរ Catalog & Content មាន ៦ Tables ដូចជា categories, products, product_variants, accessories, banners ។ Domain ទីបី Orders, Cart, Payments មាន ៩ Tables ដូចជា orders, order_items, carts, cart_items, payments, khqr_transactions, vouchers, voucher_redemptions ។ Domain ទីបួន Repair Service Management មាន ១៣ Tables ដូចជា repair_requests, intakes, diagnostics, quotations, parts, parts_usages, warranties, invoices, repair_payments, repair_status_logs, chat_messages, repair_notifications, technicians ។ Domain ទីប្រាំ Tracking, Support, Notifications មាន ៨ Tables ដូចជា order_tracking_histories, order_tracking_notifications, support_conversations, support_messages, mobile_device_tokens, admin_notification_campaigns ។

### ៤.៤ Authentication Architecture

ប្រព័ន្ធ Authentication ប្រើ Laravel Sanctum ដើម្បី Issue Bearer Token ។ Flutter App ផ្ញើ Token ក្នុង Header Authorization: Bearer ជារៀងរហូតពេល Call API ។ User មាន ៤ Role គឺ customer, staff, technician, admin ។ Middleware auth:sanctum គ្រប់គ្រង API Authentication, middleware admin ការពារ Admin-only Endpoints ។

ការ Login ពី Email/Password Backend ពិនិត្យ Password ហើយ Issue Token ។ ការ Login ពី Google Backend ពិនិត្យ Google ID Token ហើយ Issue Token ។ ការ Login ពី Phone OTP Backend ផ្ញើ OTP តាម SMS ហើយ Verify Code ហើយ Issue Token ។

### ៤.៥ Real-time Architecture

ប្រព័ន្ធ Real-time ប្រើ ២ Channel ។ ទីមួយ Pusher WebSocket ដែល Backend Broadcast Events ដូចជា Order Status Changed, Support Message ទៅ Pusher Channel ហើយ Flutter App Subscribe ។ ទីពីរ Firebase Cloud Messaging (FCM) ដែល Backend ផ្ញើ Push Notification ទៅ Device Token ដែលបាន Register ។ Mobile Device Tokens ត្រូវបាន Store ក្នុង mobile_device_tokens Table ។

### ៤.៦ Payment Architecture (KHQR)

Flutter App Call POST /api/generate-qr ហើយ Backend ទាក់ទង BakongOpenApiService ដើម្បី Get Access Token ពី Bakong API, Generate KHQR String ជាមួយ Merchant ID, Amount, Currency, Order ID ។ Backend Return QR String + MD5 Hash ទៅ Flutter ។ Flutter Render QR Code ហើយ Call POST /api/check-transaction ម្ដងម្ដងៗ ដើម្បី Poll Payment Status ។ ពេល Status SUCCESS ប្រព័ន្ធ Mark Order Paid, Deduct Stock, Issue Warranty, ផ្ញើ Notification ។

### ៤.៧ Flutter App Architecture

Flutter App ប្រើ Dart SDK 3.8+, State Management ដោយ setState + SharedPreferences, Navigation ដោយ Named Routes ។ Service Layer ក្នុង Flutter ទំនាក់ទំនងជាមួយ Backend API ។ api_service.dart ជា HTTP Client មាន Base URL + Bearer Token Header ។ App Support Khmer/English i18n ដោយ l10n/app_localizations.dart ។ Light/Dark Theme ដំណើរការតាម theme_service.dart ។ Firebase Push Notification ត្រូវបានគ្រប់គ្រង app_notification_service.dart ។

### ៤.៨ Docker Deployment Architecture

ប្រព័ន្ធ Deploy ដោយ Docker Compose ដែលមាន ៣ Container ។ Container ទីមួយ ky_app (PHP-FPM 8.5) ដែលដំណើរការ Laravel Application ជា Multi-stage Build (Stage 1 Build Assets ដោយ Node.js + Vite, Stage 2 Install PHP Dependencies + Copy Assets), Supervisor គ្រប់គ្រង PHP-FPM Process + Queue Worker, OPcache Enable សម្រាប់ Production Performance ។ Container ទីពីរ ky_nginx (Nginx 1.27) ដែល Serve Static Files ពី /public ហើយ Proxy Request ទៅ PHP-FPM ។ Container ទីបី ky_mysql (MySQL 8.0) ជា Database ។ Container ទាំង ៣ ទំនាក់ទំនងតាម Internal Network ky_network ។ Volume mysql_data Store Database Data, Volume app_storage Store File Uploads + Logs ។

### ៤.៩ Security Architecture

ប្រព័ន្ធ KneaYerng Service Center ប្រើ Security ១០ ស្រទាប់ ។ ១-HTTPS/TLS Encrypt Traffic ទាំងអស់ ។ ២-Sanctum Bearer Token Auth ។ ៣-Middleware ការពារ Admin Endpoints ។ ៤-OTP Rate Limiting ការពារ Brute Force ។ ៥-Bcrypt (12 rounds) Hash Password ។ ៦-CORS ការពារ Unauthorized Origins ។ ៧-Form Request Validation លើ Input ទាំងអស់ ។ ៨-MIME Type + Size Validation លើ File Upload ។ ៩-Eloquent ORM ការពារ SQL Injection ។ ១០-.env File ដាក់ .gitignore ការពារ Credentials Leak ។

---

## ៥. ការអនុវត្តន៍

### ៥.១ ដំណើរការអភិវឌ្ឍ

ការអភិវឌ្ឍ KneaYerng Service Center ត្រូវបានចែកជា ៥ Phase ។

Phase ទី ១ (December 2025) ជា Core Infrastructure ។ ក្នុង Phase នេះ ក្រុម Develop Auth System (Sanctum, OTP, Google Login), Categories, Products, Product Variants, Orders, Cart, Checkout, Admin Panel Blade, Flutter App Skeleton, Auth Screens ។

Phase ទី ២ (January 2026) ជា Payment & Notifications ។ ក្រុម Integrate KHQR/Bakong Payment Gateway, Pusher Real-time, Firebase FCM, Order Tracking System, Telegram Bot, Voucher/Discount System ។

Phase ទី ៣ (February 2026) ជា Repair System ។ ក្រុម Build Repair Request, Intake, Diagnostic, Quotation Approval Workflow, Parts Inventory, Invoice PDF Generation, Repair Payment (Deposit + Final), Chat, Repair Warranty ។

Phase ទី ៤ (March–April 2026) ជា Warranty & Analytics ។ ក្រុម Build Product Warranty System, Admin Reports (Sales, Inventory, Customer), CSV/PDF Export, Admin Notification Campaign, Support Chat ។

Phase ទី ៥ (May–June 2026) ជា Deployment & Polish ។ ក្រុម Setup Docker Compose, Implement Flutter Multi-language (Khmer/English), Dark/Light Theme, Warranty Screen Flutter, Final Testing, Bug Fixes ។

### ៥.២ Backend Implementation Details

Laravel Backend ប្រើ Service Pattern ដើម្បីញែក Business Logic ចេញពី Controller ។ ឧទាហរណ៍ ProductWarrantyService ដំណើរការ Create Warranty ពេល Order Paid, Sync Expiration Date, Calculate Days Remaining ។ OrderTrackingService ដំណើរការ Log Status Transition ២ ហើយ Trigger Notifications ។ BakongOpenApiService ទំនាក់ទំនងជាមួយ Bakong API ។

API Response Standard Format គឺ JSON Object មាន success (boolean), message (string), data (object/array) ។ Error Response មាន errors (array of validation messages) ។

### ៥.៣ Repair Workflow Implementation

Repair Workflow ដំណើរការ Step-by-Step ។ RepairRequestController store() Create RepairRequest ក្នុង DB Status received ហើយ Notify Customer ។ RepairIntakeController store() Upload Photos ទៅ S3, Save Checklist, Update Status diagnosing ។ RepairDiagnosticController store() Record Parts, Labor, Update Status waiting_approval ។ RepairQuotationController store() Create Quotation, Notify Customer Push + SMS ។ Customer Approve/Reject ។ Status Transitions in_repair → qc → ready → completed ដំណើរការ Log RepairStatusLog ក្នុងរៀងរហូត, ផ្ញើ RepairNotification ។ RepairInvoiceController store() Create Invoice PDF ។ ProductWarrantyService createFromRepair() Issue Repair Warranty ។

### ៥.៤ Flutter State & Navigation

Flutter App ប្រើ setState ជា State Management សាមញ្ញ ដោយ SharedPreferences Store Token + User Data Local ។ Navigation ប្រើ Named Routes ។ AuthGuard Widget ការពារ Screens ដែល Require Authentication ។ api_service.dart ជួបបញ្ហា Token Expired ហើយ Redirect ទៅ Login ដោយ Auto ។

### ៥.៥ Testing Strategy

Backend Testing ប្រើ Pest PHP Framework ។ Unit Tests គ្រប Scope Services, Models ។ Feature Tests គ្រប API Endpoints ។ Integration Tests គ្រប Payment Flow, OTP Flow ។ Manual Testing ដោយ Postman គ្រប 157 API Endpoints ។ Flutter UI Testing ធ្វើ Manual ដោយ QA Team ដោយ Test Golden Path + Edge Cases ។

---

## ៦. ការដំឡើង Software — Computer for Development

### ៦.១ Software ដែលត្រូវការ

ដើម្បី Develop Project KneaYerng Service Center Developer ត្រូវដំឡើង Software ដូចខាងក្រោម ។

ទីមួយ PHP 8.2 ឬ ខ្ពស់ជាងនេះ (Project ប្រើ PHP 8.5) ។ Download ពី php.net ។ Windows ប្រើ Thread-Safe ZIP Extract ហើយ Add to PATH ។ Extensions ដែលត្រូវ Enable ក្នុង php.ini គឺ pdo_mysql, mbstring, openssl, fileinfo, curl, zip, gd, intl, bcmath ។ ពិនិត្យដោយ Command "php --version" ។

ទីពីរ Composer ជា PHP Package Manager ។ Download Installer ពី getcomposer.org ។ ពិនិត្យដោយ "composer --version" ។

ទីបី MySQL 8.0 ។ ជម្រើសស្រួលបំផុតជា XAMPP ឬ ប្រើ Docker (Recommend) ។ Create Database ឈ្មោះ db_ky_servicercenter, Create User laravel ជាមួយ Password ។

ទីបួន Node.js 20+ ។ Download LTS ពី nodejs.org ។ ចំបាច់សម្រាប់ Build Frontend Assets ដោយ Vite ។ ពិនិត្យ "node --version" ។

ទីប្រាំ Flutter SDK Dart 3.8+ ។ Download ពី flutter.dev/get-started ។ Windows Extract ទៅ C:\flutter, Add C:\flutter\bin ទៅ PATH ។ ពិនិត្យ "flutter doctor" ហើយ Resolve Issues ទាំងអស់ ។

ទីប្រាំមួយ Android Studio ។ Download ពី developer.android.com ។ Install Android SDK API 33+, Android Virtual Device (AVD), Flutter Plugin, Dart Plugin ។ Create Emulator Pixel 6 API 33 ។

ទីប្រាំពីរ VS Code ជា IDE ។ Install Extensions Flutter, Dart, PHP Intelephense, Laravel Blade Snippets, GitLens, Docker ។

ទីប្រាំបី Git ។ Download ពី git-scm.com ។ Config Name + Email ។

ទីប្រាំបួន Postman ។ Download ពី postman.com ។ ប្រើ Test API Endpoints ទាំង 157 ។

ទីដប់ TablePlus ឬ DBeaver ជា Database GUI ។ ភ្ជាប់ MySQL localhost:3306 ដើម្បី Browse Tables ។

### ៦.២ Setup Backend (ជំហានលម្អិត)

ជំហានទី ១ Clone Repository ហើយ Navigate ទៅ Folder backend ។

ជំហានទី ២ Run "composer install" ដើម្បី Install PHP Dependencies ។

ជំហានទី ៣ Copy .env.example ទៅ .env ហើយ Run "php artisan key:generate" ។

ជំហានទី ៤ Edit .env Set DB_HOST, DB_DATABASE, DB_USERNAME, DB_PASSWORD ។

ជំហានទី ៥ Run "php artisan migrate" ដើម្បី Create Tables ។

ជំហានទី ៦ Run "npm install" ហើយ "npm run dev" ដើម្បី Build Assets ។

ជំហានទី ៧ Run "php artisan serve --host=0.0.0.0 --port=8000" ដើម្បី Start Server ។

ជំហានទី ៨ Run "php artisan queue:work" ក្នុង Terminal ផ្សេង ដើម្បី Start Queue Worker ។

### ៦.៣ Setup Flutter App (ជំហានលម្អិត)

ជំហានទី ១ Navigate ទៅ Folder app_ky_service_center ។

ជំហានទី ២ Run "flutter pub get" ដើម្បី Install Dependencies ។

ជំហានទី ៣ Edit lib/services/api_service.dart Set baseUrl ទៅ IP Dev Machine ដូចជា http://192.168.x.x:8000/api ។

ជំហានទី ៤ Download google-services.json ពី Firebase Console ហើយ Place ទៅ android/app/ ។

ជំហានទី ៥ Run "flutter run" ដើម្បី Start App លើ Emulator ឬ Physical Device ។

### ៦.៤ Firebase Setup

ចូល Firebase Console, Project knea-yerng-service ។ Enable Authentication Email/Password, Phone SMS, Google ។ Download google-services.json ។ Generate Service Account Private Key JSON ។ Save ជា backend/firebase-credentials.json ។ Set .env FIREBASE_CREDENTIALS=firebase-credentials.json ។

### ៦.៥ Bakong/KHQR Setup (Sandbox)

Register Sandbox Merchant Account ពី Bakong Developer Portal ។ Copy BAKONG_MERCHANT_ID និង BAKONG_TOKEN ។ Set BAKONG_ENV=sandbox ក្នុង .env ។ Test ដោយ POST /api/generate-qr ជាមួយ amount=1.00, currency=USD ។

---

## ៧. ការដំឡើងម៉ាស៊ីនមេ — Ready to Implement

### ៧.១ ជម្រើសម៉ាស៊ីនមេ

ជម្រើសដ៏ល្អបំផុតសម្រាប់ Deploy ប្រព័ន្ធ KneaYerng Service Center គឺ VPS (Virtual Private Server) ជំនួស Ubuntu 22.04 LTS ដោយប្រើ Docker Compose ។ ជម្រើសផ្សេងទៀតដូចជា AWS EC2, DigitalOcean Droplet, Vultr, Linode ក៏ Compatible ។ Shared Hosting មិន Recommended ព្រោះ Laravel ត្រូវការ PHP-FPM, Queue Worker, Custom Config ។

Server Requirements Minimum គឺ 1 vCPU, RAM 1GB, Storage 20GB SSD ។ ណែនាំ 2 vCPU, RAM 2–4GB, Storage 40GB SSD ។

### ៧.២ Server Setup (ជំហានលម្អិត)

ជំហានទី ១ Update System ។ SSH ចូល Server ហើយ Run "sudo apt update && sudo apt upgrade -y" ។

ជំហានទី ២ Install Docker + Docker Compose ។ Run Install Script ពី docker.com ។ Add User ទៅ docker Group ។

ជំហានទី ៣ Clone Project ។ Navigate ទៅ /var/www ហើយ "git clone" Project ។

ជំហានទី ៤ Configure Environment ។ Copy .env.docker ទៅ .env ក្នុង Folder backend ។ Edit .env Set APP_URL=https://api.yourdomain.com, APP_ENV=production, APP_DEBUG=false, DB_HOST=ky_mysql (Docker Service Name), DB_PASSWORD ជា Strong Password, ចំណុចសំខាន់ Set Credentials ទាំងអស់ (Bakong, Firebase, Pusher, Telegram, AWS) ។

ជំហានទី ៥ Place Firebase Credentials ។ Copy firebase-credentials.json ទៅ backend/firebase-credentials.json ។

ជំហានទី ៦ Build + Start Docker ។ Run "docker compose build" ហើយ "docker compose up -d" ។ Check Status ដោយ "docker compose ps" ។

ជំហានទី ៧ Run Migrations ។ "docker compose exec ky_app php artisan migrate --force" ។

ជំហានទី ៨ Set Permissions ។ Set www-data:www-data ទៅ storage/ ហើយ bootstrap/cache/ ។ Run "php artisan storage:link" ។

ជំហានទី ៩ Cache Production ។ Run "php artisan optimize" ដើម្បី Cache Config, Route, View ។

### ៧.៣ SSL/HTTPS Setup

Install Certbot ។ Stop ky_nginx Container ។ Run "certbot certonly --standalone -d api.yourdomain.com" ។ Certificate Save ទៅ /etc/letsencrypt/live/ ។ Update docker/nginx/default.conf ឱ្យ Listen port 443 ssl, Set ssl_certificate Paths ។ Mount /etc/letsencrypt ក្នុង docker-compose.yml ky_nginx volumes ។ Restart ky_nginx ។ Setup Auto-renew Cron Job ។

### ៧.៤ Domain & DNS Setup

ក្នុង Domain Provider (GoDaddy, Namecheap) Add DNS Records ។ A Record "api" → Server IP (TTL 300) សម្រាប់ Backend API ។ A Record "admin" → Server IP (TTL 300) សម្រាប់ Admin Panel ។

### ៧.៥ Firewall Setup

Enable UFW ។ Allow SSH (Port 22), HTTP (Port 80), HTTPS (Port 443) ។ Block គ្រប់ Port ផ្សេងទៀត ។ Enable UFW ។

### ៧.៦ Monitoring & Logs

View Logs ដោយ "docker compose logs -f" ដើម្បីមើល All Services ។ View Laravel Logs ដោយ "docker compose exec ky_app tail -f storage/logs/laravel.log" ។ Check Queue Worker Status ដោយ "docker compose exec ky_app supervisorctl status" ។

### ៧.៧ Backup Strategy

Manual Backup ។ Run mysqldump ពី MySQL Container ដើម្បី Export SQL File ។ Setup Cron Job ដើម្បី Auto Backup ជារៀងរាល់ថ្ងៃ ។ Laravel Backup Package (spatie/laravel-backup) Configure ឱ្យ Backup ទៅ AWS S3 Daily 3AM ។ Queue Worker Handle Auto Backup ។

### ៧.៨ Flutter Release Build

Update api_service.dart baseUrl ទៅ Production URL ។ Build Release APK ដោយ "flutter build apk --release" ។ Build App Bundle (Google Play) ដោយ "flutter build appbundle --release" ។ Sign APK ដោយ Keystore File ។ Upload ទៅ Google Play Console ។

### ៧.៩ Redeploy (Update Code)

Pull Latest Code ដោយ "git pull origin main" ។ Rebuild ky_app Container ។ Restart Container ។ Run New Migrations ។ Clear Cache ហើយ Re-optimize ។

### ៧.១០ Health Check

ក្រោយ Deploy ពិនិត្យ Health ២ ចំណុច ។ ទីមួយ GET https://api.yourdomain.com/api/public/products គួរ Return 200 OK ជាមួយ Product List ។ ទីពីរ GET https://api.yourdomain.com/admin គួរ Redirect ទៅ Login Page ។ Database Health ពិនិត្យ "docker compose exec ky_mysql mysql -ularavel -p -e 'SHOW TABLES;'" ។

### ៧.១១ Summary Environment

ក្នុង Development ប្រើ Backend URL http://192.168.x.x:8000, Database MySQL Local, File Storage Local Disk, Cache File, Queue Sync/Database, Debug true ។ ក្នុង Production ប្រើ Backend URL https://api.yourdomain.com, Database MySQL Docker Container, File Storage AWS S3, Cache Database (Redis Recommended), Queue Database (Redis Recommended), Debug false, SSL Let's Encrypt ។

---

## សង្ខេប

ប្រព័ន្ធ KneaYerng Service Center គឺជា Full-Stack Application ដ៏ទូលំទូលាយ ដែលត្រូវបានអភិវឌ្ឍ ដោយ Backend Laravel 12.42 PHP 8.5 MySQL 8.0 មាន 157 API Endpoints, 36 Models, 45 Tables, 54 Migrations, 37 Controllers, 16 Services ។ Frontend Flutter Dart 3.8+ មាន 40 Screens, Support Khmer/English ។ Payment KHQR/Bakong, ABA, Cash ។ Real-time Pusher WebSocket + Firebase FCM ។ Deploy ដោយ Docker Compose (Nginx + PHP-FPM + MySQL) ។ Security Sanctum, OTP Rate-limit, Bcrypt, CORS, HTTPS ។ ប្រព័ន្ធ Ready to Deploy លើ Ubuntu VPS ណាមួយ ក្នុងរយៈពេល ៣០ នាទី ។

---

*ឯកសារបានបង្កើតថ្ងៃទី ២ ខែ មិថុនា ឆ្នាំ ២០២៦*
*Version 2.0 — KneaYerng Service Center App — ការពន្យល់ជាអក្សរ*
