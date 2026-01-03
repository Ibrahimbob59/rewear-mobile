import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';

import '../config/app_config.dart';
import '../config/constants.dart';
import 'storage_service.dart';

class TokenService {
  TokenService._internal();
  static final TokenService _instance = TokenService._internal();
  factory TokenService() => _instance;

  final StorageService _storageService = StorageService();
  final Logger _logger = Logger();

  bool _isRefreshing = false;

  Future<bool> refreshToken() async {
    if (_isRefreshing) return false;
    _isRefreshing = true;

    try {
      final refreshToken = await _storageService.getRefreshToken();
      if (refreshToken == null) {
        _logger.e('No refresh token found');
        return false;
      }

      final url = Uri.parse(
        '${AppConfig.baseUrl}${AppConstants.refreshTokenEndpoint}',
      );

      final response = await http
          .post(
            url,
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode({'refresh_token': refreshToken}),
          )
          .timeout(AppConfig.connectionTimeout);

      _logger.d('Refresh token status: ${response.statusCode}');
      _logger.d('Refresh token body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;

        final newAccessToken = data['access_token'] as String?;
        final newRefreshToken = data['refresh_token'] as String?;

        if (newAccessToken != null) {
          await _storageService.saveAccessToken(newAccessToken);
        }
        if (newRefreshToken != null) {
          await _storageService.saveRefreshToken(newRefreshToken);
        }

        _logger.i('Token refreshed successfully');
        return true;
      }

      _logger.e(
        'Token refresh failed: ${response.statusCode} ${response.body}',
      );
      return false;
    } on TimeoutException {
      _logger.e('Token refresh timeout');
      return false;
    } catch (e) {
      _logger.e('Token refresh error: $e');
      return false;
    } finally {
      _isRefreshing = false;
    }
  }

  Future<bool> isTokenValid() async {
    final token = await _storageService.getAccessToken();
    if (token == null) return false;

    try {
      final url = Uri.parse(
        '${AppConfig.baseUrl}${AppConstants.validateTokenEndpoint}',
      );

      final response = await http
          .post(
            url,
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode({'token': token}),
          )
          .timeout(AppConfig.connectionTimeout);

      _logger.d('Validate token status: ${response.statusCode}');
      _logger.d('Validate token body: ${response.body}');

      if (response.statusCode == 200) {
        // assuming your APIResponse format: { "success": true, ... }
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return data['success'] == true;
      }

      return false;
    } on TimeoutException {
      _logger.e('Token validate timeout');
      return false;
    } catch (e) {
      _logger.e('Token validation error: $e');
      return false;
    }
  }
}
