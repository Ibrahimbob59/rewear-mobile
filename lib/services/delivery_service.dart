import 'package:dio/dio.dart';

class DeliveryService {
  final Dio dio;

  DeliveryService(this.dio);

  // ✅ Helper to safely extract list from various response structures
  List<Map<String, dynamic>> _extractDeliveriesList(dynamic data) {
    if (data == null) return [];
    
    if (data is List) {
      return data.map((item) {
        if (item is Map) return Map<String, dynamic>.from(item);
        return <String, dynamic>{};
      }).toList();
    }
    
    if (data is Map) {
      if (data.containsKey('deliveries') && data['deliveries'] is List) {
        final list = data['deliveries'] as List;
        return list.map((item) {
          if (item is Map) return Map<String, dynamic>.from(item);
          return <String, dynamic>{};
        }).toList();
      }
      
      if (data.containsKey('data') && data['data'] is List) {
        final list = data['data'] as List;
        return list.map((item) {
          if (item is Map) return Map<String, dynamic>.from(item);
          return <String, dynamic>{};
        }).toList();
      }
      
      return [Map<String, dynamic>.from(data)];
    }
    
    return [];
  }

  // ✅ Helper to extract detailed error message from DioException
  String _extractErrorMessage(DioException e) {
    // Check for response data
    if (e.response?.data != null) {
      final data = e.response!.data;
      
      // Check for 'message' field
      if (data is Map && data['message'] != null) {
        return data['message'].toString();
      }
      
      // Check for 'error' field
      if (data is Map && data['error'] != null) {
        return data['error'].toString();
      }
      
      // Check for validation errors
      if (data is Map && data['errors'] != null) {
        final errors = data['errors'];
        if (errors is Map) {
          final errorMessages = <String>[];
          errors.forEach((key, value) {
            if (value is List) {
              errorMessages.addAll(value.map((e) => e.toString()));
            } else {
              errorMessages.add(value.toString());
            }
          });
          return errorMessages.join(', ');
        }
      }
    }
    
    // Fallback to status code message
    if (e.response?.statusCode != null) {
      return 'HTTP ${e.response!.statusCode}: ${e.response!.statusMessage ?? "Unknown error"}';
    }
    
    return e.message ?? 'Network error occurred';
  }

  // Get all deliveries
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
      
      return _extractDeliveriesList(response.data['data']);
    } on DioException catch (e) {
      throw Exception(_extractErrorMessage(e));
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
      
      return Map<String, dynamic>.from(response.data['data'] ?? {});
    } on DioException catch (e) {
      throw Exception(_extractErrorMessage(e));
    } catch (e) {
      throw Exception('Failed to load delivery: $e');
    }
  }

  // ✅ IMPROVED: Mark delivery as picked up with better error handling
  Future<Map<String, dynamic>> markAsPickedUp(int deliveryId) async {
    try {
      print('🚚 Attempting to mark delivery $deliveryId as picked up...');
      
      final response = await dio.post('/deliveries/$deliveryId/pickup');
      
      print('✅ Response received: ${response.statusCode}');
      print('📦 Response data: ${response.data}');
      
      if (response.data['success'] != true) {
        final errorMsg = response.data['message'] ?? 'Failed to mark as picked up';
        print('❌ Backend error: $errorMsg');
        throw Exception(errorMsg);
      }
      
      return Map<String, dynamic>.from(response.data['data'] ?? {});
    } on DioException catch (e) {
      print('❌ DioException occurred!');
      print('   Status: ${e.response?.statusCode}');
      print('   Data: ${e.response?.data}');
      
      final errorMsg = _extractErrorMessage(e);
      throw Exception(errorMsg);
    } catch (e) {
      print('❌ Unexpected error: $e');
      throw Exception('Failed to mark as picked up: $e');
    }
  }

  // Mark delivery as delivered
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
      
      return Map<String, dynamic>.from(response.data['data'] ?? {});
    } on DioException catch (e) {
      throw Exception(_extractErrorMessage(e));
    } catch (e) {
      throw Exception('Failed to mark as delivered: $e');
    }
  }

  // Mark delivery as failed
  Future<Map<String, dynamic>> markAsFailed(int deliveryId, String reason) async {
    try {
      final response = await dio.post('/deliveries/$deliveryId/fail', data: {
        'failure_reason': reason,
      });
      
      if (response.data['success'] != true) {
        throw Exception(response.data['message'] ?? 'Failed to mark as failed');
      }
      
      return Map<String, dynamic>.from(response.data['data'] ?? {});
    } on DioException catch (e) {
      throw Exception(_extractErrorMessage(e));
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
      
      return Map<String, dynamic>.from(response.data['data'] ?? {});
    } on DioException catch (e) {
      throw Exception(_extractErrorMessage(e));
    } catch (e) {
      throw Exception('Failed to assign driver: $e');
    }
  }

  // Get available deliveries for drivers
  Future<List<Map<String, dynamic>>> getAvailableDeliveries() async {
    try {
      print('🔍 Fetching available deliveries...');
      final response = await dio.get('/driver/available-deliveries');

      print('✅ Response: ${response.statusCode}');

      if (response.data['success'] != true) {
        throw Exception(response.data['message'] ?? 'Failed to load available deliveries');
      }

      final allDeliveries = _extractDeliveriesList(response.data['data']);
      print('📦 Total deliveries from backend: ${allDeliveries.length}');

      // Filter out deliveries that already have a driver assigned (defensive filtering)
      final availableDeliveries = allDeliveries.where((delivery) {
        final driverId = delivery['driver_id'];
        final status = (delivery['status'] as String?)?.toLowerCase() ?? '';

        // Only show deliveries that:
        // 1. Don't have a driver assigned (driver_id is null)
        // 2. Are in 'pending' status
        final isAvailable = driverId == null && status == 'pending';

        if (!isAvailable) {
          print('   ⚠️ Filtering out delivery #${delivery['id']} (driver_id: $driverId, status: $status)');
        }

        return isAvailable;
      }).toList();

      print('✅ Available deliveries after filtering: ${availableDeliveries.length}');
      return availableDeliveries;
    } on DioException catch (e) {
      print('❌ DioException: ${e.message}');
      print('   Response: ${e.response?.data}');
      throw Exception(_extractErrorMessage(e));
    } catch (e) {
      print('❌ Error: $e');
      throw Exception('Failed to load available deliveries: $e');
    }
  }

  // Get active deliveries for current driver
  Future<List<Map<String, dynamic>>> getActiveDeliveries() async {
    try {
      print('🔍 Fetching active deliveries...');
      // Try without status filter first to get all deliveries
      final response = await dio.get('/driver/deliveries');

      print('✅ Response: ${response.statusCode}');

      if (response.data['success'] != true) {
        throw Exception(response.data['message'] ?? 'Failed to load active deliveries');
      }

      final allDeliveries = _extractDeliveriesList(response.data['data']);
      print('📦 Total deliveries: ${allDeliveries.length}');

      // Filter active deliveries on client side (assigned, picked_up, in_transit)
      final activeDeliveries = allDeliveries.where((delivery) {
        final status = (delivery['status'] as String?)?.toLowerCase() ?? '';
        final isActive = status == 'assigned' || status == 'picked_up' || status == 'in_transit';
        if (isActive) {
          print('   ✓ Active delivery #${delivery['id']}: $status');
        }
        return isActive;
      }).toList();

      print('🚚 Active deliveries count: ${activeDeliveries.length}');
      return activeDeliveries;
    } on DioException catch (e) {
      print('❌ DioException: ${e.message}');
      print('   Response: ${e.response?.data}');
      throw Exception(_extractErrorMessage(e));
    } catch (e) {
      print('❌ Error: $e');
      throw Exception('Failed to load active deliveries: $e');
    }
  }

  // Get delivery history
  Future<List<Map<String, dynamic>>> getDeliveryHistory() async {
    try {
      print('📜 Fetching delivery history...');
      // Get all deliveries and filter for completed ones (delivered, cancelled, failed)
      final response = await dio.get('/driver/deliveries');

      print('✅ Response: ${response.statusCode}');

      if (response.data['success'] != true) {
        throw Exception(response.data['message'] ?? 'Failed to load delivery history');
      }

      final allDeliveries = _extractDeliveriesList(response.data['data']);
      print('📦 Total deliveries: ${allDeliveries.length}');

      // Filter for completed deliveries (delivered, cancelled, or failed)
      final historyDeliveries = allDeliveries.where((delivery) {
        final status = (delivery['status'] as String?)?.toLowerCase() ?? '';
        final isCompleted = status == 'delivered' || status == 'cancelled' || status == 'failed';
        if (isCompleted) {
          print('   ✓ Delivery #${delivery['id']}: $status');
        }
        return isCompleted;
      }).toList();

      print('📜 Delivery history count: ${historyDeliveries.length}');
      return historyDeliveries;
    } on DioException catch (e) {
      print('❌ DioException: ${e.message}');
      throw Exception(_extractErrorMessage(e));
    } catch (e) {
      print('❌ Error: $e');
      throw Exception('Failed to load delivery history: $e');
    }
  }

  // Accept delivery (for drivers)
  Future<Map<String, dynamic>> acceptDelivery(int deliveryId) async {
    try {
      print('🚚 Attempting to accept delivery #$deliveryId...');
      final response = await dio.post('/driver/accept-delivery/$deliveryId');

      print('✅ Accept response: ${response.statusCode}');
      print('📦 Response data: ${response.data}');

      if (response.data['success'] != true) {
        final errorMsg = response.data['message'] ?? 'Failed to accept delivery';
        print('❌ Backend rejected: $errorMsg');
        throw Exception(errorMsg);
      }

      print('✅ Delivery accepted successfully!');
      return Map<String, dynamic>.from(response.data['data'] ?? {});
    } on DioException catch (e) {
      print('❌ DioException during accept!');
      print('   Status: ${e.response?.statusCode}');
      print('   Data: ${e.response?.data}');
      final errorMsg = _extractErrorMessage(e);
      print('   Extracted error: $errorMsg');
      throw Exception(errorMsg);
    } catch (e) {
      print('❌ Unexpected error: $e');
      throw Exception('Failed to accept delivery: $e');
    }
  }

  // ✅ IMPROVED: Confirm pickup with better error handling
  Future<Map<String, dynamic>> confirmPickup(int deliveryId) async {
    return await markAsPickedUp(deliveryId);
  }

  // Confirm delivery
  Future<Map<String, dynamic>> confirmDelivery(int deliveryId, {String? notes}) async {
    return await markAsDelivered(deliveryId, notes: notes);
  }

  // Cancel delivery
  Future<void> cancelDelivery(int deliveryId, String reason) async {
    try {
      print('🚫 Attempting to cancel delivery #$deliveryId...');
      print('   Reason: $reason');

      final response = await dio.post('/deliveries/$deliveryId/cancel', data: {
        'reason': reason,  // Changed from 'cancellation_reason' to 'reason'
      });

      print('✅ Cancel response: ${response.statusCode}');
      print('📦 Response data: ${response.data}');

      if (response.data['success'] != true) {
        final errorMsg = response.data['message'] ?? 'Failed to cancel delivery';
        print('❌ Backend rejected cancel: $errorMsg');
        throw Exception(errorMsg);
      }

      print('✅ Delivery cancelled successfully!');
    } on DioException catch (e) {
      print('❌ DioException during cancel!');
      print('   Status: ${e.response?.statusCode}');
      print('   Data: ${e.response?.data}');
      throw Exception(_extractErrorMessage(e));
    } catch (e) {
      print('❌ Unexpected error: $e');
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
      
      return Map<String, dynamic>.from(response.data['data'] ?? {});
    } on DioException catch (e) {
      throw Exception(_extractErrorMessage(e));
    } catch (e) {
      throw Exception('Failed to track delivery: $e');
    }
  }
}