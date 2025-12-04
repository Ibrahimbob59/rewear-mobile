import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../config/app_config.dart';
import '../models/user_model.dart';

class StorageService {
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  SharedPreferences? _prefs;

  // Flag to check if initialized
  bool _initialized = false;

  Future<void> init() async {
    if (!_initialized) {
      _prefs = await SharedPreferences.getInstance();
      _initialized = true;
    }
  }

  // Ensure initialization before any operation
  Future<void> _ensureInitialized() async {
    if (!_initialized) {
      await init();
    }
  }

  // Secure Token Storage
  Future<void> saveAccessToken(String token) async {
    await _secureStorage.write(key: AppConfig.accessTokenKey, value: token);
  }

  Future<String?> getAccessToken() async {
    return await _secureStorage.read(key: AppConfig.accessTokenKey);
  }

  Future<void> saveRefreshToken(String token) async {
    await _secureStorage.write(key: AppConfig.refreshTokenKey, value: token);
  }

  Future<String?> getRefreshToken() async {
    return await _secureStorage.read(key: AppConfig.refreshTokenKey);
  }

  Future<bool> hasAccessToken() async {
    final token = await getAccessToken();
    return token != null && token.isNotEmpty;
  }

  // User Data Storage
  Future<void> saveUser(UserModel user) async {
    await _ensureInitialized();
    final userJson = jsonEncode(user.toJson());
    await _prefs?.setString(AppConfig.userKey, userJson);
  }

  Future<UserModel?> getUser() async {
    await _ensureInitialized();
    final userJson = _prefs?.getString(AppConfig.userKey);
    if (userJson != null) {
      return UserModel.fromJson(jsonDecode(userJson));
    }
    return null;
  }

  // Device Name
  Future<void> saveDeviceName(String deviceName) async {
    await _ensureInitialized();
    await _prefs?.setString(AppConfig.deviceNameKey, deviceName);
  }

  Future<String?> getDeviceName() async {
    await _ensureInitialized();
    return _prefs?.getString(AppConfig.deviceNameKey);
  }

  // Clear All Data (Logout)
  Future<void> clearAll() async {
    await _ensureInitialized();
    await _secureStorage.deleteAll();
    await _prefs?.clear();
  }

  // Clear only auth tokens
  Future<void> clearTokens() async {
    await _secureStorage.delete(key: AppConfig.accessTokenKey);
    await _secureStorage.delete(key: AppConfig.refreshTokenKey);
  }
}