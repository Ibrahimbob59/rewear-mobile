import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/storage_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  final StorageService _storageService = StorageService();

  UserModel? _user;
  bool _isLoading = false;
  String? _errorMessage;

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isLoggedIn => _user != null;

  // Initialize - Load user from storage
  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    try {
      _user = await _storageService.getUser();
      if (_user != null) {
        // Refresh user data from API
        final response = await _authService.getCurrentUser();
        if (response.success && response.data != null) {
          _user = response.data;
        }
      }
    } catch (e) {
      debugPrint('Initialize error: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  // Login
  Future<bool> login({
    required String email,
    required String password,
    required String deviceName,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final response = await _authService.login(
      email: email,
      password: password,
      deviceName: deviceName,
    );

    _isLoading = false;

    if (response.success && response.data != null) {
      _user = response.data!.user;
      notifyListeners();
      return true;
    } else {
      _errorMessage = response.firstError;
      notifyListeners();
      return false;
    }
  }

  // Register
  Future<bool> register({
    required String email,
    required String code,
    required String name,
    required String password,
    required String passwordConfirmation,
    required String phone,
    required String deviceName,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final response = await _authService.register(
      email: email,
      code: code,
      name: name,
      password: password,
      passwordConfirmation: passwordConfirmation,
      phone: phone,
      deviceName: deviceName,
    );

    _isLoading = false;

    if (response.success && response.data != null) {
      _user = response.data!.user;
      notifyListeners();
      return true;
    } else {
      _errorMessage = response.firstError;
      notifyListeners();
      return false;
    }
  }

  // Logout
  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Clear local state immediately
      _user = null;
      await _storageService.clearTokens();
      notifyListeners();

      // Call logout API in background (don't await)
      _authService.logout().catchError((e) {
        debugPrint('Logout API error (ignored): $e');
      });
    } catch (e) {
      debugPrint('Logout error: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  // Update Profile
  Future<bool> updateProfile({
    String? name,
    String? phone,
    String? bio,
    String? city,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final response = await _authService.updateProfile(
      name: name,
      phone: phone,
      bio: bio,
      city: city,
    );

    _isLoading = false;

    if (response.success && response.data != null) {
      _user = response.data;
      notifyListeners();
      return true;
    } else {
      _errorMessage = response.firstError;
      notifyListeners();
      return false;
    }
  }

  // Clear Error
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }// Change Password
  Future<bool> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final response = await _authService.changePassword(
      oldPassword: oldPassword,
      newPassword: newPassword,
      newPasswordConfirmation: newPassword,  // ← ADDED THIS
    );

    _isLoading = false;

    if (response.success) {
      notifyListeners();
      return true;
    } else {
      _errorMessage = response.firstError;
      notifyListeners();
      return false;
    }
  }

  // Deactivate Account
  Future<bool> deactivateAccount() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final response = await _authService.deleteAccount('User requested account deletion');  // ← ADDED REASON

    _isLoading = false;

    if (response.success) {
      _user = null;
      notifyListeners();
      return true;
    } else {
      _errorMessage = response.firstError;
      notifyListeners();
      return false;
    }
  }
}