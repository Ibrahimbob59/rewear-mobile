import 'package:dio/dio.dart';

class DeliveryService {
  final Dio dio;

  DeliveryService(this.dio);

  // Get all deliveries (admin only or filtered for user)
  Future<List<Map<String, dynamic>>> getDeliveries({
    String? status,
    int? orderId,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (status != null) queryParams['status'] = status;
      if (orderId != null) queryParams['order_id'] = orderId;

      final response = await dio.get('/deliveries', queryParameters: queryParams);
      
      if (response.data['success'] != true) {
        throw Exception(response.data['message'] ?? 'Failed to load deliveries');
      }
      
      final data = response.data['data'];
      return List<Map<String, dynamic>>.from(data['deliveries'] ?? []);
    } catch (e) {
      throw Exception('Failed to load deliveries: $e');
    }
  }

  // Get single delivery details
  Future<Map<String, dynamic>> getDelivery(int deliveryId) async {
    try {
      final response = await dio.get('/deliveries/$deliveryId');
      
      if (response.data['success'] != true) {
        throw Exception(response.data['message'] ?? 'Failed to load delivery');
      }
      
      return response.data['data'];
    } catch (e) {
      throw Exception('Failed to load delivery: $e');
    }
  }

  // Mark delivery as picked up - CORRECT
  Future<Map<String, dynamic>> markAsPickedUp(int deliveryId) async {
    try {
      final response = await dio.post('/deliveries/$deliveryId/pickup');
      
      if (response.data['success'] != true) {
        throw Exception(response.data['message'] ?? 'Failed to mark as picked up');
      }
      
      return response.data['data'];
    } catch (e) {
      throw Exception('Failed to mark as picked up: $e');
    }
  }

  // Mark delivery as delivered - CORRECT
  Future<Map<String, dynamic>> markAsDelivered(int deliveryId, {String? notes}) async {
    try {
      final requestData = notes != null ? {'delivery_notes': notes} : null;
      final response = await dio.post(
        '/deliveries/$deliveryId/deliver',
        data: requestData,
      );
      
      if (response.data['success'] != true) {
        throw Exception(response.data['message'] ?? 'Failed to mark as delivered');
      }
      
      return response.data['data'];
    } catch (e) {
      throw Exception('Failed to mark as delivered: $e');
    }
  }

  // Mark delivery as failed - CORRECT
  Future<Map<String, dynamic>> markAsFailed(int deliveryId, String reason) async {
    try {
      final response = await dio.post('/deliveries/$deliveryId/fail', data: {
        'failure_reason': reason,
      });
      
      if (response.data['success'] != true) {
        throw Exception(response.data['message'] ?? 'Failed to mark as failed');
      }
      
      return response.data['data'];
    } catch (e) {
      throw Exception('Failed to mark as failed: $e');
    }
  }

  // Admin: Assign driver to delivery
  Future<Map<String, dynamic>> assignDriver(int deliveryId, int driverId) async {
    try {
      final response = await dio.post('/deliveries/$deliveryId/assign-driver', data: {
        'driver_id': driverId,
      });
      
      if (response.data['success'] != true) {
        throw Exception(response.data['message'] ?? 'Failed to assign driver');
      }
      
      return response.data['data'];
    } catch (e) {
      throw Exception('Failed to assign driver: $e');
    }
  }
  // Get available deliveries for drivers
  Future<List<Map<String, dynamic>>> getAvailableDeliveries() async {
    try {
      final response = await dio.get('/driver/available-deliveries');
      
      if (response.data['success'] != true) {
        throw Exception(response.data['message'] ?? 'Failed to load available deliveries');
      }
      
      final data = response.data['data'];
      return List<Map<String, dynamic>>.from(data['deliveries'] ?? []);
    } catch (e) {
      throw Exception('Failed to load available deliveries: $e');
    }
  }

  // Get active deliveries for current driver
  Future<List<Map<String, dynamic>>> getActiveDeliveries() async {
    try {
      final response = await dio.get('/driver/deliveries', queryParameters: {
        'status': 'active'
      });
      
      if (response.data['success'] != true) {
        throw Exception(response.data['message'] ?? 'Failed to load active deliveries');
      }
      
      final data = response.data['data'];
      return List<Map<String, dynamic>>.from(data['deliveries'] ?? []);
    } catch (e) {
      throw Exception('Failed to load active deliveries: $e');
    }
  }

  // Get delivery history
  Future<List<Map<String, dynamic>>> getDeliveryHistory() async {
    try {
      final response = await dio.get('/driver/deliveries', queryParameters: {
        'status': 'completed'
      });
      
      if (response.data['success'] != true) {
        throw Exception(response.data['message'] ?? 'Failed to load delivery history');
      }
      
      final data = response.data['data'];
      return List<Map<String, dynamic>>.from(data['deliveries'] ?? []);
    } catch (e) {
      throw Exception('Failed to load delivery history: $e');
    }
  }

  // Accept delivery (for drivers)
  Future<Map<String, dynamic>> acceptDelivery(int deliveryId) async {
    try {
      final response = await dio.post('/driver/accept-delivery/$deliveryId');
      
      if (response.data['success'] != true) {
        throw Exception(response.data['message'] ?? 'Failed to accept delivery');
      }
      
      return response.data['data'];
    } catch (e) {
      throw Exception('Failed to accept delivery: $e');
    }
  }

  // Confirm pickup
  Future<Map<String, dynamic>> confirmPickup(int deliveryId) async {
    try {
      final response = await dio.post('/deliveries/$deliveryId/pickup');
      
      if (response.data['success'] != true) {
        throw Exception(response.data['message'] ?? 'Failed to confirm pickup');
      }
      
      return response.data['data'];
    } catch (e) {
      throw Exception('Failed to confirm pickup: $e');
    }
  }

  // Confirm delivery
  Future<Map<String, dynamic>> confirmDelivery(int deliveryId, {String? notes}) async {
    try {
      final requestData = notes != null ? {'delivery_notes': notes} : null;
      final response = await dio.post(
        '/deliveries/$deliveryId/deliver',
        data: requestData,
      );
      
      if (response.data['success'] != true) {
        throw Exception(response.data['message'] ?? 'Failed to confirm delivery');
      }
      
      return response.data['data'];
    } catch (e) {
      throw Exception('Failed to confirm delivery: $e');
    }
  }

  // Cancel delivery
  Future<void> cancelDelivery(int deliveryId, String reason) async {
    try {
      final response = await dio.post('/deliveries/$deliveryId/cancel', data: {
        'cancellation_reason': reason,
      });
      
      if (response.data['success'] != true) {
        throw Exception(response.data['message'] ?? 'Failed to cancel delivery');
      }
    } catch (e) {
      throw Exception('Failed to cancel delivery: $e');
    }
  }

  // Track delivery (get real-time status)
  Future<Map<String, dynamic>> trackDelivery(int deliveryId) async {
    try {
      final response = await dio.get('/deliveries/$deliveryId/track');
      
      if (response.data['success'] != true) {
        throw Exception(response.data['message'] ?? 'Failed to track delivery');
      }
      
      return response.data['data'];
    } catch (e) {
      throw Exception('Failed to track delivery: $e');
    }
  }
}