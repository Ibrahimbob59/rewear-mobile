import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import '../config/app_config.dart';
import '../models/api_response.dart';
import 'storage_service.dart';
import 'token_service.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  final StorageService _storageService = StorageService();
  final TokenService _tokenService = TokenService();
  final Logger _logger = Logger();

  // GET Request
  Future<ApiResponse<T>> get<T>(
    String endpoint, {
    Map<String, String>? headers,
    T Function(dynamic)? fromJson,
  }) async {
    try {
      final url = Uri.parse('${AppConfig.baseUrl}$endpoint');
      final token = await _storageService.getAccessToken();
      
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
          ...?headers,
        },
      ).timeout(AppConfig.connectionTimeout);

      return _handleResponse<T>(response, fromJson);
    } on TimeoutException {
      return ApiResponse<T>(
        success: false,
        message: 'Request timeout. Please try again.',
      );
    } catch (e) {
      _logger.e('GET Error: $e');
      return ApiResponse<T>(
        success: false,
        message: 'Network error: ${e.toString()}',
      );
    }
  }

  // POST Request
  Future<ApiResponse<T>> post<T>(
    String endpoint, {
    Map<String, dynamic>? body,
    Map<String, String>? headers,
    T Function(dynamic)? fromJson,
    bool requiresAuth = false,
  }) async {
    try {
      final url = Uri.parse('${AppConfig.baseUrl}$endpoint');
      final token = await _storageService.getAccessToken();
      
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          if (requiresAuth && token != null) 'Authorization': 'Bearer $token',
          ...?headers,
        },
        body: body != null ? jsonEncode(body) : null,
      ).timeout(AppConfig.connectionTimeout);

      return _handleResponse<T>(response, fromJson);
    } on TimeoutException {
      return ApiResponse<T>(
        success: false,
        message: 'Request timeout. Please try again.',
      );
    } catch (e) {
      _logger.e('POST Error: $e');
      return ApiResponse<T>(
        success: false,
        message: 'Network error: ${e.toString()}',
      );
    }
  }

  // PUT Request
  Future<ApiResponse<T>> put<T>(
    String endpoint, {
    Map<String, dynamic>? body,
    Map<String, String>? headers,
    T Function(dynamic)? fromJson,
  }) async {
    try {
      final url = Uri.parse('${AppConfig.baseUrl}$endpoint');
      final token = await _storageService.getAccessToken();
      
      final response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
          ...?headers,
        },
        body: body != null ? jsonEncode(body) : null,
      ).timeout(AppConfig.connectionTimeout);

      return _handleResponse<T>(response, fromJson);
    } catch (e) {
      _logger.e('PUT Error: $e');
      return ApiResponse<T>(
        success: false,
        message: 'Network error: ${e.toString()}',
      );
    }
  }

  // DELETE Request
  Future<ApiResponse<T>> delete<T>(
    String endpoint, {
    Map<String, String>? headers,
    T Function(dynamic)? fromJson,
  }) async {
    try {
      final url = Uri.parse('${AppConfig.baseUrl}$endpoint');
      final token = await _storageService.getAccessToken();
      
      final response = await http.delete(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
          ...?headers,
        },
      ).timeout(AppConfig.connectionTimeout);

      return _handleResponse<T>(response, fromJson);
    } catch (e) {
      _logger.e('DELETE Error: $e');
      return ApiResponse<T>(
        success: false,
        message: 'Network error: ${e.toString()}',
      );
    }
  }

  // Handle Response
  Future<ApiResponse<T>> _handleResponse<T>(
    http.Response response,
    T Function(dynamic)? fromJson,
  ) async {
    _logger.d('Response Status: ${response.statusCode}');
    _logger.d('Response Body: ${response.body}');

    if (response.statusCode == 401) {
      // Token expired, try to refresh
      final refreshed = await _tokenService.refreshToken();
      if (!refreshed) {
        return ApiResponse<T>(
          success: false,
          message: 'Session expired. Please login again.',
        );
      }
    }

    final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
    
    return ApiResponse<T>.fromJson(jsonResponse, fromJson);
  }
}