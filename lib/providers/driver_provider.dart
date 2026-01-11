import 'dart:io';
import 'package:flutter/material.dart';
import '../models/driver_model.dart';
import '../services/driver_service.dart';

class DriverProvider with ChangeNotifier {
  final DriverService _driverService;

  DriverProvider(this._driverService);

  Driver? _driver;
  Map<String, dynamic>? _dashboard;
  Map<String, dynamic>? _earnings;
  Map<String, dynamic>? _application;
  bool _isLoading = false;
  String? _error;

  Driver? get driver => _driver;
  Map<String, dynamic>? get dashboard => _dashboard;
  Map<String, dynamic>? get earnings => _earnings;
  Map<String, dynamic>? get application => _application;
  bool get isLoading => _isLoading;
  String? get error => _error;

  bool get isDriver => _driver != null;
  bool get isPending => _driver?.isPending ?? false;
  bool get isApproved => _driver?.isApproved ?? false;
  bool get isAvailable => _driver?.isAvailable ?? false;
  bool get isRejected => _driver?.isRejected ?? false;

  Future<bool> applyAsDriver({
    required String vehicleType,
    required String vehicleNumber,
    required String licenseNumber,
    required File licenseImage,
    required File vehicleImage,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _driver = await _driverService.applyAsDriver(
        vehicleType: vehicleType,
        vehicleNumber: vehicleNumber,
        licenseNumber: licenseNumber,
        licenseImage: licenseImage,
        vehicleImage: vehicleImage,
      );
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> loadDashboard() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _dashboard = await _driverService.getDashboard();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _dashboard = null;
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadMyApplication() async {
    try {
      _application = await _driverService.getMyApplication();
      notifyListeners();
    } catch (e) {
      print('Error loading application: $e');
    }
  }

  Future<Map<String, dynamic>?> checkEligibility() async {
    try {
      return await _driverService.checkEligibility();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return null;
    }
  }

  Future<void> loadEarnings({String? period}) async {
    _isLoading = true;
    notifyListeners();

    try {
      _earnings = await _driverService.getEarnings(period: period);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
