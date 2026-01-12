import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// Config
import 'config/theme.dart';
import 'config/router.dart';

// Services
import 'services/items_service.dart';
import 'services/orders_service.dart';
import 'services/addresses_service.dart';
import 'services/favorites_service.dart';
import 'services/driver_service.dart';
import 'services/delivery_service.dart';
import 'services/charity_service.dart';
import 'services/location_service.dart';
import 'services/storage_service.dart';

// Providers
import 'providers/auth_provider.dart';
import 'providers/items_provider.dart';
import 'providers/cart_provider.dart';
import 'providers/favorites_provider.dart';
import 'providers/orders_provider.dart';
import 'providers/addresses_provider.dart';
import 'providers/driver_provider.dart';
import 'providers/delivery_provider.dart';
import 'providers/charity_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Secure storage (for access_token / refresh_token)
  const storage = FlutterSecureStorage();

  // Dio base options
  final dio = Dio(
    BaseOptions(
      baseUrl: 'http://127.0.0.1:8000/api', // Android emulator
      // iOS simulator: 'http://localhost:8000/api'
      // Physical device: 'http://YOUR_IP:8000/api'
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
    ),
  );

  // Initialize storage service
  await StorageService().init();

  // ============================
  // AUTH + REFRESH INTERCEPTOR
  // ============================
  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await storage.read(key: 'access_token');
        if (token != null && token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
        }

        // Optional debug logs
        // ignore: avoid_print
        print('📤 ${options.method} ${options.uri}');
        return handler.next(options);
      },
      onResponse: (response, handler) {
        // ignore: avoid_print
        print('📥 ${response.statusCode} ${response.requestOptions.uri}');
        return handler.next(response);
      },
      onError: (error, handler) async {
        // ignore: avoid_print
        print('❌ ${error.response?.statusCode} ${error.requestOptions.uri}');

        // Only handle 401 once per request (avoid infinite loop)
        final is401 = error.response?.statusCode == 401;
        final alreadyRetried = error.requestOptions.extra['retried'] == true;

        if (is401 && !alreadyRetried) {
          final refreshToken = await storage.read(key: 'refresh_token');

          if (refreshToken != null && refreshToken.isNotEmpty) {
            try {
              // ignore: avoid_print
              print('🔄 Refreshing access token...');

              final refreshDio = Dio(
                BaseOptions(
                    baseUrl: 'http://127.0.0.1:8000/api',
                  connectTimeout: const Duration(seconds: 30),
                  receiveTimeout: const Duration(seconds: 30),
                ),
              );

              final refreshResponse = await refreshDio.post(
                '/auth/refresh-token',
                data: {'refresh_token': refreshToken},
              );

              if (refreshResponse.data['success'] == true) {
                final newToken =
                    refreshResponse.data['data']['tokens']['access_token'];

                await storage.write(key: 'access_token', value: newToken);

                // Mark request as retried
                final requestOptions = error.requestOptions;
                requestOptions.extra['retried'] = true;

                // Update header and retry
                requestOptions.headers['Authorization'] = 'Bearer $newToken';
                final retryResponse = await dio.fetch(requestOptions);
                return handler.resolve(retryResponse);
              }
            } catch (e) {
              // ignore: avoid_print
              print('❌ Token refresh failed: $e');
              await storage.deleteAll();
              // TODO: navigate to login (depends on your app structure)
            }
          } else {
            // No refresh token -> logout
            await storage.deleteAll();
            // TODO: navigate to login
          }
        }

        return handler.next(error);
      },
    ),
  );
  // ============================
  // END INTERCEPTOR
  // ============================

  // Initialize all services
  final itemsService = ItemsService(dio);
  final ordersService = OrdersService(dio);
  final addressesService = AddressesService(dio);
  final favoritesService = FavoritesService(dio);
  final driverService = DriverService(dio);
  final deliveryService = DeliveryService(dio);
  final charityService = CharityService(dio);
  final locationService = LocationService();

  // Create AuthProvider instance and initialize
  final authProvider = AuthProvider();
  await authProvider.initialize();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: authProvider),
        ChangeNotifierProvider(create: (_) => ItemsProvider(itemsService)),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => FavoritesProvider(favoritesService)),
        ChangeNotifierProvider(create: (_) => OrdersProvider(ordersService)),
        ChangeNotifierProvider(create: (_) => AddressesProvider(addressesService)),
        ChangeNotifierProvider(create: (_) => DriverProvider(driverService)),

        // Keep your old signature exactly:
        ChangeNotifierProvider(
          create: (_) => DeliveryProvider(deliveryService, locationService),
        ),

        ChangeNotifierProvider(create: (_) => CharityProvider(charityService)),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'ReWear',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      routerConfig: AppRouter.router,
    );
  }
}
