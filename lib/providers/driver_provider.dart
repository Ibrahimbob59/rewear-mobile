import 'package:flutter/foundation.dart';
import '../services/driver_service.dart';

class DriverProvider extends ChangeNotifier {
  final DriverService _driverService;

  bool isLoading = false;
  String? error;

  // ALL CHANGED TO Map<String, dynamic>
  Map<String, dynamic>? _applicationData;
  Map<String, dynamic>? dashboardStats;
  List<Map<String, dynamic>> availableDeliveries = [];
  List<Map<String, dynamic>> myDeliveries = [];
  Map<String, dynamic>? earnings;

  DriverProvider(this._driverService);

  // Getters
  Map<String, dynamic>? get applicationData => _applicationData;
  String? get applicationStatus => _applicationData?['status'];
  bool get hasApplication => _applicationData != null;

  // Load my driver application
  Future<void> loadMyApplication() async {
    try {
      isLoading = true;
      error = null;
      notifyListeners();

      final applicationData = await _driverService.getMyApplication();
      
      // Store as raw data instead of Driver object
      _applicationData = applicationData;

      isLoading = false;
      notifyListeners();
    } catch (e) {
      error = e.toString();
      isLoading = false;
      notifyListeners();
    }
  }

  // Check driver eligibility
  Future<Map<String, dynamic>?> checkEligibility() async {
    try {
      isLoading = true;
      error = null;
      notifyListeners();

      final eligibility = await _driverService.checkEligibility();

      isLoading = false;
      notifyListeners();
      return eligibility;
    } catch (e) {
      error = e.toString();
      isLoading = false;
      notifyListeners();
      return null;
    }
  }

  // Load driver dashboard
  Future<void> loadDashboard() async {
    try {
      isLoading = true;
      error = null;
      notifyListeners();

      dashboardStats = await _driverService.getDashboard();

      isLoading = false;
      notifyListeners();
    } catch (e) {
      error = e.toString();
      isLoading = false;
      notifyListeners();
    }
  }

  // Load available deliveries
  Future<void> loadAvailableDeliveries() async {
    try {
      isLoading = true;
      error = null;
      notifyListeners();

      availableDeliveries = await _driverService.getAvailableDeliveries();

      isLoading = false;
      notifyListeners();
    } catch (e) {
      error = e.toString();
      isLoading = false;
      notifyListeners();
    }
  }

  // Load my deliveries
  Future<void> loadMyDeliveries({String? status}) async {
    try {
      isLoading = true;
      error = null;
      notifyListeners();

      myDeliveries = await _driverService.getMyDeliveries(status: status);

      isLoading = false;
      notifyListeners();
    } catch (e) {
      error = e.toString();
      isLoading = false;
      notifyListeners();
    }
  }

  // Accept delivery
  Future<bool> acceptDelivery(int deliveryId) async {
    try {
      isLoading = true;
      error = null;
      notifyListeners();

      await _driverService.acceptDelivery(deliveryId);
      
      // Reload dashboard and deliveries
      await loadDashboard();
      await loadAvailableDeliveries();
      await loadMyDeliveries();

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

  // Load earnings
  Future<void> loadEarnings({String? period}) async {
    try {
      isLoading = true;
      error = null;
      notifyListeners();

      earnings = await _driverService.getEarnings(period: period);

      isLoading = false;
      notifyListeners();
    } catch (e) {
      error = e.toString();
      isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    error = null;
    notifyListeners();
  }
}