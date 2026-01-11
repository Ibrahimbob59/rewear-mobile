import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../models/delivery_model.dart';
import '../services/delivery_service.dart';
import '../services/location_service.dart';

class DeliveryProvider with ChangeNotifier {
  final DeliveryService _deliveryService;
  final LocationService _locationService;

  DeliveryProvider(this._deliveryService, this._locationService);

  // State
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

  // Getters
  List<Delivery> get availableDeliveries => _availableDeliveries;
  List<Delivery> get activeDeliveries => _activeDeliveries;
  List<Delivery> get deliveryHistory => _deliveryHistory;
  Delivery? get selectedDelivery => _selectedDelivery;
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  String? get error => _error;
  Position? get currentPosition => _currentPosition;

  // Load available deliveries
  Future<void> loadAvailableDeliveries() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

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
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

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
    try {
      if (page == 1) {
        _isLoading = true;
        _deliveryHistory = [];
      } else {
        _isLoadingMore = true;
      }
      _error = null;
      notifyListeners();

      final newDeliveries = await _deliveryService.getDeliveryHistory(page: page);
      
      if (page == 1) {
        _deliveryHistory = newDeliveries;
      } else {
        _deliveryHistory.addAll(newDeliveries);
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

  // Load single delivery
  Future<void> loadDelivery(int id) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _selectedDelivery = await _deliveryService.getDelivery(id);
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Accept delivery
  Future<bool> acceptDelivery(int deliveryId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final delivery = await _deliveryService.acceptDelivery(deliveryId);
      
      // Remove from available, add to active
      _availableDeliveries.removeWhere((d) => d.id == deliveryId);
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
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

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
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final delivery = await _deliveryService.confirmDelivery(
        deliveryId: deliveryId,
        proofImage: proofImage,
        codCollected: codCollected,
        notes: notes,
      );
      
      // Remove from active deliveries
      _activeDeliveries.removeWhere((d) => d.id == deliveryId);
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

  // Cancel delivery (only before pickup)
  Future<bool> cancelDelivery({
    required int deliveryId,
    required String reason,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final delivery = await _deliveryService.cancelDelivery(
        deliveryId: deliveryId,
        reason: reason,
      );
      
      // Remove from active deliveries
      _activeDeliveries.removeWhere((d) => d.id == deliveryId);
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

  // Check if delivery can be cancelled
  bool canCancelDelivery(Delivery delivery) {
    return delivery.canBeCancelled;
  }

  // Track delivery for order
  Future<void> trackDelivery(int orderId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _selectedDelivery = await _deliveryService.trackDelivery(orderId);
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Location tracking
  Future<void> startLocationTracking(int deliveryId) async {
    try {
      _locationSubscription?.cancel();
      
      final hasPermission = await _locationService.requestPermission();
      if (hasPermission == false) {  // ✅ FIXED - was !hasPermission
        _error = 'Location permission denied';
        notifyListeners();
        return;
      }

      _locationSubscription = Geolocator.getPositionStream(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 10,
        ),
      ).listen((Position position) {
        _currentPosition = position;
        notifyListeners();
      });
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  void stopLocationTracking() {
    _locationSubscription?.cancel();
    _locationSubscription = null;
    _currentPosition = null;
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  @override
  void dispose() {
    stopLocationTracking();
    super.dispose();
  }
}