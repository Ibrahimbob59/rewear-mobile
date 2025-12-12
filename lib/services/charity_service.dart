import 'package:dio/dio.dart';
import '../models/charity_model.dart';

class CharityService {
  final Dio _dio;

  CharityService(this._dio);

  // Get charity profile
  Future<Charity> getCharityProfile() async {
    try {
      final response = await _dio.get('/charity/profile');
      return Charity.fromJson(response.data['data']);
    } catch (e) {
      print('Error getting charity profile: $e');
      rethrow;
    }
  }

  // Get pending donations
  Future<List<DonatedItem>> getPendingDonations() async {
    try {
      final response = await _dio.get('/charity/donations/pending');
      final List<dynamic> data = response.data['data'];
      return data.map((json) => DonatedItem.fromJson(json)).toList();
    } catch (e) {
      print('Error getting pending donations: $e');
      rethrow;
    }
  }

  // Get accepted donations
  Future<List<DonatedItem>> getAcceptedDonations() async {
    try {
      final response = await _dio.get('/charity/donations/accepted');
      final List<dynamic> data = response.data['data'];
      return data.map((json) => DonatedItem.fromJson(json)).toList();
    } catch (e) {
      print('Error getting accepted donations: $e');
      rethrow;
    }
  }

  // Accept donation
  Future<DonatedItem> acceptDonation(int donationId) async {
    try {
      final response = await _dio.post('/charity/donations/$donationId/accept');
      return DonatedItem.fromJson(response.data['data']);
    } catch (e) {
      print('Error accepting donation: $e');
      rethrow;
    }
  }

  // Reject donation
  Future<void> rejectDonation(int donationId, {String? reason}) async {
    try {
      await _dio.post('/charity/donations/$donationId/reject', data: {
        if (reason != null) 'reason': reason,
      });
    } catch (e) {
      print('Error rejecting donation: $e');
      rethrow;
    }
  }

  // Get impact stats
  Future<Map<String, dynamic>> getImpactStats() async {
    try {
      final response = await _dio.get('/charity/impact');
      return response.data['data'];
    } catch (e) {
      print('Error getting impact stats: $e');
      rethrow;
    }
  }
}