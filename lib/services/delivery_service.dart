import 'dart:io';
import 'package:dio/dio.dart';
import '../models/delivery_model.dart';

class DeliveryService {
  final Dio _dio;

  DeliveryService(this._dio);

  // Get available deliveries for driver
  Future<List<Delivery>> getAvailableDeliveries() async {
    try {
      final response = await _dio.get('/deliveries/available');
      final List<dynamic> data = response.data['data'];
      return data.map((json) => Delivery.fromJson(json)).toList();
    } catch (e) {
      print('Error getting available deliveries: $e');
      rethrow;
    }
  }

  // Get driver's active deliveries
  Future<List<Delivery>> getActiveDeliveries() async {
    try {
      final response = await _dio.get('/deliveries/active');
      final List<dynamic> data = response.data['data'];
      return data.map((json) => Delivery.fromJson(json)).toList();
    } catch (e) {
      print('Error getting active deliveries: $e');
      rethrow;
    }
  }

  // Get delivery history
  Future<List<Delivery>> getDeliveryHistory({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final response = await _dio.get('/deliveries/history', queryParameters: {
        'page': page,
        'limit': limit,
      });
      final List<dynamic> data = response.data['data'];
      return data.map((json) => Delivery.fromJson(json)).toList();
    } catch (e) {
      print('Error getting delivery history: $e');
      rethrow;
    }
  }

  // Accept delivery
  Future<Delivery> acceptDelivery(int deliveryId) async {
    try {
      final response = await _dio.post('/deliveries/$deliveryId/accept');
      return Delivery.fromJson(response.data['data']);
    } catch (e) {
      print('Error accepting delivery: $e');
      rethrow;
    }
  }

  // Confirm pickup
  Future<Delivery> confirmPickup({
    required int deliveryId,
    required File proofImage,
    String? notes,
  }) async {
    try {
      final formData = FormData.fromMap({
        'proof_image': await MultipartFile.fromFile(
          proofImage.path,
          filename: 'pickup_${DateTime.now().millisecondsSinceEpoch}.jpg',
        ),
        if (notes != null) 'notes': notes,
      });

      final response = await _dio.post(
        '/deliveries/$deliveryId/pickup',
        data: formData,
      );
      return Delivery.fromJson(response.data['data']);
    } catch (e) {
      print('Error confirming pickup: $e');
      rethrow;
    }
  }

  // Confirm delivery
  Future<Delivery> confirmDelivery({
    required int deliveryId,
    required File proofImage,
    double? codCollected,
    String? notes,
  }) async {
    try {
      final formData = FormData.fromMap({
        'proof_image': await MultipartFile.fromFile(
          proofImage.path,
          filename: 'delivery_${DateTime.now().millisecondsSinceEpoch}.jpg',
        ),
        if (codCollected != null) 'cod_collected': codCollected,
        if (notes != null) 'notes': notes,
      });

      final response = await _dio.post(
        '/deliveries/$deliveryId/deliver',
        data: formData,
      );
      return Delivery.fromJson(response.data['data']);
    } catch (e) {
      print('Error confirming delivery: $e');
      rethrow;
    }
  }

  // Update location
  Future<void> updateLocation({
    required int deliveryId,
    required double latitude,
    required double longitude,
  }) async {
    try {
      await _dio.post('/deliveries/$deliveryId/location', data: {
        'latitude': latitude,
        'longitude': longitude,
      });
    } catch (e) {
      print('Error updating location: $e');
      rethrow;
    }
  }

  // Get delivery by ID
  Future<Delivery> getDelivery(int deliveryId) async {
    try {
      final response = await _dio.get('/deliveries/$deliveryId');
      return Delivery.fromJson(response.data['data']);
    } catch (e) {
      print('Error getting delivery: $e');
      rethrow;
    }
  }

  // Track delivery (for buyers/sellers)
  Future<Delivery> trackDelivery(int orderId) async {
    try {
      final response = await _dio.get('/orders/$orderId/delivery');
      return Delivery.fromJson(response.data['data']);
    } catch (e) {
      print('Error tracking delivery: $e');
      rethrow;
    }
  }
}