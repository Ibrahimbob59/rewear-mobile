# ReWear - Sustainable Fashion Marketplace

## Overview
ReWear is a Flutter-based sustainable fashion marketplace mobile app built for web deployment. Users can buy, sell, and donate secondhand clothing items, with features including driver deliveries and charity donations.

## Project Architecture

### Tech Stack
- **Framework**: Flutter 3.32.0
- **Language**: Dart 3.8.0
- **State Management**: Provider
- **Navigation**: go_router
- **HTTP Client**: Dio
- **Storage**: SharedPreferences, FlutterSecureStorage

### Directory Structure
```
lib/
├── config/          # App configuration (theme, router, API config)
├── models/          # Data models (User, Item, Order, etc.)
├── providers/       # State management providers
├── screens/         # UI screens organized by feature
│   ├── auth/        # Login, Register, OTP verification
│   ├── cart/        # Shopping cart and checkout
│   ├── charity/     # Charity donation features
│   ├── delivery/    # Order tracking
│   ├── driver/      # Driver dashboard and deliveries
│   ├── favorites/   # Saved items
│   ├── home/        # Main home screen
│   ├── items/       # Item listing and details
│   ├── orders/      # Order management
│   ├── profile/     # User profile
│   └── search/      # Search functionality
├── services/        # API and business logic services
├── utils/           # Helper utilities
├── widgets/         # Reusable UI components
└── main.dart        # App entry point
```

### Build Configuration
- **Web Build**: Located in `build/web/`
- **Server**: Python HTTP server serving static files on port 5000

## Running the App

### Development
The app runs using a pre-built Flutter web release served via Python HTTP server:
```bash
python -m http.server 5000 --bind 0.0.0.0 --directory build/web
```

### Rebuilding
To rebuild the Flutter web app:
```bash
flutter pub get
flutter build web --release
```

## Backend Requirements
The app expects a backend API at `http://localhost:8000/api`. The backend is not included in this project. To use the app fully, you'll need to configure the API endpoint in `lib/main.dart`.

## Recent Changes
- January 11, 2026: API & UI Overhaul for Android
  - Fixed all API endpoint mismatches with Laravel backend (driver, charity, orders services)
  - Updated base URL to 10.0.2.2:8000 for Android emulator compatibility
  - Implemented bottom navigation bar using ShellRoute pattern (Home, Cart, Orders, Profile)
  - Redesigned Profile screen with live statistics connected to real provider data
  - Updated theme with #2A9D8F primary color and #21867A dark variant
  - Fixed ShellRoute index calculation for nested routes and deep links
  
- January 11, 2026: Initial Replit environment setup
  - Installed Flutter via Nix
  - Built Flutter web release
  - Configured Python HTTP server for serving
  - Added cache-busting and service worker cleanup to index.html

## User Preferences
- None documented yet

## Key Features
- User authentication (login/register)
- Item browsing by category (Tops, Bottoms, Dresses, Outerwear, Shoes, Accessories)
- Shopping cart and checkout
- Order tracking with driver delivery
- Charity donation system
- User profiles and addresses
