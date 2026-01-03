import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/auth/otp_verification_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/items/item_detail_screen.dart';
import '../screens/items/create_item_screen.dart';
import '../screens/cart/cart_screen.dart';
import '../screens/cart/checkout_screen.dart';
import '../screens/orders/orders_screen.dart';
import '../screens/orders/order_detail_screen.dart';
import '../screens/favorites/favorites_screen.dart';
import '../screens/search/search_screen.dart';
import '../screens/selling/selling_screen.dart';
import '../screens/profile/profile_edit_screen.dart';
import '../screens/profile/change_password_screen.dart';
import '../screens/profile/deactivate_account_screen.dart';
import '../screens/driver/driver_application_screen.dart';
import '../screens/driver/driver_dashboard_screen.dart';
import '../screens/charity/charity_home_screen.dart';
import '../screens/charity/charity_donations_screen.dart';
import '../screens/charity/charity_claimed_screen.dart';
import '../screens/charity/charity_donate_screen.dart';
import '../services/storage_service.dart';

class AppRouter {
  static final StorageService _storageService = StorageService();
  
  static final GoRouter router = GoRouter(
    initialLocation: '/login',
    redirect: (BuildContext context, GoRouterState state) async {
      await _storageService.init();

      final bool isLoggedIn = await _storageService.hasAccessToken();
      final String location = state.matchedLocation;

      // Public routes
      final bool isPublicRoute = location == '/login' ||
                                 location == '/register' ||
                                 location == '/driver-application' ||
                                 location.startsWith('/otp-verification');

      // If not logged in and trying to access protected route
      if (!isLoggedIn && !isPublicRoute) {
        return '/login';
      }

      // If logged in and trying to access auth screens
      if (isLoggedIn && (location == '/login' || location == '/register')) {
        return '/home';
      }

      return null;
    },
    routes: [
      // Auth Routes
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        name: 'register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/otp-verification',
        name: 'otp-verification',
        builder: (context, state) {
          final email = state.uri.queryParameters['email'] ?? '';
          return OTPVerificationScreen(email: email);
        },
      ),

      // Main Routes
      GoRoute(
        path: '/home',
        name: 'home',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/',
        redirect: (context, state) => '/home',
      ),

      // Profile Routes
      GoRoute(
        path: '/profile',
        name: 'profile',
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: '/profile/edit',
        builder: (context, state) => const ProfileEditScreen(),
      ),
      GoRoute(
        path: '/profile/change-password',
        builder: (context, state) => const ChangePasswordScreen(),
      ),
      GoRoute(
        path: '/profile/deactivate',
        builder: (context, state) => const DeactivateAccountScreen(),
      ),

      // Item Routes
      GoRoute(
        path: '/item/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return ItemDetailScreen(itemId: id);
        },
      ),
      GoRoute(
        path: '/create-item',
        builder: (context, state) => const CreateItemScreen(),
      ),

      // Search & Selling
      GoRoute(
        path: '/search',
        builder: (context, state) => const SearchScreen(),
      ),
      GoRoute(
        path: '/selling',
        builder: (context, state) => const SellingScreen(),
      ),

      // Cart & Checkout
      GoRoute(
        path: '/cart',
        builder: (context, state) => const CartScreen(),
      ),
      GoRoute(
        path: '/checkout',
        builder: (context, state) => const CheckoutScreen(),
      ),

      // Orders
      GoRoute(
        path: '/orders',
        builder: (context, state) => const OrdersScreen(),
      ),
      GoRoute(
        path: '/orders/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return OrderDetailScreen(orderId: id);
        },
      ),

      // Favorites
      GoRoute(
        path: '/favorites',
        builder: (context, state) => const FavoritesScreen(),
      ),

      // Driver Routes
      GoRoute(
        path: '/driver-application',
        builder: (context, state) => const DriverApplicationScreen(),
      ),
      GoRoute(
        path: '/driver/dashboard',
        builder: (context, state) => const DriverDashboardScreen(),
      ),

      // Charity Routes
      GoRoute(
        path: '/charity/home',
        builder: (context, state) => const CharityHomeScreen(),
      ),
      GoRoute(
        path: '/charity/donations',
        builder: (context, state) => const CharityDonationsScreen(),
      ),
      GoRoute(
        path: '/charity/claimed',
        builder: (context, state) => const CharityClaimedScreen(),
      ),
      GoRoute(
        path: '/charity/donate',
        builder: (context, state) => const CharityDonateScreen(),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text('Page not found: ${state.matchedLocation}'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.go('/login'),
              child: const Text('Go to Login'),
            ),
          ],
        ),
      ),
    ),
  );
}