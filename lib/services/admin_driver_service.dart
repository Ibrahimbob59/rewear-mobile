import 'package:dio/dio.dart';

class AdminDriverService {
  final Dio dio;

  AdminDriverService(this.dio);

  /// Get all driver applications with optional status filter
  Future<List<Map<String, dynamic>>> getAllDriverApplications({String? status}) async {
    try {
      final queryParams = status != null ? {'status': status} : null;
      final response = await dio.get(
        '/admin/driver-applications',
        queryParameters: queryParams,
      );

      if (response.data['success'] == true) {
        final data = response.data['data'];
        return List<Map<String, dynamic>>.from(data);
      }
      return [];
    } catch (e) {
      throw Exception('Failed to load driver applications: $e');
    }
  }

  /// Get detailed information about a specific driver application
  Future<Map<String, dynamic>> getDriverApplicationDetails(int applicationId) async {
    try {
      final response = await dio.get('/admin/driver-applications/$applicationId');

      if (response.data['success'] == true) {
        return response.data['data'];
      }
      throw Exception('Failed to get application details');
    } catch (e) {
      throw Exception('Failed to get application details: $e');
    }
  }

  /// Approve a driver application
  Future<bool> approveDriverApplication(int applicationId) async {
    try {
      final response = await dio.post('/admin/driver-applications/$applicationId/approve');

      if (response.data['success'] == true) {
        return true;
      }
      return false;
    } catch (e) {
      throw Exception('Failed to approve application: $e');
    }
  }

  /// Reject a driver application with a reason
  Future<bool> rejectDriverApplication(int applicationId, String reason) async {
    try {
      final response = await dio.post(
        '/admin/driver-applications/$applicationId/reject',
        data: {'reason': reason},
      );

      if (response.data['success'] == true) {
        return true;
      }
      return false;
    } catch (e) {
      throw Exception('Failed to reject application: $e');
    }
  }

  /// Get all verified drivers
  Future<List<Map<String, dynamic>>> getAllVerifiedDrivers() async {
    try {
      final response = await dio.get('/admin/drivers');

      if (response.data['success'] == true) {
        final data = response.data['data'];
        return List<Map<String, dynamic>>.from(data);
      }
      return [];
    } catch (e) {
      throw Exception('Failed to load drivers: $e');
    }
  }

  /// Get driver application statistics
  Future<Map<String, dynamic>> getDriverApplicationStats() async {
    try {
      final response = await dio.get('/admin/driver-applications/stats');

      if (response.data['success'] == true) {
        return response.data['data'];
      }
      return {};
    } catch (e) {
      throw Exception('Failed to load statistics: $e');
    }
  }
}
