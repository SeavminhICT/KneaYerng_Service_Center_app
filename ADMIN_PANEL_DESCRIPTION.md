# ជំពូកទី ៦ — ការពណ៌នាលម្អិតនៃ Admin Panel
## KNEAYERNG-Admin Web Application

---

## ៦.១ ទិដ្ឋភាពទូទៅ

**KNEAYERNG-Admin** គឺជា Web Application សម្រាប់ Admin, Staff, និង Technician ប្រើប្រាស់ ។ Admin Panel ត្រូវបានបង្កើតដោយ **Laravel Blade + TailwindCSS** ដែលអ្នកគ្រប់គ្រងអាចចូលប្រើតាម Browser ។

Admin Panel ត្រូវបានបែងចែកជា **៦ Section ចំបង** ដូចខាងក្រោម:

| Section | Screens |
|---------|:-------:|
| OVERVIEW | Dashboard, Notifications, Reports |
| CATALOG | Categories, Products, Product Master, Accessories, Banners |
| SALES | Order Dashboard, Checking Pick Up, Tracking Order, Payment Voucher, Customers, Payments |
| REPAIRS | Repair Management, Support Inbox, Technicians |
| INVENTORY | Parts Inventory, Warranty Records |
| FINANCE | Invoices, Payments, Revenue Reports |
| ACCESS | User Management, Settings |

---

# SECTION ១ — OVERVIEW

---

## ៦.២ Dashboard

### ៦.២.១ តួនាទី (Purpose)

**Dashboard** ជាទំព័រដំបូងដែល Admin ឃើញ នៅពេល Login ចូលក្នុងប្រព័ន្ធ ។ វាផ្ដល់ទិដ្ឋភាពទូទៅ (Overview) នៃស្ថានភាពប្រព័ន្ធទាំងមូល ក្នុងពេលជាក់ស្ដែង (Real-time) ។

### ៦.២.២ Feature & Function ទាំងអស់

**Summary Cards (ករ្ណក ស្ថិតិ) — ៤ ករ្ណក:**

- **Total Sales** — បង្ហាញ ចំនួនប្រាក់ Sale សរុប (USD) ពី Order ទាំងអស់ ចាប់ពីដំបូងរហូតដល់ពេលនេះ (All time)
- **Total Orders** — បង្ហាញ ចំនួន Order ទាំងអស់ ក្នុងប្រព័ន្ធ
- **Total Products** — បង្ហាញ ចំនួន Product ទាំងអស់ ក្នុង Catalog
- **Total Customers** — បង្ហាញ ចំនួន Customer ដែលបានចុះឈ្មោះ

ករ្ណកទាំងអស់ Loading Data Live ពី API `/api/admin/metrics` ។

---

**Sales Overview Chart (ក្រាបលក់):**

- បង្ហាញ Bar Chart នៃ Revenue ចំនួន **១២ សប្ដាហ៍** ចុងក្រោយ
- ពណ៌ Bar = Primary Blue
- Mouse Hover → បង្ហាញ Label (Week · Revenue · Order Count)
- ប្រសិនបើ គ្មានទិន្នន័យ → បង្ហាញ "No sales data available yet"

---

**Recent Orders Table (តារាង Order ថ្មីៗ):**

- បង្ហាញ Order ចំនួន ៥ ចុងក្រោយ ជា Table
- Columns: Order ID, Customer Name, Date, Total Amount, Payment Status, Action

| ការអនុញ្ញាត | ការពន្យល់ |
|-----------|---------|
| Search Orders | ស្វែងរក Order ក្នុង Table ដោយ Keyword |
| Export Button | Export Order Data |
| View Link | ចូលមើល Order Detail |
| Payment Status Dropdown | Admin អាចប្ដូរ Payment Status (unpaid/paid/failed/refunded) ភ្លាមៗក្នុង Table ដោយ PATCH Request |

---

**Low Stock Alerts (ការព្រមានស្ទុំទំនិញ):**

- Loading Product ដែល Stock ≤ 10 ដំណាល់គ្នា
- បង្ហាញ Product Name, SKU, Stock Count (ប្រើ Warning Color ស្ទើប)
- **View all** Link → ទៅ Products Page

---

## ៦.៣ Notifications

### ៦.៣.១ តួនាទី

**Notifications** ជាទំព័រសម្រាប់ Admin **ផ្ញើ Push Notification** ទៅ Customer តាម Firebase Cloud Messaging (FCM) ។

### ៦.៣.២ Feature & Function ទាំងអស់

**បញ្ចូនការជូនដំណឹងថ្មី (Send Notification):**

| Field | ការពន្យល់ |
|-------|---------|
| Title | ចំណងជើង Notification |
| Message | ខ្លឹមសារ |
| Audience | All Users ឬ Specific Users |
| Customer List | ជ្រើស User ដោយ Checkbox (បង្ហាញ name, email, phone) |
| Deep Link | Link ខ្លាំងចូល App Screen ជាក់លាក់ |

**Notification History (ប្រវត្តិ):**
- មើលឡើងវិញ Campaign ដែលបានផ្ញើ
- Status, Audience, Title, Date ។

---

## ៦.៤ Reports

### ៦.៤.១ តួនាទី

**Reports** ជាទំព័ររបាយការណ៍ (Report) ដែលអនុញ្ញាតឱ្យ Admin ចូលមើលរបាយការណ៍ Sales, Inventory, Customer ហើយ Export ចេញជា CSV/Excel ។

### ៦.៤.២ Feature & Function ទាំងអស់

| Report Type | ខ្លឹមសារ |
|-------------|---------|
| Sales Report | Revenue ប្រចាំថ្ងៃ/ខែ/ឆ្នាំ, Top Products |
| Inventory Report | Product Stock Level, Low Stock |
| Customer Report | Customer Registration Trend, Top Customers |

**Export Feature:**
- ជ្រើស Report Type + Date Range
- ចុច Export → Generate CSV/Excel File
- ទាញ Download Link → Download File

---

# SECTION ២ — CATALOG

---

## ៦.៥ Categories (ប្រភេទ)

### ៦.៥.១ តួនាទី

**Categories** ជាទំព័រគ្រប់គ្រងប្រភេទផលិតផល ។ Category ដែលបង្កើតនៅទីនេះ នឹងបង្ហាញក្នុង User App (Mobile) នៅ Tab Categories ។

### ៦.៥.២ Feature & Function ទាំងអស់

**Category List Table:**

| Column | ការពន្យល់ |
|--------|---------|
| IMAGE | រូបភាព Category (Icon) |
| CATEGORY | ឈ្មោះ Category |
| SLUG | ឈ្មោះខ្លី (URL-friendly) |
| PRODUCTS | ចំនួន Product ក្នុង Category |
| STATUS | active / inactive |
| ACTION | View, Edit, Deactivate, Delete |

**Action Buttons:**

| Action | ការងារ |
|--------|--------|
| **+ Add Category** | បង្កើត Category ថ្មី — Form: Name, Image (upload), Sort Order, Status |
| **View** | ចូលមើល Category Detail + Products ក្នុង Category |
| **Edit** | កែប្រែ Name, Image, Sort Order, Status |
| **Deactivate** | លាក់ Category ពី User App (Status → inactive) |
| **Delete** | លុប Category ចេញ (មិនអាចលុបបានប្រសិនបើ Category មាន Product) |

**Bulk Actions:**
- ជ្រើស Checkbox ច្រើន → Bulk Deactivate / Bulk Delete

**Search:**
- ស្វែងរក Category ដោយ Name ក្នុង Table

---

## ៦.៦ Products (ផលិតផល)

### ៦.៦.១ តួនាទី

**Products** ជាទំព័រគ្រប់គ្រង Catalog ផលិតផលសំខាន់ (Phone, Laptop, Tablet) ។ Product ដែលបង្កើតនៅទីនេះ នឹងបង្ហាញក្នុង User App ។

### ៦.៦.២ Feature & Function ទាំងអស់

**Product List Table:**

| Column | ការពន្យល់ |
|--------|---------|
| IMAGE | Thumbnail |
| NAME / SKU | ឈ្មោះ + SKU |
| CATEGORY | Category ដែល Product ស្ថិតក្នុង |
| PRICE | តម្លៃ (USD) |
| STOCK | ចំនួន Stock |
| STATUS | active / inactive |
| ACTION | View, Edit, Toggle Status, Delete |

**+ Add Product — Form Fields:**

| Field | ការពន្យល់ |
|-------|---------|
| Product Name | ឈ្មោះ |
| SKU | Stock Keeping Unit |
| Category | ជ្រើស Category |
| Description | ការពណ៌នា |
| Price | តម្លៃ |
| Discount | % ឬ $$ |
| Stock | ចំនួន |
| Brand | យីហោ |
| Warranty | ការធានា (e.g. 1 Year) |
| Tag | Tag (New, Hot, Sale) |
| Condition | New / Used |
| Specifications | RAM, Storage, CPU, Display, SSD, Country |
| Image (Main) | Upload |
| Thumbnail | Upload |
| Image Gallery | Upload ច្រើន |
| Status | Active / Inactive |

**Product Variants:**
- Admin អាចបន្ថែម Variant ក្នុង Product (e.g. iPhone 14 Pro — 256GB Black, 512GB White)
- Variant Fields: Storage, Color, RAM, Price, Stock, SKU, Image

**Toggle Status:**
- PATCH `/products/{id}/status` — Enable/Disable Product ដោយ Click

**Low Stock Filter:**
- Filter Product ដែល Stock ≤ 10

---

## ៦.៧ Product Master (Product Attributes)

### ៦.៧.១ តួនាទី

**Product Master** (Product Attributes) ជាទំព័រគ្រប់គ្រង Attribute Options ដែល Reuse បានក្នុង Product Variants ។ ឧទាហរណ៍ Color "Space Gray", Storage "256 GB", RAM "8 GB" ។

### ៦.៧.២ Feature & Function ទាំងអស់

**Attribute List:**

| Column | ការពន្យល់ |
|--------|---------|
| TYPE | color / storage / ram / ssd / condition |
| VALUE | "256GB" / "Space Gray" / "8GB" |
| ACTION | Edit, Delete |

**+ Add Attribute:**
- Form: Type (dropdown), Value (text)
- Save → ក្លាយជា Option ដែលអាចជ្រើសនៅ Product Variants

**Edit / Delete:**
- Edit → Update Type, Value
- Delete → Remove Option

---

## ៦.៨ Accessories (គ្រឿងបន្ថែម)

### ៦.៨.១ តួនាទី

**Accessories** ជាទំព័រគ្រប់គ្រង Catalog គ្រឿងបន្ថែម ដូចជា Case, Charger, Earphone, Screen Protector ។

### ៦.៨.២ Feature & Function ទាំងអស់

**Accessory List Table:**

| Column | ការពន្យល់ |
|--------|---------|
| IMAGE | រូប |
| NAME | ឈ្មោះ |
| BRAND | Brand |
| PRICE | តម្លៃ |
| STOCK | ចំនួន |
| STATUS | Active / Inactive |
| ACTION | View, Edit, Delete |

**+ Add Accessory — Form Fields:**

| Field | ការពន្យល់ |
|-------|---------|
| Name, Brand | ឈ្មោះ + Brand |
| Price, Discount | តម្លៃ + ការបញ្ចុះ |
| Stock | ចំនួន |
| Warranty | ការធានា |
| Tag | New / Sale / Hot |
| Description | ការពណ៌នា |
| Image | Upload |

---

## ៦.៩ Banners (Banner ផ្ទាំងផ្សាយ)

### ៦.៩.១ តួនាទី

**Banners** ជាទំព័រគ្រប់គ្រង Banner Image ដែលបង្ហាញជា Slideshow ក្នុង Home Screen របស់ User App ។

### ៦.៩.២ Feature & Function ទាំងអស់

**Banner List:**
- Preview Banner Image, Badge Label, Title, CTA Button

**+ Add Banner — Form Fields:**

| Field | ការពន្យល់ |
|-------|---------|
| Image | Upload Banner Image (max 5MB) |
| Badge Label | ករ្ណក តូចលើ Banner (e.g. "NEW", "HOT DEAL") |
| Title | ចំណងជើងធំ |
| Subtitle | ការពណ៌នាខ្លី |
| CTA Label | ឈ្មោះប៊ូតុង (e.g. "Shop Now") |

**Edit / Delete:**
- Edit → Update Fields + Replace Image (Image ចាស់ត្រូវបានលុប Storage)
- Delete → Remove Banner + Delete Image ចេញពី Storage

---

# SECTION ៣ — SALES

---

## ៦.១០ Order Dashboard

### ៦.១០.១ តួនាទី

**Order Dashboard** ជាទំព័រគ្រប់គ្រង Order ទាំងអស់ ។ Admin, Staff អាច Approve, Reject, Assign, និង Update Status Order ។

### ៦.១០.២ Feature & Function ទាំងអស់

**Order List Table:**

| Column | ការពន្យល់ |
|--------|---------|
| ORDER NUMBER | លេខ Order |
| CUSTOMER | ឈ្មោះ Customer |
| TYPE | delivery / pickup |
| ITEMS | ចំនួន Items |
| TOTAL | ថ្លៃសរុប |
| STATUS | pending / approved / processing / delivered |
| PAYMENT | paid / unpaid / failed |
| ACTION | View Detail |

**Filter & Search:**
- Filter ដោយ Status, Payment Status, Order Type, Date Range
- Search ដោយ Order Number ឬ Customer Name

**Order Detail Page:**

Admin ចូល Order Detail ហើយ អាចធ្វើ Action ដូចខាងក្រោម:

| Action | ការងារ | លទ្ធផល |
|--------|--------|--------|
| **Approve** | Approve Order | Status → approved, Stock ដក, FCM Push ជូន Customer |
| **Reject** | Reject + Reject Reason | Status → rejected, FCM Push ជូន Customer |
| **Assign Staff** | ជ្រើស Staff User | Order Assigned ជូន Staff, Staff ទទួល FCM |
| **Update Status** | ប្ដូរ Status (processing / out_for_delivery / delivered) | Tracking History Save, FCM Push |
| **Notify Telegram** | ផ្ញើ Alert ទៅ Telegram Bot | Admin Group ក្នុង Telegram ទទួល Alert |
| **Generate QR** | Generate Pickup QR Token | QR Code Created, Expiry Set |
| **Export** | Export Orders CSV | Download File |

---

## ៦.១១ Checking Pick Up (ការ Verify QR Pickup)

### ៦.១១.១ តួនាទី

**Checking Pick Up** ជាទំព័រដែល Staff ប្រើ **Scan QR Code** ដែល Customer បង្ហាញ នៅពេល Customer មកទទួល Order ផ្ទាល់នៅ Counter ។

### ៦.១១.២ Feature & Function ទាំងអស់

| Function | ការពន្យល់ |
|---------|---------|
| **Scan QR / Input Token** | Admin/Staff Input QR Token ឬ Scan QR ពី Customer Phone |
| **Verify Token** | POST `/admin/orders/verify-qr` → ពិនិត្យ Token ត្រឹមត្រូវ និង មិនផុតកំណត់ |
| **Mark Delivered** | Order Status → delivered, `pickup_verified_at` Stamped, `pickup_verified_by` Save |
| **Error Alert** | Token ខុស ឬ Expired → បង្ហាញ Error Message |

**Security:** QR Token ត្រូវបាន Signed + Expiry Timestamp — Admin មិនអាច Verify Token ហួសកំណត់ ។

---

## ៦.១២ Tracking Order (ការតាមដាន Order)

### ៦.១២.១ តួនាទី

**Tracking Order** ជាទំព័របង្ហាញ **Order Status Timeline** ពេញលេញ ដែល Admin, Staff អាចមើល ហើយ Update Status Order ។

### ៦.១២.២ Feature & Function ទាំងអស់

| Function | ការពន្យល់ |
|---------|---------|
| Order Timeline | Timeline ពី pending → approved → processing → out_for_delivery → delivered |
| Status History | ឃើញ ជាមួយ Timestamp, User ដែល Update, Role |
| Update Status | Admin ប្ដូរ Status → Save History, FCM Push ជូន Customer |
| Staff View | Staff ឃើញ Order ដែល Assigned ទៅខ្លួន |
| Staff Accept | Staff Confirm ទទួល Order → Status Updated |

---

## ៦.១៣ Payment Voucher (Voucher ចុះតម្លៃ)

### ៦.១៣.១ តួនាទី

**Payment Voucher** ជាទំព័រគ្រប់គ្រង Voucher (Discount Code) ដែល Customer ប្រើក្នុង Checkout ។

### ៦.១៣.២ Feature & Function ទាំងអស់

**Voucher List Table:**

| Column | ការពន្យល់ |
|--------|---------|
| CODE | Voucher Code |
| NAME | ឈ្មោះ Voucher |
| DISCOUNT | %, $ (fixed amount) |
| MIN ORDER | ថ្លៃ Order អប្បបរមា |
| EXPIRY | ថ្ងៃផុតកំណត់ |
| USED | ចំនួន Redemptions |
| STATUS | Active / Inactive |
| ACTION | Edit, Delete |

**+ Create Voucher — Form Fields:**

| Field | ការពន្យល់ |
|-------|---------|
| Code | Voucher Code (unique) e.g. "SAVE10" |
| Name | ឈ្មោះពណ៌នា |
| Discount Type | Percentage (%) ឬ Fixed Amount ($) |
| Discount Value | ចំនួន |
| Min Order Amount | Order ត្រូវ ≥ X ដើម្បីប្រើ Voucher |
| Starts At | ថ្ងៃចាប់ផ្ដើម |
| Expires At | ថ្ងៃផុតកំណត់ |
| Usage Limit (Total) | ចំនួន Redemption ស្រប (0 = Unlimited) |
| Usage Limit (Per User) | ចំនួន Use ក្នុង User តែមួយ |
| Is Active | Toggle Enable/Disable |
| Is Stackable | អាច Stack ជាមួយ Voucher ផ្សេង |

---

## ៦.១៤ Customers (អតិថិជន)

### ៦.១៤.១ តួនាទី

**Customers** ជាទំព័របង្ហាញ ព័ត៌មាន Customer ទាំងអស់ ដែលបានចុះឈ្មោះ ។ Admin មើលបាន ប៉ុន្ដែ **មិនអាចកែប្រែ** Customer Data ។

### ៦.១៤.២ Feature & Function ទាំងអស់

**Customer Table:**

| Column | ការពន្យល់ |
|--------|---------|
| NAME | ឈ្មោះ |
| EMAIL / PHONE | ទំនាក់ទំនង |
| TOTAL ORDERS | ចំនួន Order ដែលបាន Place |
| TOTAL SPENT | ប្រាក់សរុបដែលបានចំណាយ |
| JOINED | ថ្ងៃចុះឈ្មោះ |

**Features:**
- Search ដោយ Name, Email, Phone
- Sort ដោយ Total Spent, Total Orders
- Customer Count Summary Card

---

## ៦.១៥ Payments (ការទូទាត់)

### ៦.១៥.១ តួនាទី

**Payments** (ក្នុង Sales Section) ជាទំព័រ Monitor Payment ទាំងអស់ដែលបានធ្វើ — ទាំង Cash, KHQR/Bakong ។

### ៦.១៥.២ Feature & Function ទាំងអស់

**Summary Cards:**

| Card | ការពន្យល់ |
|------|---------|
| Today Revenue | ប្រាក់ Sale ដែលទទួលបានថ្ងៃនេះ |
| Pending Payments | ចំនួន Payment ដែល pending/processing |
| Reconciliation Issues | Payment ដែល Status មិន Match ជាមួយ KHQR |
| KHQR Pending | Transaction KHQR ដែលមិនទាន់ Confirmed |

**Payment Table:**

| Column | ការពន្យល់ |
|--------|---------|
| ORDER NUMBER | Order ជាប់ទាក់ |
| METHOD | Cash / Bakong |
| AMOUNT | ចំនួន |
| STATUS | pending / success / failed |
| KHQR STATUS | PENDING / SUCCESS / NOT_FOUND |
| PAID AT | ថ្ងៃ/ម៉ោង Confirm |

---

# SECTION ៤ — REPAIRS

---

## ៦.១៦ Repair Management (ការគ្រប់គ្រងជួសជុល)

### ៦.១៦.១ តួនាទី

**Repair Management** ជាទំព័រគ្រប់គ្រង Repair Request ទាំងអស់ ។ Admin, Technician ចូលគ្រប់គ្រង Workflow ចាប់ពី Intake រហូតដល់ Invoice ។

### ៦.១៦.២ Feature & Function ទាំងអស់

**Repair List Table:**

| Column | ការពន្យល់ |
|--------|---------|
| TICKET ID | លេខ Ticket |
| CUSTOMER | ឈ្មោះ Customer |
| DEVICE | Device Model |
| ISSUE TYPE | ប្រភេទបញ្ហា |
| TECHNICIAN | ជាងដែល Assign |
| APPOINTMENT | ពេលវេលា Appointment |
| STATUS | submitted / intake / diagnosed / quoted / in_repair / completed / delivered |
| ACTION | View Detail |

**Filter:**
- Filter ដោយ Status, Technician, Date Range

---

**Repair Detail Page — Actions ទាំងអស់:**

**ជំហាន ១ — Assign Technician:**

| Function | ការពន្យល់ |
|---------|---------|
| Assign Technician | ជ្រើស Technician ម្នាក់ → Repair Assigned |
| Auto-Assign | ប្រព័ន្ធ Auto ជ្រើស Technician ដែលមាន Load តិចបំផុត |

---

**ជំហាន ២ — Intake:**

| Field | ការពន្យល់ |
|-------|---------|
| IMEI / Serial Number | លេខ IMEI ឬ Serial |
| Device Condition Checklist | ស្ថានភាព: Screen, Battery, Body, Camera... |
| Intake Photos | Upload Photos ឧបករណ៍ |
| Notes | ចំណាំ |

បន្ទាប់ Save → Status ប្ដូរ: `intake`, Customer ទទួល Notification ។

---

**ជំហាន ៣ — Diagnostic:**

| Field | ការពន្យល់ |
|-------|---------|
| Problem Description | ការពណ៌នាបញ្ហា |
| Parts Required | គ្រឿងដែលត្រូវការ |
| Labor Cost | ថ្លៃការងារ |
| Notes | ចំណាំ |

បន្ទាប់ Save → Status: `diagnosed` ។

---

**ជំហាន ៤ — Quotation:**

| Field | ការពន្យល់ |
|-------|---------|
| Parts Cost | ថ្លៃ Parts |
| Labor Cost | ថ្លៃការងារ |
| Total Cost | សរុបគណនា |

Save → Status: `quoted`, **Customer ទទួល Notification** ហើយ Customer Approve/Reject ។

---

**ជំហាន ៥ — Update Repair Status:**

- Status Options: `in_repair`, `completed`, `delivered`
- Save → Tracking Log, FCM Push ជូន Customer

---

**ជំហាន ៦ — Create Invoice:**

| Field | ការពន្យល់ |
|-------|---------|
| Subtotal | ថ្លៃ Parts + Labor |
| Tax | ពន្ធ |
| Total | ថ្លៃសរុប |

---

**ជំហាន ៧ — Warranty:**

| Field | ការពន្យល់ |
|-------|---------|
| Duration (days) | ចំនួនថ្ងៃ ធានា |
| Covered Issues | ផ្នែកដែល Covered |
| Start / End Date | ថ្ងៃចាប់ - ថ្ងៃផុត |

Save → Status: `delivered`, Customer ឃើញ Warranty ក្នុង App ។

---

**Repair Chat:**
- Admin/Technician អាចផ្ញើ Message ទៅ Customer ផ្ទាល់ ពីក្នុង Repair Detail
- Customer ឃើញ Message ក្នុង App Tickets Screen

---

## ៦.១៧ Support Inbox (ការជជែក Support)

### ៦.១៧.១ តួនាទី

**Support Inbox** ជាទំព័រ Live Chat សម្រាប់ Admin/Staff ឆ្លើយ Message ជូន Customer ។

### ៦.១៧.២ Feature & Function ទាំងអស់

**Conversation List:**

| Column | ការពន្យល់ |
|--------|---------|
| CUSTOMER | ឈ្មោះ + Avatar |
| SUBJECT | ចំណងជើង |
| STATUS | open / resolved / closed |
| ASSIGNED TO | Staff ដែលទទួល |
| LAST MESSAGE | Message ចុងក្រោយ |
| UNREAD | Badge ចំនួន Unread |

**Conversation Detail Actions:**

| Action | ការពន្យល់ |
|--------|---------|
| Reply Message | ផ្ញើ Message Text / Media | Customer ទទួល FCM Push |
| Assign to Staff | Admin Assign Conversation ជូន Staff ជាក់លាក់ |
| Update Status | open → resolved → closed |
| Mark Read | Mark Unread Messages as Read |

---

## ៦.១៨ Technicians (ជាងបច្ចេកទេស)

### ៦.១៨.១ តួនាទី

**Technicians** ជាទំព័រគ្រប់គ្រង Profile ជាងបច្ចេកទេស (Technician) ។

### ៦.១៨.២ Feature & Function ទាំងអស់

**Technician List Table:**

| Column | ការពន្យល់ |
|--------|---------|
| NAME | ឈ្មោះ |
| SKILL SET | ជំនាញ (e.g. iOS Repair, Android Repair) |
| ACTIVE JOBS | ចំនួន Repair ដែល Active |
| AVAILABILITY | available / busy / offline |
| ACTION | Edit, Delete |

**+ Add Technician:**

| Field | ការពន្យល់ |
|-------|---------|
| Name | ឈ្មោះ |
| Skill Set | ជំនាញ (Free Text ឬ Tag) |
| Availability Status | available / busy / offline |

**Edit / Delete Technician**

---

# SECTION ៥ — INVENTORY

---

## ៦.១៩ Parts Inventory (ស្ទុំ គ្រឿងជួសជុល)

### ៦.១៩.១ តួនាទី

**Parts Inventory** ជាទំព័រគ្រប់គ្រង Stock គ្រឿង (Parts) ដែលប្រើក្នុងការជួសជុល ។

### ៦.១៩.២ Feature & Function ទាំងអស់

**Parts List Table:**

| Column | ការពន្យល់ |
|--------|---------|
| NAME | ឈ្មោះ Part |
| BRAND | Brand |
| TYPE | ប្រភេទ (Screen, Battery, Charging Port...) |
| SKU | Stock Keeping Unit |
| STOCK | ចំនួននៅ |
| UNIT COST | ថ្លៃ/Unit |
| STATUS | available / out_of_stock |
| TAG | Tag |
| ACTION | Edit, Delete |

**+ Add Part:**

| Field | ការពន្យល់ |
|-------|---------|
| Name | ឈ្មោះ |
| Brand | Brand |
| Type | Battery / Screen / Charging Port / Camera... |
| SKU | Code |
| Stock | ចំនួន |
| Unit Cost | ថ្លៃ |
| Status | available / out_of_stock |
| Tag | New / Low Stock / Popular |

**Edit / Delete Part**

**Usage Tracking:**
- Parts ដែលត្រូវបានប្រើក្នុង Repair នឹង Record ទៅ `parts_usages`

---

## ៦.២០ Warranty Records (កំណត់ត្រាការធានា)

### ៦.២០.១ តួនាទី

**Warranty Records** ជាទំព័រ Admin មើល Warranty ទាំងអស់ ដែលត្រូវបានផ្ដល់ជូន Customer ។

### ៦.២០.២ Feature & Function ទាំងអស់

**Warranty List Table:**

| Column | ការពន្យល់ |
|--------|---------|
| REPAIR ID | Repair ជាប់ |
| CUSTOMER | Customer |
| DEVICE | Device |
| DURATION | ចំនួនថ្ងៃ ធានា |
| START DATE | ថ្ងៃចាប់ |
| END DATE | ថ្ងៃផុត |
| COVERED ISSUES | ផ្នែក Covered |
| STATUS | active / expired |

---

# SECTION ៦ — FINANCE

---

## ៦.២១ Invoices (វិក្កយបត្រ)

### ៦.២១.១ តួនាទី

**Invoices** ជាទំព័របង្ហាញ Invoice ទាំងអស់ ដែលបានបង្កើតពី Repair Job ។

### ៦.២១.២ Feature & Function ទាំងអស់

**Invoice List Table:**

| Column | ការពន្យល់ |
|--------|---------|
| INVOICE NUMBER | លេខ Invoice |
| REPAIR ID | Repair ជាប់ |
| CUSTOMER | Customer |
| SUBTOTAL | ថ្លៃ Subtotal |
| TAX | ពន្ធ |
| TOTAL | ថ្លៃសរុប |
| PAYMENT STATUS | pending / partial / paid |

**Invoice Detail:**
- List `repair_payments` ក្នុង Invoice
- Deposit paid / Final paid

---

## ៦.២២ Finance Payments (ការទូទាត់ Finance)

### ៦.២២.១ តួនាទី

**Finance Payments** ជាទំព័របង្ហាញ Payment ទាំងអស់ ដែលធ្វើទាក់ទងនឹង Repair Service (Deposit + Final Payment) ។

### ៦.២២.២ Feature & Function ទាំងអស់

| Column | ការពន្យល់ |
|--------|---------|
| INVOICE | Invoice ជាប់ |
| TYPE | deposit / final |
| METHOD | cash / bakong |
| AMOUNT | ចំនួន |
| STATUS | pending / success |
| TRANSACTION REF | Reference Number |

---

## ៦.២៣ Revenue Reports (របាយការណ៍ចំណូល)

### ៦.២៣.១ តួនាទី

**Revenue Reports** ជាទំព័ររបាយការណ៍ ហិរញ្ញវត្ថុ ។ Admin ប្រើ ដើម្បីវិភាគ Revenue ប្រចាំខែ ។

### ៦.២៣.២ Feature & Function ទាំងអស់

| Function | ការពន្យល់ |
|---------|---------|
| Sales Summary | Revenue ប្រចាំថ្ងៃ, ខែ, ឆ្នាំ |
| Top Products | Product ដែលលក់ច្រើនបំផុត |
| Export CSV / Excel | Download Data |
| Date Range Filter | Filter តាម Date Range |

---

# SECTION ៧ — ACCESS

---

## ៦.២៤ User Management (ការគ្រប់គ្រង Staff)

### ៦.២៤.១ តួនាទី

**User Management** ជាទំព័រ Admin (**Admin Only**) បង្កើតគណនី **Staff** និង **Technician** ។

### ៦.២៤.២ Feature & Function ទាំងអស់

**User List Table:**

| Column | ការពន្យល់ |
|--------|---------|
| NAME | ឈ្មោះ |
| EMAIL / PHONE | ព័ត៌មានទំនាក់ |
| ROLE | staff / technician |
| CREATED | ថ្ងៃបង្កើត |

**+ Add User — Form Fields:**

| Field | ការពន្យល់ |
|-------|---------|
| First Name, Last Name | ឈ្មោះ |
| Email | Email (unique) |
| Phone | ទូរស័ព្ទ |
| Role | staff / technician |
| Password | Password (min 8 chars) |

**Search:**
- Filter ដោយ Role (staff / technician)
- Search ដោយ Name, Email, Phone

**Note:** Admin Account ត្រូវបង្កើតតាម Database Seeder — មិនអាចបង្កើតពីទំព័រនេះ ។

---

## ៦.២៥ Settings

### ៦.២៥.១ តួនាទី

**Settings** ជាទំព័រ Configuration ប្រព័ន្ធ ។

### ៦.២៥.២ Feature & Function ទាំងអស់

| Setting | ការពន្យល់ |
|---------|---------|
| App Configuration | ការ Config ទូទៅ |
| Language | ភាសា Admin Panel (KM/EN) |
| Theme | Light / Dark Mode |

---

# សង្ខេប — Admin Panel All Screens

| # | Screen | Section | Function សំខាន់ |
|---|--------|---------|----------------|
| 1 | Dashboard | Overview | Metrics, Sales Chart, Recent Orders, Low Stock |
| 2 | Notifications | Overview | Send FCM Push Campaign ជូន Customers |
| 3 | Reports | Overview | Sales/Inventory/Customer Reports + Export |
| 4 | Categories | Catalog | CRUD, Deactivate, Bulk Actions |
| 5 | Products | Catalog | CRUD + Variants + Status Toggle |
| 6 | Product Master | Catalog | CRUD Attribute Options |
| 7 | Accessories | Catalog | CRUD |
| 8 | Banners | Catalog | CRUD + Image Upload |
| 9 | Order Dashboard | Sales | List, Approve/Reject, Assign Staff, Status Update, Telegram |
| 10 | Checking Pick Up | Sales | Scan/Verify QR, Mark Delivered |
| 11 | Tracking Order | Sales | Timeline View, Update Status |
| 12 | Payment Voucher | Sales | CRUD Vouchers + Rules |
| 13 | Customers | Sales | View Customer Stats (Read Only) |
| 14 | Payments | Sales | Monitor Payments + KHQR Reconciliation |
| 15 | Repair Management | Repairs | Full Repair Workflow (Intake→Invoice→Warranty) |
| 16 | Support Inbox | Repairs | Reply Chat, Assign, Resolve |
| 17 | Technicians | Repairs | CRUD Technicians |
| 18 | Parts Inventory | Inventory | CRUD Parts + Stock |
| 19 | Warranty Records | Inventory | View All Warranties |
| 20 | Invoices | Finance | View Repair Invoices |
| 21 | Finance Payments | Finance | View Repair Payments |
| 22 | Revenue Reports | Finance | Revenue Charts + Export |
| 23 | User Management | Access | Create Staff/Technician Accounts |
| 24 | Settings | Access | App Config, Language, Theme |

---

*ឯកសារនេះ ពណ៌នាអំពី Screen, Function, និង Feature ទាំងអស់ ក្នុង Admin Panel (KNEAYERNG-Admin) ចំនួន ២៤ Screen ។*
