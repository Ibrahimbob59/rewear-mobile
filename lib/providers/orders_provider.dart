import 'package:flutter/foundation.dart';
import '../services/orders_service.dart';

class OrdersProvider extends ChangeNotifier {
  final OrdersService _ordersService;

  bool isLoading = false;
  bool isCreatingOrder = false;
  String? error;

  // ALL CHANGED TO Map<String, dynamic>
  List<Map<String, dynamic>> buyerOrders = [];
  List<Map<String, dynamic>> sellerOrders = [];
  Map<String, dynamic>? selectedOrder;

  OrdersProvider(this._ordersService);

  // Create new order
  Future<Map<String, dynamic>?> createOrder({
    required int itemId,
    required int deliveryAddressId,
  }) async {
    try {
      isCreatingOrder = true;
      error = null;
      notifyListeners();

      final orderData = await _ordersService.createOrder(
        itemId: itemId,
        deliveryAddressId: deliveryAddressId,
      );

      isCreatingOrder = false;
      notifyListeners();

      // Return the raw order data
      return orderData;
    } catch (e) {
      error = e.toString();
      isCreatingOrder = false;
      notifyListeners();
      return null;
    }
  }

  // Load buyer orders (orders I placed)
  Future<void> loadBuyerOrders() async {
    try {
      isLoading = true;
      error = null;
      notifyListeners();

      buyerOrders = await _ordersService.getBuyerOrders();

      isLoading = false;
      notifyListeners();
    } catch (e) {
      error = e.toString();
      isLoading = false;
      notifyListeners();
    }
  }

  // Load seller orders (items I sold)
  Future<void> loadSellerOrders() async {
    try {
      isLoading = true;
      error = null;
      notifyListeners();

      sellerOrders = await _ordersService.getSellerOrders();

      isLoading = false;
      notifyListeners();
    } catch (e) {
      error = e.toString();
      isLoading = false;
      notifyListeners();
    }
  }

  // Load all orders
  Future<void> loadAllOrders() async {
    try {
      isLoading = true;
      error = null;
      notifyListeners();

      final orders = await _ordersService.getOrders();
      // For now, put all in buyer orders
      buyerOrders = orders;

      isLoading = false;
      notifyListeners();
    } catch (e) {
      error = e.toString();
      isLoading = false;
      notifyListeners();
    }
  }

  // Load single order details
  Future<void> loadOrder(int orderId) async {
    try {
      isLoading = true;
      error = null;
      notifyListeners();

      selectedOrder = await _ordersService.getOrder(orderId);

      isLoading = false;
      notifyListeners();
    } catch (e) {
      error = e.toString();
      isLoading = false;
      notifyListeners();
    }
  }

  // Cancel order
  Future<bool> cancelOrder(int orderId, String reason) async {
    try {
      isLoading = true;
      error = null;
      notifyListeners();

      await _ordersService.cancelOrder(orderId, reason);

      // Reload orders after cancellation
      await loadBuyerOrders();

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

  // Confirm order
  Future<bool> confirmOrder(int orderId) async {
    try {
      isLoading = true;
      error = null;
      notifyListeners();

      await _ordersService.confirmOrder(orderId);

      // Reload order details
      await loadOrder(orderId);

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

  void clearError() {
    error = null;
    notifyListeners();
  }

  void clearSelectedOrder() {
    selectedOrder = null;
    notifyListeners();
  }
}