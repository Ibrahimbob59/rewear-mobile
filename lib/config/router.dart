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
import '../screens/addresses/addresses_screen.dart';
import '../screens/addresses/add_address_screen.dart';
import '../screens/driver/driver_application_screen.dart';
import '../screens/driver/driver_dashboard_screen.dart';
import '../screens/driver/active_delivery_screen.dart';
import '../screens/driver/delivery_history_screen.dart';
import '../screens/delivery/order_tracking_screen.dart';
import '../screens/charity/charity_home_screen.dart';
import '../screens/charity/charity_donations_screen.dart';
import '../screens/charity/charity_claimed_screen.dart';
import '../screens/charity/charity_donate_screen.dart';
import '../services/storage_service.dart';

class AppRouter {
  static final StorageService _storageService = StorageService();
  
  static final GoRouter router = GoRouter(
    initialLocation: '/home',
    redirect: (BuildContext context, GoRouterState state) async {
      await _storageService.init();
      final bool isLoggedIn = await _storageService.hasAccessToken();
      final String location = state.matchedLocation;

      // Routes that absolutely need authentication
      final bool needsAuth = location == '/create-item' ||
                             location == '/orders' ||
                             location.startsWith('/orders/') ||
                             location.startsWith('/profile/edit') ||
                             location == '/profile/change-password' ||
                             location == '/selling' ||
                             location.startsWith('/driver') ||
                             location.startsWith('/charity');

      if (!isLoggedIn && needsAuth) {
        return '/login';
      }

      if (isLoggedIn && (location == '/login' || location == '/register')) {
        return '/home';
      }

      return null;
    },
    routes: [
      GoRoute(path: '/login', name: 'login', builder: (context, state) => const LoginScreen()),
      GoRoute(path: '/register', name: 'register', builder: (context, state) => const RegisterScreen()),
      GoRoute(
        path: '/otp-verification',
        name: 'otp-verification',
        builder: (context, state) {
          final email = state.uri.queryParameters['email'] ?? '';
          return OTPVerificationScreen(email: email);
        },
      ),
      GoRoute(path: '/home', name: 'home', builder: (context, state) => const HomeScreen()),
      GoRoute(path: '/', redirect: (context, state) => '/home'),
      GoRoute(path: '/profile', name: 'profile', builder: (context, state) => const ProfileScreen()),
      GoRoute(path: '/profile/edit', builder: (context, state) => const ProfileEditScreen()),
      GoRoute(path: '/profile/change-password', builder: (context, state) => const ChangePasswordScreen()),
      GoRoute(path: '/profile/deactivate', builder: (context, state) => const DeactivateAccountScreen()),
      GoRoute(path: '/addresses', name: 'addresses', builder: (context, state) => const AddressesScreen()),
      GoRoute(path: '/add-address', name: 'add-address', builder: (context, state) => const AddAddressScreen()),
      GoRoute(
        path: '/item/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return ItemDetailScreen(itemId: id);
        },
      ),
      GoRoute(path: '/create-item', builder: (context, state) => const CreateItemScreen()),
      GoRoute(path: '/search', builder: (context, state) => const SearchScreen()),
      GoRoute(path: '/selling', builder: (context, state) => const SellingScreen()),
      GoRoute(path: '/cart', builder: (context, state) => const CartScreen()),
      GoRoute(path: '/checkout', builder: (context, state) => const CheckoutScreen()),
      GoRoute(path: '/orders', builder: (context, state) => const OrdersScreen()),
      GoRoute(
        path: '/orders/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return OrderDetailScreen(orderId: id);
        },
      ),
      GoRoute(path: '/favorites', builder: (context, state) => const FavoritesScreen()),
      GoRoute(path: '/driver-application', builder: (context, state) => const DriverApplicationScreen()),
      GoRoute(path: '/driver/dashboard', builder: (context, state) => const DriverDashboardScreen()),
      GoRoute(
        path: '/driver/delivery/:deliveryId',
        builder: (context, state) {
          final deliveryId = state.pathParameters['deliveryId']!;
          return ActiveDeliveryScreen(deliveryId: deliveryId);
        },
      ),
      GoRoute(path: '/driver/history', builder: (context, state) => const DeliveryHistoryScreen()),
      GoRoute(
        path: '/track-order/:orderId',
        builder: (context, state) {
          final orderId = state.pathParameters['orderId']!;
          return OrderTrackingScreen(orderId: orderId);
        },
      ),
      GoRoute(path: '/charity/home', builder: (context, state) => const CharityHomeScreen()),
      GoRoute(path: '/charity/donations', builder: (context, state) => const CharityDonationsScreen()),
      GoRoute(path: '/charity/claimed', builder: (context, state) => const CharityClaimedScreen()),
      GoRoute(path: '/charity/donate', builder: (context, state) => const CharityDonateScreen()),
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
              onPressed: () => context.go('/home'),
              child: const Text('Go Home'),
            ),
          ],
        ),
      ),
    ),
  );
}