# KneaYerng Service Center - Data Dictionary
## ឯកសារចងក្រងលម្អិតលក្ខណៈដទ្ឋានទិន្នន័យ

---

## 📋 Table of Contents
1. [External Entities](#external-entities)
2. [Data Stores](#data-stores)
3. [Data Flow](#data-flow)
4. [Processes](#processes)
5. [Data Elements](#data-elements)
6. [Data Validation Rules](#data-validation-rules)
7. [System Maintenance Guide](#system-maintenance-guide)

---

## 🔗 External Entities

### 1. Customer (អតិថិជន)
**Description:** End user who accesses the KneaYerng Service Center application

**Attributes:**
| Field | Type | Format | Description |
|-------|------|--------|-------------|
| user_id | Integer | Unique ID | Primary identifier |
| first_name | String | Text (50) | Customer first name |
| last_name | String | Text (50) | Customer last name |
| email | String | Email format | Email address |
| phone | String | Phone (12) | Phone number |
| birth | String | YYYY-MM-DD | Date of birth |
| gender | String | M/F/Other | Gender |
| avatar_url | String | URL | Profile picture |
| role | String | Enum | User role (customer/admin) |
| is_admin | Boolean | True/False | Admin flag |
| created_at | DateTime | ISO 8601 | Account creation date |
| updated_at | DateTime | ISO 8601 | Last update date |

**Interactions:**
- User Authentication (Login/Register)
- Profile Management
- Order Management
- Support Chat
- Cart Management

---

### 2. Product Supplier (ផ្គត់ផ្គង់ផលិតផល)
**Description:** External entity providing products and inventory

**Data Received:**
- Product Information
- Pricing
- Stock Levels
- Product Images
- Category Information
- Warranty Information

**Data Provided:**
- Order Information
- Delivery Status
- Invoice Details

---

### 3. Payment Gateway (Bakong Payment)
**Description:** External payment processing system for transactions

**Interactions:**
- Payment Initiation
- Payment Status Updates
- Transaction Confirmation
- Receipt Generation

**Data Exchanged:**
- Amount
- Transaction ID
- Order Reference
- Payment Status

---

### 4. Firebase (Firebase Auth, Messaging)
**Description:** Cloud service for authentication and push notifications

**Services Used:**
- Firebase Authentication
- Firebase Cloud Messaging (FCM)
- Firebase Core

**Data Managed:**
- User Tokens
- Authentication Credentials
- Device Tokens
- Notification Data

---

### 5. Delivery Partner (ដឹកជញ្ជូនលទ្ធផល)
**Description:** External service providing delivery/pickup services

**Data Exchanged:**
- Delivery Address
- Delivery Status
- Delivery Timeline
- Staff Assignment
- Tracking Information

---

### 6. Support Staff (បុគ្គលិកគាំព្របច្ចេកទេស)
**Description:** Internal/External personnel handling customer support

**Functions:**
- Chat Management
- Ticket Resolution
- Customer Communication
- Order Status Updates

---

## 💾 Data Stores

### 1. User Profile Store
**Type:** Local (SharedPreferences) + Remote (API Backend)

**Data Stored:**
```
UserProfile {
  firstName: String
  lastName: String
  email: String
  phone: String
  birth: String (YYYY-MM-DD)
  gender: String (M/F/Other)
  avatarUrl: String (URL)
  role: String (enum)
  isAdmin: Boolean
}
```

**Lifecycle:**
- Created: User Registration
- Updated: Profile Edit
- Retrieved: Login/App Launch
- Duration: Account lifetime
- Storage: SharedPreferences + Backend Database

---

### 2. Products Store
**Type:** Remote (API Backend)

**Data Stored:**
```
Product {
  id: Integer
  name: String
  price: Double
  salePriceOverride: Double (nullable)
  imageUrl: String (URL)
  thumbnailUrl: String (URL)
  imageGallery: List<String>
  categoryName: String
  categoryId: Integer
  brand: String
  description: String
  sku: String
  discount: Double (nullable)
  rating: Double (default: 0)
  ratingCount: Integer
  stock: Integer
  status: String (active/inactive)
  tag: String
  warranty: String
  storageCapacity: String
  color: String
  condition: String
  ramOptions: List<String>
  ssd: String
  cpu: String
  display: String
  country: String
  variants: List<ProductVariant>
  createdAt: DateTime
}

ProductVariant {
  id: Integer
  storageCapacity: String
  color: String
  condition: String
  price: Double
  stock: Integer
  ram: String (nullable)
  ssd: String (nullable)
  sku: String (nullable)
  imageUrl: String (nullable)
  isActive: Boolean
}
```

**Lifecycle:**
- Created: Admin uploads products
- Updated: Inventory/Price changes
- Retrieved: Product browsing/search
- Frequency: Real-time sync
- Storage: Backend Database + Local Cache

---

### 3. Categories Store
**Type:** Remote (API Backend)

**Data Stored:**
```
Category {
  id: Integer
  name: String
  slug: String
  imageUrl: String (URL)
  productsCount: Integer
  status: String (active/inactive)
  createdAt: DateTime
  updatedAt: DateTime
}
```

**Lifecycle:**
- Created: Admin creates category
- Updated: Name/Image changes
- Retrieved: Category browsing
- Duration: Category active period
- Storage: Backend Database

---

### 4. Cart Store
**Type:** Local (SharedPreferences/Local Database)

**Data Stored:**
```
CartItem {
  remoteId: Integer (nullable)
  product: Product
  quantity: Integer
  variant: String (nullable)
  variantId: Integer (nullable)
  variantImageUrl: String (nullable)
  variantStock: Integer (nullable)
  unitPrice: Double (nullable)
}

Cart {
  items: List<CartItem>
  subtotal: Double
  deliveryFee: Double
  discountAmount: Double
  totalAmount: Double
  createdAt: DateTime
  updatedAt: DateTime
}
```

**Lifecycle:**
- Created: First item added
- Updated: Item add/remove/quantity change
- Retrieved: Cart view
- Cleared: Checkout completion or manual clear
- Duration: Session or persistent storage
- Storage: SharedPreferences (local)

---

### 5. Orders Store
**Type:** Remote (API Backend)

**Data Stored:**
```
PickupTicket (Order) {
  orderId: Integer
  orderNumber: String
  customerName: String
  customerEmail: String (nullable)
  orderType: String (delivery/pickup)
  paymentMethod: String (bakong/cash/etc)
  paymentStatus: String (pending/completed/failed)
  orderStatus: String (pending/approved/processing/completed/cancelled/rejected)
  deliveryAddress: String
  deliveryPhone: String
  deliveryNote: String
  subtotal: Double
  deliveryFee: Double
  discountAmount: Double
  totalAmount: Double
  placedAt: DateTime
  approvedAt: DateTime (nullable)
  rejectedAt: DateTime (nullable)
  cancelledAt: DateTime (nullable)
  assignedStaffId: Integer (nullable)
  assignedStaffName: String (nullable)
  pickupQrGeneratedAt: DateTime (nullable)
  pickupQrExpiresAt: DateTime (nullable)
  pickupVerifiedAt: DateTime (nullable)
  pickupQrToken: String
  pickupQrCode: String
  pickupTicketId: String
  items: List<PickupTicketItem>
  trackingTimeline: List<TrackingTimelineStep>
  trackingHistory: List<TrackingHistoryEntry>
}

PickupTicketItem {
  name: String
  quantity: Integer
  price: Double
}

TrackingTimelineStep {
  status: String (enum)
  label: String
  description: String (nullable)
  done: Boolean
  current: Boolean
  upcoming: Boolean
  at: DateTime (nullable)
}

TrackingHistoryEntry {
  id: Integer
  fromStatus: String (nullable)
  toStatus: String (required)
  changedByRole: String (admin/staff/customer)
  changedByUserId: Integer (nullable)
  changedByName: String
  assignedStaffId: Integer (nullable)
  assignedStaffName: String (nullable)
  overrideUsed: Boolean
  note: String (nullable)
  createdAt: DateTime
}
```

**Lifecycle:**
- Created: Checkout completion
- Updated: Status changes, staff assignment
- Retrieved: Order history, tracking
- Duration: Order lifetime (months/years)
- Storage: Backend Database

---

### 6. Address Store
**Type:** Local (SharedPreferences) + Remote (API Backend)

**Data Stored:**
```
SavedAddress {
  id: String (UUID)
  name: String
  phone: String
  addressLine: String
  note: String
  lat: Double
  lng: Double
  createdAt: DateTime
  isDefault: Boolean (nullable)
}
```

**Lifecycle:**
- Created: User saves address
- Updated: Address edit
- Retrieved: Delivery address selection
- Deleted: User deletion
- Storage: Local + Backend Database

---

### 7. Support Conversations Store
**Type:** Remote (API Backend)

**Data Stored:**
```
SupportConversation {
  id: Integer
  customerId: Integer
  assignedTo: Integer (nullable, staff_id)
  status: String (open/in_progress/resolved/closed)
  contextType: String (order/ticket/general)
  contextId: Integer (nullable)
  subject: String
  lastMessageAt: DateTime
  customerLastReadAt: DateTime (nullable)
  supportLastReadAt: DateTime (nullable)
  resolvedAt: DateTime (nullable)
  unreadForCustomer: Integer
  unreadForSupport: Integer
  customer: SupportChatParticipant
  assignee: SupportChatParticipant (nullable)
  messages: List<SupportChatMessage>
}

SupportChatMessage {
  id: Integer
  conversationId: Integer
  senderUserId: Integer (nullable)
  senderType: String (customer/support)
  messageType: String (text/voice/image)
  body: String (nullable)
  mediaUrl: String (nullable)
  mediaDurationSec: Integer (nullable)
  deliveryStatus: String (sent/delivered/seen)
  seenAt: DateTime (nullable)
  createdAt: DateTime
}

SupportChatParticipant {
  id: Integer
  name: String
  email: String (nullable)
  phone: String (nullable)
  role: String (customer/support_agent/admin)
}
```

**Lifecycle:**
- Created: Customer initiates chat
- Updated: New message, status change
- Retrieved: Support dashboard, chat view
- Resolved: Issue resolution
- Storage: Backend Database

---

### 8. Notifications Store
**Type:** Remote (API Backend)

**Data Stored:**
```
AdminNotification {
  id: Integer
  title: String
  body: String
  imageUrl: String (nullable)
  actionUrl: String (nullable)
  targetUsers: String (all/specific_users)
  priority: String (high/medium/low)
  sentAt: DateTime
  expiresAt: DateTime (nullable)
}

NotificationTracking {
  id: Integer
  notificationId: Integer
  userId: Integer
  deliveryStatus: String (sent/delivered/seen)
  readAt: DateTime (nullable)
}
```

**Lifecycle:**
- Created: Admin creates campaign
- Delivered: FCM delivery
- Read: User interaction
- Expired: Time-based expiration
- Storage: Backend Database

---

### 9. Favorites Store
**Type:** Local (SharedPreferences) + Remote (API Backend)

**Data Stored:**
```
Favorite {
  id: String
  userId: Integer
  productId: Integer
  product: Product (nested)
  createdAt: DateTime
}
```

**Lifecycle:**
- Created: User favorites product
- Retrieved: Favorites list view
- Deleted: User unfavorites
- Sync: Between local and remote
- Storage: Local + Backend Database

---

## 🔄 Data Flow

### 1. User Authentication Flow
```
┌─────────────────┐
│   User Input    │
│ (Email/Password)│
└────────┬────────┘
         │
         ▼
┌─────────────────────┐
│ Client Validation   │
│ - Email Format      │
│ - Password Strength │
└────────┬────────────┘
         │
         ▼
┌──────────────────────┐     ┌──────────────┐
│  Firebase Auth API   │────▶│ Backend API  │
│  - User Registration │     │ - User Sync  │
│  - User Login        │     │ - Token Gen  │
└────────┬─────────────┘     └──────┬───────┘
         │                          │
         ▼                          ▼
┌──────────────────┐     ┌──────────────────┐
│ Firebase Tokens  │     │ Backend Database │
│ - Auth Token     │     │ - User Profile   │
│ - Refresh Token  │     │ - User Metadata  │
└────────┬─────────┘     └──────┬───────────┘
         │                      │
         ▼                      ▼
┌─────────────────────────────────────────┐
│  Local Storage (SharedPreferences)      │
│  - Auth Token                            │
│  - User Profile Cache                    │
│  - Login State                           │
└─────────────────────────────────────────┘
```

**Data Elements Exchanged:**
- Email, Password
- Auth Token, Refresh Token
- User ID, User Profile
- Device Token

---

### 2. Product Browsing & Search Flow
```
┌──────────────────┐
│  User Request    │
│ - Browse/Search  │
└────────┬─────────┘
         │
         ▼
┌──────────────────────┐
│  API Service         │
│  - Get Products      │
│  - Apply Filters     │
│  - Search Query      │
└────────┬─────────────┘
         │
         ▼
┌──────────────────────┐
│  Backend API         │
│  - GET /products     │
│  - GET /categories   │
│  - GET /search       │
└────────┬─────────────┘
         │
         ▼
┌──────────────────────┐
│  Backend Database    │
│  - Product Records   │
│  - Categories        │
│  - Ratings/Reviews   │
└────────┬─────────────┘
         │
         ▼
┌──────────────────────┐
│  Response Processing │
│  - Parse JSON        │
│  - Normalize URLs    │
│  - Map to Models     │
└────────┬─────────────┘
         │
         ▼
┌──────────────────────┐
│  Local Caching       │
│  - Cached Images     │
│  - Product List      │
└────────┬─────────────┘
         │
         ▼
┌──────────────────────┐
│  UI Display          │
│  - Product Grid      │
│  - Product Details   │
└──────────────────────┘
```

**Data Elements Exchanged:**
- Product Data, Images, Ratings
- Category Information
- Pricing, Stock, Variants
- Filter Parameters

---

### 3. Shopping Cart & Checkout Flow
```
┌──────────────────────┐
│  Add to Cart         │
│  (Product Selected)  │
└────────┬─────────────┘
         │
         ▼
┌──────────────────────┐
│  Validate Selection  │
│  - Check Stock       │
│  - Check Variant     │
│  - Check Quantity    │
└────────┬─────────────┘
         │
         ▼
┌──────────────────────┐
│  Update Local Cart   │
│  (SharedPreferences) │
│  - Add/Update Item   │
│  - Calculate Total   │
└────────┬─────────────┘
         │
         ▼
┌──────────────────────┐
│  Checkout Process    │
│  - Review Items      │
│  - Select Address    │
│  - Choose Delivery   │
└────────┬─────────────┘
         │
         ▼
┌──────────────────────┐
│  Payment Processing  │
│  - Bakong Payment    │
│  - Transaction Init  │
└────────┬─────────────┘
         │
         ▼
┌──────────────────────┐
│  Backend Order API   │
│  - POST /orders      │
│  - Sync Cart Items   │
│  - Create Order      │
└────────┬─────────────┘
         │
         ▼
┌──────────────────────┐
│  Backend Database    │
│  - Store Order       │
│  - Record Items      │
│  - Update Inventory  │
└────────┬─────────────┘
         │
         ▼
┌──────────────────────┐
│  Order Confirmation  │
│  - Generate QR Code  │
│  - Email Receipt     │
│  - Push Notification │
└────────┬─────────────┘
         │
         ▼
┌──────────────────────┐
│  Clear Local Cart    │
│  - Reset State       │
│  - Show Success      │
└──────────────────────┘
```

**Data Elements Exchanged:**
- Product ID, Quantity, Variant
- Cart Items List
- Delivery Address, Phone
- Payment Details
- Order Confirmation, QR Code

---

### 4. Order Tracking Flow
```
┌──────────────────────┐
│  View Order History  │
└────────┬─────────────┘
         │
         ▼
┌──────────────────────┐
│  Backend API         │
│  - GET /orders       │
│  - GET /orders/{id}  │
└────────┬─────────────┘
         │
         ▼
┌──────────────────────┐
│  Backend Database    │
│  - Order Records     │
│  - Status History    │
│  - Tracking Timeline │
└────────┬─────────────┘
         │
         ▼
┌──────────────────────┐
│  Parse & Map Data    │
│  - Order Details     │
│  - Timeline Steps    │
│  - Tracking History  │
└────────┬─────────────┘
         │
         ▼
┌──────────────────────┐
│  Cache Locally       │
│  - Order List        │
│  - Order Details     │
└────────┬─────────────┘
         │
         ▼
┌──────────────────────┐
│  Display UI          │
│  - Order Timeline    │
│  - Status Updates    │
│  - Delivery Info     │
└──────────────────────┘
```

**Data Elements Exchanged:**
- Order ID, Order Number
- Order Status, Timeline
- Tracking History
- Delivery Information

---

### 5. Support Chat Flow
```
┌──────────────────────┐
│  Customer Message    │
└────────┬─────────────┘
         │
         ▼
┌──────────────────────┐
│  Local Message Queue │
│  - Prepare Message   │
│  - Validate Content  │
└────────┬─────────────┘
         │
         ▼
┌──────────────────────┐
│  Backend Chat API    │
│  - POST /messages    │
│  - Send Message      │
└────────┬─────────────┘
         │
         ▼
┌──────────────────────┐
│  Backend Database    │
│  - Store Message     │
│  - Update Timestamp  │
│  - Notify Support    │
└────────┬─────────────┘
         │
         ▼
┌──────────────────────┐
│  Websocket/FCM       │
│  - Real-time Update  │
│  - Push Notification │
└────────┬─────────────┘
         │
         ▼
┌──────────────────────┐
│  UI Update           │
│  - Display Message   │
│  - Show Timestamp    │
│  - Mark as Sent      │
└──────────────────────┘
```

**Data Elements Exchanged:**
- Message Content, Type
- Sender Information
- Conversation ID
- Delivery Status, Timestamp

---

## ⚙️ Processes

### Process 1: User Registration (ដំណើរការចុះឈ្មោះប្រើប្រាស់)

**Input:**
- Email
- Password
- First Name
- Last Name
- Phone (optional)
- Terms Acceptance

**Processing Steps:**
1. Validate email format and uniqueness
2. Validate password strength
3. Hash password
4. Create Firebase Auth user
5. Create backend user record
6. Send verification email
7. Initialize user preferences

**Output:**
- User ID
- Auth Token
- Refresh Token
- User Profile

**Error Handling:**
- Invalid email format → Display error message
- Email already exists → Suggest login
- Weak password → Show requirements
- Firebase error → Retry or fallback

**Maintenance Notes:**
- Monitor registration failures
- Track email verification rates
- Review spam registrations

---

### Process 2: Product Inventory Management (គ្រប់គ្រងស្តុក)

**Input:**
- Product Information (from supplier)
- Stock Levels
- Pricing
- Images
- Category Assignment

**Processing Steps:**
1. Validate product data
2. Normalize media URLs
3. Parse variants
4. Check stock thresholds
5. Update category counts
6. Cache product data locally
7. Trigger UI updates

**Output:**
- Product Records
- Variant Records
- Cached Images
- Updated Categories

**Data Validation:**
- Product name required
- Price must be positive
- Stock must be non-negative
- Category must exist
- Images must be valid URLs

**Maintenance Notes:**
- Monitor stock levels daily
- Archive inactive products
- Update pricing regularly
- Clean up broken image URLs

---

### Process 3: Order Processing (ដំណើរការលម្អិតរបស់ការបញ្ជាទិញ)

**Input:**
- Cart Items
- Delivery Address
- Payment Information
- Delivery Preference

**Processing Steps:**
1. Validate cart items (stock, prices)
2. Calculate totals (subtotal, fees, tax)
3. Process payment (Bakong)
4. Verify payment success
5. Create order record
6. Assign order number
7. Generate QR code
8. Send confirmation email
9. Update inventory
10. Notify support staff
11. Send push notification

**Output:**
- Order Record
- QR Code
- Pickup Ticket
- Confirmation Email
- Notification

**Error Handling:**
- Out of stock → Halt and notify
- Payment failed → Retry or cancel
- Invalid address → Request correction

**Maintenance Notes:**
- Monitor order processing time
- Track payment success rate
- Audit order cancellations
- Review order-related disputes

---

### Process 4: Order Tracking & Status Updates (តាមដានលក្ខខ័ណ្ឌនៃការបញ្ជាទិញ)

**Input:**
- Order ID
- Status Change Request
- Staff Information (optional)
- Update Notes (optional)

**Processing Steps:**
1. Validate order exists
2. Validate status transition
3. Check authorization
4. Create history entry
5. Update order status
6. Update timeline
7. Notify customer
8. Assign staff (if applicable)
9. Generate tracking info

**Output:**
- Updated Order Status
- Tracking History Entry
- Customer Notification
- Timeline Update

**Status Transitions:**
```
Created → Pending → Approved → Processing → Ready → 
(Out for Delivery / Ready for Pickup) → Delivered/Complete

Alternative:
Created → Rejected / Cancelled
```

**Maintenance Notes:**
- Monitor status update frequency
- Track delivery time accuracy
- Review stuck orders
- Audit unauthorized updates

---

### Process 5: Support Chat Management (គ្រប់គ្រងការគាត់ឆាក់គាំព្របច្ចេកទេស)

**Input:**
- User Message
- Conversation ID
- Attachment (optional)
- Conversation Context

**Processing Steps:**
1. Validate message content
2. Validate user authorization
3. Create message record
4. Store in database
5. Update conversation status
6. Mark timestamp
7. Notify recipient
8. Update unread counts
9. Archive old conversations

**Output:**
- Message Record
- Notification
- Updated Conversation
- Read Status Update

**Message Types:**
- Text
- Voice Message
- Image/File
- System Message

**Maintenance Notes:**
- Monitor response times
- Track resolution rates
- Audit chat quality
- Clean up old messages
- Monitor storage usage

---

### Process 6: Notification Campaign Management (ដឹកនាំគម្រោង​ការប្រកាស​ដូរដែល)

**Input:**
- Campaign Title
- Message Body
- Target Audience
- Images/Media
- Scheduling (optional)
- Expiration (optional)

**Processing Steps:**
1. Validate campaign data
2. Select target users
3. Create notification record
4. Format FCM payload
5. Send via Firebase
6. Track delivery status
7. Monitor read rates
8. Archive when expired

**Output:**
- Notification Record
- FCM Delivery Status
- Tracking Records
- Analytics Data

**Targeting Options:**
- All users
- Specific user IDs
- User segments
- Location-based
- Recent activity-based

**Maintenance Notes:**
- Monitor FCM delivery rates
- Track engagement metrics
- Review spam complaints
- Archive old campaigns
- Monitor data usage

---

## 📊 Data Elements

### Core Data Elements Reference

| Element | Type | Range | Format | Validation | Storage |
|---------|------|-------|--------|-----------|---------|
| User ID | Integer | 1-∞ | Unique | Required | DB |
| Email | String | 5-255 | RFC 5322 | Email regex | DB |
| Password | String | 8-128 | Hashed | Bcrypt/Hash | DB |
| Phone | String | 8-15 | E.164 | Phone regex | DB |
| Amount | Double | 0-999999 | 2 decimals | Positive | DB |
| Order ID | Integer | 1-∞ | Unique | Required | DB |
| Product ID | Integer | 1-∞ | Unique | Required | DB |
| Quantity | Integer | 1-10000 | Positive | Required | DB |
| Image URL | String | 0-2048 | HTTP(S) | URL regex | DB/Cache |
| Status | String | - | Enum | Predefined | DB |
| Created At | DateTime | - | ISO 8601 | Auto-set | DB |
| Updated At | DateTime | - | ISO 8601 | Auto-set | DB |
| Rating | Double | 0-5 | 2 decimals | 0≤x≤5 | DB |
| Latitude | Double | -90 to 90 | 8 decimals | GeoValid | DB |
| Longitude | Double | -180 to 180 | 8 decimals | GeoValid | DB |

---

## ✅ Data Validation Rules

### 1. User Profile Validation
```
first_name:
  - Required
  - Min length: 2
  - Max length: 50
  - Alphanumeric + spaces + hyphens

last_name:
  - Optional
  - Min length: 2
  - Max length: 50
  - Alphanumeric + spaces + hyphens

email:
  - Required
  - Valid RFC 5322 format
  - Unique in database
  - Max length: 255

phone:
  - Required
  - Valid E.164 format
  - Length: 8-15 characters
  - Numeric only

birth:
  - Optional
  - Format: YYYY-MM-DD
  - Cannot be future date
  - Minimum age: 13 years (if enforced)

gender:
  - Optional
  - Enum: [M, F, Other, Prefer not to say]
```

### 2. Product Validation
```
name:
  - Required
  - Min length: 3
  - Max length: 255
  - No special characters (except - and _)

price:
  - Required
  - Type: Double
  - Min: 0.01
  - Max: 999999.99
  - Decimal places: 2

stock:
  - Optional
  - Type: Integer
  - Min: 0
  - Max: 999999

category_id:
  - Required
  - Must exist in categories table
  - Valid foreign key

image_url:
  - Optional
  - Valid HTTP(S) URL
  - Accessible from CDN
  - Format: JPEG/PNG/WebP

sku:
  - Optional
  - Max length: 50
  - Alphanumeric only
  - Unique if provided
```

### 3. Order Validation
```
quantity:
  - Required
  - Type: Integer
  - Min: 1
  - Max: 10000
  - Cannot exceed stock

delivery_address:
  - Required
  - Min length: 10
  - Max length: 500
  - Valid format (street, city, country)

payment_method:
  - Required
  - Enum: [bakong, cash_on_delivery, bank_transfer]

order_status:
  - Required
  - Enum: [pending, approved, processing, 
           ready, delivered, cancelled, rejected]
  - Valid transitions only
```

### 4. Support Chat Validation
```
message_body:
  - Required if text message
  - Min length: 1
  - Max length: 5000
  - HTML escaping required

message_type:
  - Required
  - Enum: [text, voice, image, system]

attachment_file:
  - Optional
  - Max size: 25 MB
  - Allowed types: [jpg, png, mp3, m4a, pdf]

conversation_id:
  - Required
  - Must exist
  - User must have access
```

---

## 🔧 System Maintenance Guide

### Daily Maintenance Tasks

#### 1. Data Integrity Check
```
• Verify database connections
• Check backup completion
• Monitor storage usage
• Review error logs
• Validate data consistency
```

**Command Example:**
```sql
-- Check for orphaned records
SELECT order_id FROM orders 
WHERE customer_id NOT IN (SELECT id FROM users);

-- Verify status transitions
SELECT * FROM orders 
WHERE order_status NOT IN ('pending', 'approved', 
  'processing', 'ready', 'delivered', 'cancelled', 'rejected');
```

---

#### 2. Performance Monitoring
```
• Monitor API response times
• Check database query performance
• Review Firebase metrics
• Monitor storage usage
• Track cache hit rates
```

**Metrics to Track:**
- API response time (target: <500ms)
- Database query time (target: <100ms)
- Cache hit rate (target: >80%)
- Error rate (target: <1%)
- FCM delivery rate (target: >98%)

---

#### 3. User Activity Audit
```
• Review new user registrations
• Check suspicious login patterns
• Monitor order volume
• Track support chat activity
• Review payment transactions
```

---

### Weekly Maintenance Tasks

#### 1. Data Cleanup
```sql
-- Archive old notifications (older than 30 days)
DELETE FROM notifications 
WHERE created_at < DATE_SUB(NOW(), INTERVAL 30 DAY)
  AND status = 'archived';

-- Clean up expired orders
DELETE FROM orders 
WHERE status = 'cancelled' 
  AND created_at < DATE_SUB(NOW(), INTERVAL 90 DAY);

-- Clear old chat history (optional)
DELETE FROM support_messages 
WHERE created_at < DATE_SUB(NOW(), INTERVAL 1 YEAR)
  AND conversation_id IN (
    SELECT id FROM support_conversations 
    WHERE status = 'closed'
  );
```

---

#### 2. Database Optimization
```sql
-- Optimize tables
OPTIMIZE TABLE users;
OPTIMIZE TABLE products;
OPTIMIZE TABLE orders;
OPTIMIZE TABLE support_conversations;
OPTIMIZE TABLE support_messages;

-- Rebuild indexes
ANALYZE TABLE orders;
ANALYZE TABLE products;
```

---

#### 3. Backup Verification
```
• Verify daily backup completion
• Test backup restoration
• Check backup storage location
• Monitor backup size growth
• Update backup retention policy
```

---

### Monthly Maintenance Tasks

#### 1. Data Archive
```sql
-- Archive old orders (older than 12 months)
INSERT INTO orders_archive
SELECT * FROM orders 
WHERE created_at < DATE_SUB(NOW(), INTERVAL 12 MONTH);

DELETE FROM orders 
WHERE created_at < DATE_SUB(NOW(), INTERVAL 12 MONTH);

-- Archive old conversations
INSERT INTO support_conversations_archive
SELECT * FROM support_conversations 
WHERE resolved_at < DATE_SUB(NOW(), INTERVAL 6 MONTH);
```

---

#### 2. Statistical Analysis
```sql
-- Monthly sales report
SELECT 
  DATE_TRUNC(created_at, MONTH) as month,
  COUNT(*) as total_orders,
  SUM(total_amount) as revenue,
  AVG(total_amount) as avg_order_value
FROM orders
WHERE status = 'delivered'
GROUP BY month
ORDER BY month DESC;

-- Product performance
SELECT 
  product_id,
  COUNT(*) as sales,
  SUM(quantity) as units_sold,
  AVG(rating) as avg_rating
FROM order_items
GROUP BY product_id
ORDER BY sales DESC
LIMIT 20;

-- Support metrics
SELECT 
  DATE_TRUNC(created_at, MONTH) as month,
  COUNT(*) as conversations,
  AVG(DATEDIFF(resolved_at, created_at)) as avg_resolution_time
FROM support_conversations
GROUP BY month;
```

---

#### 3. Security Audit
```
• Review user access logs
• Audit admin actions
• Check for unauthorized access attempts
• Verify API key rotation
• Review Firebase security rules
• Check payment gateway compliance
```

---

### Quarterly Maintenance Tasks

#### 1. Database Schema Review
```
• Review table structures
• Analyze indexing strategy
• Check foreign key constraints
• Validate data types
• Review column constraints
• Plan schema migrations
```

---

#### 2. Performance Tuning
```sql
-- Identify slow queries
SELECT query_time, query FROM slow_log
WHERE query_time > 1000000;  -- 1 second in microseconds

-- Find missing indexes
-- Check tables for full table scans
EXPLAIN SELECT * FROM orders 
WHERE customer_id = 123;

-- Analyze query execution plans
EXPLAIN FORMAT=JSON SELECT * FROM products
WHERE category_id = 5 AND price < 1000;
```

---

#### 3. Data Quality Audit
```sql
-- Check for NULL values in required fields
SELECT COUNT(*) FROM users WHERE email IS NULL;
SELECT COUNT(*) FROM products WHERE name IS NULL;
SELECT COUNT(*) FROM orders WHERE customer_id IS NULL;

-- Identify duplicate records
SELECT email, COUNT(*) 
FROM users 
GROUP BY email 
HAVING COUNT(*) > 1;

-- Check data consistency
SELECT COUNT(*) FROM order_items 
WHERE order_id NOT IN (SELECT id FROM orders);
```

---

### Annual Maintenance Tasks

#### 1. System Upgrade Review
```
• Evaluate Flutter version updates
• Check dependency updates
• Review Firebase SDK versions
• Plan security patches
• Update development tools
• Review hosting/infrastructure
```

---

#### 2. Disaster Recovery Testing
```
• Perform full backup restoration test
• Test database failover
• Validate data recovery procedures
• Update disaster recovery plan
• Document recovery time objective (RTO)
• Document recovery point objective (RPO)
```

---

#### 3. Capacity Planning
```
• Analyze growth trends
• Plan storage expansion
• Review database sizing
• Plan API infrastructure scaling
• Budget for resources
• Update infrastructure roadmap
```

---

## 📈 Data Dictionary Maintenance Schedule

| Task | Frequency | Owner | Notes |
|------|-----------|-------|-------|
| Update Data Dictionary | Quarterly | Tech Lead | When schema changes |
| Backup Verification | Weekly | DevOps | Test restoration |
| Data Cleanup | Weekly | Database Admin | Archive old data |
| Performance Review | Monthly | DevOps | Identify bottlenecks |
| Security Audit | Quarterly | Security Team | Check access logs |
| Capacity Planning | Annually | Infrastructure | Plan growth |

---

## 🎯 Key Performance Indicators (KPIs)

| KPI | Target | Measurement |
|-----|--------|-------------|
| API Response Time | < 500ms | Average |
| Database Query Time | < 100ms | P95 |
| Data Backup Success | 100% | Daily |
| System Uptime | 99.9% | Monthly |
| Cache Hit Rate | > 80% | Daily |
| FCM Delivery Rate | > 98% | Daily |
| Order Processing Error | < 0.1% | Weekly |
| Support Response Time | < 1 hour | Average |

---

## 📞 Contact & Support

For data dictionary updates or maintenance issues:

| Role | Contact | Responsibility |
|------|---------|-----------------|
| Database Admin | [Email] | Daily maintenance, backups |
| Backend Developer | [Email] | Data schema, API design |
| System Administrator | [Email] | Infrastructure, monitoring |
| Tech Lead | [Email] | Data dictionary updates |

---

**Last Updated:** 2025-06-19
**Version:** 1.0
**Status:** Active

---

## 📚 Appendix

### A. SQL Schema Overview

**Users Table:**
```sql
CREATE TABLE users (
  id INT PRIMARY KEY AUTO_INCREMENT,
  email VARCHAR(255) UNIQUE NOT NULL,
  password_hash VARCHAR(255) NOT NULL,
  first_name VARCHAR(50),
  last_name VARCHAR(50),
  phone VARCHAR(15),
  birth DATE,
  gender ENUM('M', 'F', 'Other'),
  avatar_url VARCHAR(2048),
  role VARCHAR(20) DEFAULT 'customer',
  is_admin BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  INDEX idx_email (email),
  INDEX idx_created_at (created_at)
);
```

**Products Table:**
```sql
CREATE TABLE products (
  id INT PRIMARY KEY AUTO_INCREMENT,
  name VARCHAR(255) NOT NULL,
  price DECIMAL(10, 2) NOT NULL,
  sale_price DECIMAL(10, 2),
  image_url VARCHAR(2048),
  thumbnail_url VARCHAR(2048),
  category_id INT,
  brand VARCHAR(100),
  description TEXT,
  sku VARCHAR(50) UNIQUE,
  discount DECIMAL(10, 2),
  rating DECIMAL(3, 2) DEFAULT 0,
  rating_count INT DEFAULT 0,
  stock INT,
  status VARCHAR(20) DEFAULT 'active',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (category_id) REFERENCES categories(id),
  INDEX idx_category_id (category_id),
  INDEX idx_status (status),
  INDEX idx_created_at (created_at)
);
```

**Orders Table:**
```sql
CREATE TABLE orders (
  id INT PRIMARY KEY AUTO_INCREMENT,
  order_number VARCHAR(50) UNIQUE NOT NULL,
  customer_id INT NOT NULL,
  order_type ENUM('delivery', 'pickup') DEFAULT 'delivery',
  status VARCHAR(20) DEFAULT 'pending',
  payment_method VARCHAR(20),
  payment_status VARCHAR(20),
  delivery_address VARCHAR(500),
  delivery_phone VARCHAR(15),
  delivery_fee DECIMAL(10, 2),
  discount_amount DECIMAL(10, 2),
  total_amount DECIMAL(10, 2),
  subtotal DECIMAL(10, 2),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  approved_at TIMESTAMP NULL,
  delivered_at TIMESTAMP NULL,
  FOREIGN KEY (customer_id) REFERENCES users(id),
  INDEX idx_customer_id (customer_id),
  INDEX idx_status (status),
  INDEX idx_created_at (created_at)
);
```

---

### B. API Endpoints Reference

**Authentication:**
- POST /auth/register
- POST /auth/login
- POST /auth/logout
- POST /auth/refresh-token
- POST /auth/forgot-password
- POST /auth/reset-password

**Products:**
- GET /products
- GET /products/{id}
- GET /products/search?q={query}
- GET /categories
- GET /categories/{id}/products

**Orders:**
- GET /orders
- GET /orders/{id}
- POST /orders
- PUT /orders/{id}/status
- GET /orders/{id}/tracking

**Support:**
- GET /support/conversations
- GET /support/conversations/{id}
- POST /support/conversations/{id}/messages
- PUT /support/conversations/{id}/status

**User:**
- GET /user/profile
- PUT /user/profile
- POST /user/addresses
- GET /user/addresses
- DELETE /user/addresses/{id}

---

### C. Error Codes Reference

| Code | Status | Description | Action |
|------|--------|-------------|--------|
| 400 | Bad Request | Invalid input data | Validate input |
| 401 | Unauthorized | Authentication failed | Re-login |
| 403 | Forbidden | Permission denied | Check authorization |
| 404 | Not Found | Resource not found | Verify resource ID |
| 409 | Conflict | Data conflict (duplicate) | Check existing records |
| 422 | Unprocessable | Validation error | Fix data format |
| 500 | Server Error | Internal error | Retry or contact support |
| 503 | Service Unavailable | Service down | Wait and retry |

---

**End of Data Dictionary**
