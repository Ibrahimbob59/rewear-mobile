import 'package:dio/dio.dart';

class OrdersService {
  final Dio dio;

  OrdersService(this.dio);

  // Create new order - CORRECTED ENDPOINT
  Future<Map<String, dynamic>> createOrder({
    required int itemId,
    required int deliveryAddressId,
    String paymentMethod = 'cod',
  }) async {
    try {
      final response = await dio.post('/orders', data: {
        'item_id': itemId,
        'delivery_address_id': deliveryAddressId,
        'payment_method': paymentMethod,
      });
      
      if (response.data['success'] != true) {
        throw Exception(response.data['message'] ?? 'Failed to create order');
      }
      
      return response.data['data'];
    } catch (e) {
      throw Exception('Failed to create order: $e');
    }
  }

  // Get all orders for current user
  Future<List<Map<String, dynamic>>> getOrders({String? type}) async {
    try {
      final queryParams = type != null ? {'type': type} : null;
      final response = await dio.get('/orders', queryParameters: queryParams);
      
      if (response.data['success'] != true) {
        throw Exception(response.data['message'] ?? 'Failed to load orders');
      }
      
      final data = response.data['data'];
      return List<Map<String, dynamic>>.from(data['orders'] ?? []);
    } catch (e) {
      throw Exception('Failed to load orders: $e');
    }
  }

  // Get single order details
  Future<Map<String, dynamic>> getOrder(int orderId) async {
    try {
      final response = await dio.get('/orders/$orderId');
      
      if (response.data['success'] != true) {
        throw Exception(response.data['message'] ?? 'Failed to load order');
      }
      
      return response.data['data'];
    } catch (e) {
      throw Exception('Failed to load order: $e');
    }
  }

  // Cancel order
  Future<void> cancelOrder(int orderId, String reason) async {
    try {
      final response = await dio.post('/orders/$orderId/cancel', data: {
        'cancellation_reason': reason,
      });
      
      if (response.data['success'] != true) {
        throw Exception(response.data['message'] ?? 'Failed to cancel order');
      }
    } catch (e) {
      throw Exception('Failed to cancel order: $e');
    }
  }

  // Confirm order (admin or system)
  Future<void> confirmOrder(int orderId) async {
    try {
      final response = await dio.post('/orders/$orderId/confirm');
      
      if (response.data['success'] != true) {
        throw Exception(response.data['message'] ?? 'Failed to confirm order');
      }
    } catch (e) {
      throw Exception('Failed to confirm order: $e');
    }
  }

  // Get order statistics
  Future<Map<String, dynamic>> getOrderStats() async {
    try {
      final response = await dio.get('/orders/stats');
      
      if (response.data['success'] != true) {
        throw Exception(response.data['message'] ?? 'Failed to load stats');
      }
      
      return response.data['data'];
    } catch (e) {
      throw Exception('Failed to load order stats: $e');
    }
  }
  // Get buyer orders (orders I placed)
  Future<List<Map<String, dynamic>>> getBuyerOrders() async {
    try {
      final response = await dio.get('/orders', queryParameters: {
        'type': 'buyer'
      });
      
      if (response.data['success'] != true) {
        throw Exception(response.data['message'] ?? 'Failed to load orders');
      }
      
      final data = response.data['data'];
      return List<Map<String, dynamic>>.from(data['orders'] ?? []);
    } catch (e) {
      throw Exception('Failed to load buyer orders: $e');
    }
  }

  // Get seller orders (items I sold)
  Future<List<Map<String, dynamic>>> getSellerOrders() async {
    try {
      final response = await dio.get('/orders', queryParameters: {
        'type': 'seller'
      });
      
      if (response.data['success'] != true) {
        throw Exception(response.data['message'] ?? 'Failed to load orders');
      }
      
      final data = response.data['data'];
      return List<Map<String, dynamic>>.from(data['orders'] ?? []);
    } catch (e) {
      throw Exception('Failed to load seller orders: $e');
    }
  }
}