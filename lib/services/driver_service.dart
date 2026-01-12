import 'package:dio/dio.dart';

class DriverService {
  final Dio dio;

  DriverService(this.dio);

  // Apply as driver - CORRECTED ENDPOINT
  Future<Map<String, dynamic>> applyAsDriver({
    required String fullName,
    required String phone,
    required String email,
    required String address,
    required String city,
    required String vehicleType,
    String? idDocumentUrl,
    String? drivingLicenseUrl,
    String? vehicleRegistrationUrl,
  }) async {
    try {
      final formData = FormData.fromMap({
        'full_name': fullName,
        'phone': phone,
        'email': email,
        'address': address,
        'city': city,
        'vehicle_type': vehicleType,
        if (idDocumentUrl != null) 
          'id_document': await MultipartFile.fromFile(idDocumentUrl),
        if (drivingLicenseUrl != null)
          'driving_license': await MultipartFile.fromFile(drivingLicenseUrl),
        if (vehicleRegistrationUrl != null)
          'vehicle_registration': await MultipartFile.fromFile(vehicleRegistrationUrl),
      });

      final response = await dio.post('/driver-applications', data: formData);
      
      if (response.data['success'] != true) {
        throw Exception(response.data['message'] ?? 'Failed to submit application');
      }
      
      return response.data['data'];
    } catch (e) {
      throw Exception('Failed to submit driver application: $e');
    }
  }

  // Get my application status - CORRECTED ENDPOINT
  Future<Map<String, dynamic>?> getMyApplication() async {
    try {
      final response = await dio.get('/driver-applications/my-application');
      
      if (response.data['success'] == true) {
        return response.data['data'];
      }
      return null;
    } catch (e) {
      if (e is DioException && e.response?.statusCode == 404) {
        return null; // No application yet
      }
      throw Exception('Failed to get application: $e');
    }
  }

  // Check driver eligibility - CORRECTED ENDPOINT
  Future<Map<String, dynamic>> checkEligibility() async {
    try {
      final response = await dio.get('/driver-applications/eligibility');
      return response.data['data'];
    } catch (e) {
      throw Exception('Failed to check eligibility: $e');
    }
  }

  // Get driver dashboard stats - CORRECT
  Future<Map<String, dynamic>> getDashboard() async {
    try {
      final response = await dio.get('/driver/dashboard');
      
      if (response.data['success'] != true) {
        throw Exception(response.data['message'] ?? 'Failed to load dashboard');
      }
      
      return response.data['data'];
    } catch (e) {
      throw Exception('Failed to load dashboard: $e');
    }
  }

  // Get my deliveries - CORRECT
  Future<List<Map<String, dynamic>>> getMyDeliveries({String? status}) async {
    try {
      final queryParams = status != null ? {'status': status} : null;
      final response = await dio.get('/driver/deliveries', queryParameters: queryParams);
      
      if (response.data['success'] != true) {
        throw Exception(response.data['message'] ?? 'Failed to load deliveries');
      }
      
      final data = response.data['data'];
      return List<Map<String, dynamic>>.from(data['deliveries'] ?? []);
    } catch (e) {
      throw Exception('Failed to load deliveries: $e');
    }
  }

  // Get available deliveries to accept - CORRECT
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

  // Accept a delivery - CORRECT
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

  // Get earnings - CORRECT
  Future<Map<String, dynamic>> getEarnings({String? period}) async {
    try {
      final queryParams = period != null ? {'period': period} : null;
      final response = await dio.get('/driver/earnings', queryParameters: queryParams);
      
      if (response.data['success'] != true) {
        throw Exception(response.data['message'] ?? 'Failed to load earnings');
      }
      
      return response.data['data'];
    } catch (e) {
      throw Exception('Failed to load earnings: $e');
    }
  }
}