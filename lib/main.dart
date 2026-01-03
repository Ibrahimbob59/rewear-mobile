import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dio/dio.dart';

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
  
  // Initialize Dio
  final dio = Dio(BaseOptions(
    baseUrl: 'http://localhost:8000/api', // ⬅️ CHANGE TO YOUR BACKEND URL
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(seconds: 30),
  ));

  // Initialize all services
  final itemsService = ItemsService(dio);
  final ordersService = OrdersService(dio);
  final addressesService = AddressesService(dio);
  final favoritesService = FavoritesService(dio);
  final driverService = DriverService(dio);
  final deliveryService = DeliveryService(dio);
  final charityService = CharityService(dio);
  final locationService = LocationService();

  runApp(
    MultiProvider(
      providers: [
        // Week 1-2: Auth Provider
        ChangeNotifierProvider(
          create: (_) => AuthProvider(),
        ),
        
        // Week 3: Items Provider
        ChangeNotifierProvider(
          create: (_) => ItemsProvider(itemsService),
        ),
        
        // Week 3: Cart Provider
        ChangeNotifierProvider(
          create: (_) => CartProvider(),
        ),
        
        // Week 3: Favorites Provider
        ChangeNotifierProvider(
          create: (_) => FavoritesProvider(favoritesService),
        ),
        
        // Week 3: Orders Provider
        ChangeNotifierProvider(
          create: (_) => OrdersProvider(ordersService),
        ),
        
        // Week 3: Addresses Provider
        ChangeNotifierProvider(
          create: (_) => AddressesProvider(addressesService),
        ),
        
        // Week 4: Driver Provider ⬅️ NEW
        ChangeNotifierProvider(
          create: (_) => DriverProvider(driverService),
        ),
        
        // Week 4: Delivery Provider ⬅️ NEW
        ChangeNotifierProvider(
          create: (_) => DeliveryProvider(deliveryService, locationService),
        ),
        
        // Week 4: Charity Provider ⬅️ NEW
        ChangeNotifierProvider(
          create: (_) => CharityProvider(charityService),
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