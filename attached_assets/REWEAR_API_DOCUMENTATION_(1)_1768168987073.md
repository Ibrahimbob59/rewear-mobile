# ReWear API Documentation
**Complete API Reference for Frontend Development**

**Base URL:** `http://localhost:8000/api`  
**Version:** 1.0  
**Last Updated:** January 10, 2026

---

## Table of Contents
1. [Authentication](#1-authentication-19-endpoints)
2. [User Profile](#2-user-profile-3-endpoints)
3. [Items Marketplace](#3-items-marketplace-7-endpoints)
4. [Favorites](#4-favorites-3-endpoints)
5. [Orders](#5-orders-5-endpoints)
6. [Addresses](#6-addresses-4-endpoints)
7. [Driver Applications](#7-driver-applications-3-endpoints)
8. [Deliveries](#8-deliveries-5-endpoints)
9. [Driver Dashboard](#9-driver-dashboard-5-endpoints)
10. [Charity](#10-charity-7-endpoints)
11. [Notifications](#11-notifications-7-endpoints)
12. [Maps & Distance](#12-maps--distance-3-endpoints)
13. [Admin - Users](#13-admin---users-4-endpoints)
14. [Admin - Charities](#14-admin---charities-3-endpoints)
15. [Admin - Drivers](#15-admin---drivers-3-endpoints)
16. [Admin - Items](#16-admin---items-2-endpoints)
17. [Admin - Stats](#17-admin---stats-1-endpoint)

**Total Endpoints:** 75+

---

## Authentication Header

All protected endpoints require JWT Bearer token:

```
Authorization: Bearer <your_access_token>
```

---

# 1. Authentication (19 Endpoints)

## 1.1 Register - Request OTP Code

**POST** `/auth/register-code`

Send OTP code to email for registration.

**Request Body:**
```json
{
  "email": "user@example.com"
}
```

**Response (201):**
```json
{
  "success": true,
  "message": "Verification code sent to your email",
  "data": {
    "email": "user@example.com",
    "expires_at": "2026-01-10T12:15:00Z"
  }
}
```

**Errors:**
- `422` - Email already registered
- `429` - Too many requests (rate limited)

---

## 1.2 Register - Verify OTP & Create Account

**POST** `/auth/register`

Complete registration with OTP code.

**Request Body:**
```json
{
  "email": "user@example.com",
  "code": "123456",
  "name": "John Doe",
  "phone": "+9611234567",
  "password": "SecurePass123!",
  "password_confirmation": "SecurePass123!"
}
```

**Response (201):**
```json
{
  "success": true,
  "message": "Registration successful",
  "data": {
    "user": {
      "id": 1,
      "name": "John Doe",
      "email": "user@example.com",
      "phone": "+9611234567",
      "role": "user",
      "is_driver": false,
      "created_at": "2026-01-10T12:00:00Z"
    },
    "tokens": {
      "access_token": "eyJ0eXAiOiJKV1QiLCJhbGc...",
      "refresh_token": "def50200a1b2c3d4e5f6...",
      "token_type": "Bearer",
      "expires_in": 900
    }
  }
}
```

**Errors:**
- `400` - Invalid or expired OTP
- `422` - Validation errors

---

## 1.3 Resend OTP Code

**POST** `/auth/resend-code`

Resend verification code to email.

**Request Body:**
```json
{
  "email": "user@example.com"
}
```

**Response (200):**
```json
{
  "success": true,
  "message": "New verification code sent",
  "data": {
    "expires_at": "2026-01-10T12:20:00Z"
  }
}
```

---

## 1.4 Login

**POST** `/auth/login`

Login with email and password.

**Request Body:**
```json
{
  "email": "user@example.com",
  "password": "SecurePass123!"
}
```

**Response (200):**
```json
{
  "success": true,
  "message": "Login successful",
  "data": {
    "user": {
      "id": 1,
      "name": "John Doe",
      "email": "user@example.com",
      "role": "user",
      "is_driver": false
    },
    "tokens": {
      "access_token": "eyJ0eXAiOiJKV1QiLCJhbGc...",
      "refresh_token": "def50200a1b2c3d4e5f6...",
      "token_type": "Bearer",
      "expires_in": 900
    }
  }
}
```

**Errors:**
- `401` - Invalid credentials
- `403` - Account locked (too many failed attempts)

---

## 1.5 Refresh Access Token

**POST** `/auth/refresh-token`

Get new access token using refresh token.

**Request Body:**
```json
{
  "refresh_token": "def50200a1b2c3d4e5f6..."
}
```

**Response (200):**
```json
{
  "success": true,
  "data": {
    "access_token": "eyJ0eXAiOiJKV1QiLCJhbGc...",
    "token_type": "Bearer",
    "expires_in": 900
  }
}
```

**Errors:**
- `401` - Invalid or expired refresh token

---

## 1.6 Validate Token

**POST** `/auth/validate`

Check if access token is valid.

**Request Body:**
```json
{
  "token": "eyJ0eXAiOiJKV1QiLCJhbGc..."
}
```

**Response (200):**
```json
{
  "success": true,
  "message": "Token is valid",
  "data": {
    "valid": true,
    "user_id": 1,
    "expires_at": "2026-01-10T12:15:00Z"
  }
}
```

---

## 1.7 Get Current User

**GET** `/auth/me`  
🔒 **Requires:** Authentication

Get authenticated user profile.

**Response (200):**
```json
{
  "success": true,
  "data": {
    "id": 1,
    "name": "John Doe",
    "email": "user@example.com",
    "phone": "+9611234567",
    "role": "user",
    "is_driver": false,
    "driver_status": null,
    "created_at": "2026-01-10T12:00:00Z"
  }
}
```

---

## 1.8 Update Profile

**PUT** `/auth/profile`  
🔒 **Requires:** Authentication

Update user profile information.

**Request Body:**
```json
{
  "name": "John Smith",
  "phone": "+9611234567"
}
```

**Response (200):**
```json
{
  "success": true,
  "message": "Profile updated successfully",
  "data": {
    "id": 1,
    "name": "John Smith",
    "phone": "+9611234567"
  }
}
```

---

## 1.9 Change Password

**PUT** `/auth/password`  
🔒 **Requires:** Authentication

Change user password.

**Request Body:**
```json
{
  "current_password": "OldPass123!",
  "new_password": "NewSecurePass456!",
  "new_password_confirmation": "NewSecurePass456!"
}
```

**Response (200):**
```json
{
  "success": true,
  "message": "Password changed successfully"
}
```

**Errors:**
- `401` - Current password incorrect

---

## 1.10 Logout (Current Device)

**POST** `/auth/logout`  
🔒 **Requires:** Authentication

Logout from current device only.

**Response (200):**
```json
{
  "success": true,
  "message": "Logged out successfully"
}
```

---

## 1.11 Logout (All Devices)

**POST** `/auth/logout-all`  
🔒 **Requires:** Authentication

Logout from all devices (revoke all tokens).

**Response (200):**
```json
{
  "success": true,
  "message": "Logged out from all devices"
}
```

---

## 1.12 Get Active Sessions

**GET** `/auth/sessions`  
🔒 **Requires:** Authentication

View all active sessions/devices.

**Response (200):**
```json
{
  "success": true,
  "data": {
    "sessions": [
      {
        "id": 1,
        "device": "iPhone 13",
        "ip_address": "192.168.1.1",
        "last_used": "2026-01-10T12:00:00Z",
        "is_current": true
      }
    ]
  }
}
```

---

## 1.13 Get Token Statistics

**GET** `/auth/token-stats`  
🔒 **Requires:** Authentication

Get token usage statistics.

**Response (200):**
```json
{
  "success": true,
  "data": {
    "total_tokens": 3,
    "active_tokens": 2,
    "revoked_tokens": 1
  }
}
```

---

## 1.14 Delete Account

**DELETE** `/user/delete-account`  
🔒 **Requires:** Authentication

Permanently delete user account.

**Request Body:**
```json
{
  "password": "SecurePass123!"
}
```

**Response (200):**
```json
{
  "success": true,
  "message": "Account deleted successfully"
}
```

---

# 2. User Profile (3 Endpoints)

Covered in Authentication section (1.7, 1.8, 1.9)

---

# 3. Items Marketplace (7 Endpoints)

## 3.1 Browse Items (Public)

**GET** `/items`

Browse all available items (no authentication required).

**Query Parameters:**
- `category` - Filter by category
- `size` - Filter by size
- `condition` - Filter by condition (new, like_new, good, fair)
- `gender` - Filter by gender (male, female, unisex)
- `min_price` - Minimum price
- `max_price` - Maximum price
- `search` - Search in title/description
- `sort_by` - Sort field (price, created_at)
- `sort_order` - Sort direction (asc, desc)
- `per_page` - Items per page (default: 15)

**Example Request:**
```
GET /items?category=tshirts&size=M&condition=like_new&min_price=10&max_price=50&per_page=20
```

**Response (200):**
```json
{
  "success": true,
  "data": {
    "items": [
      {
        "id": 1,
        "title": "Nike T-Shirt",
        "description": "Brand new Nike athletic t-shirt",
        "price": 25.00,
        "category": "tshirts",
        "size": "M",
        "condition": "like_new",
        "gender": "male",
        "brand": "Nike",
        "images": [
          "https://storage.url/image1.jpg"
        ],
        "is_available": true,
        "seller": {
          "id": 2,
          "name": "Jane Doe"
        },
        "created_at": "2026-01-09T10:00:00Z"
      }
    ]
  },
  "meta": {
    "current_page": 1,
    "per_page": 20,
    "total": 45,
    "last_page": 3
  }
}
```

---

## 3.2 Get Item Details (Public)

**GET** `/items/{id}`

Get detailed information about a specific item.

**Response (200):**
```json
{
  "success": true,
  "data": {
    "id": 1,
    "title": "Nike T-Shirt",
    "description": "Brand new Nike athletic t-shirt, never worn",
    "price": 25.00,
    "category": "tshirts",
    "size": "M",
    "condition": "like_new",
    "gender": "male",
    "brand": "Nike",
    "color": "Blue",
    "material": "Cotton",
    "images": [
      "https://storage.url/image1.jpg",
      "https://storage.url/image2.jpg"
    ],
    "is_available": true,
    "listing_type": "sale",
    "seller": {
      "id": 2,
      "name": "Jane Doe",
      "items_sold": 12,
      "member_since": "2025-06-15T00:00:00Z"
    },
    "created_at": "2026-01-09T10:00:00Z",
    "updated_at": "2026-01-09T10:00:00Z"
  }
}
```

---

## 3.3 Create Item Listing

**POST** `/items`  
🔒 **Requires:** Authentication

Create new item listing (sale or donation).

**Request Body (multipart/form-data):**
```
title: "Nike T-Shirt"
description: "Brand new Nike athletic t-shirt"
category: "tshirts"
size: "M"
condition: "like_new"
gender: "male"
brand: "Nike"
color: "Blue"
material: "Cotton"
listing_type: "sale"  // or "donation"
price: 25.00  // Required if listing_type=sale
images[]: [File, File, File]  // Max 5 images
```

**Response (201):**
```json
{
  "success": true,
  "message": "Item listed successfully",
  "data": {
    "id": 1,
    "title": "Nike T-Shirt",
    "price": 25.00,
    "listing_type": "sale",
    "status": "available",
    "images": [
      "https://storage.url/image1.jpg"
    ]
  }
}
```

**Validation Rules:**
- `title`: Required, max 255 characters
- `description`: Required, max 2000 characters
- `category`: Required (tshirts, jeans, dresses, etc.)
- `size`: Required
- `condition`: Required (new, like_new, good, fair)
- `listing_type`: Required (sale, donation)
- `price`: Required if listing_type=sale, min 1
- `images`: Required, min 1, max 5, each max 5MB

---

## 3.4 Get My Listings

**GET** `/items/my-listings`  
🔒 **Requires:** Authentication

Get all items listed by authenticated user.

**Query Parameters:**
- `status` - Filter by status (available, sold, pending)
- `listing_type` - Filter by type (sale, donation)
- `per_page` - Items per page

**Response (200):**
```json
{
  "success": true,
  "data": {
    "items": [
      {
        "id": 1,
        "title": "Nike T-Shirt",
        "price": 25.00,
        "status": "available",
        "listing_type": "sale",
        "views": 45,
        "favorites": 8,
        "created_at": "2026-01-09T10:00:00Z"
      }
    ]
  },
  "meta": {
    "total": 12
  }
}
```

---

## 3.5 Update Item

**PUT** `/items/{id}`  
🔒 **Requires:** Authentication (Owner only)

Update existing item listing.

**Request Body:**
```json
{
  "title": "Updated Title",
  "price": 30.00,
  "description": "Updated description"
}
```

**Response (200):**
```json
{
  "success": true,
  "message": "Item updated successfully",
  "data": {
    "id": 1,
    "title": "Updated Title",
    "price": 30.00
  }
}
```

**Errors:**
- `403` - Not item owner
- `400` - Cannot edit sold items

---

## 3.6 Delete Item

**DELETE** `/items/{id}`  
🔒 **Requires:** Authentication (Owner only)

Delete item listing.

**Response (200):**
```json
{
  "success": true,
  "message": "Item deleted successfully"
}
```

**Errors:**
- `403` - Not item owner
- `400` - Cannot delete sold items

---

## 3.7 Toggle Item Status

**POST** `/items/{id}/toggle-status`  
🔒 **Requires:** Authentication (Owner only)

Toggle item between available/unavailable.

**Response (200):**
```json
{
  "success": true,
  "message": "Item status updated",
  "data": {
    "id": 1,
    "status": "unavailable"
  }
}
```

---

# 4. Favorites (3 Endpoints)

## 4.1 Get My Favorites

**GET** `/favorites`  
🔒 **Requires:** Authentication

Get all favorited items.

**Response (200):**
```json
{
  "success": true,
  "data": {
    "favorites": [
      {
        "item_id": 1,
        "item": {
          "id": 1,
          "title": "Nike T-Shirt",
          "price": 25.00,
          "images": ["https://..."],
          "is_available": true
        },
        "favorited_at": "2026-01-10T10:00:00Z"
      }
    ]
  }
}
```

---

## 4.2 Add to Favorites

**POST** `/favorites/{itemId}`  
🔒 **Requires:** Authentication

Add item to favorites.

**Response (201):**
```json
{
  "success": true,
  "message": "Item added to favorites"
}
```

**Errors:**
- `404` - Item not found
- `400` - Already in favorites

---

## 4.3 Remove from Favorites

**DELETE** `/favorites/{itemId}`  
🔒 **Requires:** Authentication

Remove item from favorites.

**Response (200):**
```json
{
  "success": true,
  "message": "Item removed from favorites"
}
```

---

# 5. Orders (5 Endpoints)

## 5.1 Create Order

**POST** `/orders`  
🔒 **Requires:** Authentication

Place new order (buy item).

**Request Body:**
```json
{
  "item_id": 1,
  "delivery_address_id": 1,
  "delivery_fee": 2.50
}
```

**Response (201):**
```json
{
  "success": true,
  "message": "Order placed successfully",
  "data": {
    "id": 1,
    "order_number": "RW-20260110-00001",
    "status": "pending",
    "item": {
      "id": 1,
      "title": "Nike T-Shirt",
      "price": 25.00
    },
    "buyer": {
      "id": 1,
      "name": "John Doe"
    },
    "seller": {
      "id": 2,
      "name": "Jane Doe"
    },
    "delivery_address": {
      "full_name": "John Doe",
      "phone": "+9611234567",
      "address_line1": "123 Main St",
      "city": "Beirut"
    },
    "item_price": 25.00,
    "delivery_fee": 2.50,
    "total_amount": 27.50,
    "payment_method": "cash_on_delivery",
    "delivery": {
      "id": 1,
      "status": "pending",
      "distance_km": 10.00,
      "driver_earnings": 1.88,
      "platform_earnings": 0.62
    },
    "created_at": "2026-01-10T12:00:00Z"
  }
}
```

**Errors:**
- `404` - Item not found
- `400` - Item not available / Cannot buy own item
- `422` - Invalid delivery address

---

## 5.2 Get My Orders (as Buyer)

**GET** `/orders`  
🔒 **Requires:** Authentication

Get all orders where user is the buyer.

**Query Parameters:**
- `status` - Filter by status (pending, confirmed, delivered, cancelled)
- `per_page` - Orders per page

**Response (200):**
```json
{
  "success": true,
  "data": {
    "orders": [
      {
        "id": 1,
        "order_number": "RW-20260110-00001",
        "status": "confirmed",
        "item": {...},
        "seller": {...},
        "total_amount": 27.50,
        "created_at": "2026-01-10T12:00:00Z"
      }
    ]
  },
  "meta": {
    "total": 5
  }
}
```

---

## 5.3 Get My Orders (as Seller)

**GET** `/orders/as-seller`  
🔒 **Requires:** Authentication

Get all orders where user is the seller.

**Response (200):**
```json
{
  "success": true,
  "data": {
    "orders": [
      {
        "id": 1,
        "order_number": "RW-20260110-00001",
        "status": "confirmed",
        "item": {...},
        "buyer": {...},
        "total_amount": 27.50,
        "created_at": "2026-01-10T12:00:00Z"
      }
    ]
  }
}
```

---

## 5.4 Get Order Details

**GET** `/orders/{id}`  
🔒 **Requires:** Authentication (Buyer or Seller only)

Get detailed information about specific order.

**Response (200):**
```json
{
  "success": true,
  "data": {
    "id": 1,
    "order_number": "RW-20260110-00001",
    "status": "confirmed",
    "item": {...},
    "buyer": {...},
    "seller": {...},
    "delivery_address": {...},
    "delivery": {
      "id": 1,
      "status": "pending",
      "driver": {
        "id": 3,
        "name": "Driver Name",
        "phone": "+9611111111"
      },
      "distance_km": 10.00,
      "estimated_time": "30-45 minutes"
    },
    "item_price": 25.00,
    "delivery_fee": 2.50,
    "total_amount": 27.50,
    "created_at": "2026-01-10T12:00:00Z",
    "confirmed_at": "2026-01-10T12:05:00Z"
  }
}
```

---

## 5.5 Cancel Order

**PUT** `/orders/{id}/cancel`  
🔒 **Requires:** Authentication (Buyer only, before delivery)

Cancel pending order.

**Request Body:**
```json
{
  "reason": "Changed my mind"
}
```

**Response (200):**
```json
{
  "success": true,
  "message": "Order cancelled successfully",
  "data": {
    "id": 1,
    "status": "cancelled",
    "cancellation_reason": "Changed my mind",
    "cancelled_at": "2026-01-10T12:10:00Z"
  }
}
```

**Errors:**
- `403` - Only buyer can cancel
- `400` - Cannot cancel delivered orders

---

# 6. Addresses (4 Endpoints)

## 6.1 Get My Addresses

**GET** `/addresses`  
🔒 **Requires:** Authentication

Get all delivery addresses for user.

**Response (200):**
```json
{
  "success": true,
  "data": {
    "addresses": [
      {
        "id": 1,
        "label": "Home",
        "full_name": "John Doe",
        "phone": "+9611234567",
        "address_line1": "123 Main St",
        "address_line2": "Apt 4B",
        "city": "Beirut",
        "state": "Beirut",
        "postal_code": "1107",
        "country": "Lebanon",
        "latitude": 33.8938,
        "longitude": 35.5018,
        "is_default": true
      }
    ]
  }
}
```

---

## 6.2 Create Address

**POST** `/addresses`  
🔒 **Requires:** Authentication

Add new delivery address.

**Request Body:**
```json
{
  "label": "Office",
  "full_name": "John Doe",
  "phone": "+9611234567",
  "address_line1": "456 Business Ave",
  "address_line2": "Suite 200",
  "city": "Beirut",
  "state": "Beirut",
  "postal_code": "1107",
  "country": "Lebanon",
  "latitude": 33.8938,
  "longitude": 35.5018,
  "is_default": false
}
```

**Response (201):**
```json
{
  "success": true,
  "message": "Address created successfully",
  "data": {
    "id": 2,
    "label": "Office",
    "is_default": false
  }
}
```

**Validation:**
- All fields required except `address_line2`
- Phone must be valid format
- Coordinates must be valid lat/lng

---

## 6.3 Update Address

**PUT** `/addresses/{id}`  
🔒 **Requires:** Authentication (Owner only)

Update existing address.

**Request Body:**
```json
{
  "label": "New Office",
  "phone": "+9619999999"
}
```

**Response (200):**
```json
{
  "success": true,
  "message": "Address updated successfully"
}
```

---

## 6.4 Delete Address

**DELETE** `/addresses/{id}`  
🔒 **Requires:** Authentication (Owner only)

Delete delivery address.

**Response (200):**
```json
{
  "success": true,
  "message": "Address deleted successfully"
}
```

**Errors:**
- `400` - Cannot delete default address (set another as default first)

---

# 7. Driver Applications (3 Endpoints)

## 7.1 Submit Driver Application

**POST** `/driver-applications`  
🔒 **Requires:** Authentication

Apply to become a driver.

**Request Body (multipart/form-data):**
```
vehicle_type: "motorcycle"  // or "car", "bicycle"
vehicle_model: "Honda CBR"
vehicle_year: 2020
license_number: "ABC123"
license_expiry: "2027-12-31"
license_document: [File]  // Image of license
vehicle_registration: [File]  // Image of registration
insurance_document: [File]  // Image of insurance
```

**Response (201):**
```json
{
  "success": true,
  "message": "Application submitted successfully",
  "data": {
    "id": 1,
    "status": "pending",
    "vehicle_type": "motorcycle",
    "submitted_at": "2026-01-10T12:00:00Z"
  }
}
```

**Errors:**
- `400` - Already has pending/approved application
- `422` - Invalid documents or expired license

---

## 7.2 Get My Application

**GET** `/driver-applications/my-application`  
🔒 **Requires:** Authentication

Get current user's driver application status.

**Response (200):**
```json
{
  "success": true,
  "data": {
    "id": 1,
    "status": "pending",  // pending, approved, rejected
    "vehicle_type": "motorcycle",
    "vehicle_model": "Honda CBR",
    "submitted_at": "2026-01-10T12:00:00Z",
    "reviewed_at": null,
    "rejection_reason": null
  }
}
```

**Response if no application (404):**
```json
{
  "success": false,
  "message": "No application found"
}
```

---

## 7.3 Check Driver Eligibility

**GET** `/driver-applications/eligibility`  
🔒 **Requires:** Authentication

Check if user can apply to be a driver.

**Response (200):**
```json
{
  "success": true,
  "data": {
    "eligible": true,
    "reasons": []
  }
}
```

**Response if not eligible (200):**
```json
{
  "success": true,
  "data": {
    "eligible": false,
    "reasons": [
      "Already a verified driver",
      "Pending application exists"
    ]
  }
}
```

---

# 8. Deliveries (5 Endpoints)

## 8.1 Get All Deliveries (Admin Only)

**GET** `/deliveries`  
🔒 **Requires:** Admin role

Get all deliveries in system.

**Query Parameters:**
- `status` - Filter by status
- `driver_id` - Filter by driver
- `per_page` - Deliveries per page

**Response (200):**
```json
{
  "success": true,
  "data": {
    "deliveries": [
      {
        "id": 1,
        "order_number": "RW-20260110-00001",
        "status": "pending",
        "driver": {...},
        "pickup_address": {...},
        "delivery_address": {...},
        "distance_km": 10.00
      }
    ]
  }
}
```

---

## 8.2 Get Delivery Details

**GET** `/deliveries/{id}`  
🔒 **Requires:** Authentication (Buyer, Seller, Driver, or Admin)

Get detailed delivery information.

**Response (200):**
```json
{
  "success": true,
  "data": {
    "id": 1,
    "order": {
      "id": 1,
      "order_number": "RW-20260110-00001"
    },
    "status": "in_transit",
    "driver": {
      "id": 3,
      "name": "Driver Name",
      "phone": "+9611111111",
      "vehicle_type": "motorcycle"
    },
    "pickup_address": {...},
    "delivery_address": {...},
    "distance_km": 10.00,
    "delivery_fee": 2.50,
    "driver_earnings": 1.88,
    "platform_earnings": 0.62,
    "picked_up_at": "2026-01-10T13:00:00Z",
    "delivered_at": null,
    "estimated_delivery": "2026-01-10T13:45:00Z"
  }
}
```

---

## 8.3 Assign Driver (Admin Only)

**POST** `/deliveries/{id}/assign-driver`  
🔒 **Requires:** Admin role

Manually assign driver to delivery.

**Request Body:**
```json
{
  "driver_id": 3
}
```

**Response (200):**
```json
{
  "success": true,
  "message": "Driver assigned successfully",
  "data": {
    "delivery_id": 1,
    "driver": {
      "id": 3,
      "name": "Driver Name"
    }
  }
}
```

---

## 8.4 Mark as Picked Up (Driver Only)

**POST** `/deliveries/{id}/pickup`  
🔒 **Requires:** Verified driver role

Mark delivery as picked up from seller.

**Response (200):**
```json
{
  "success": true,
  "message": "Marked as picked up",
  "data": {
    "id": 1,
    "status": "in_transit",
    "picked_up_at": "2026-01-10T13:00:00Z"
  }
}
```

**Errors:**
- `403` - Not assigned driver
- `400` - Already picked up

---

## 8.5 Mark as Delivered (Driver Only)

**POST** `/deliveries/{id}/deliver`  
🔒 **Requires:** Verified driver role

Mark delivery as completed and delivered.

**Request Body:**
```json
{
  "delivery_notes": "Left at door as requested"
}
```

**Response (200):**
```json
{
  "success": true,
  "message": "Delivery completed successfully",
  "data": {
    "id": 1,
    "status": "delivered",
    "delivered_at": "2026-01-10T13:40:00Z",
    "driver_earnings": 1.88
  }
}
```

---

# 9. Driver Dashboard (5 Endpoints)

## 9.1 Driver Dashboard

**GET** `/driver/dashboard`  
🔒 **Requires:** Verified driver role

Get driver dashboard overview.

**Response (200):**
```json
{
  "success": true,
  "data": {
    "stats": {
      "total_deliveries": 45,
      "completed_today": 5,
      "pending_deliveries": 2,
      "total_earnings": 875.50,
      "this_month_earnings": 125.00
    },
    "pending_deliveries": [
      {
        "id": 1,
        "order_number": "RW-20260110-00001",
        "status": "assigned",
        "distance_km": 10.00,
        "earnings": 1.88
      }
    ]
  }
}
```

---

## 9.2 Get My Deliveries (Driver)

**GET** `/driver/deliveries`  
🔒 **Requires:** Verified driver role

Get all deliveries assigned to driver.

**Query Parameters:**
- `status` - Filter by status (assigned, in_transit, delivered)
- `per_page` - Deliveries per page

**Response (200):**
```json
{
  "success": true,
  "data": {
    "deliveries": [
      {
        "id": 1,
        "order_number": "RW-20260110-00001",
        "status": "assigned",
        "pickup_address": {...},
        "delivery_address": {...},
        "distance_km": 10.00,
        "earnings": 1.88,
        "assigned_at": "2026-01-10T12:30:00Z"
      }
    ]
  }
}
```

---

## 9.3 Get Available Deliveries

**GET** `/driver/available-deliveries`  
🔒 **Requires:** Verified driver role

Get unassigned deliveries available for driver to accept.

**Response (200):**
```json
{
  "success": true,
  "data": {
    "available_deliveries": [
      {
        "id": 2,
        "order_number": "RW-20260110-00002",
        "pickup_city": "Beirut",
        "delivery_city": "Beirut",
        "distance_km": 8.00,
        "earnings": 1.50,
        "created_at": "2026-01-10T14:00:00Z"
      }
    ]
  }
}
```

---

## 9.4 Accept Delivery

**POST** `/driver/accept-delivery/{id}`  
🔒 **Requires:** Verified driver role

Accept an available delivery.

**Response (200):**
```json
{
  "success": true,
  "message": "Delivery accepted",
  "data": {
    "delivery_id": 2,
    "order_number": "RW-20260110-00002",
    "earnings": 1.50,
    "pickup_address": {...},
    "delivery_address": {...}
  }
}
```

**Errors:**
- `400` - Delivery already assigned
- `400` - Driver at max capacity (has 5+ active deliveries)

---

## 9.5 Get Earnings Summary

**GET** `/driver/earnings`  
🔒 **Requires:** Verified driver role

Get detailed earnings breakdown.

**Query Parameters:**
- `start_date` - Filter from date (YYYY-MM-DD)
- `end_date` - Filter to date (YYYY-MM-DD)

**Response (200):**
```json
{
  "success": true,
  "data": {
    "total_earnings": 875.50,
    "completed_deliveries": 45,
    "average_per_delivery": 19.46,
    "breakdown": {
      "today": 35.00,
      "this_week": 125.00,
      "this_month": 450.00
    },
    "recent_deliveries": [
      {
        "order_number": "RW-20260110-00001",
        "completed_at": "2026-01-10T13:40:00Z",
        "earnings": 1.88
      }
    ]
  }
}
```

---

# 10. Charity (7 Endpoints)

## 10.1 Charity Dashboard

**GET** `/charity/dashboard`  
🔒 **Requires:** Charity role

Get charity dashboard overview.

**Response (200):**
```json
{
  "success": true,
  "data": {
    "stats": {
      "total_donations_received": 125,
      "pending_donations": 8,
      "distributed_items": 110,
      "people_helped": 85
    },
    "recent_donations": [
      {
        "id": 1,
        "item": {
          "title": "Winter Jacket",
          "condition": "like_new"
        },
        "donor": {
          "name": "Jane Doe"
        },
        "status": "pending",
        "donated_at": "2026-01-10T10:00:00Z"
      }
    ]
  }
}
```

---

## 10.2 Get Available Donations

**GET** `/charity/available-donations`  
🔒 **Requires:** Charity role

Browse donation items available for charity to accept.

**Query Parameters:**
- `category` - Filter by category
- `condition` - Filter by condition
- `per_page` - Items per page

**Response (200):**
```json
{
  "success": true,
  "data": {
    "donations": [
      {
        "item_id": 5,
        "title": "Winter Jacket",
        "description": "Warm winter jacket in good condition",
        "category": "jackets",
        "size": "L",
        "condition": "good",
        "images": ["https://..."],
        "donor": {
          "name": "Anonymous"  // Can be hidden
        },
        "listed_at": "2026-01-10T09:00:00Z"
      }
    ]
  }
}
```

---

## 10.3 Accept Donation

**POST** `/charity/accept-donation/{itemId}`  
🔒 **Requires:** Charity role

Accept a donation item.

**Response (200):**
```json
{
  "success": true,
  "message": "Donation accepted successfully",
  "data": {
    "order_id": 10,
    "order_number": "RW-20260110-00010",
    "item": {
      "id": 5,
      "title": "Winter Jacket"
    },
    "delivery": {
      "status": "pending",
      "estimated_delivery": "2026-01-11T10:00:00Z"
    }
  }
}
```

**Errors:**
- `400` - Item already accepted by another charity
- `404` - Item not found or not a donation

---

## 10.4 Get My Donations

**GET** `/charity/my-donations`  
🔒 **Requires:** Charity role

Get all donations accepted by this charity.

**Query Parameters:**
- `status` - Filter by status (pending, in_transit, received, distributed)
- `per_page` - Items per page

**Response (200):**
```json
{
  "success": true,
  "data": {
    "donations": [
      {
        "id": 1,
        "order_number": "RW-20260110-00010",
        "item": {
          "title": "Winter Jacket",
          "condition": "good"
        },
        "donor": {
          "name": "Jane Doe"
        },
        "status": "received",
        "accepted_at": "2026-01-10T11:00:00Z",
        "received_at": "2026-01-11T10:30:00Z"
      }
    ]
  }
}
```

---

## 10.5 Mark as Distributed

**POST** `/charity/mark-distributed/{orderId}`  
🔒 **Requires:** Charity role

Mark donated item as distributed to beneficiary.

**Request Body:**
```json
{
  "beneficiary_count": 1,
  "distribution_notes": "Given to family in need"
}
```

**Response (200):**
```json
{
  "success": true,
  "message": "Marked as distributed successfully",
  "data": {
    "order_id": 10,
    "status": "distributed",
    "distributed_at": "2026-01-11T15:00:00Z",
    "beneficiary_count": 1
  }
}
```

---

## 10.6 Get Impact Statistics

**GET** `/charity/impact-stats`  
🔒 **Requires:** Charity role

Get charity's social impact statistics.

**Response (200):**
```json
{
  "success": true,
  "data": {
    "total_items_received": 125,
    "items_distributed": 110,
    "pending_distribution": 15,
    "people_helped": 85,
    "impact_by_category": {
      "clothing": 80,
      "shoes": 25,
      "accessories": 20
    },
    "monthly_trend": [
      {
        "month": "2026-01",
        "items_received": 35,
        "people_helped": 28
      }
    ]
  }
}
```

---

## 10.7 Get Recommended Donations

**GET** `/charity/recommended-donations`  
🔒 **Requires:** Charity role

Get AI-recommended donations based on charity's acceptance history.

**Response (200):**
```json
{
  "success": true,
  "data": {
    "recommendations": [
      {
        "item_id": 12,
        "title": "Children's Clothes Set",
        "match_score": 0.92,
        "reason": "Similar to your frequently accepted items"
      }
    ]
  }
}
```

---

# 11. Notifications (7 Endpoints)

## 11.1 Get My Notifications

**GET** `/notifications`  
🔒 **Requires:** Authentication

Get all notifications for user.

**Query Parameters:**
- `unread_only` - Only unread notifications (true/false)
- `type` - Filter by type (order, delivery, charity, system)
- `per_page` - Notifications per page

**Response (200):**
```json
{
  "success": true,
  "data": {
    "notifications": [
      {
        "id": 1,
        "type": "order",
        "title": "New Order",
        "message": "You have a new order for Nike T-Shirt",
        "data": {
          "order_id": 1,
          "order_number": "RW-20260110-00001"
        },
        "read_at": null,
        "created_at": "2026-01-10T12:05:00Z"
      }
    ]
  },
  "meta": {
    "unread_count": 5,
    "total": 25
  }
}
```

---

## 11.2 Get Unread Count

**GET** `/notifications/unread-count`  
🔒 **Requires:** Authentication

Get count of unread notifications.

**Response (200):**
```json
{
  "success": true,
  "data": {
    "unread_count": 5
  }
}
```

---

## 11.3 Mark as Read

**POST** `/notifications/{id}/mark-read`  
🔒 **Requires:** Authentication

Mark specific notification as read.

**Response (200):**
```json
{
  "success": true,
  "message": "Notification marked as read"
}
```

---

## 11.4 Mark All as Read

**POST** `/notifications/mark-all-read`  
🔒 **Requires:** Authentication

Mark all notifications as read.

**Response (200):**
```json
{
  "success": true,
  "message": "All notifications marked as read"
}
```

---

## 11.5 Delete Notification

**DELETE** `/notifications/{id}`  
🔒 **Requires:** Authentication

Delete specific notification.

**Response (200):**
```json
{
  "success": true,
  "message": "Notification deleted"
}
```

---

## 11.6 Clear All Notifications

**DELETE** `/notifications/clear-all`  
🔒 **Requires:** Authentication

Delete all notifications.

**Response (200):**
```json
{
  "success": true,
  "message": "All notifications cleared"
}
```

---

## 11.7 Send Test Notification (Dev Only)

**POST** `/notifications/test`  
🔒 **Requires:** Authentication

Send test notification (development/testing only).

**Request Body:**
```json
{
  "title": "Test Notification",
  "message": "This is a test",
  "type": "system"
}
```

**Response (200):**
```json
{
  "success": true,
  "message": "Test notification sent"
}
```

---

# 12. Maps & Distance (3 Endpoints)

## 12.1 Calculate Delivery Fee

**POST** `/maps/calculate-delivery-fee`  
🔒 **Requires:** Authentication

Calculate delivery fee based on distance between two addresses.

**Request Body:**
```json
{
  "pickup_latitude": 33.8938,
  "pickup_longitude": 35.5018,
  "delivery_latitude": 33.8886,
  "delivery_longitude": 35.4955
}
```

**Response (200):**
```json
{
  "success": true,
  "data": {
    "distance_km": 10.25,
    "delivery_fee": 2.56,
    "driver_earnings": 1.92,
    "platform_earnings": 0.64,
    "formula": "(10.25 km ÷ 4) × $1 = $2.56"
  }
}
```

**Errors:**
- `400` - Invalid coordinates
- `503` - Google Maps API unavailable

---

## 12.2 Validate Coordinates

**POST** `/maps/validate-coordinates`  
🔒 **Requires:** Authentication

Validate if coordinates are in serviceable area.

**Request Body:**
```json
{
  "latitude": 33.8938,
  "longitude": 35.5018
}
```

**Response (200):**
```json
{
  "success": true,
  "data": {
    "valid": true,
    "in_service_area": true,
    "latitude": 33.8938,
    "longitude": 35.5018,
    "location_info": "Beirut, Lebanon"
  }
}
```

---

## 12.3 Get Service Areas

**GET** `/maps/service-areas`  
🔒 **Requires:** Authentication

Get list of supported service areas.

**Response (200):**
```json
{
  "success": true,
  "data": {
    "supported_areas": [
      {
        "name": "Beirut",
        "bounds": {
          "north": 33.9,
          "south": 33.85,
          "east": 35.55,
          "west": 35.45
        }
      },
      {
        "name": "Tripoli",
        "bounds": {...}
      }
    ]
  }
}
```

---

# 13. Admin - Users (4 Endpoints)

## 13.1 Get All Users

**GET** `/admin/users`  
🔒 **Requires:** Admin role

Get list of all users with filtering.

**Query Parameters:**
- `role` - Filter by role (user, charity, driver)
- `search` - Search by name/email
- `is_driver` - Filter drivers (true/false)
- `per_page` - Users per page

**Response (200):**
```json
{
  "success": true,
  "data": {
    "users": [
      {
        "id": 1,
        "name": "John Doe",
        "email": "user@example.com",
        "phone": "+9611234567",
        "role": "user",
        "is_driver": false,
        "items_listed": 5,
        "orders_count": 12,
        "created_at": "2025-12-01T00:00:00Z"
      }
    ]
  },
  "meta": {
    "total": 150,
    "current_page": 1,
    "per_page": 20
  }
}
```

---

## 13.2 Get User Details

**GET** `/admin/users/{id}`  
🔒 **Requires:** Admin role

Get detailed information about specific user.

**Response (200):**
```json
{
  "success": true,
  "data": {
    "id": 1,
    "name": "John Doe",
    "email": "user@example.com",
    "phone": "+9611234567",
    "role": "user",
    "is_driver": false,
    "stats": {
      "items_listed": 5,
      "items_sold": 3,
      "orders_placed": 12,
      "total_spent": 350.00
    },
    "recent_activity": [...]
  }
}
```

---

## 13.3 Delete User

**DELETE** `/admin/users/{id}`  
🔒 **Requires:** Admin role

Permanently delete user account.

**Response (200):**
```json
{
  "success": true,
  "message": "User deleted successfully"
}
```

**Errors:**
- `400` - Cannot delete user with active orders
- `400` - Cannot delete admin account

---

## 13.4 Bulk Delete Users

**POST** `/admin/users/bulk-delete`  
🔒 **Requires:** Admin role

Delete multiple users at once.

**Request Body:**
```json
{
  "user_ids": [1, 2, 3, 4, 5]
}
```

**Response (200):**
```json
{
  "success": true,
  "message": "5 users deleted successfully"
}
```

---

# 14. Admin - Charities (3 Endpoints)

## 14.1 Create Charity Account

**POST** `/admin/charity/create`  
🔒 **Requires:** Admin role

Create new charity organization account.

**Request Body:**
```json
{
  "name": "Hope Foundation",
  "email": "contact@hope.org",
  "phone": "+9611234567",
  "password": "SecurePass123!",
  "organization_name": "Hope Foundation Lebanon",
  "registration_number": "REG123456",
  "description": "Helping families in need",
  "address": "123 Charity St, Beirut",
  "website": "https://hope.org"
}
```

**Response (201):**
```json
{
  "success": true,
  "message": "Charity account created successfully",
  "data": {
    "id": 10,
    "name": "Hope Foundation",
    "email": "contact@hope.org",
    "role": "charity",
    "organization_name": "Hope Foundation Lebanon"
  }
}
```

---

## 14.2 Get All Charities

**GET** `/admin/charities`  
🔒 **Requires:** Admin role

List all charity organizations.

**Response (200):**
```json
{
  "success": true,
  "data": {
    "charities": [
      {
        "id": 10,
        "name": "Hope Foundation",
        "organization_name": "Hope Foundation Lebanon",
        "email": "contact@hope.org",
        "donations_received": 125,
        "items_distributed": 110,
        "people_helped": 85,
        "created_at": "2025-11-01T00:00:00Z"
      }
    ]
  }
}
```

---

## 14.3 Update Charity

**PUT** `/admin/charities/{id}`  
🔒 **Requires:** Admin role

Update charity information.

**Request Body:**
```json
{
  "organization_name": "Updated Name",
  "description": "Updated description"
}
```

**Response (200):**
```json
{
  "success": true,
  "message": "Charity updated successfully"
}
```

---

# 15. Admin - Drivers (3 Endpoints)

## 15.1 Get Driver Applications

**GET** `/admin/driver-applications`  
🔒 **Requires:** Admin role

Get all driver applications with filtering.

**Query Parameters:**
- `status` - Filter by status (pending, approved, rejected)
- `per_page` - Applications per page

**Response (200):**
```json
{
  "success": true,
  "data": {
    "applications": [
      {
        "id": 1,
        "applicant": {
          "id": 5,
          "name": "Driver Name",
          "email": "driver@example.com"
        },
        "vehicle_type": "motorcycle",
        "vehicle_model": "Honda CBR",
        "license_number": "ABC123",
        "status": "pending",
        "submitted_at": "2026-01-09T10:00:00Z"
      }
    ]
  }
}
```

---

## 15.2 Get Application Details

**GET** `/admin/driver-applications/{id}`  
🔒 **Requires:** Admin role

Get detailed driver application with documents.

**Response (200):**
```json
{
  "success": true,
  "data": {
    "id": 1,
    "applicant": {...},
    "vehicle_type": "motorcycle",
    "vehicle_model": "Honda CBR",
    "vehicle_year": 2020,
    "license_number": "ABC123",
    "license_expiry": "2027-12-31",
    "documents": {
      "license": "https://storage.url/license.jpg",
      "registration": "https://storage.url/registration.jpg",
      "insurance": "https://storage.url/insurance.jpg"
    },
    "status": "pending",
    "submitted_at": "2026-01-09T10:00:00Z"
  }
}
```

---

## 15.3 Approve/Reject Driver Application

**POST** `/admin/driver-applications/{id}/review`  
🔒 **Requires:** Admin role

Approve or reject driver application.

**Request Body (Approve):**
```json
{
  "action": "approve"
}
```

**Request Body (Reject):**
```json
{
  "action": "reject",
  "reason": "Invalid license document"
}
```

**Response (200):**
```json
{
  "success": true,
  "message": "Application approved successfully",
  "data": {
    "application_id": 1,
    "status": "approved",
    "reviewed_at": "2026-01-10T15:00:00Z"
  }
}
```

---

# 16. Admin - Items (2 Endpoints)

## 16.1 Get All Items

**GET** `/admin/items`  
🔒 **Requires:** Admin role

Get all items with advanced filtering.

**Query Parameters:**
- `status` - Filter by status (available, sold, pending)
- `listing_type` - Filter by type (sale, donation)
- `flagged` - Show flagged items (true/false)
- `per_page` - Items per page

**Response (200):**
```json
{
  "success": true,
  "data": {
    "items": [
      {
        "id": 1,
        "title": "Nike T-Shirt",
        "price": 25.00,
        "status": "available",
        "listing_type": "sale",
        "seller": {...},
        "is_flagged": false,
        "created_at": "2026-01-09T10:00:00Z"
      }
    ]
  }
}
```

---

## 16.2 Delete Item (Admin)

**DELETE** `/admin/items/{id}`  
🔒 **Requires:** Admin role

Delete any item (even if not owner).

**Request Body:**
```json
{
  "reason": "Violates community guidelines"
}
```

**Response (200):**
```json
{
  "success": true,
  "message": "Item deleted by admin"
}
```

---

# 17. Admin - Stats (1 Endpoint)

## 17.1 Get Platform Statistics

**GET** `/admin/stats`

Get platform-wide statistics (public endpoint for impact banner).

**Response (200):**
```json
{
  "success": true,
  "data": {
    "total_users": 1250,
    "total_items": 3480,
    "items_sold": 1890,
    "items_donated": 567,
    "active_drivers": 45,
    "total_charities": 8,
    "items_saved_from_landfill": 2457,
    "people_helped": 1234,
    "total_deliveries": 2150,
    "platform_earnings": 1250.00,
    "monthly_growth": {
      "new_users": 85,
      "new_listings": 234,
      "completed_orders": 156
    }
  }
}
```

---

## Error Response Format

All API errors follow this structure:

```json
{
  "success": false,
  "message": "Error description",
  "errors": {
    "field_name": ["Validation error message"]
  }
}
```

**Common HTTP Status Codes:**
- `200 OK` - Success
- `201 Created` - Resource created
- `400 Bad Request` - Invalid request
- `401 Unauthorized` - Missing/invalid token
- `403 Forbidden` - Insufficient permissions
- `404 Not Found` - Resource not found
- `422 Unprocessable Entity` - Validation failed
- `429 Too Many Requests` - Rate limited
- `500 Internal Server Error` - Server error

---

## Rate Limiting

**Registration & OTP:**
- 5 requests per email per hour
- 5 requests per IP per hour

**General API:**
- 60 requests per minute per user

**Headers in Response:**
```
X-RateLimit-Limit: 60
X-RateLimit-Remaining: 45
X-RateLimit-Reset: 1641556800
```

---

## Pagination

Endpoints that return lists use pagination:

**Query Parameters:**
- `page` - Page number (default: 1)
- `per_page` - Items per page (default: 15, max: 100)

**Response Meta:**
```json
{
  "meta": {
    "current_page": 1,
    "per_page": 15,
    "total": 150,
    "last_page": 10,
    "from": 1,
    "to": 15
  }
}
```

---

## File Upload Guidelines

**Supported Formats:**
- Images: JPG, JPEG, PNG, GIF, WEBP
- Documents: PDF (driver applications)

**Size Limits:**
- Item images: 5MB per file, max 5 files
- Driver documents: 5MB per file

**Upload Method:**
- Use `multipart/form-data` content type
- Files stored in Firebase Storage
- URLs returned in response

---

## Testing Credentials

**Admin Account:**
```
Email: admin@rewear.com
Password: Admin@12345
```

**Test User:**
```
Email: john@test.com
Password: TestPass123!
```

**Test Charity:**
```
Email: charity@test.com
Password: TestPass123!
```

**Test Driver:**
```
Email: driver@test.com
Password: TestPass123!
```

---

## Postman Collection

Import the Postman collection for easy testing:
- File: `ReWear_API.postman_collection.json`
- Environment: `ReWear_Local.postman_environment.json`

**Collection includes:**
- All 75+ endpoints
- Pre-configured requests
- Example responses
- Environment variables for tokens

---

## WebSocket Events (Future)

**Planned real-time features:**
- Order status updates
- Delivery tracking
- New message notifications
- New donation alerts (charities)

---

**END OF API DOCUMENTATION**

For questions or issues, contact the development team.

---

**Version:** 1.0.0  
**Last Updated:** January 10, 2026  
**Total Endpoints:** 75+  
**Status:** ✅ Production Ready
