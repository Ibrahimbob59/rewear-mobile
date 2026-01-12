import 'package:dio/dio.dart';
import '../models/item_model.dart';

class CharityService {
  final Dio dio;

  CharityService(this.dio);

  // Get charity profile - CORRECT
  Future<Map<String, dynamic>> getProfile() async {
    try {
      final response = await dio.get('/charity/profile');
      
      if (response.data['success'] != true) {
        throw Exception(response.data['message'] ?? 'Failed to load profile');
      }
      
      return response.data['data'];
    } catch (e) {
      throw Exception('Failed to load charity profile: $e');
    }
  }

  // Get impact statistics - CORRECT
  Future<Map<String, dynamic>> getImpact() async {
    try {
      final response = await dio.get('/charity/impact');
      
      if (response.data['success'] != true) {
        throw Exception(response.data['message'] ?? 'Failed to load impact stats');
      }
      
      return response.data['data'];
    } catch (e) {
      throw Exception('Failed to load impact stats: $e');
    }
  }

  // Get available donations - CORRECTED (uses items endpoint with filters)
  Future<List<Item>> getAvailableDonations() async {
    try {
      final response = await dio.get('/items', queryParameters: {
        'is_donation': 'true',
        'status': 'available',
      });
      
      if (response.data['success'] != true) {
        throw Exception(response.data['message'] ?? 'Failed to load donations');
      }
      
      final data = response.data['data'];
      final itemsList = data['items'] as List;
      
      return itemsList.map((json) => Item.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to load available donations: $e');
    }
  }

  // Get pending donations for this charity - CORRECT
  Future<List<Map<String, dynamic>>> getPendingDonations() async {
    try {
      final response = await dio.get('/charity/pending-donations');
      
      if (response.data['success'] != true) {
        throw Exception(response.data['message'] ?? 'Failed to load pending donations');
      }
      
      final data = response.data['data'];
      return List<Map<String, dynamic>>.from(data['donations'] ?? []);
    } catch (e) {
      throw Exception('Failed to load pending donations: $e');
    }
  }

  // Claim a donation - CORRECTED ENDPOINT AND PARAMETERS
  Future<Map<String, dynamic>> claimDonation({
    required int itemId,
    required String distributionPlan,
    required int beneficiariesCount,
  }) async {
    try {
      final response = await dio.post('/charity/claim-donation', data: {
        'item_id': itemId,
        'distribution_plan': distributionPlan,
        'beneficiaries_count': beneficiariesCount,
      });
      
      if (response.data['success'] != true) {
        throw Exception(response.data['message'] ?? 'Failed to claim donation');
      }
      
      return response.data['data'];
    } catch (e) {
      throw Exception('Failed to claim donation: $e');
    }
  }

  // Get claimed donations (received items) - CORRECT
  Future<List<Map<String, dynamic>>> getClaimedDonations() async {
    try {
      final response = await dio.get('/charity/claimed-donations');
      
      if (response.data['success'] != true) {
        throw Exception(response.data['message'] ?? 'Failed to load claimed donations');
      }
      
      final data = response.data['data'];
      return List<Map<String, dynamic>>.from(data['donations'] ?? []);
    } catch (e) {
      throw Exception('Failed to load claimed donations: $e');
    }
  }

  // Mark donation as distributed - CORRECT
  Future<void> markAsDistributed({
    required int orderId,
    required int beneficiariesCount,
    String? notes,
  }) async {
    try {
      final response = await dio.post('/charity/mark-distributed/$orderId', data: {
        'beneficiaries_count': beneficiariesCount,
        if (notes != null) 'distribution_notes': notes,
      });
      
      if (response.data['success'] != true) {
        throw Exception(response.data['message'] ?? 'Failed to mark as distributed');
      }
    } catch (e) {
      throw Exception('Failed to mark as distributed: $e');
    }
  }

  // Get distribution history - CORRECT
  Future<List<Map<String, dynamic>>> getDistributionHistory() async {
    try {
      final response = await dio.get('/charity/distribution-history');
      
      if (response.data['success'] != true) {
        throw Exception(response.data['message'] ?? 'Failed to load history');
      }
      
      final data = response.data['data'];
      return List<Map<String, dynamic>>.from(data['distributions'] ?? []);
    } catch (e) {
      throw Exception('Failed to load distribution history: $e');
    }
  }
  // Get charity dashboard data
  Future<Map<String, dynamic>> getDashboard() async {
    try {
      final response = await dio.get('/charity/profile');
      
      if (response.data['success'] != true) {
        throw Exception(response.data['message'] ?? 'Failed to load dashboard');
      }
      
      return response.data['data'];
    } catch (e) {
      throw Exception('Failed to load charity dashboard: $e');
    }
  }

  // Get my donations (claimed donations)
  Future<List<Map<String, dynamic>>> getMyDonations() async {
    try {
      final response = await dio.get('/charity/claimed-donations');
      
      if (response.data['success'] != true) {
        throw Exception(response.data['message'] ?? 'Failed to load donations');
      }
      
      final data = response.data['data'];
      return List<Map<String, dynamic>>.from(data['donations'] ?? []);
    } catch (e) {
      throw Exception('Failed to load my donations: $e');
    }
  }

  // Accept/Claim donation (use the claimDonation method instead)
  Future<void> acceptDonation(int itemId, String plan, int beneficiaries) async {
    await claimDonation(
      itemId: itemId,
      distributionPlan: plan,
      beneficiariesCount: beneficiaries,
    );
  }

  // Mark donation as distributed
  Future<void> markDistributed(int orderId, int beneficiaries, {String? notes}) async {
    await markAsDistributed(
      orderId: orderId,
      beneficiariesCount: beneficiaries,
      notes: notes,
    );
  }

  // Get impact statistics
  Future<Map<String, dynamic>> getImpactStats() async {
    return await getImpact();
  }
}