class UserModel {
  final int id;
  final String name;
  final String email;
  final String? phone;
  final String userType;
  final String? profilePicture;
  final String? bio;
  final String? city;
  final double? latitude;
  final double? longitude;
  final bool isDriver;
  final bool driverVerified;
  final bool emailVerified;
  final DateTime? emailVerifiedAt;
  final DateTime? lastLoginAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<String>? roles;
  final List<String>? permissions;
  
  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    required this.userType,
    this.profilePicture,
    this.bio,
    this.city,
    this.latitude,
    this.longitude,
    this.isDriver = false,
    this.driverVerified = false,
    this.emailVerified = false,
    this.emailVerifiedAt,
    this.lastLoginAt,
    required this.createdAt,
    required this.updatedAt,
    this.roles,
    this.permissions,
  });
  
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
      userType: json['user_type'] ?? 'user',
      profilePicture: json['profile_picture'],
      bio: json['bio'],
      city: json['city'],
      latitude: json['latitude'] != null ? double.tryParse(json['latitude'].toString()) : null,
      longitude: json['longitude'] != null ? double.tryParse(json['longitude'].toString()) : null,
      isDriver: json['is_driver'] ?? false,
      driverVerified: json['driver_verified'] ?? false,
      emailVerified: json['email_verified'] ?? false,
      emailVerifiedAt: json['email_verified_at'] != null 
          ? DateTime.parse(json['email_verified_at']) 
          : null,
      lastLoginAt: json['last_login_at'] != null 
          ? DateTime.parse(json['last_login_at']) 
          : null,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      roles: json['roles'] != null ? List<String>.from(json['roles']) : null,
      permissions: json['permissions'] != null ? List<String>.from(json['permissions']) : null,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'user_type': userType,
      'profile_picture': profilePicture,
      'bio': bio,
      'city': city,
      'latitude': latitude,
      'longitude': longitude,
      'is_driver': isDriver,
      'driver_verified': driverVerified,
      'email_verified': emailVerified,
      'email_verified_at': emailVerifiedAt?.toIso8601String(),
      'last_login_at': lastLoginAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'roles': roles,
      'permissions': permissions,
    };
  }
  
  bool get isAdmin => roles?.contains('admin') ?? false;
  bool get isCharity => userType == 'charity';
  bool get isVerifiedDriver => isDriver && driverVerified;
}