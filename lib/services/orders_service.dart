import 'package:dio/dio.dart';
import '../models/order_model.dart';

class OrdersService {
  final Dio _dio;

  OrdersService(this._dio);

  // Create new order
  Future<Order> createOrder({
    required int itemId,
    required int deliveryAddressId,
    required double deliveryFee,
  }) async {
    try {
      final response = await _dio.post('/orders', data: {
        'item_id': itemId,
        'delivery_address_id': deliveryAddressId,
        'delivery_fee': deliveryFee,
      });

      return Order.fromJson(response.data['data'] as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Failed to create order: $e');
    }
  }

  // Get buyer's orders (orders where I'm buying)
  Future<List<Order>> getBuyerOrders() async {
    try {
      final response = await _dio.get('/orders');
      final List<dynamic> data = response.data['data'] as List<dynamic>;
      return data.map((json) => Order.fromJson(json as Map<String, dynamic>)).toList();
    } catch (e) {
      throw Exception('Failed to fetch buyer orders: $e');
    }
  }

  // Get seller's orders (orders where I'm selling)
  Future<List<Order>> getSellerOrders() async {
    try {
      final response = await _dio.get('/orders/as-seller');
      final List<dynamic> data = response.data['data'] as List<dynamic>;
      return data.map((json) => Order.fromJson(json as Map<String, dynamic>)).toList();
    } catch (e) {
      throw Exception('Failed to fetch seller orders: $e');
    }
  }

  // Get single order details
  Future<Order> getOrder(int id) async {
    try {
      final response = await _dio.get('/orders/$id');
      return Order.fromJson(response.data['data'] as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Failed to fetch order: $e');
    }
  }

  // Cancel order
  Future<Order> cancelOrder(int id, {String? reason}) async {
    try {
      final response = await _dio.put(
        '/orders/$id/cancel',
        data: reason != null ? {'reason': reason} : null,
      );

      return Order.fromJson(response.data['data'] as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Failed to cancel order: $e');
    }
  }
}