import 'package:logger/logger.dart';
import '../config/constants.dart';
import '../models/api_response.dart';
import '../models/auth_response.dart';
import '../models/user_model.dart';
import 'api_service.dart';
import 'storage_service.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final ApiService _apiService = ApiService();
  final StorageService _storageService = StorageService();
  final Logger _logger = Logger();

  // Send OTP for Registration
  Future<ApiResponse> sendRegistrationOTP(String email) async {
    try {
      final response = await _apiService.post(
        AppConstants.registerCodeEndpoint,
        body: {'email': email},
      );
      return response;
    } catch (e) {
      _logger.e('Send OTP Error: $e');
      return ApiResponse(
        success: false,
        message: AppConstants.unknownError,
      );
    }
  }

  // Register User
  Future<ApiResponse<AuthResponse>> register({
    required String email,
    required String code,
    required String name,
    required String password,
    required String passwordConfirmation,
    required String phone,
    required String deviceName,
  }) async {
    try {
      final response = await _apiService.post<AuthResponse>(
        AppConstants.registerEndpoint,
        body: {
          'email': email,
          'code': code,
          'name': name,
          'password': password,
          'password_confirmation': passwordConfirmation,
          'phone': phone,
          'device_name': deviceName,
        },
        fromJson: (json) => AuthResponse.fromJson(json),
      );

      if (response.success && response.data != null) {
        await _saveAuthData(response.data!);
      }

      return response;
    } catch (e) {
      _logger.e('Register Error: $e');
      return ApiResponse<AuthResponse>(
        success: false,
        message: AppConstants.unknownError,
      );
    }
  }

  // Resend OTP
  Future<ApiResponse> resendOTP(String email) async {
    try {
      final response = await _apiService.post(
        AppConstants.resendCodeEndpoint,
        body: {'email': email},
      );
      return response;
    } catch (e) {
      _logger.e('Resend OTP Error: $e');
      return ApiResponse(
        success: false,
        message: AppConstants.unknownError,
      );
    }
  }

  // Login
  Future<ApiResponse<AuthResponse>> login({
    required String email,
    required String password,
    required String deviceName,
  }) async {
    try {
      final response = await _apiService.post<AuthResponse>(
        AppConstants.loginEndpoint,
        body: {
          'email': email,
          'password': password,
          'device_name': deviceName,
        },
        fromJson: (json) => AuthResponse.fromJson(json),
      );

      if (response.success && response.data != null) {
        await _saveAuthData(response.data!);
      }

      return response;
    } catch (e) {
      _logger.e('Login Error: $e');
      return ApiResponse<AuthResponse>(
        success: false,
        message: AppConstants.unknownError,
      );
    }
  }

  // Get Current User
  Future<ApiResponse<UserModel>> getCurrentUser() async {
    try {
      final response = await _apiService.get<UserModel>(
        AppConstants.getMeEndpoint,
        fromJson: (json) => UserModel.fromJson(json['user']),
      );

      if (response.success && response.data != null) {
        await _storageService.saveUser(response.data!);
      }

      return response;
    } catch (e) {
      _logger.e('Get User Error: $e');
      return ApiResponse<UserModel>(
        success: false,
        message: AppConstants.unknownError,
      );
    }
  }

  // Logout
  Future<ApiResponse> logout() async {
    try {
      final response = await _apiService.post(
        AppConstants.logoutEndpoint,
        requiresAuth: true,
      );

      // Don't clear storage here - let AuthProvider handle it
      return response;
    } catch (e) {
      _logger.e('Logout Error: $e');
      // Return success even if API fails - we'll clear locally
      return ApiResponse(
        success: true,
        message: 'Logged out',
      );
    }
  }

  // Logout All Devices
  Future<ApiResponse> logoutAll() async {
    try {
      final response = await _apiService.post(
        AppConstants.logoutAllEndpoint,
        requiresAuth: true,
      );

      if (response.success) {
        await _storageService.clearAll();
      }

      return response;
    } catch (e) {
      _logger.e('Logout All Error: $e');
      await _storageService.clearAll();
      return ApiResponse(
        success: true,
        message: 'Logged out from all devices',
      );
    }
  }

  // Update Profile
  Future<ApiResponse<UserModel>> updateProfile({
    String? name,
    String? phone,
    String? bio,
    String? city,
    double? latitude,
    double? longitude,
  }) async {
    try {
      final body = <String, dynamic>{};
      if (name != null) body['name'] = name;
      if (phone != null) body['phone'] = phone;
      if (bio != null) body['bio'] = bio;
      if (city != null) body['city'] = city;
      if (latitude != null) body['latitude'] = latitude;
      if (longitude != null) body['longitude'] = longitude;

      final response = await _apiService.put<UserModel>(
        AppConstants.updateProfileEndpoint,
        body: body,
        fromJson: (json) => UserModel.fromJson(json['user']),
      );

      if (response.success && response.data != null) {
        await _storageService.saveUser(response.data!);
      }

      return response;
    } catch (e) {
      _logger.e('Update Profile Error: $e');
      return ApiResponse<UserModel>(
        success: false,
        message: AppConstants.unknownError,
      );
    }
  }

  // Change Password
  Future<ApiResponse> changePassword({
    required String oldPassword,
    required String newPassword,
    required String newPasswordConfirmation,
  }) async {
    try {
      final response = await _apiService.put(
        AppConstants.changePasswordEndpoint,
        body: {
          'old_password': oldPassword,
          'new_password': newPassword,
          'new_password_confirmation': newPasswordConfirmation,
        },
      );

      return response;
    } catch (e) {
      _logger.e('Change Password Error: $e');
      return ApiResponse(
        success: false,
        message: AppConstants.unknownError,
      );
    }
  }

  // Delete Account
  Future<ApiResponse> deleteAccount(String password) async {
    try {
      final response = await _apiService.delete(
        AppConstants.deleteAccountEndpoint,
      );

      if (response.success) {
        await _storageService.clearAll();
      }

      return response;
    } catch (e) {
      _logger.e('Delete Account Error: $e');
      return ApiResponse(
        success: false,
        message: AppConstants.unknownError,
      );
    }
  }

  // Save Auth Data
  Future<void> _saveAuthData(AuthResponse authResponse) async {
    await _storageService.saveAccessToken(authResponse.accessToken);
    await _storageService.saveRefreshToken(authResponse.refreshToken);
    await _storageService.saveUser(authResponse.user);
    _logger.i('Auth data saved successfully');
  }

  // Check if user is logged in
  Future<bool> isLoggedIn() async {
    return await _storageService.hasAccessToken();
  }
}