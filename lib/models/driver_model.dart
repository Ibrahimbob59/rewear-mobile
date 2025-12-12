class Driver {
  final int id;
  final int userId;
  final String name;
  final String email;
  final String phone;
  final String? profilePicture;
  final String status;
  final String? vehicleType;
  final String? vehicleNumber;
  final String? licenseNumber;
  final String? licenseImage;
  final String? vehicleImage;
  final double? rating;
  final int totalDeliveries;
  final double totalEarnings;
  final bool isAvailable;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Driver({
    required this.id,
    required this.userId,
    required this.name,
    required this.email,
    required this.phone,
    this.profilePicture,
    required this.status,
    this.vehicleType,
    this.vehicleNumber,
    this.licenseNumber,
    this.licenseImage,
    this.vehicleImage,
    this.rating,
    required this.totalDeliveries,
    required this.totalEarnings,
    required this.isAvailable,
    this.createdAt,
    this.updatedAt,
  });

  factory Driver.fromJson(Map<String, dynamic> json) {
    return Driver(
      id: json['id'] ?? 0,
      userId: json['user_id'] ?? 0,
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      profilePicture: json['profile_picture'],
      status: json['status'] ?? 'pending',
      vehicleType: json['vehicle_type'],
      vehicleNumber: json['vehicle_number'],
      licenseNumber: json['license_number'],
      licenseImage: json['license_image'],
      vehicleImage: json['vehicle_image'],
      rating: json['rating']?.toDouble(),
      totalDeliveries: json['total_deliveries'] ?? 0,
      totalEarnings: (json['total_earnings'] ?? 0).toDouble(),
      isAvailable: json['is_available'] ?? false,
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
          : null,
      updatedAt: json['updated_at'] != null 
          ? DateTime.parse(json['updated_at']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'email': email,
      'phone': phone,
      'profile_picture': profilePicture,
      'status': status,
      'vehicle_type': vehicleType,
      'vehicle_number': vehicleNumber,
      'license_number': licenseNumber,
      'license_image': licenseImage,
      'vehicle_image': vehicleImage,
      'rating': rating,
      'total_deliveries': totalDeliveries,
      'total_earnings': totalEarnings,
      'is_available': isAvailable,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  String get ratingDisplay => rating != null ? rating!.toStringAsFixed(1) : 'N/A';
  String get earningsDisplay => '\$${totalEarnings.toStringAsFixed(2)}';
  bool get isPending => status == 'pending';
  bool get isApproved => status == 'approved';
  bool get isRejected => status == 'rejected';
}