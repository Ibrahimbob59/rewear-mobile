import 'user_model.dart';

class AuthResponse {
  final UserModel user;
  final String accessToken;
  final String refreshToken;
  final String tokenType;
  final int expiresIn;
  
  AuthResponse({
    required this.user,
    required this.accessToken,
    required this.refreshToken,
    this.tokenType = 'Bearer',
    required this.expiresIn,
  });
  
  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    try {
      return AuthResponse(
        user: UserModel.fromJson(json['user'] as Map<String, dynamic>),
        accessToken: (json['access_token'] as String?) ?? '',
        refreshToken: (json['refresh_token'] as String?) ?? '',
        tokenType: (json['token_type'] as String?) ?? 'Bearer',
        expiresIn: (json['expires_in'] as int?) ?? 0,
      );
    } catch (e) {
      // Add detailed error logging
      print('❌ AuthResponse.fromJson Error: $e');
      print('📦 JSON data: $json');
      rethrow;
    }
  }
  
  Map<String, dynamic> toJson() {
    return {
      'user': user.toJson(),
      'access_token': accessToken,
      'refresh_token': refreshToken,
      'token_type': tokenType,
      'expires_in': expiresIn,
    };
  }
}