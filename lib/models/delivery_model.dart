class Delivery {
  final int id;
  final int orderId;
  final int? driverId;
  final String status;
  final double deliveryFee;
  final double? codAmount;
  final String pickupAddress;
  final double pickupLatitude;
  final double pickupLongitude;
  final String deliveryAddress;
  final double deliveryLatitude;
  final double deliveryLongitude;
  final String? pickupProofImage;
  final String? deliveryProofImage;
  final DateTime? pickupTime;
  final DateTime? deliveryTime;
  final String? notes;
  final DateTime createdAt;
  final DateTime? updatedAt;

  // Related data
  final DeliveryDriver? driver;
  final DeliveryOrder? order;

  Delivery({
    required this.id,
    required this.orderId,
    this.driverId,
    required this.status,
    required this.deliveryFee,
    this.codAmount,
    required this.pickupAddress,
    required this.pickupLatitude,
    required this.pickupLongitude,
    required this.deliveryAddress,
    required this.deliveryLatitude,
    required this.deliveryLongitude,
    this.pickupProofImage,
    this.deliveryProofImage,
    this.pickupTime,
    this.deliveryTime,
    this.notes,
    required this.createdAt,
    this.updatedAt,
    this.driver,
    this.order,
  });

  factory Delivery.fromJson(Map<String, dynamic> json) {
    return Delivery(
      id: json['id'] ?? 0,
      orderId: json['order_id'] ?? 0,
      driverId: json['driver_id'],
      status: json['status'] ?? 'pending',
      deliveryFee: (json['delivery_fee'] ?? 0).toDouble(),
      codAmount: json['cod_amount']?.toDouble(),
      pickupAddress: json['pickup_address'] ?? '',
      pickupLatitude: (json['pickup_latitude'] ?? 0).toDouble(),
      pickupLongitude: (json['pickup_longitude'] ?? 0).toDouble(),
      deliveryAddress: json['delivery_address'] ?? '',
      deliveryLatitude: (json['delivery_latitude'] ?? 0).toDouble(),
      deliveryLongitude: (json['delivery_longitude'] ?? 0).toDouble(),
      pickupProofImage: json['pickup_proof_image'],
      deliveryProofImage: json['delivery_proof_image'],
      pickupTime: json['pickup_time'] != null 
          ? DateTime.parse(json['pickup_time']) 
          : null,
      deliveryTime: json['delivery_time'] != null 
          ? DateTime.parse(json['delivery_time']) 
          : null,
      notes: json['notes'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: json['updated_at'] != null 
          ? DateTime.parse(json['updated_at']) 
          : null,
      driver: json['driver'] != null 
          ? DeliveryDriver.fromJson(json['driver']) 
          : null,
      order: json['order'] != null 
          ? DeliveryOrder.fromJson(json['order']) 
          : null,
    );
  }

  String get deliveryFeeDisplay => '\$${deliveryFee.toStringAsFixed(2)}';
  String get codAmountDisplay => codAmount != null 
      ? '\$${codAmount!.toStringAsFixed(2)}' 
      : 'N/A';

  bool get hasDriver => driverId != null;
  bool get isPickedUp => pickupTime != null;
  bool get isDelivered => deliveryTime != null;
}

class DeliveryDriver {
  final int id;
  final String name;
  final String phone;
  final String? profilePicture;
  final String? vehicleType;
  final String? vehicleNumber;
  final double? rating;

  DeliveryDriver({
    required this.id,
    required this.name,
    required this.phone,
    this.profilePicture,
    this.vehicleType,
    this.vehicleNumber,
    this.rating,
  });

  factory DeliveryDriver.fromJson(Map<String, dynamic> json) {
    return DeliveryDriver(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      phone: json['phone'] ?? '',
      profilePicture: json['profile_picture'],
      vehicleType: json['vehicle_type'],
      vehicleNumber: json['vehicle_number'],
      rating: json['rating']?.toDouble(),
    );
  }
}

class DeliveryOrder {
  final int id;
  final String orderNumber;
  final String itemTitle;
  final String? itemImage;
  final String buyerName;
  final String sellerName;

  DeliveryOrder({
    required this.id,
    required this.orderNumber,
    required this.itemTitle,
    this.itemImage,
    required this.buyerName,
    required this.sellerName,
  });

  factory DeliveryOrder.fromJson(Map<String, dynamic> json) {
    return DeliveryOrder(
      id: json['id'] ?? 0,
      orderNumber: json['order_number'] ?? '',
      itemTitle: json['item_title'] ?? '',
      itemImage: json['item_image'],
      buyerName: json['buyer_name'] ?? '',
      sellerName: json['seller_name'] ?? '',
    );
  }
}