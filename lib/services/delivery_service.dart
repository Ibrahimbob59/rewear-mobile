import 'dart:io';
import 'package:dio/dio.dart';
import '../models/delivery_model.dart';
import 'storage_service.dart';

class DeliveryService {
  final Dio _dio;
  final StorageService _storageService = StorageService();

  DeliveryService(this._dio);

  Future<Map<String, String>> _getHeaders() async {
    final token = await _storageService.getAccessToken();
    return {
      'Authorization': 'Bearer $token',
      'Accept': 'application/json',
    };
  }

  // Get available deliveries for driver
  Future<List<Delivery>> getAvailableDeliveries() async {
    try {
      final response = await _dio.get(
        '/driver/available-deliveries',
        options: Options(headers: await _getHeaders()),
      );
      
      final data = response.data['data'];
      if (data is List) {
        return data.map((json) => Delivery.fromJson(json as Map<String, dynamic>)).toList();
      }
      return [];
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to load available deliveries');
    }
  }

  // Get driver's active deliveries
  Future<List<Delivery>> getActiveDeliveries() async {
    try {
      final response = await _dio.get(
        '/driver/deliveries',
        queryParameters: {'status': 'assigned,in_transit'},
        options: Options(headers: await _getHeaders()),
      );
      
      final data = response.data['data'];
      if (data is List) {
        return data.map((json) => Delivery.fromJson(json as Map<String, dynamic>)).toList();
      }
      return [];
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to load active deliveries');
    }
  }

  // Get delivery history
  Future<List<Delivery>> getDeliveryHistory({int page = 1}) async {
    try {
      final response = await _dio.get(
        '/driver/deliveries',
        queryParameters: {
          'page': page,
          'per_page': 20,
        },
        options: Options(headers: await _getHeaders()),
      );
      
      final data = response.data['data'];
      if (data is List) {
        return data.map((json) => Delivery.fromJson(json as Map<String, dynamic>)).toList();
      }
      return [];
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to load delivery history');
    }
  }

  // Get single delivery
  Future<Delivery> getDelivery(int id) async {
    try {
      final response = await _dio.get(
        '/deliveries/$id',
        options: Options(headers: await _getHeaders()),
      );
      
      return Delivery.fromJson(response.data['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to load delivery');
    }
  }

  // Accept delivery
  Future<Delivery> acceptDelivery(int deliveryId) async {
    try {
      final response = await _dio.post(
        '/driver/accept-delivery/$deliveryId',
        options: Options(headers: await _getHeaders()),
      );
      
      return Delivery.fromJson(response.data['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to accept delivery');
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
        if (notes != null && notes.isNotEmpty) 'notes': notes,
      });

      final response = await _dio.post(
        '/deliveries/$deliveryId/pickup',
        data: formData,
        options: Options(headers: await _getHeaders()),
      );
      
      return Delivery.fromJson(response.data['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to confirm pickup');
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
        if (notes != null && notes.isNotEmpty) 'notes': notes,
      });

      final response = await _dio.post(
        '/deliveries/$deliveryId/deliver',
        data: formData,
        options: Options(headers: await _getHeaders()),
      );
      
      return Delivery.fromJson(response.data['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to confirm delivery');
    }
  }

  // Cancel delivery (only before pickup)
  Future<Delivery> cancelDelivery({
    required int deliveryId,
    required String reason,
  }) async {
    try {
      final response = await _dio.post(
        '/deliveries/$deliveryId/cancel',
        data: {'reason': reason},
        options: Options(headers: await _getHeaders()),
      );
      
      if (response.data['success'] == true) {
        return Delivery.fromJson(response.data['data'] as Map<String, dynamic>);
      } else {
        throw Exception(response.data['message'] ?? 'Failed to cancel delivery');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 400) {
        throw Exception('Cannot cancel delivery after item has been picked up');
      } else if (e.response?.statusCode == 403) {
        throw Exception('You do not have permission to cancel this delivery');
      }
      throw Exception(e.response?.data['message'] ?? 'Failed to cancel delivery');
    }
  }

  // Track delivery (for buyers/sellers)
  Future<Delivery> trackDelivery(int orderId) async {
    try {
      final response = await _dio.get(
        '/orders/$orderId/delivery',
        options: Options(headers: await _getHeaders()),
      );
      
      return Delivery.fromJson(response.data['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to track delivery');
    }
  }
}