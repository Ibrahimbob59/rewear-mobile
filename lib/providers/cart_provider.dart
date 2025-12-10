import 'package:flutter/foundation.dart';
import '../models/item_model.dart';

class CartItem {
  final Item item;
  final double deliveryFee;

  CartItem({
    required this.item,
    required this.deliveryFee,
  });

  double get totalPrice => (item.price ?? 0) + deliveryFee;
}

class CartProvider with ChangeNotifier {
  final List<CartItem> _cartItems = [];

  // Getters
  List<CartItem> get cartItems => _cartItems;
  
  int get itemCount => _cartItems.length;
  
  bool get isEmpty => _cartItems.isEmpty;
  
  double get subtotal => _cartItems.fold(
        0,
        (sum, cartItem) => sum + (cartItem.item.price ?? 0),
      );
  
  double get totalDeliveryFees => _cartItems.fold(
        0,
        (sum, cartItem) => sum + cartItem.deliveryFee,
      );
  
  double get totalAmount => subtotal + totalDeliveryFees;

  // Check if item is in cart
  bool isInCart(int itemId) {
    return _cartItems.any((cartItem) => cartItem.item.id == itemId);
  }

  // Add item to cart
  bool addToCart(Item item, double deliveryFee) {
    // Check if item already in cart
    if (isInCart(item.id)) {
      return false;
    }

    // Check if item is available for purchase
    if (!item.canPurchase) {
      return false;
    }

    _cartItems.add(CartItem(
      item: item,
      deliveryFee: deliveryFee,
    ));
    
    notifyListeners();
    return true;
  }

  // Remove item from cart
  void removeFromCart(int itemId) {
    _cartItems.removeWhere((cartItem) => cartItem.item.id == itemId);
    notifyListeners();
  }

  // Clear cart
  void clearCart() {
    _cartItems.clear();
    notifyListeners();
  }

  // Get cart item by item id
  CartItem? getCartItem(int itemId) {
    try {
      return _cartItems.firstWhere((cartItem) => cartItem.item.id == itemId);
    } catch (e) {
      return null;
    }
  }

  // Group cart items by seller
  Map<int, List<CartItem>> get itemsBySeller {
    final Map<int, List<CartItem>> grouped = {};
    
    for (var cartItem in _cartItems) {
      final sellerId = cartItem.item.seller.id;
      if (!grouped.containsKey(sellerId)) {
        grouped[sellerId] = [];
      }
      grouped[sellerId]!.add(cartItem);
    }
    
    return grouped;
  }

  // Calculate total for a specific seller
  double getTotalForSeller(int sellerId) {
    final sellerItems = _cartItems.where(
      (cartItem) => cartItem.item.seller.id == sellerId,
    );
    
    return sellerItems.fold(
      0,
      (sum, cartItem) => sum + cartItem.totalPrice,
    );
  }
}