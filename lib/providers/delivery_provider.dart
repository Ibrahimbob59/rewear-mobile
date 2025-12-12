import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import '../models/delivery_model.dart';
import '../services/delivery_service.dart';
import '../services/location_service.dart';
import 'package:geolocator/geolocator.dart';

class DeliveryProvider with ChangeNotifier {
  final DeliveryService _deliveryService;
  final LocationService _locationService;

  DeliveryProvider(this._deliveryService, this._locationService);

  List<Delivery> _availableDeliveries = [];
  List<Delivery> _activeDeliveries = [];
  List<Delivery> _deliveryHistory = [];
  Delivery? _selectedDelivery;
  bool _isLoading = false;
  bool _isLoadingMore = false;
  String? _error;

  // Location tracking
  StreamSubscription<Position>? _locationSubscription;
  Position? _currentPosition;

  List<Delivery> get availableDeliveries => _availableDeliveries;
  List<Delivery> get activeDeliveries => _activeDeliveries;
  List<Delivery> get deliveryHistory => _deliveryHistory;
  Delivery? get selectedDelivery => _selectedDelivery;
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  String? get error => _error;
  Position? get currentPosition => _currentPosition;

  bool get hasActiveDelivery => _activeDeliveries.isNotEmpty;

  @override
  void dispose() {
    _locationSubscription?.cancel();
    super.dispose();
  }

  // Load available deliveries
  Future<void> loadAvailableDeliveries() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _availableDeliveries = await _deliveryService.getAvailableDeliveries();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load active deliveries
  Future<void> loadActiveDeliveries() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _activeDeliveries = await _deliveryService.getActiveDeliveries();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load delivery history
  Future<void> loadDeliveryHistory({int page = 1}) async {
    if (page == 1) {
      _isLoading = true;
    } else {
      _isLoadingMore = true;
    }
    _error = null;
    notifyListeners();

    try {
      final history = await _deliveryService.getDeliveryHistory(page: page);
      
      if (page == 1) {
        _deliveryHistory = history;
      } else {
        _deliveryHistory.addAll(history);
      }
      
      _isLoading = false;
      _isLoadingMore = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  // Accept delivery
  Future<bool> acceptDelivery(int deliveryId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final delivery = await _deliveryService.acceptDelivery(deliveryId);
      
      // Remove from available
      _availableDeliveries.removeWhere((d) => d.id == deliveryId);
      
      // Add to active
      _activeDeliveries.add(delivery);
      _selectedDelivery = delivery;
      
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

  // Confirm pickup
  Future<bool> confirmPickup({
    required int deliveryId,
    required File proofImage,
    String? notes,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final delivery = await _deliveryService.confirmPickup(
        deliveryId: deliveryId,
        proofImage: proofImage,
        notes: notes,
      );
      
      // Update in active deliveries
      final index = _activeDeliveries.indexWhere((d) => d.id == deliveryId);
      if (index != -1) {
        _activeDeliveries[index] = delivery;
      }
      
      _selectedDelivery = delivery;
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

  // Confirm delivery
  Future<bool> confirmDelivery({
    required int deliveryId,
    required File proofImage,
    double? codCollected,
    String? notes,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final delivery = await _deliveryService.confirmDelivery(
        deliveryId: deliveryId,
        proofImage: proofImage,
        codCollected: codCollected,
        notes: notes,
      );
      
      // Remove from active
      _activeDeliveries.removeWhere((d) => d.id == deliveryId);
      
      // Add to history
      _deliveryHistory.insert(0, delivery);
      
      _selectedDelivery = null;
      
      // Stop location tracking
      stopLocationTracking();
      
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

  // Start location tracking
  Future<void> startLocationTracking(int deliveryId) async {
    try {
      // Get initial position
      _currentPosition = await _locationService.getCurrentLocation();
      
      // Send initial location
      await _deliveryService.updateLocation(
        deliveryId: deliveryId,
        latitude: _currentPosition!.latitude,
        longitude: _currentPosition!.longitude,
      );
      
      // Start listening to location updates
      _locationSubscription = _locationService.getLocationStream().listen(
        (position) async {
          _currentPosition = position;
          notifyListeners();
          
          // Update location on server
          try {
            await _deliveryService.updateLocation(
              deliveryId: deliveryId,
              latitude: position.latitude,
              longitude: position.longitude,
            );
          } catch (e) {
            print('Error updating location: $e');
          }
        },
      );
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  // Stop location tracking
  void stopLocationTracking() {
    _locationSubscription?.cancel();
    _locationSubscription = null;
    _currentPosition = null;
    notifyListeners();
  }

  // Load delivery by ID
  Future<void> loadDelivery(int deliveryId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _selectedDelivery = await _deliveryService.getDelivery(deliveryId);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Track delivery (for buyers/sellers)
  Future<void> trackDelivery(int orderId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _selectedDelivery = await _deliveryService.trackDelivery(orderId);
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

  void clearSelectedDelivery() {
    _selectedDelivery = null;
    notifyListeners();
  }
}