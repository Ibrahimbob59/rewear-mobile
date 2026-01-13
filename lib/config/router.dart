import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/auth/otp_verification_screen.dart';
import '../screens/main/main_scaffold.dart';
import '../screens/home/home_screen.dart';
import '../screens/cart/cart_screen.dart';
import '../screens/orders/orders_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/items/item_detail_screen.dart';
import '../screens/items/create_item_screen.dart';
import '../screens/cart/checkout_screen.dart';
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
import '../screens/driver/available_deliveries_screen.dart';
import '../screens/driver/driver_earnings_screen.dart';
import '../screens/delivery/order_tracking_screen.dart';
import '../screens/charity/charity_home_screen.dart';
import '../screens/charity/charity_donations_screen.dart';
import '../screens/charity/charity_claimed_screen.dart';
import '../screens/charity/charity_donate_screen.dart';
import '../screens/charity/charity_dashboard_screen.dart';
import '../screens/charity/pending_donations_screen.dart';
import '../screens/charity/impact_stats_screen.dart';

import '../services/storage_service.dart';
import '../providers/auth_provider.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<NavigatorState> _shellNavigatorKey = GlobalKey<NavigatorState>();

class AppRouter {
  static final StorageService _storageService = StorageService();

  static int _getIndexFromLocation(String location) {
    if (location.startsWith('/selling')) return 1;
    if (location.startsWith('/orders')) return 2;
    if (location.startsWith('/profile')) return 3;
    return 0;
  }

  static bool _isAuthPage(String location) {
    return location == '/login' ||
        location == '/register' ||
        location.startsWith('/otp');
  }

  static bool _needsAuth(String location) {
    // Public routes (no auth required)
    if (location == '/login' ||
        location == '/register' ||
        location.startsWith('/otp') ||
        location == '/item') {
      return false;
    }

    // All other routes require authentication
    return true;
  }

  static final GoRouter router = GoRouter(
    navigatorKey: _rootNavigatorKey,

    initialLocation: '/',

    redirect: (BuildContext context, GoRouterState state) async {
      await _storageService.init();

      final String location = state.matchedLocation;

      // Login state (source of truth: tokens in storage)
      final bool isLoggedIn = await _storageService.hasAccessToken();

      // Try to read AuthProvider user (may be null early)
      AuthProvider? authProvider;
      try {
        authProvider = context.read<AuthProvider>();
      } catch (_) {
        authProvider = null;
      }

      final user = authProvider?.user;

      // 1) If not logged in and trying to access protected route -> go login
      if (!isLoggedIn && _needsAuth(location)) {
        return '/login';
      }

      // 2) If logged in and on login/register/otp -> redirect based on role
      if (isLoggedIn && _isAuthPage(location)) {
        // Charity users -> charity home (your real route)
        if (user?.role == 'charity') {
          return '/charity/home';
        }

        // Verified drivers -> driver dashboard
        if (user?.isDriver == true && user?.driverVerified == true) {
          return '/driver/dashboard';
        }

        // Regular users -> home (your real route is '/')
        return '/';
      }

      return null;
    },

    routes: [
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) {
          final index = _getIndexFromLocation(state.matchedLocation);
          return MainScaffold(
            currentIndex: index,
            child: child,
          );
        },
        routes: [
          GoRoute(
            path: '/',
            name: 'home',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: HomeScreen(),
            ),
          ),
          GoRoute(
            path: '/cart',
            name: 'cart',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: CartScreen(),
            ),
          ),
          GoRoute(
            path: '/orders',
            name: 'orders',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: OrdersScreen(),
            ),
          ),
          GoRoute(
            path: '/profile',
            name: 'profile',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: ProfileScreen(),
            ),
          ),
          GoRoute(
            path: '/selling',
            name: 'selling',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: SellingScreen(),
            ),
          ),
        ],
      ),

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
      GoRoute(path: '/checkout', builder: (context, state) => const CheckoutScreen()),

      GoRoute(
        path: '/orders/:id',
        builder: (context, state) {
          final orderId = int.parse(state.pathParameters['id'] ?? '0');
          return OrderDetailScreen(orderId: orderId);
        },
      ),

      GoRoute(path: '/favorites', builder: (context, state) => const FavoritesScreen()),

      // ========== DRIVER ROUTES ==========
      GoRoute(path: '/driver-application', builder: (context, state) => const DriverApplicationScreen()),
      GoRoute(path: '/driver/dashboard', builder: (context, state) => const DriverDashboardScreen()),
      
      // ✅ NEW: Available deliveries route
      GoRoute(path: '/driver/available-deliveries', builder: (context, state) => const AvailableDeliveriesScreen()),
      
      // ✅ NEW: Driver earnings route
      GoRoute(path: '/driver/earnings', builder: (context, state) => const DriverEarningsScreen()),

      GoRoute(
        path: '/driver/delivery/:deliveryId',
        builder: (context, state) {
          final deliveryId = int.parse(state.pathParameters['deliveryId'] ?? '0');
          return ActiveDeliveryScreen(deliveryId: deliveryId);
        },
      ),

      GoRoute(path: '/driver/history', builder: (context, state) => const DeliveryHistoryScreen()),

      GoRoute(
        path: '/track-order/:orderId',
        builder: (context, state) {
          final orderId = int.parse(state.pathParameters['orderId'] ?? '0');
          return OrderTrackingScreen(orderId: orderId);
        },
      ),

      // ========== CHARITY ROUTES ==========
      GoRoute(path: '/charity/home', builder: (context, state) => const CharityHomeScreen()),
      
      // ✅ NEW: Charity dashboard route (different from home)
      GoRoute(path: '/charity/dashboard', builder: (context, state) => const CharityDashboardScreen()),
      
      GoRoute(path: '/charity/donations', builder: (context, state) => const CharityDonationsScreen()),
      GoRoute(path: '/charity/claimed', builder: (context, state) => const CharityClaimedScreen()),
      GoRoute(path: '/charity/donate', builder: (context, state) => const CharityDonateScreen()),
      
      // ✅ NEW: Pending donations route
      GoRoute(path: '/charity/pending-donations', builder: (context, state) => const PendingDonationsScreen()),
      
      // ✅ NEW: Impact stats route
      GoRoute(path: '/charity/impact-stats', builder: (context, state) => const ImpactStatsScreen()),
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
              onPressed: () => context.go('/'),
              child: const Text('Go Home'),
            ),
          ],
        ),
      ),
    ),
  );
}