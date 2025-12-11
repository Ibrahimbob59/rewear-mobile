import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// Config
import 'config/theme.dart';
import 'config/router.dart';

// Services
import 'services/api_service.dart';
import 'services/storage_service.dart';
import 'services/items_service.dart';
import 'services/orders_service.dart';
import 'services/addresses_service.dart';
import 'services/favorites_service.dart';
import 'services/image_upload_service.dart';

// Providers
import 'providers/auth_provider.dart';
import 'providers/items_provider.dart';
import 'providers/cart_provider.dart';
import 'providers/favorites_provider.dart';
import 'providers/orders_provider.dart';
import 'providers/addresses_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize services
  final storage = const FlutterSecureStorage();
  final dio = Dio(BaseOptions(
    baseUrl: 'http://localhost:8000/api', // Change this to your backend URL
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(seconds: 30),
  ));

  // Initialize all services
  final storageService = StorageService();
  final apiService = ApiService();
  
  // Initialize feature services
  final itemsService = ItemsService(dio);
  final ordersService = OrdersService(dio);
  final addressesService = AddressesService(dio);
  final favoritesService = FavoritesService(dio);
  final imageUploadService = ImageUploadService();

  runApp(
    MultiProvider(
      providers: [
        // Auth Provider (from Week 1-2)
        ChangeNotifierProvider(
          create: (_) => AuthProvider(),
        ),
        
        // Items Provider
        ChangeNotifierProvider(
          create: (_) => ItemsProvider(itemsService),
        ),
        
        // Cart Provider (client-side, no service needed)
        ChangeNotifierProvider(
          create: (_) => CartProvider(),
        ),
        
        // Favorites Provider
        ChangeNotifierProvider(
          create: (_) => FavoritesProvider(favoritesService),
        ),
        
        // Orders Provider
        ChangeNotifierProvider(
          create: (_) => OrdersProvider(ordersService),
        ),
        
        // Addresses Provider
        ChangeNotifierProvider(
          create: (_) => AddressesProvider(addressesService),
        ),
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