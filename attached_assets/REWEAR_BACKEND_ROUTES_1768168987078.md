# ReWear Backend Routes Reference
**Actual Laravel Route Definitions**

**Base URL:** `http://localhost:8000/api`  
**Routes File:** `routes/api.php`

---

## 📋 Quick Navigation
1. [Public Routes (No Auth)](#public-routes-no-authentication)
2. [Authentication Routes](#authentication-routes-protected)
3. [User Management](#user-management)
4. [Items](#items-routes)
5. [Favorites](#favorites-routes)
6. [Orders](#orders-routes)
7. [Addresses](#addresses-routes)
8. [Driver Applications](#driver-applications)
9. [Deliveries](#deliveries)
10. [Driver Dashboard](#driver-dashboard)
11. [Charity](#charity-routes)
12. [Notifications](#notifications)
13. [Maps & Distance](#maps--delivery-calculation)
14. [Admin - Users](#admin---user-management)
15. [Admin - Charities](#admin---charity-management)
16. [Admin - Drivers](#admin---driver-management)
17. [Admin - Deliveries](#admin---delivery-stats)
18. [Admin - Donations](#admin---donation-stats)
19. [Health & Testing](#health--testing-routes)

---

## Public Routes (No Authentication)

### Authentication (Public)
```php
// Registration
POST   /api/auth/register-code          → RegisterController::requestCode
POST   /api/auth/register                → RegisterController::register
POST   /api/auth/resend-code             → RegisterController::resendCode

// Login
POST   /api/auth/login                   → LoginController::login

// Token Management (Public)
POST   /api/auth/refresh-token           → TokenController::refreshToken
POST   /api/auth/validate                → TokenController::validateToken
```

### Marketplace (Public)
```php
// Browse items without authentication
GET    /api/items                        → ItemController::index
GET    /api/items/{id}                   → ItemController::show (whereNumber)

// Platform statistics (public for impact banner)
GET    /api/admin/stats                  → AdminController::getStats
```

---

## Protected Routes
**Middleware:** `auth:api` (JWT Bearer token required)

---

## Authentication Routes (Protected)

### Profile Management
```php
Route::prefix('auth')->group(function () {
    GET    /api/auth/me                  → ProfileController::me
    PUT    /api/auth/profile             → ProfileController::updateProfile
    PUT    /api/auth/password            → ProfileController::changePassword
});
```

### Logout & Sessions
```php
Route::prefix('auth')->group(function () {
    POST   /api/auth/logout              → TokenController::logout
    POST   /api/auth/logout-all          → TokenController::logoutAll
    
    GET    /api/auth/sessions            → TokenController::getSessions
    GET    /api/auth/token-stats         → TokenController::getTokenStats
});
```

---

## User Management

### Self Account Management
```php
Route::prefix('user')->group(function () {
    DELETE /api/user/delete-account      → UserManagementController::deleteSelfAccount
});
```

---

## Items Routes

```php
Route::prefix('items')->group(function () {
    POST   /api/items                    → ItemController::store
    GET    /api/items/my-listings        → ItemController::myListings
    PUT    /api/items/{id}               → ItemController::update
    DELETE /api/items/{id}               → ItemController::destroy
    POST   /api/items/{id}/toggle-status → ItemController::toggleStatus
});
```

**Note:** Public item browsing routes are listed in Public Routes section above.

---

## Favorites Routes

```php
Route::prefix('favorites')->group(function () {
    GET    /api/favorites                → FavoriteController::index
    POST   /api/favorites/{itemId}       → FavoriteController::store
    DELETE /api/favorites/{itemId}       → FavoriteController::destroy
});
```

---

## Orders Routes

```php
Route::prefix('orders')->group(function () {
    POST   /api/orders                   → OrderController::store
    GET    /api/orders                   → OrderController::index
    GET    /api/orders/as-seller         → OrderController::asSeller
    GET    /api/orders/{id}              → OrderController::show
    PUT    /api/orders/{id}/cancel       → OrderController::cancel
    POST   /api/orders/{id}/confirm      → OrderController::confirm
});
```

---

## Addresses Routes

```php
Route::prefix('addresses')->group(function () {
    GET    /api/addresses                → AddressController::index
    POST   /api/addresses                → AddressController::store
    PUT    /api/addresses/{id}           → AddressController::update
    DELETE /api/addresses/{id}           → AddressController::destroy
});
```

---

## Driver Applications

```php
Route::prefix('driver-applications')->group(function () {
    POST   /api/driver-applications      → DriverApplicationController::store
    GET    /api/driver-applications/my-application     
                                         → DriverApplicationController::myApplication
    GET    /api/driver-applications/eligibility
                                         → DriverApplicationController::checkEligibility
});
```

---

## Deliveries

```php
Route::prefix('deliveries')->group(function () {
    GET    /api/deliveries               → DeliveryController::index (Admin only)
    GET    /api/deliveries/{id}          → DeliveryController::show
    POST   /api/deliveries/{id}/assign-driver
                                         → DeliveryController::assignDriver (Admin only)
    POST   /api/deliveries/{id}/pickup   → DeliveryController::markAsPickedUp
    POST   /api/deliveries/{id}/deliver  → DeliveryController::markAsDelivered
    POST   /api/deliveries/{id}/fail     → DeliveryController::markAsFailed
});
```

---

## Driver Dashboard
**Middleware:** `auth:api` + `verified_driver`

```php
Route::prefix('driver')->middleware('verified_driver')->group(function () {
    GET    /api/driver/dashboard         → DriverDashboardController::dashboard
    GET    /api/driver/deliveries        → DriverDashboardController::myDeliveries
    GET    /api/driver/available-deliveries
                                         → DriverDashboardController::availableDeliveries
    POST   /api/driver/accept-delivery/{id}
                                         → DriverDashboardController::acceptDelivery
    GET    /api/driver/earnings          → DriverDashboardController::earnings
});
```

---

## Charity Routes
**Middleware:** `auth:api` + `role:charity`

```php
Route::prefix('charity')->middleware('role:charity')->group(function () {
    GET    /api/charity/dashboard        → CharityController::dashboard
    GET    /api/charity/available-donations
                                         → CharityController::availableDonations
    POST   /api/charity/accept-donation/{itemId}
                                         → CharityController::acceptDonation
    GET    /api/charity/my-donations     → CharityController::myDonations
    POST   /api/charity/mark-distributed/{orderId}
                                         → CharityController::markDistributed
    GET    /api/charity/impact-stats     → CharityController::impactStats
    GET    /api/charity/recommended-donations
                                         → CharityController::recommendedDonations
});
```

---

## Notifications

```php
Route::prefix('notifications')->group(function () {
    GET    /api/notifications            → NotificationController::index
    GET    /api/notifications/unread-count
                                         → NotificationController::unreadCount
    POST   /api/notifications/{id}/mark-read
                                         → NotificationController::markAsRead
    POST   /api/notifications/mark-all-read
                                         → NotificationController::markAllAsRead
    DELETE /api/notifications/{id}       → NotificationController::destroy
    DELETE /api/notifications/clear-all  → NotificationController::clearAll
    POST   /api/notifications/test       → NotificationController::sendTestNotification (Dev)
});
```

---

## Maps & Delivery Calculation

```php
Route::prefix('maps')->group(function () {
    POST   /api/maps/calculate-delivery-fee
                                         → GoogleMapsController::calculateDeliveryFee
    POST   /api/maps/validate-coordinates
                                         → GoogleMapsController::validateCoordinates
    GET    /api/maps/service-areas       → GoogleMapsController::serviceAreas
});

// Direct route (alternative for convenience)
POST   /api/calculate-delivery-fee      → GoogleMapsController::calculateDeliveryFee
```

---

## Admin Routes
**Middleware:** `auth:api` + `admin`

---

## Admin - User Management

```php
Route::middleware('admin')->prefix('admin')->group(function () {
    Route::prefix('users')->group(function () {
        GET    /api/admin/users          → UserManagementController::getAllUsers
        DELETE /api/admin/users/{userId} → UserManagementController::deleteUserByAdmin
    });
});
```

---

## Admin - Charity Management

```php
Route::middleware('admin')->prefix('admin')->group(function () {
    Route::prefix('charity')->group(function () {
        POST   /api/admin/charity/create → AdminController::createCharity
    });
    
    GET    /api/admin/charities          → AdminController::getCharities
});
```

---

## Admin - Driver Management

```php
Route::middleware('admin')->prefix('admin')->group(function () {
    Route::prefix('driver-applications')->group(function () {
        GET    /api/admin/driver-applications
                                         → AdminDriverController::applications
        GET    /api/admin/driver-applications/stats
                                         → AdminDriverController::applicationStats
        GET    /api/admin/driver-applications/{id}
                                         → AdminDriverController::applicationDetails
        POST   /api/admin/driver-applications/{id}/approve
                                         → AdminDriverController::approveApplication
        POST   /api/admin/driver-applications/{id}/reject
                                         → AdminDriverController::rejectApplication
        POST   /api/admin/driver-applications/{id}/set-under-review
                                         → AdminDriverController::setUnderReview
    });
    
    Route::prefix('drivers')->group(function () {
        GET    /api/admin/drivers        → AdminDriverController::drivers
    });
});
```

---

## Admin - Delivery Stats

```php
Route::middleware('admin')->prefix('admin')->group(function () {
    Route::prefix('deliveries')->group(function () {
        GET    /api/admin/deliveries/stats → Closure (inline stats aggregation)
    });
});
```

**Returns:**
- Total deliveries count
- Pending deliveries
- Active deliveries (assigned + in_transit)
- Completed deliveries
- Failed deliveries
- Total revenue
- Driver earnings
- Platform revenue

---

## Admin - Donation Stats

```php
Route::middleware('admin')->prefix('admin')->group(function () {
    Route::prefix('donations')->group(function () {
        GET    /api/admin/donations/stats → Closure (uses DonationService)
    });
});
```

**Returns:**
- Platform donation statistics
- Category breakdown

---

## Health & Testing Routes

```php
// Health check (no auth required)
GET    /api/health                       → Closure (JSON health status)

// Google Maps API test (no auth required)
GET    /api/test-google-maps             → Closure (tests Google Maps integration)
```

---

## Route Grouping Summary

### By Middleware:

**Public (No Auth):**
- Auth registration & login (6 routes)
- Public item browsing (2 routes)
- Platform stats (1 route)
- Health check (2 routes)

**Protected (auth:api):**
- All authenticated user routes
- Profile management (3 routes)
- Logout & sessions (4 routes)
- Items CRUD (5 routes)
- Favorites (3 routes)
- Orders (6 routes)
- Addresses (4 routes)
- Driver applications (3 routes)
- Deliveries (6 routes)
- Notifications (7 routes)
- Maps (3 routes)

**Driver Only (auth:api + verified_driver):**
- Driver dashboard (5 routes)

**Charity Only (auth:api + role:charity):**
- Charity operations (7 routes)

**Admin Only (auth:api + admin):**
- User management (2 routes)
- Charity management (2 routes)
- Driver management (7 routes)
- Stats (2 routes)

---

## Controller Reference

```php
use App\Http\Controllers\Api\Auth\RegisterController;
use App\Http\Controllers\Api\Auth\LoginController;
use App\Http\Controllers\Api\Auth\TokenController;
use App\Http\Controllers\Api\Auth\ProfileController;
use App\Http\Controllers\Api\UserManagementController;
use App\Http\Controllers\Admin\AdminController;
use App\Http\Controllers\Api\ItemController;
use App\Http\Controllers\Api\FavoriteController;
use App\Http\Controllers\Api\OrderController;
use App\Http\Controllers\Api\AddressController;
use App\Http\Controllers\Api\DriverApplicationController;
use App\Http\Controllers\Api\DeliveryController;
use App\Http\Controllers\Api\DriverDashboardController;
use App\Http\Controllers\Api\CharityController;
use App\Http\Controllers\Api\NotificationController;
use App\Http\Controllers\Api\GoogleMapsController;
use App\Http\Controllers\Admin\AdminDriverController;
```

---

## Middleware Explanations

### `auth:api`
- JWT token required in header: `Authorization: Bearer <token>`
- Validates token via Lcobucci JWT library
- Loads authenticated user

### `verified_driver`
- User must have `is_driver = true`
- Driver application must be approved
- Used for driver-only routes

### `role:charity`
- User must have `role = 'charity'`
- Uses Spatie Permission package
- Restricts charity-specific operations

### `admin`
- User must have `role = 'admin'`
- Full platform access
- All admin routes require this

---

## Route Parameters

**ID Parameters:**
- `{id}` - Numeric only (via `whereNumber()` constraint on item routes)
- `{userId}` - User ID for admin operations
- `{itemId}` - Item ID for favorites
- `{orderId}` - Order ID for charity distribution

**Query Parameters:**
See individual endpoint documentation for supported query strings.

---

## Route Testing with cURL

### Public Route Example:
```bash
curl http://localhost:8000/api/items
```

### Protected Route Example:
```bash
curl http://localhost:8000/api/auth/me \
  -H "Authorization: Bearer YOUR_TOKEN"
```

### POST Route Example:
```bash
curl -X POST http://localhost:8000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"user@example.com","password":"Password123!"}'
```

---

## Laravel Artisan Commands

### List all routes:
```bash
php artisan route:list
```

### Filter API routes:
```bash
php artisan route:list --path=api
```

### Search specific route:
```bash
php artisan route:list --name=items
```

### Show route with middleware:
```bash
php artisan route:list --columns=method,uri,name,middleware
```

---

## Response Format

All routes follow standard JSON response format:

**Success Response:**
```json
{
  "success": true,
  "message": "Operation successful",
  "data": { ... },
  "meta": { ... }
}
```

**Error Response:**
```json
{
  "success": false,
  "message": "Error description",
  "errors": {
    "field": ["Validation error"]
  }
}
```

---

## HTTP Status Codes Used

- `200` - Success
- `201` - Created (POST requests)
- `400` - Bad Request
- `401` - Unauthorized (missing/invalid token)
- `403` - Forbidden (insufficient permissions)
- `404` - Not Found
- `422` - Validation Failed
- `429` - Too Many Requests (rate limited)
- `500` - Server Error

---

## Important Notes

1. **Base URL includes `/api` prefix** - All routes start with `/api`
2. **Route constraints** - Item IDs must be numeric (`whereNumber`)
3. **Middleware stacking** - Some routes have multiple middleware (e.g., `auth:api` + `admin`)
4. **Route caching** - Run `php artisan route:cache` in production
5. **CORS** - Configured for frontend domains

---

**Total Route Count:** 75+ endpoints

**File Location:** `routes/api.php`  
**Last Updated:** January 10, 2026  
**Status:** ✅ Production Ready
