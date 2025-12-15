import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import '../config/app_config.dart';
import '../models/api_response.dart';
import 'storage_service.dart';
import 'token_service.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;

  late Dio _dio;
  final StorageService _storageService = StorageService();
  final TokenService _tokenService = TokenService();
  final Logger _logger = Logger();

  ApiService._internal() {
    _initializeDio();
  }

  // Initialize Dio for file uploads and better request handling
  void _initializeDio() {
    _dio = Dio(BaseOptions(
      baseUrl: AppConfig.baseUrl,
      connectTimeout: AppConfig.connectionTimeout,
      receiveTimeout: AppConfig.connectionTimeout,
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
    ));

    // Add interceptors for automatic token injection and refresh
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _storageService.getAccessToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          
          _logger.d('📤 ${options.method} ${options.path}');
          _logger.d('Headers: ${options.headers}');
          
          return handler.next(options);
        },
        onResponse: (response, handler) {
          _logger.d('📥 ${response.statusCode} ${response.requestOptions.path}');
          _logger.d('Response: ${response.data}');
          return handler.next(response);
        },
        onError: (error, handler) async {
          _logger.e('❌ ${error.response?.statusCode} ${error.requestOptions.path}');
          _logger.e('Error: ${error.message}');
          
          // Handle 401 Unauthorized - token expired
          if (error.response?.statusCode == 401) {
            _logger.w('🔐 Token expired, attempting refresh...');
            
            final refreshed = await _tokenService.refreshToken();
            if (refreshed) {
              _logger.i('✅ Token refreshed, retrying request...');
              // Retry the failed request with new token
              return handler.resolve(await _retryRequest(error.requestOptions));
            } else {
              _logger.e('❌ Token refresh failed');
              await _storageService.clearTokens();
            }
          }
          
          return handler.next(error);
        },
      ),
    );
  }

  // Retry failed request with new token
  Future<Response<dynamic>> _retryRequest(RequestOptions requestOptions) async {
    final token = await _storageService.getAccessToken();
    
    final options = Options(
      method: requestOptions.method,
      headers: {
        ...requestOptions.headers,
        'Authorization': 'Bearer $token',
      },
    );

    return _dio.request<dynamic>(
      requestOptions.path,
      data: requestOptions.data,
      queryParameters: requestOptions.queryParameters,
      options: options,
    );
  }

  // Expose Dio instance for direct use (file uploads, etc.)
  Dio get dio => _dio;

  // ============================================================
  // HTTP PACKAGE METHODS (For backward compatibility)
  // ============================================================

  // GET Request
  Future<ApiResponse<T>> get<T>(
    String endpoint, {
    Map<String, String>? headers,
    T Function(dynamic)? fromJson,
  }) async {
    try {
      final url = Uri.parse('${AppConfig.baseUrl}$endpoint');
      final token = await _storageService.getAccessToken();
      
      _logger.d('📤 GET $url');

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
      _logger.e('⏱️ Request timeout');
      return ApiResponse<T>(
        success: false,
        message: 'Request timeout. Please check your internet connection.',
      );
    } catch (e) {
      _logger.e('❌ GET Error: $e');
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
      
      _logger.d('📤 POST $url');
      _logger.d('Body: $body');

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
      _logger.e('⏱️ Request timeout');
      return ApiResponse<T>(
        success: false,
        message: 'Request timeout. Please check your internet connection.',
      );
    } catch (e) {
      _logger.e('❌ POST Error: $e');
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
      
      _logger.d('📤 PUT $url');
      _logger.d('Body: $body');

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
    } on TimeoutException {
      _logger.e('⏱️ Request timeout');
      return ApiResponse<T>(
        success: false,
        message: 'Request timeout. Please check your internet connection.',
      );
    } catch (e) {
      _logger.e('❌ PUT Error: $e');
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
      
      _logger.d('📤 DELETE $url');

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
    } on TimeoutException {
      _logger.e('⏱️ Request timeout');
      return ApiResponse<T>(
        success: false,
        message: 'Request timeout. Please check your internet connection.',
      );
    } catch (e) {
      _logger.e('❌ DELETE Error: $e');
      return ApiResponse<T>(
        success: false,
        message: 'Network error: ${e.toString()}',
      );
    }
  }

  // ============================================================
  // DIO METHODS (For file uploads and advanced features)
  // ============================================================

  // POST with Dio (for file uploads)
  Future<Response> postWithDio(
    String endpoint, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    ProgressCallback? onSendProgress,
  }) async {
    try {
      _logger.d('📤 DIO POST $endpoint');
      
      final response = await _dio.post(
        endpoint,
        data: data,
        queryParameters: queryParameters,
        options: options,
        onSendProgress: onSendProgress,
      );

      return response;
    } catch (e) {
      _logger.e('❌ DIO POST Error: $e');
      rethrow;
    }
  }

  // PUT with Dio
  Future<Response> putWithDio(
    String endpoint, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      _logger.d('📤 DIO PUT $endpoint');
      
      final response = await _dio.put(
        endpoint,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );

      return response;
    } catch (e) {
      _logger.e('❌ DIO PUT Error: $e');
      rethrow;
    }
  }

  // GET with Dio
  Future<Response> getWithDio(
    String endpoint, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      _logger.d('📤 DIO GET $endpoint');
      
      final response = await _dio.get(
        endpoint,
        queryParameters: queryParameters,
        options: options,
      );

      return response;
    } catch (e) {
      _logger.e('❌ DIO GET Error: $e');
      rethrow;
    }
  }

  // DELETE with Dio
  Future<Response> deleteWithDio(
    String endpoint, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      _logger.d('📤 DIO DELETE $endpoint');
      
      final response = await _dio.delete(
        endpoint,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );

      return response;
    } catch (e) {
      _logger.e('❌ DIO DELETE Error: $e');
      rethrow;
    }
  }

  // ============================================================
  // RESPONSE HANDLER
  // ============================================================

  // Handle HTTP Response
  Future<ApiResponse<T>> _handleResponse<T>(
    http.Response response,
    T Function(dynamic)? fromJson,
  ) async {
    _logger.d('📥 Response Status: ${response.statusCode}');
    _logger.d('📥 Response Body: ${response.body}');

    // Handle 401 Unauthorized (Token expired)
    if (response.statusCode == 401) {
      _logger.w('🔐 Token expired, attempting refresh...');
      
      final refreshed = await _tokenService.refreshToken();
      if (!refreshed) {
        _logger.e('❌ Token refresh failed');
        await _storageService.clearTokens();
        return ApiResponse<T>(
          success: false,
          message: 'Session expired. Please login again.',
        );
      }
      
      _logger.i('✅ Token refreshed successfully');
      // Note: Caller should retry the request
    }

    // Parse response
    try {
      // Handle different status codes
      if (response.statusCode >= 200 && response.statusCode < 300) {
        // Success (200-299)
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        return ApiResponse<T>.fromJson(jsonResponse, fromJson);
      } else if (response.statusCode == 422) {
        // Validation error
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        return ApiResponse<T>(
          success: false,
          message: jsonResponse['message'] ?? 'Validation error',
          errors: jsonResponse['errors'],
        );
      } else if (response.statusCode == 404) {
        // Not found
        return ApiResponse<T>(
          success: false,
          message: 'Resource not found',
        );
      } else if (response.statusCode == 403) {
        // Forbidden
        return ApiResponse<T>(
          success: false,
          message: 'You do not have permission to access this resource',
        );
      } else if (response.statusCode >= 500) {
        // Server error
        return ApiResponse<T>(
          success: false,
          message: 'Server error. Please try again later.',
        );
      } else {
        // Other errors
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        return ApiResponse<T>(
          success: false,
          message: jsonResponse['message'] ?? 'An error occurred',
        );
      }
    } catch (e) {
      _logger.e('❌ JSON parsing error: $e');
      return ApiResponse<T>(
        success: false,
        message: 'Failed to parse response',
      );
    }
  }

  // ============================================================
  // UTILITY METHODS
  // ============================================================

  // Check if user is authenticated
  Future<bool> isAuthenticated() async {
    final token = await _storageService.getAccessToken();
    return token != null && token.isNotEmpty;
  }

  // Clear all data and logout
  Future<void> logout() async {
    await _storageService.clearTokens();
    _logger.i('👋 User logged out');
  }

  // Get current access token
  Future<String?> getAccessToken() async {
    return await _storageService.getAccessToken();
  }

  // Get current refresh token
  Future<String?> getRefreshToken() async {
    return await _storageService.getRefreshToken();
  }
}