class AppConfig {
  // API Configuration
  // Use 10.0.2.2 for Android emulator (maps to host machine's localhost)
  static const String baseUrl = 'http://10.0.2.2:8000/api'; // Android emulator
  // static const String baseUrl = 'http://localhost:8000/api'; // iOS simulator
  // static const String baseUrl = 'https://api.rewear.com/api'; // Production
  
  static const String apiVersion = 'v1';
  
  // Timeout durations
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  
  // Storage Keys
  static const String accessTokenKey = 'access_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userKey = 'user_data';
  static const String deviceNameKey = 'device_name';
  
  // Token expiry
  static const Duration accessTokenExpiry = Duration(minutes: 15);
  static const Duration refreshTokenExpiry = Duration(days: 7);
  
  // App Info
  static const String appName = 'ReWear';
  static const String appVersion = '1.0.0';
  
  // Validation
  static const int otpLength = 6;
  static const Duration otpExpiry = Duration(minutes: 15);
  static const int maxLoginAttempts = 5;
  static const Duration accountLockDuration = Duration(minutes: 30);
  
  // Password Requirements
  static const int minPasswordLength = 8;
  static const String passwordPattern = 
      r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]';
}