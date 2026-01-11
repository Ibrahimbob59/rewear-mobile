import 'dart:io';
import 'package:dio/dio.dart';
import '../models/driver_model.dart';

class DriverService {
  final Dio _dio;

  DriverService(this._dio);

  Future<Driver> applyAsDriver({
    required String vehicleType,
    required String vehicleNumber,
    required String licenseNumber,
    required File licenseImage,
    required File vehicleImage,
  }) async {
    try {
      final formData = FormData.fromMap({
        'vehicle_type': vehicleType,
        'vehicle_number': vehicleNumber,
        'license_number': licenseNumber,
        'license_image': await MultipartFile.fromFile(
          licenseImage.path,
          filename: 'license_${DateTime.now().millisecondsSinceEpoch}.jpg',
        ),
        'vehicle_image': await MultipartFile.fromFile(
          vehicleImage.path,
          filename: 'vehicle_${DateTime.now().millisecondsSinceEpoch}.jpg',
        ),
      });

      final response = await _dio.post('/driver-applications', data: formData);
      return Driver.fromJson(response.data['data']);
    } catch (e) {
      print('Error applying as driver: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>?> getMyApplication() async {
    try {
      final response = await _dio.get('/driver-applications/my-application');
      return response.data['data'];
    } catch (e) {
      print('Error getting my application: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>> checkEligibility() async {
    try {
      final response = await _dio.get('/driver-applications/eligibility');
      return response.data['data'];
    } catch (e) {
      print('Error checking eligibility: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getDashboard() async {
    try {
      final response = await _dio.get('/driver/dashboard');
      return response.data['data'];
    } catch (e) {
      print('Error getting driver dashboard: $e');
      rethrow;
    }
  }

  Future<List<dynamic>> getMyDeliveries({String? status}) async {
    try {
      final queryParams = <String, dynamic>{};
      if (status != null) queryParams['status'] = status;
      
      final response = await _dio.get('/driver/deliveries', queryParameters: queryParams);
      return response.data['data'] as List<dynamic>;
    } catch (e) {
      print('Error getting my deliveries: $e');
      rethrow;
    }
  }

  Future<List<dynamic>> getAvailableDeliveries() async {
    try {
      final response = await _dio.get('/driver/available-deliveries');
      return response.data['data'] as List<dynamic>;
    } catch (e) {
      print('Error getting available deliveries: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> acceptDelivery(int deliveryId) async {
    try {
      final response = await _dio.post('/driver/accept-delivery/$deliveryId');
      return response.data['data'];
    } catch (e) {
      print('Error accepting delivery: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getEarnings({String? period}) async {
    try {
      final queryParams = <String, dynamic>{};
      if (period != null) queryParams['period'] = period;
      
      final response = await _dio.get('/driver/earnings', queryParameters: queryParams);
      return response.data['data'];
    } catch (e) {
      print('Error getting earnings: $e');
      rethrow;
    }
  }
}
