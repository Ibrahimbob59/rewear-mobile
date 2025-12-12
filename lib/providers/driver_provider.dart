import 'dart:io';
import 'package:flutter/material.dart';
import '../models/driver_model.dart';
import '../services/driver_service.dart';

class DriverProvider with ChangeNotifier {
  final DriverService _driverService;

  DriverProvider(this._driverService);

  Driver? _driver;
  Map<String, dynamic>? _stats;
  Map<String, dynamic>? _earnings;
  bool _isLoading = false;
  String? _error;

  Driver? get driver => _driver;
  Map<String, dynamic>? get stats => _stats;
  Map<String, dynamic>? get earnings => _earnings;
  bool get isLoading => _isLoading;
  String? get error => _error;

  bool get isDriver => _driver != null;
  bool get isPending => _driver?.isPending ?? false;
  bool get isApproved => _driver?.isApproved ?? false;
  bool get isAvailable => _driver?.isAvailable ?? false;

  // Apply as driver
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

  // Load driver profile
  Future<void> loadDriverProfile() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _driver = await _driverService.getDriverProfile();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _driver = null;
      _isLoading = false;
      notifyListeners();
    }
  }

  // Toggle availability
  Future<bool> toggleAvailability() async {
    if (_driver == null) return false;

    try {
      _driver = await _driverService.toggleAvailability(!_driver!.isAvailable);
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Load stats
  Future<void> loadStats() async {
    try {
      _stats = await _driverService.getDriverStats();
      notifyListeners();
    } catch (e) {
      print('Error loading stats: $e');
    }
  }

  // Load earnings
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