import 'dart:io';
import 'package:dio/dio.dart';
import '../models/driver_model.dart';

class DriverService {
  final Dio _dio;

  DriverService(this._dio);

  // Apply to become a driver
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

      final response = await _dio.post('/driver/apply', data: formData);
      return Driver.fromJson(response.data['data']);
    } catch (e) {
      print('Error applying as driver: $e');
      rethrow;
    }
  }

  // Get driver profile
  Future<Driver> getDriverProfile() async {
    try {
      final response = await _dio.get('/driver/profile');
      return Driver.fromJson(response.data['data']);
    } catch (e) {
      print('Error getting driver profile: $e');
      rethrow;
    }
  }

  // Toggle driver availability
  Future<Driver> toggleAvailability(bool isAvailable) async {
    try {
      final response = await _dio.put('/driver/availability', data: {
        'is_available': isAvailable,
      });
      return Driver.fromJson(response.data['data']);
    } catch (e) {
      print('Error toggling availability: $e');
      rethrow;
    }
  }

  // Get driver stats
  Future<Map<String, dynamic>> getDriverStats() async {
    try {
      final response = await _dio.get('/driver/stats');
      return response.data['data'];
    } catch (e) {
      print('Error getting driver stats: $e');
      rethrow;
    }
  }

  // Get driver earnings
  Future<Map<String, dynamic>> getEarnings({
    String? period, // 'today', 'week', 'month', 'all'
  }) async {
    try {
      final response = await _dio.get('/driver/earnings', queryParameters: {
        if (period != null) 'period': period,
      });
      return response.data['data'];
    } catch (e) {
      print('Error getting earnings: $e');
      rethrow;
    }
  }
}