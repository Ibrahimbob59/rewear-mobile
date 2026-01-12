class UserModel {
  final int id;
  final String name;
  final String email;
  final String? phone;
  final String? role; 
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
  final DateTime? createdAt;  // ✅ Changed to nullable
  final DateTime? updatedAt;  // ✅ Changed to nullable
  final List<String>? roles;
  final List<String>? permissions;
  
  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.role,
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
    this.createdAt,  // ✅ Now optional
    this.updatedAt,  // ✅ Now optional
    this.roles,
    this.permissions,
  });
  
  factory UserModel.fromJson(Map<String, dynamic> json) {
    // Helper function to safely parse boolean from any value
    bool parseBool(dynamic value) {
      if (value == null) return false;
      if (value is bool) return value;
      if (value is String) return value.toLowerCase() == 'true';
      if (value is int) return value == 1;
      return false;
    }
    
    // Helper function to safely parse DateTime
    DateTime? parseDateTime(dynamic value) {
      if (value == null) return null;
      if (value is String) {
        try {
          return DateTime.parse(value);
        } catch (e) {
          return null;
        }
      }
      return null;
    }
    
    return UserModel(
      id: json['id'] as int,
      name: json['name'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String?,
      role: json['role'], 
      userType: json['user_type'] as String? ?? 'user',
      profilePicture: json['profile_picture'] as String?,
      bio: json['bio'] as String?,
      city: json['city'] as String?,
      latitude: json['latitude'] != null 
          ? double.tryParse(json['latitude'].toString()) 
          : null,
      longitude: json['longitude'] != null 
          ? double.tryParse(json['longitude'].toString()) 
          : null,
      isDriver: parseBool(json['is_driver']),
      driverVerified: parseBool(json['driver_verified']),
      emailVerified: parseBool(json['email_verified']),
      emailVerifiedAt: parseDateTime(json['email_verified_at']),
      lastLoginAt: parseDateTime(json['last_login_at']),
      createdAt: parseDateTime(json['created_at']),  // ✅ Now uses parseDateTime
      updatedAt: parseDateTime(json['updated_at']),  // ✅ Now uses parseDateTime
      roles: json['roles'] != null 
          ? List<String>.from(json['roles'] as List) 
          : null,
      permissions: json['permissions'] != null 
          ? List<String>.from(json['permissions'] as List) 
          : null,
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
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'roles': roles,
      'permissions': permissions,
    };
  }
  
  bool get isAdmin => roles?.contains('admin') ?? false;
  bool get isCharity => userType == 'charity';
  bool get isVerifiedDriver => isDriver && driverVerified;
}