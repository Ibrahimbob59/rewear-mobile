import 'package:dio/dio.dart';
import '../models/charity_model.dart';

class CharityService {
  final Dio _dio;

  CharityService(this._dio);

  Future<Map<String, dynamic>> getDashboard() async {
    try {
      final response = await _dio.get('/charity/dashboard');
      return response.data['data'];
    } catch (e) {
      print('Error getting charity dashboard: $e');
      rethrow;
    }
  }

  Future<List<DonatedItem>> getAvailableDonations() async {
    try {
      final response = await _dio.get('/charity/available-donations');
      final List<dynamic> data = response.data['data'] ?? [];
      return data.map((json) => DonatedItem.fromJson(json)).toList();
    } catch (e) {
      print('Error getting available donations: $e');
      rethrow;
    }
  }

  Future<DonatedItem> acceptDonation(int itemId) async {
    try {
      final response = await _dio.post('/charity/accept-donation/$itemId');
      return DonatedItem.fromJson(response.data['data']);
    } catch (e) {
      print('Error accepting donation: $e');
      rethrow;
    }
  }

  Future<List<DonatedItem>> getMyDonations() async {
    try {
      final response = await _dio.get('/charity/my-donations');
      final List<dynamic> data = response.data['data'] ?? [];
      return data.map((json) => DonatedItem.fromJson(json)).toList();
    } catch (e) {
      print('Error getting my donations: $e');
      rethrow;
    }
  }

  Future<void> markDistributed(int orderId) async {
    try {
      await _dio.post('/charity/mark-distributed/$orderId');
    } catch (e) {
      print('Error marking distributed: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getImpactStats() async {
    try {
      final response = await _dio.get('/charity/impact-stats');
      return response.data['data'];
    } catch (e) {
      print('Error getting impact stats: $e');
      rethrow;
    }
  }

  Future<List<DonatedItem>> getRecommendedDonations() async {
    try {
      final response = await _dio.get('/charity/recommended-donations');
      final List<dynamic> data = response.data['data'] ?? [];
      return data.map((json) => DonatedItem.fromJson(json)).toList();
    } catch (e) {
      print('Error getting recommended donations: $e');
      rethrow;
    }
  }
}
