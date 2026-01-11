import 'package:flutter/material.dart';
import '../models/charity_model.dart';
import '../services/charity_service.dart';

class CharityProvider with ChangeNotifier {
  final CharityService _charityService;

  CharityProvider(this._charityService);

  Charity? _charity;
  Map<String, dynamic>? _dashboard;
  List<DonatedItem> _availableDonations = [];
  List<DonatedItem> _myDonations = [];
  Map<String, dynamic>? _impactStats;
  bool _isLoading = false;
  String? _error;

  Charity? get charity => _charity;
  Map<String, dynamic>? get dashboard => _dashboard;
  List<DonatedItem> get availableDonations => _availableDonations;
  List<DonatedItem> get myDonations => _myDonations;
  List<DonatedItem> get pendingDonations => _availableDonations;
  List<DonatedItem> get acceptedDonations => _myDonations;
  Map<String, dynamic>? get impactStats => _impactStats;
  bool get isLoading => _isLoading;
  String? get error => _error;

  bool get isCharity => _charity != null || _dashboard != null;
  int get pendingCount => _availableDonations.length;
  int get acceptedCount => _myDonations.length;

  Future<void> loadDashboard() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _dashboard = await _charityService.getDashboard();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _dashboard = null;
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadCharityProfile() async {
    await loadDashboard();
  }

  Future<void> loadAvailableDonations() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _availableDonations = await _charityService.getAvailableDonations();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadPendingDonations() async {
    await loadAvailableDonations();
  }

  Future<void> loadMyDonations() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _myDonations = await _charityService.getMyDonations();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadAcceptedDonations() async {
    await loadMyDonations();
  }

  Future<bool> acceptDonation(int itemId) async {
    try {
      final donation = await _charityService.acceptDonation(itemId);
      
      _availableDonations.removeWhere((d) => d.id == itemId);
      _myDonations.insert(0, donation);
      
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> rejectDonation(int donationId, {String? reason}) async {
    _availableDonations.removeWhere((d) => d.id == donationId);
    notifyListeners();
    return true;
  }

  Future<void> markDistributed(int orderId) async {
    try {
      await _charityService.markDistributed(orderId);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

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
