import 'package:flutter/material.dart';
import '../models/charity_model.dart';
import '../services/charity_service.dart';

class CharityProvider with ChangeNotifier {
  final CharityService _charityService;

  CharityProvider(this._charityService);

  Charity? _charity;
  List<DonatedItem> _pendingDonations = [];
  List<DonatedItem> _acceptedDonations = [];
  Map<String, dynamic>? _impactStats;
  bool _isLoading = false;
  String? _error;

  Charity? get charity => _charity;
  List<DonatedItem> get pendingDonations => _pendingDonations;
  List<DonatedItem> get acceptedDonations => _acceptedDonations;
  Map<String, dynamic>? get impactStats => _impactStats;
  bool get isLoading => _isLoading;
  String? get error => _error;

  bool get isCharity => _charity != null;
  int get pendingCount => _pendingDonations.length;
  int get acceptedCount => _acceptedDonations.length;

  // Load charity profile
  Future<void> loadCharityProfile() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _charity = await _charityService.getCharityProfile();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _charity = null;
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load pending donations
  Future<void> loadPendingDonations() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _pendingDonations = await _charityService.getPendingDonations();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load accepted donations
  Future<void> loadAcceptedDonations() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _acceptedDonations = await _charityService.getAcceptedDonations();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Accept donation
  Future<bool> acceptDonation(int donationId) async {
    try {
      final donation = await _charityService.acceptDonation(donationId);
      
      // Remove from pending
      _pendingDonations.removeWhere((d) => d.id == donationId);
      
      // Add to accepted
      _acceptedDonations.insert(0, donation);
      
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Reject donation
  Future<bool> rejectDonation(int donationId, {String? reason}) async {
    try {
      await _charityService.rejectDonation(donationId, reason: reason);
      
      // Remove from pending
      _pendingDonations.removeWhere((d) => d.id == donationId);
      
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Load impact stats
  Future<void> loadImpactStats() async {
    try {
      _impactStats = await _charityService.getImpactStats();
      notifyListeners();
    } catch (e) {
      print('Error loading impact stats: $e');
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}