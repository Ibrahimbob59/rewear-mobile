import 'address_model.dart';
import 'order_status_enum.dart';

class OrderUser {
  final int id;
  final String name;
  final String? phone;
  final String? profilePicture;

  OrderUser({
    required this.id,
    required this.name,
    this.phone,
    this.profilePicture,
  });

  factory OrderUser.fromJson(Map<String, dynamic> json) {
    return OrderUser(
      id: json['id'] as int,
      name: json['name'] as String,
      phone: json['phone'] as String?,
      profilePicture: json['profile_picture'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'profile_picture': profilePicture,
    };
  }
}

class OrderItem {
  final int id;
  final String title;
  final String? image;
  final double price;

  OrderItem({
    required this.id,
    required this.title,
    this.image,
    required this.price,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      id: json['id'] as int,
      title: json['title'] as String,
      image: json['image'] as String?,
      price: json['price'] != null 
          ? double.tryParse(json['price'].toString()) ?? 0.0 
          : 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'image': image,
      'price': price,
    };
  }
}

class Order {
  final int id;
  final String orderNumber;
  final OrderItem item;
  final OrderUser buyer;
  final OrderUser seller;
  final Address? deliveryAddress;
  final double itemPrice;
  final double deliveryFee;
  final double totalAmount;
  final OrderStatus status;
  final String paymentMethod;
  final String paymentStatus;
  final DateTime? confirmedAt;
  final DateTime? deliveredAt;
  final DateTime? cancelledAt;
  final String? cancellationReason;
  final DateTime createdAt;
  final DateTime updatedAt;

  Order({
    required this.id,
    required this.orderNumber,
    required this.item,
    required this.buyer,
    required this.seller,
    this.deliveryAddress,
    required this.itemPrice,
    required this.deliveryFee,
    required this.totalAmount,
    required this.status,
    required this.paymentMethod,
    required this.paymentStatus,
    this.confirmedAt,
    this.deliveredAt,
    this.cancelledAt,
    this.cancellationReason,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'] as int,
      orderNumber: json['order_number'] as String,
      item: OrderItem.fromJson(json['item'] as Map<String, dynamic>),
      buyer: OrderUser.fromJson(json['buyer'] as Map<String, dynamic>),
      seller: OrderUser.fromJson(json['seller'] as Map<String, dynamic>),
      deliveryAddress: json['delivery_address'] != null 
          ? Address.fromJson(json['delivery_address'] as Map<String, dynamic>) 
          : null,
      itemPrice: double.tryParse(json['item_price'].toString()) ?? 0.0,
      deliveryFee: double.tryParse(json['delivery_fee'].toString()) ?? 0.0,
      totalAmount: double.tryParse(json['total_amount'].toString()) ?? 0.0,
      status: OrderStatus.fromString(json['status'] as String),
      paymentMethod: json['payment_method'] as String,
      paymentStatus: json['payment_status'] as String,
      confirmedAt: json['confirmed_at'] != null 
          ? DateTime.parse(json['confirmed_at'] as String) 
          : null,
      deliveredAt: json['delivered_at'] != null 
          ? DateTime.parse(json['delivered_at'] as String) 
          : null,
      cancelledAt: json['cancelled_at'] != null 
          ? DateTime.parse(json['cancelled_at'] as String) 
          : null,
      cancellationReason: json['cancellation_reason'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'order_number': orderNumber,
      'item': item.toJson(),
      'buyer': buyer.toJson(),
      'seller': seller.toJson(),
      'delivery_address': deliveryAddress?.toJson(),
      'item_price': itemPrice,
      'delivery_fee': deliveryFee,
      'total_amount': totalAmount,
      'status': status.value,
      'payment_method': paymentMethod,
      'payment_status': paymentStatus,
      'confirmed_at': confirmedAt?.toIso8601String(),
      'delivered_at': deliveredAt?.toIso8601String(),
      'cancelled_at': cancelledAt?.toIso8601String(),
      'cancellation_reason': cancellationReason,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  // Helper getters
  bool get canCancel => status.canCancel;
  bool get isActive => status.isActive;
  bool get isCancelled => status == OrderStatus.cancelled;
  bool get isCompleted => status == OrderStatus.completed;

  String get statusText => status.displayName;
  String get statusDescription => status.description;

  String get totalAmountDisplay => '\$${totalAmount.toStringAsFixed(2)}';
  String get itemPriceDisplay => '\$${itemPrice.toStringAsFixed(2)}';
  String get deliveryFeeDisplay => '\$${deliveryFee.toStringAsFixed(2)}';

  // Copy with method
  Order copyWith({
    int? id,
    String? orderNumber,
    OrderItem? item,
    OrderUser? buyer,
    OrderUser? seller,
    Address? deliveryAddress,
    double? itemPrice,
    double? deliveryFee,
    double? totalAmount,
    OrderStatus? status,
    String? paymentMethod,
    String? paymentStatus,
    DateTime? confirmedAt,
    DateTime? deliveredAt,
    DateTime? cancelledAt,
    String? cancellationReason,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Order(
      id: id ?? this.id,
      orderNumber: orderNumber ?? this.orderNumber,
      item: item ?? this.item,
      buyer: buyer ?? this.buyer,
      seller: seller ?? this.seller,
      deliveryAddress: deliveryAddress ?? this.deliveryAddress,
      itemPrice: itemPrice ?? this.itemPrice,
      deliveryFee: deliveryFee ?? this.deliveryFee,
      totalAmount: totalAmount ?? this.totalAmount,
      status: status ?? this.status,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      confirmedAt: confirmedAt ?? this.confirmedAt,
      deliveredAt: deliveredAt ?? this.deliveredAt,
      cancelledAt: cancelledAt ?? this.cancelledAt,
      cancellationReason: cancellationReason ?? this.cancellationReason,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}