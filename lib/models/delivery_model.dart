class Delivery {
  final int id;
  final int orderId;
  final int? driverId;
  final String status;
  final double deliveryFee;
  final double driverEarning;
  final double platformFee;
  final String? pickupAddress;
  final double? pickupLatitude;
  final double? pickupLongitude;
  final String? deliveryAddress;
  final double? deliveryLatitude;
  final double? deliveryLongitude;
  final double? distanceKm;
  final double? codAmount;  // ✅ ADDED
  final DateTime? assignedAt;
  final DateTime? pickedUpAt;
  final DateTime? deliveredAt;
  final String? deliveryNotes;
  final String? failureReason;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Related data
  final DeliveryDriver? driver;
  final DeliveryOrder? order;

  Delivery({
    required this.id,
    required this.orderId,
    this.driverId,
    required this.status,
    required this.deliveryFee,
    required this.driverEarning,
    required this.platformFee,
    this.pickupAddress,
    this.pickupLatitude,
    this.pickupLongitude,
    this.deliveryAddress,
    this.deliveryLatitude,
    this.deliveryLongitude,
    this.distanceKm,
    this.codAmount,  // ✅ ADDED
    this.assignedAt,
    this.pickedUpAt,
    this.deliveredAt,
    this.deliveryNotes,
    this.failureReason,
    required this.createdAt,
    required this.updatedAt,
    this.driver,
    this.order,
  });

  factory Delivery.fromJson(Map<String, dynamic> json) {
    return Delivery(
      id: json['id'] as int,
      orderId: json['order_id'] as int? ?? json['order']?['id'] as int,
      driverId: json['driver_id'] as int?,
      status: json['status'] as String? ?? 'pending',
      deliveryFee: double.tryParse(json['delivery_fee'].toString()) ?? 0.0,
      driverEarning: double.tryParse(json['driver_earning'].toString()) ?? 0.0,
      platformFee: double.tryParse(json['platform_fee'].toString()) ?? 0.0,
      pickupAddress: json['pickup_address'] as String?,
      pickupLatitude: json['pickup_latitude'] != null
          ? double.tryParse(json['pickup_latitude'].toString())
          : json['pickup_coordinates']?['latitude'] != null
              ? double.tryParse(json['pickup_coordinates']['latitude'].toString())
              : null,
      pickupLongitude: json['pickup_longitude'] != null
          ? double.tryParse(json['pickup_longitude'].toString())
          : json['pickup_coordinates']?['longitude'] != null
              ? double.tryParse(json['pickup_coordinates']['longitude'].toString())
              : null,
      deliveryAddress: json['delivery_address'] as String?,
      deliveryLatitude: json['delivery_latitude'] != null
          ? double.tryParse(json['delivery_latitude'].toString())
          : json['delivery_coordinates']?['latitude'] != null
              ? double.tryParse(json['delivery_coordinates']['latitude'].toString())
              : null,
      deliveryLongitude: json['delivery_longitude'] != null
          ? double.tryParse(json['delivery_longitude'].toString())
          : json['delivery_coordinates']?['longitude'] != null
              ? double.tryParse(json['delivery_coordinates']['longitude'].toString())
              : null,
      distanceKm: json['distance_km'] != null
          ? double.tryParse(json['distance_km'].toString())
          : null,
      codAmount: json['cod_amount'] != null  // ✅ ADDED
          ? double.tryParse(json['cod_amount'].toString())
          : null,
      assignedAt: json['assigned_at'] != null
          ? DateTime.parse(json['assigned_at'] as String)
          : json['timeline']?['assigned_at'] != null
              ? DateTime.parse(json['timeline']['assigned_at'] as String)
              : null,
      pickedUpAt: json['picked_up_at'] != null
          ? DateTime.parse(json['picked_up_at'] as String)
          : json['timeline']?['picked_up_at'] != null
              ? DateTime.parse(json['timeline']['picked_up_at'] as String)
              : null,
      deliveredAt: json['delivered_at'] != null
          ? DateTime.parse(json['delivered_at'] as String)
          : json['timeline']?['delivered_at'] != null
              ? DateTime.parse(json['timeline']['delivered_at'] as String)
              : null,
      deliveryNotes: json['delivery_notes'] as String?,
      failureReason: json['failure_reason'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      driver: json['driver'] != null
          ? DeliveryDriver.fromJson(json['driver'] as Map<String, dynamic>)
          : null,
      order: json['order'] != null
          ? DeliveryOrder.fromJson(json['order'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'order_id': orderId,
      'driver_id': driverId,
      'status': status,
      'delivery_fee': deliveryFee,
      'driver_earning': driverEarning,
      'platform_fee': platformFee,
      'pickup_address': pickupAddress,
      'pickup_latitude': pickupLatitude,
      'pickup_longitude': pickupLongitude,
      'delivery_address': deliveryAddress,
      'delivery_latitude': deliveryLatitude,
      'delivery_longitude': deliveryLongitude,
      'distance_km': distanceKm,
      'cod_amount': codAmount,  // ✅ ADDED
      'assigned_at': assignedAt?.toIso8601String(),
      'picked_up_at': pickedUpAt?.toIso8601String(),
      'delivered_at': deliveredAt?.toIso8601String(),
      'delivery_notes': deliveryNotes,
      'failure_reason': failureReason,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  // Getters
  String get deliveryFeeDisplay => '\$${deliveryFee.toStringAsFixed(2)}';
  String get driverEarningDisplay => '\$${driverEarning.toStringAsFixed(2)}';
  String get codAmountDisplay => codAmount != null   // ✅ ADDED
      ? '\$${codAmount!.toStringAsFixed(2)}' 
      : 'N/A';
  
  bool get hasDriver => driverId != null;
  bool get isPickedUp => pickedUpAt != null;
  bool get isDelivered => deliveredAt != null;
  bool get isPending => status == 'pending';
  bool get isAssigned => status == 'assigned';
  bool get isInTransit => status == 'in_transit';
  bool get isCancelled => status == 'cancelled';
  
  // Aliases for compatibility ✅ ADDED
  DateTime? get pickupTime => pickedUpAt;
  DateTime? get deliveryTime => deliveredAt;
  
  // Can cancel only before pickup
  bool get canBeCancelled => pickedUpAt == null && (status == 'pending' || status == 'assigned');
}

class DeliveryDriver {
  final int id;
  final String name;
  final String? phone;
  final String? profilePicture;
  final String? vehicleType;
  final String? vehicleNumber;
  final double? rating;

  DeliveryDriver({
    required this.id,
    required this.name,
    this.phone,
    this.profilePicture,
    this.vehicleType,
    this.vehicleNumber,
    this.rating,
  });

  factory DeliveryDriver.fromJson(Map<String, dynamic> json) {
    return DeliveryDriver(
      id: json['id'] as int,
      name: json['name'] as String? ?? '',
      phone: json['phone'] as String?,
      profilePicture: json['profile_picture'] as String?,
      vehicleType: json['vehicle_type'] as String?,
      vehicleNumber: json['vehicle_number'] as String?,
      rating: json['rating'] != null ? double.tryParse(json['rating'].toString()) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'profile_picture': profilePicture,
      'vehicle_type': vehicleType,
      'vehicle_number': vehicleNumber,
      'rating': rating,
    };
  }
}

class DeliveryOrder {
  final int id;
  final String orderNumber;
  final String itemTitle;
  final String? itemImage;
  final String buyerName;
  final String? buyerPhone;
  final String sellerName;
  final String? sellerPhone;
  final String? pickupAddress;   // ✅ ADDED
  final String? deliveryAddress;  // ✅ ADDED
  final double? totalAmount;
  final bool isDonation;

  DeliveryOrder({
    required this.id,
    required this.orderNumber,
    required this.itemTitle,
    this.itemImage,
    required this.buyerName,
    this.buyerPhone,
    required this.sellerName,
    this.sellerPhone,
    this.pickupAddress,    // ✅ ADDED
    this.deliveryAddress,  // ✅ ADDED
    this.totalAmount,
    this.isDonation = false,
  });

  factory DeliveryOrder.fromJson(Map<String, dynamic> json) {
    return DeliveryOrder(
      id: json['id'] as int,
      orderNumber: json['order_number'] as String? ?? '',
      itemTitle: json['item_title'] as String? ?? json['item']?['title'] as String? ?? '',
      itemImage: json['item_image'] as String? ?? json['item']?['images']?.first['url'] as String?,
      buyerName: json['buyer_name'] as String? ?? json['buyer']?['name'] as String? ?? '',
      buyerPhone: json['buyer_phone'] as String? ?? json['buyer']?['phone'] as String?,
      sellerName: json['seller_name'] as String? ?? json['seller']?['name'] as String? ?? '',
      sellerPhone: json['seller_phone'] as String? ?? json['seller']?['phone'] as String?,
      pickupAddress: json['pickup_address'] as String?,    // ✅ ADDED
      deliveryAddress: json['delivery_address'] as String?,  // ✅ ADDED
      totalAmount: json['total_amount'] != null ? double.tryParse(json['total_amount'].toString()) : null,
      isDonation: json['is_donation'] as bool? ?? json['item_price'] == 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'order_number': orderNumber,
      'item_title': itemTitle,
      'item_image': itemImage,
      'buyer_name': buyerName,
      'buyer_phone': buyerPhone,
      'seller_name': sellerName,
      'seller_phone': sellerPhone,
      'pickup_address': pickupAddress,      // ✅ ADDED
      'delivery_address': deliveryAddress,  // ✅ ADDED
      'total_amount': totalAmount,
      'is_donation': isDonation,
    };
  }
}