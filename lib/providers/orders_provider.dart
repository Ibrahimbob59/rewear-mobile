import 'package:flutter/foundation.dart';
import '../models/order_model.dart';
import '../services/orders_service.dart';

class OrdersProvider with ChangeNotifier {
  final OrdersService _ordersService;

  OrdersProvider(this._ordersService);

  // State
  List<Order> _buyerOrders = [];
  List<Order> _sellerOrders = [];
  Order? _selectedOrder;
  bool _isLoading = false;
  String? _error;

  // Getters
  List<Order> get buyerOrders => _buyerOrders;
  List<Order> get sellerOrders => _sellerOrders;
  Order? get selectedOrder => _selectedOrder;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Filtered orders
  List<Order> get activeBuyerOrders =>
      _buyerOrders.where((order) => order.isActive).toList();
  
  List<Order> get activeSellerOrders =>
      _sellerOrders.where((order) => order.isActive).toList();

  // Create order
  Future<Order?> createOrder({
    required int itemId,
    required int deliveryAddressId,
    required double deliveryFee,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final order = await _ordersService.createOrder(
        itemId: itemId,
        deliveryAddressId: deliveryAddressId,
        deliveryFee: deliveryFee,
      );

      // Add to buyer orders
      _buyerOrders.insert(0, order);
      
      _error = null;
      notifyListeners();
      return order;
    } catch (e) {
      _error = e.toString();
      debugPrint('Error creating order: $e');
      notifyListeners();
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load buyer orders
  Future<void> loadBuyerOrders() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _buyerOrders = await _ordersService.getBuyerOrders();
      _error = null;
    } catch (e) {
      _error = e.toString();
      debugPrint('Error loading buyer orders: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load seller orders
  Future<void> loadSellerOrders() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _sellerOrders = await _ordersService.getSellerOrders();
      _error = null;
    } catch (e) {
      _error = e.toString();
      debugPrint('Error loading seller orders: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load single order
  Future<void> loadOrder(int id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _selectedOrder = await _ordersService.getOrder(id);
      _error = null;
    } catch (e) {
      _error = e.toString();
      debugPrint('Error loading order: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Cancel order
  Future<bool> cancelOrder(int id, {String? reason}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final updatedOrder = await _ordersService.cancelOrder(id, reason: reason);

      // Update in buyer orders
      final buyerIndex = _buyerOrders.indexWhere((order) => order.id == id);
      if (buyerIndex != -1) {
        _buyerOrders[buyerIndex] = updatedOrder;
      }

      // Update in seller orders
      final sellerIndex = _sellerOrders.indexWhere((order) => order.id == id);
      if (sellerIndex != -1) {
        _sellerOrders[sellerIndex] = updatedOrder;
      }

      // Update selected order
      if (_selectedOrder?.id == id) {
        _selectedOrder = updatedOrder;
      }

      _error = null;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      debugPrint('Error cancelling order: $e');
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Refresh all orders
  Future<void> refreshOrders() async {
    await Future.wait([
      loadBuyerOrders(),
      loadSellerOrders(),
    ]);
  }
}