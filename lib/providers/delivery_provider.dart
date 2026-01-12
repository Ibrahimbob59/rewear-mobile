import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

import '../services/delivery_service.dart';
import '../services/location_service.dart';

class DeliveryProvider extends ChangeNotifier {
  final DeliveryService _deliveryService;
  final LocationService _locationService;

  bool isLoading = false;
  String? error;

  // ALL CHANGED TO Map<String, dynamic>
  List<Map<String, dynamic>> availableDeliveries = [];
  List<Map<String, dynamic>> activeDeliveries = [];
  List<Map<String, dynamic>> _deliveryHistory = [];
  Map<String, dynamic>? currentDelivery;
  Map<String, dynamic>? _currentDeliveryData;

  // ✅ OLD SIGNATURE (2 args) RESTORED
  DeliveryProvider(this._deliveryService, this._locationService);

  List<Map<String, dynamic>> get deliveryHistory => _deliveryHistory;

  // Optional getter if you need it elsewhere
  Map<String, dynamic>? get currentDeliveryData => _currentDeliveryData;

  // Load available deliveries for drivers
  Future<void> loadAvailableDeliveries() async {
    try {
      isLoading = true;
      error = null;
      notifyListeners();

      availableDeliveries = await _deliveryService.getAvailableDeliveries();

      isLoading = false;
      notifyListeners();
    } catch (e) {
      error = e.toString();
      isLoading = false;
      notifyListeners();
    }
  }

  // Load active deliveries for current driver
  Future<void> loadActiveDeliveries() async {
    try {
      isLoading = true;
      error = null;
      notifyListeners();

      activeDeliveries = await _deliveryService.getActiveDeliveries();

      isLoading = false;
      notifyListeners();
    } catch (e) {
      error = e.toString();
      isLoading = false;
      notifyListeners();
    }
  }

  // Load delivery history
  Future<void> loadDeliveryHistory() async {
    try {
      isLoading = true;
      error = null;
      notifyListeners();

      _deliveryHistory = await _deliveryService.getDeliveryHistory();

      isLoading = false;
      notifyListeners();
    } catch (e) {
      error = e.toString();
      isLoading = false;
      notifyListeners();
    }
  }

  // Load more history (pagination)
  Future<void> loadMoreHistory() async {
    try {
      if (isLoading) return;

      isLoading = true;
      notifyListeners();

      final moreHistory = await _deliveryService.getDeliveryHistory();
      _deliveryHistory.addAll(moreHistory);

      isLoading = false;
      notifyListeners();
    } catch (e) {
      error = e.toString();
      isLoading = false;
      notifyListeners();
    }
  }

  // Load single delivery details
  Future<void> loadDelivery(int deliveryId) async {
    try {
      isLoading = true;
      error = null;
      notifyListeners();

      currentDelivery = await _deliveryService.getDelivery(deliveryId);
      _currentDeliveryData = currentDelivery;

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

      await _deliveryService.acceptDelivery(deliveryId);

      // Reload active deliveries and current delivery
      await loadActiveDeliveries();
      await loadDelivery(deliveryId);

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

  // Confirm pickup
  Future<bool> confirmPickup(
    int deliveryId, {
    String? proofImage,
    String? notes,
  }) async {
    try {
      isLoading = true;
      error = null;
      notifyListeners();

      await _deliveryService.confirmPickup(deliveryId);

      // Reload delivery details
      currentDelivery = await _deliveryService.getDelivery(deliveryId);
      _currentDeliveryData = currentDelivery;
      await loadActiveDeliveries();

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

  // Confirm delivery
  Future<bool> confirmDelivery(
    int deliveryId, {
    String? proofImage,
    double? codCollected,
    String? notes,
  }) async {
    try {
      isLoading = true;
      error = null;
      notifyListeners();

      await _deliveryService.confirmDelivery(deliveryId, notes: notes);

      // Reload delivery details
      currentDelivery = await _deliveryService.getDelivery(deliveryId);
      _currentDeliveryData = currentDelivery;
      await loadActiveDeliveries();

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

  // Cancel delivery
  Future<bool> cancelDelivery(
    int deliveryId, {
    required String reason,
  }) async {
    try {
      isLoading = true;
      error = null;
      notifyListeners();

      await _deliveryService.cancelDelivery(deliveryId, reason);

      // Clear current delivery
      currentDelivery = null;
      _currentDeliveryData = null;

      // Reload lists
      await loadActiveDeliveries();
      await loadAvailableDeliveries();

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

  // Track delivery (real-time)
  Future<void> trackDelivery(int deliveryId) async {
    try {
      currentDelivery = await _deliveryService.trackDelivery(deliveryId);
      _currentDeliveryData = currentDelivery;
      notifyListeners();
    } catch (e) {
      error = e.toString();
      notifyListeners();
    }
  }

  // Get current location
  Future<Position?> getCurrentLocation() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        permission = await Geolocator.requestPermission();

        if (permission == LocationPermission.denied ||
            permission == LocationPermission.deniedForever) {
          error = 'Location permission denied';
          notifyListeners();
          return null;
        }
      }

      return await Geolocator.getCurrentPosition();
    } catch (e) {
      error = e.toString();
      notifyListeners();
      return null;
    }
  }

  void clearError() {
    error = null;
    notifyListeners();
  }

  void clearCurrentDelivery() {
    currentDelivery = null;
    _currentDeliveryData = null;
    notifyListeners();
  }
}
