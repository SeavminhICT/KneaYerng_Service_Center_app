# 🔧 ឯកសារលម្អិតបច្ចេកទេសលម្អិត - API & Architecture

---

## 📡 REST API Documentation

### 🔐 Authentication Header
```
Authorization: Bearer {JWT_TOKEN}
Content-Type: application/json
```

### 📍 Base URL
```
https://api.service-center.kh/v1
```

---

## 🏠 Authentication API

### 1. Login
```http
POST /auth/login
Content-Type: application/json

{
  "email": "user@example.com",
  "password": "password123"
}

Response (200 OK):
{
  "success": true,
  "data": {
    "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "user": {
      "id": 1,
      "email": "user@example.com",
      "first_name": "John",
      "last_name": "Doe",
      "phone_number": "+855123456789",
      "profile_image_url": "https://api.../avatar.jpg",
      "address": "123 Street, Phnom Penh",
      "city": "Phnom Penh",
      "country": "Cambodia"
    }
  }
}
```

### 2. Register
```http
POST /auth/register
Content-Type: application/json

{
  "email": "newuser@example.com",
  "password": "password123",
  "first_name": "Jane",
  "last_name": "Smith",
  "phone_number": "+855123456789"
}

Response (201 Created):
{
  "success": true,
  "data": {
    "user_id": 2,
    "verification_token": "abc123def456",
    "message": "Registration successful. Please verify your email."
  }
}
```

### 3. Verify OTP
```http
POST /auth/verify-otp
Content-Type: application/json

{
  "user_id": 2,
  "otp": "123456"
}

Response (200 OK):
{
  "success": true,
  "data": {
    "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "user": { ... }
  }
}
```

### 4. Verify Token
```http
POST /auth/verify-token
Authorization: Bearer {TOKEN}

Response (200 OK):
{
  "success": true,
  "data": {
    "valid": true,
    "user_id": 1,
    "email": "user@example.com"
  }
}

Response (401 Unauthorized):
{
  "success": false,
  "error": "Token expired or invalid"
}
```

---

## 🛍️ Products API

### 1. Get All Products
```http
GET /products?page=1&limit=20&category=1&search=phone

Response (200 OK):
{
  "success": true,
  "data": [
    {
      "id": 1,
      "name": "Samsung Galaxy S21",
      "description": "Premium smartphone with 120Hz display",
      "price": 800.00,
      "sale_price": 750.00,
      "discount": 50.00,
      "category_id": 1,
      "category_name": "Phones",
      "brand": "Samsung",
      "stock": 25,
      "rating": 4.5,
      "rating_count": 128,
      "image_url": "https://api.../image.jpg",
      "thumbnail_url": "https://api.../thumb.jpg",
      "image_gallery": [
        "https://api.../img1.jpg",
        "https://api.../img2.jpg"
      ],
      "storage_capacity": "256GB",
      "color": "Black",
      "condition": "New",
      "ram": ["8GB", "12GB"],
      "cpu": "Snapdragon 888",
      "display": "6.2 inch AMOLED",
      "warranty": "2 years",
      "tag": "bestseller",
      "variants": [
        {
          "id": 101,
          "storage_capacity": "128GB",
          "color": "Black",
          "condition": "New",
          "price": 700.00,
          "stock": 10,
          "ram": "8GB",
          "ssd": "256GB",
          "sku": "SAM-S21-128GB-BLK"
        }
      ],
      "created_at": "2024-01-15T10:30:00Z"
    }
  ],
  "pagination": {
    "page": 1,
    "limit": 20,
    "total": 150,
    "total_pages": 8
  }
}
```

### 2. Get Product Details
```http
GET /products/1

Response (200 OK):
{
  "success": true,
  "data": {
    "id": 1,
    "name": "Samsung Galaxy S21",
    ... (full product object as above)
  }
}
```

### 3. Get Categories
```http
GET /categories

Response (200 OK):
{
  "success": true,
  "data": [
    {
      "id": 1,
      "name": "Phones",
      "image_url": "https://api.../phones.jpg",
      "product_count": 45
    },
    {
      "id": 2,
      "name": "Laptops",
      "image_url": "https://api.../laptops.jpg",
      "product_count": 30
    }
  ]
}
```

### 4. Search Products
```http
GET /search?q=phone&category=1&brand=samsung

Response (200 OK):
{
  "success": true,
  "data": {
    "products": [
      { ... product object ... }
    ],
    "categories": [
      { ... category object ... }
    ],
    "suggestions": [
      {
        "text": "samsung phone case",
        "type": "search"
      }
    ],
    "total_count": 45
  }
}
```

---

## 🛒 Cart API

### 1. Get Cart Items
```http
GET /cart
Authorization: Bearer {TOKEN}

Response (200 OK):
{
  "success": true,
  "data": [
    {
      "id": 501,
      "product": {
        "id": 1,
        "name": "Samsung Galaxy S21",
        "price": 800.00,
        "sale_price": 750.00,
        "image_url": "https://api.../image.jpg"
      },
      "quantity": 2,
      "variant": "256GB / Black / New",
      "variant_id": 101,
      "variant_image_url": "https://api.../variant.jpg",
      "unit_price": 750.00,
      "subtotal": 1500.00
    }
  ],
  "summary": {
    "subtotal": 1500.00,
    "tax": 150.00,
    "shipping": 5.00,
    "total": 1655.00
  }
}
```

### 2. Add to Cart
```http
POST /cart
Authorization: Bearer {TOKEN}
Content-Type: application/json

{
  "product_id": 1,
  "quantity": 2,
  "variant_id": 101,
  "variant": "256GB / Black / New"
}

Response (201 Created):
{
  "success": true,
  "data": {
    "cart_item": {
      "id": 501,
      "product_id": 1,
      "quantity": 2,
      "variant_id": 101
    },
    "items": [ ... all cart items ... ]
  }
}
```

### 3. Update Cart Item
```http
PUT /cart/501
Authorization: Bearer {TOKEN}
Content-Type: application/json

{
  "quantity": 3
}

Response (200 OK):
{
  "success": true,
  "data": {
    "items": [ ... updated cart items ... ]
  }
}
```

### 4. Remove from Cart
```http
DELETE /cart/501
Authorization: Bearer {TOKEN}

Response (200 OK):
{
  "success": true,
  "data": {
    "items": [ ... remaining cart items ... ]
  }
}
```

---

## 📦 Orders API

### 1. Create Order
```http
POST /orders
Authorization: Bearer {TOKEN}
Content-Type: application/json

{
  "delivery_address": "123 Street, Phnom Penh",
  "delivery_latitude": 11.5564,
  "delivery_longitude": 104.9282,
  "payment_method": "bakong",
  "bakong_qr": "00020126...",
  "notes": "Please ring doorbell"
}

Response (201 Created):
{
  "success": true,
  "data": {
    "order": {
      "id": 1001,
      "order_number": "ORD-2024-001001",
      "status": "pending",
      "total_amount": 1655.00,
      "items": [
        {
          "product_id": 1,
          "product_name": "Samsung Galaxy S21",
          "quantity": 2,
          "price": 750.00,
          "subtotal": 1500.00
        }
      ],
      "delivery_address": "123 Street, Phnom Penh",
      "created_at": "2024-06-16T10:30:00Z"
    },
    "qr_code": "00020126..." // Bakong payment QR
  }
}
```

### 2. Get User Orders
```http
GET /orders?page=1&limit=10&status=all
Authorization: Bearer {TOKEN}

Response (200 OK):
{
  "success": true,
  "data": [
    {
      "id": 1001,
      "order_number": "ORD-2024-001001",
      "status": "delivered",
      "total_amount": 1655.00,
      "created_at": "2024-06-16T10:30:00Z",
      "delivered_at": "2024-06-18T14:20:00Z",
      "items": [
        {
          "product_id": 1,
          "product_name": "Samsung Galaxy S21",
          "quantity": 2
        }
      ]
    }
  ],
  "pagination": {
    "page": 1,
    "limit": 10,
    "total": 15
  }
}
```

### 3. Get Order Details
```http
GET /orders/1001
Authorization: Bearer {TOKEN}

Response (200 OK):
{
  "success": true,
  "data": {
    "id": 1001,
    "order_number": "ORD-2024-001001",
    "status": "delivered",
    "total_amount": 1655.00,
    "items": [ ... items ... ],
    "tracking": {
      "status": "delivered",
      "current_location": "Customer Location",
      "estimated_delivery": "2024-06-18T17:00:00Z",
      "history": [
        {
          "status": "pending",
          "timestamp": "2024-06-16T10:30:00Z",
          "location": "Warehouse"
        },
        {
          "status": "shipped",
          "timestamp": "2024-06-16T15:00:00Z",
          "location": "Distribution Center"
        },
        {
          "status": "out_for_delivery",
          "timestamp": "2024-06-18T09:00:00Z",
          "location": "En Route"
        },
        {
          "status": "delivered",
          "timestamp": "2024-06-18T14:20:00Z",
          "location": "Customer Location"
        }
      ]
    }
  }
}
```

### 4. Get Order Tracking
```http
GET /orders/1001/tracking
Authorization: Bearer {TOKEN}

Response (200 OK):
{
  "success": true,
  "data": {
    "order_id": 1001,
    "order_number": "ORD-2024-001001",
    "status": "out_for_delivery",
    "current_location": "En Route to Delivery Address",
    "current_latitude": 11.5500,
    "current_longitude": 104.9250,
    "estimated_delivery": "2024-06-18T17:00:00Z",
    "driver_name": "Sokthea",
    "driver_phone": "+855123456789",
    "vehicle_plate": "PP-2024-1234",
    "history": [ ... tracking history ... ]
  }
}
```

---

## 👤 User Profile API

### 1. Get User Profile
```http
GET /profile
Authorization: Bearer {TOKEN}

Response (200 OK):
{
  "success": true,
  "data": {
    "id": 1,
    "email": "user@example.com",
    "first_name": "John",
    "last_name": "Doe",
    "phone_number": "+855123456789",
    "profile_image_url": "https://api.../avatar.jpg",
    "address": "123 Street, Phnom Penh",
    "city": "Phnom Penh",
    "country": "Cambodia"
  }
}
```

### 2. Update User Profile
```http
PUT /profile
Authorization: Bearer {TOKEN}
Content-Type: application/json

{
  "first_name": "John",
  "last_name": "Smith",
  "phone_number": "+855987654321",
  "address": "456 Avenue, Phnom Penh",
  "city": "Phnom Penh",
  "country": "Cambodia"
}

Response (200 OK):
{
  "success": true,
  "data": { ... updated user object ... }
}
```

### 3. Upload Profile Picture
```http
POST /profile/avatar
Authorization: Bearer {TOKEN}
Content-Type: multipart/form-data

file: (image file)

Response (200 OK):
{
  "success": true,
  "data": {
    "profile_image_url": "https://api.../avatar-new.jpg"
  }
}
```

### 4. Get Addresses
```http
GET /addresses
Authorization: Bearer {TOKEN}

Response (200 OK):
{
  "success": true,
  "data": [
    {
      "id": 1,
      "label": "Home",
      "address": "123 Street, Phnom Penh",
      "latitude": 11.5564,
      "longitude": 104.9282,
      "is_default": true,
      "notes": "Near market"
    },
    {
      "id": 2,
      "label": "Office",
      "address": "456 Avenue, Phnom Penh",
      "latitude": 11.5500,
      "longitude": 104.9250,
      "is_default": false
    }
  ]
}
```

### 5. Add Address
```http
POST /addresses
Authorization: Bearer {TOKEN}
Content-Type: application/json

{
  "label": "Work",
  "address": "789 Building, Phnom Penh",
  "latitude": 11.5450,
  "longitude": 104.9200,
  "is_default": false,
  "notes": "2nd floor"
}

Response (201 Created):
{
  "success": true,
  "data": {
    "id": 3,
    "label": "Work",
    ... (full address object)
  }
}
```

---

## 🔔 Notifications API

### 1. Register for Notifications
```http
POST /notifications/register
Authorization: Bearer {TOKEN}
Content-Type: application/json

{
  "token": "firebase_device_token_here",
  "platform": "android" // or "ios"
}

Response (200 OK):
{
  "success": true,
  "message": "Device registered successfully"
}
```

### 2. Get Notifications
```http
GET /notifications?page=1&limit=20&unread=false
Authorization: Bearer {TOKEN}

Response (200 OK):
{
  "success": true,
  "data": [
    {
      "id": 1,
      "type": "order_status",
      "title": "Order Shipped",
      "body": "Your order ORD-2024-001001 has been shipped",
      "data": {
        "order_id": 1001,
        "status": "shipped"
      },
      "is_read": false,
      "created_at": "2024-06-18T09:00:00Z"
    }
  ],
  "pagination": { ... }
}
```

### 3. Mark Notification as Read
```http
PUT /notifications/1/read
Authorization: Bearer {TOKEN}

Response (200 OK):
{
  "success": true
}
```

---

## ❌ Error Responses

### 400 Bad Request
```json
{
  "success": false,
  "error": "Validation error",
  "details": {
    "email": "Email is required",
    "password": "Password must be at least 8 characters"
  }
}
```

### 401 Unauthorized
```json
{
  "success": false,
  "error": "Token invalid or expired",
  "code": "UNAUTHORIZED"
}
```

### 403 Forbidden
```json
{
  "success": false,
  "error": "Access denied",
  "code": "FORBIDDEN"
}
```

### 404 Not Found
```json
{
  "success": false,
  "error": "Resource not found",
  "code": "NOT_FOUND"
}
```

### 500 Server Error
```json
{
  "success": false,
  "error": "Internal server error",
  "code": "SERVER_ERROR"
}
```

---

## 🎯 Payment Integration - Bakong

### 1. Generate Bakong QR
```http
POST /payments/bakong/generate-qr
Authorization: Bearer {TOKEN}
Content-Type: application/json

{
  "order_id": 1001,
  "amount": 1655.00,
  "merchant_id": "KYSERVICE",
  "currency": "KHR"
}

Response (200 OK):
{
  "success": true,
  "data": {
    "qr_code": "00020126360014com.ababank.bakong01051234567890520408521234567890543001065406551655.005802KH5913MERCHANT6009PHNOM PENH63041234",
    "merchant_name": "Khmer Service Center",
    "transaction_id": "TXN-1001"
  }
}
```

### 2. Verify Payment
```http
POST /payments/bakong/verify
Authorization: Bearer {TOKEN}
Content-Type: application/json

{
  "order_id": 1001,
  "transaction_id": "TXN-1001"
}

Response (200 OK):
{
  "success": true,
  "data": {
    "status": "completed",
    "amount": 1655.00,
    "timestamp": "2024-06-18T10:30:00Z"
  }
}
```

---

## 🐛 Common API Status Codes

| Code | Meaning |
|------|---------|
| 200 | OK - Request successful |
| 201 | Created - Resource created |
| 204 | No Content - Successful deletion |
| 400 | Bad Request - Invalid input |
| 401 | Unauthorized - Auth required/failed |
| 403 | Forbidden - No permission |
| 404 | Not Found - Resource doesn't exist |
| 409 | Conflict - Resource already exists |
| 422 | Unprocessable Entity - Validation failed |
| 500 | Server Error - Internal error |
| 503 | Service Unavailable - Server down |

---

## 🔐 Security Headers

```
X-Content-Type-Options: nosniff
X-Frame-Options: DENY
X-XSS-Protection: 1; mode=block
Strict-Transport-Security: max-age=31536000; includeSubDomains
Content-Security-Policy: default-src 'self'
```

---

## 📊 Rate Limiting

```
X-RateLimit-Limit: 1000
X-RateLimit-Remaining: 999
X-RateLimit-Reset: 1623945600
```

- 1000 requests per hour
- 10 requests per second (burst limit)

---

## 📝 Response Format

All responses follow this format:

```json
{
  "success": true/false,
  "data": { ... },
  "error": "error message if success=false",
  "code": "ERROR_CODE",
  "timestamp": "2024-06-18T10:30:00Z"
}
```

---

**ឯកសារលម្អិត:** API Documentation v1.0  
**កាលបរិច្ឆេទ:** ២០២៦ ខែមិថុនា
