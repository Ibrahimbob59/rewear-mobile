import 'package:flutter/foundation.dart';
import '../services/charity_service.dart';

class CharityProvider extends ChangeNotifier {
  final CharityService _charityService;

  bool isLoading = false;
  String? error;

  // ALL CHANGED TO Map<String, dynamic>
  Map<String, dynamic>? charity;
  Map<String, dynamic>? impactStats;
  List<Map<String, dynamic>> availableDonations = [];
  List<Map<String, dynamic>> pendingDonations = [];
  List<Map<String, dynamic>> _claimedDonationsRaw = [];

  CharityProvider(this._charityService);

  bool get isCharity => charity != null;

  List<Map<String, dynamic>> get claimedDonations => _claimedDonationsRaw;

  // ADDED: Getters for counts
  int get pendingCount => pendingDonations.length;
  int get acceptedCount => claimedDonations.length;

  // Load charity profile
  Future<void> loadCharityProfile() async {
    try {
      isLoading = true;
      error = null;
      notifyListeners();

      charity = await _charityService.getProfile();

      isLoading = false;
      notifyListeners();
    } catch (e) {
      error = e.toString();
      isLoading = false;
      notifyListeners();
    }
  }

  // Load impact statistics
  Future<void> loadImpactStats() async {
    try {
      isLoading = true;
      error = null;
      notifyListeners();

      impactStats = await _charityService.getImpact();

      isLoading = false;
      notifyListeners();
    } catch (e) {
      error = e.toString();
      isLoading = false;
      notifyListeners();
    }
  }

  // Load available donations
  Future<void> loadAvailableDonations() async {
    try {
      isLoading = true;
      error = null;
      notifyListeners();

      // FIXED: Proper casting to List<Map<String, dynamic>>
      final items = await _charityService.getAvailableDonations();
      availableDonations = List<Map<String, dynamic>>.from(
        items.map((item) => item as Map<String, dynamic>)
      );

      isLoading = false;
      notifyListeners();
    } catch (e) {
      error = e.toString();
      isLoading = false;
      notifyListeners();
    }
  }

  // Load pending donations (claimed but not received yet)
  Future<void> loadPendingDonations() async {
    try {
      isLoading = true;
      error = null;
      notifyListeners();

      pendingDonations = await _charityService.getPendingDonations();

      isLoading = false;
      notifyListeners();
    } catch (e) {
      error = e.toString();
      isLoading = false;
      notifyListeners();
    }
  }

  // Load claimed donations
  Future<void> loadClaimedDonations() async {
    try {
      isLoading = true;
      error = null;
      notifyListeners();

      _claimedDonationsRaw = await _charityService.getMyDonations();

      isLoading = false;
      notifyListeners();
    } catch (e) {
      error = e.toString();
      isLoading = false;
      notifyListeners();
    }
  }

  // Claim a donation
  Future<bool> claimDonation({
    required int itemId,
    required String distributionPlan,
    required int beneficiariesCount,
  }) async {
    try {
      isLoading = true;
      error = null;
      notifyListeners();

      await _charityService.claimDonation(
        itemId: itemId,
        distributionPlan: distributionPlan,
        beneficiariesCount: beneficiariesCount,
      );

      // Refresh lists
      await loadAvailableDonations();
      await loadPendingDonations();

      isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      error = e.toString();
      isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Accept donation (wrapper method)
  Future<bool> acceptDonation(
    int itemId,
    String distributionPlan,
    int beneficiariesCount,
  ) async {
    return await claimDonation(
      itemId: itemId,
      distributionPlan: distributionPlan,
      beneficiariesCount: beneficiariesCount,
    );
  }

  // Mark donation as distributed
  Future<bool> markAsDistributed({
    required int orderId,
    required int beneficiariesCount,
    String? notes,
  }) async {
    try {
      isLoading = true;
      error = null;
      notifyListeners();

      await _charityService.markAsDistributed(
        orderId: orderId,
        beneficiariesCount: beneficiariesCount,
        notes: notes,
      );

      // Refresh data
      await loadPendingDonations();
      await loadImpactStats();

      isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      error = e.toString();
      isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Mark distributed (wrapper method)
  Future<bool> markDistributed(
    int orderId,
    int beneficiariesCount, {
    String? notes,
  }) async {
    return await markAsDistributed(
      orderId: orderId,
      beneficiariesCount: beneficiariesCount,
      notes: notes,
    );
  }

  // Get impact statistics (wrapper method)
  Future<Map<String, dynamic>> getImpactStats() async {
    return await _charityService.getImpactStats();
  }

  void clearError() {
    error = null;
    notifyListeners();
  }
}