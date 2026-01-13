import 'package:dio/dio.dart';

/// Utility class for handling API errors and responses
class ApiHelper {
  /// Extract user-friendly error message from DioException
  /// 
  /// Handles Laravel validation errors (422) and other API errors
  static String extractErrorMessage(dynamic error) {
    if (error is DioException) {
      // Handle 422 Validation Errors
      if (error.response?.statusCode == 422) {
        return _parseValidationErrors(error.response?.data);
      }
      
      // Handle 401 Unauthorized
      if (error.response?.statusCode == 401) {
        return 'Session expired. Please login again.';
      }
      
      // Handle 403 Forbidden
      if (error.response?.statusCode == 403) {
        return 'You do not have permission to perform this action.';
      }
      
      // Handle 404 Not Found
      if (error.response?.statusCode == 404) {
        return error.response?.data?['message'] ?? 'Resource not found.';
      }
      
      // Handle 500 Server Error
      if (error.response?.statusCode == 500) {
        return 'Server error. Please try again later.';
      }
      
      // Generic API error with message
      if (error.response?.data?['message'] != null) {
        return error.response!.data['message'];
      }
      
      // DioException message
      if (error.message != null) {
        return error.message!;
      }
      
      return 'Network error. Please check your connection.';
    }
    
    // Non-Dio errors
    return error.toString();
  }
  
  /// Parse Laravel validation errors from 422 response
  /// 
  /// Laravel format: { "errors": { "field": ["error message"] } }
  static String _parseValidationErrors(dynamic responseData) {
    if (responseData == null) {
      return 'Validation failed';
    }
    
    // Check for errors object
    if (responseData['errors'] != null) {
      final errors = responseData['errors'] as Map<String, dynamic>;
      final errorMessages = <String>[];
      
      errors.forEach((field, messages) {
        if (messages is List && messages.isNotEmpty) {
          // Add field name for clarity
          final fieldName = _formatFieldName(field);
          errorMessages.add('$fieldName: ${messages.first}');
        }
      });
      
      if (errorMessages.isNotEmpty) {
        return errorMessages.join('\n');
      }
    }
    
    // Fallback to message field
    if (responseData['message'] != null) {
      return responseData['message'];
    }
    
    return 'Validation failed';
  }
  
  /// Format field name for display
  /// 
  /// Converts snake_case to Title Case
  /// Examples: 
  /// - item_id → Item ID
  /// - delivery_address_id → Delivery Address ID
  static String _formatFieldName(String field) {
    return field
        .split('_')
        .map((word) => word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }
  
  /// Check if response is successful
  static bool isSuccess(Map<String, dynamic>? data) {
    return data?['success'] == true;
  }
  
  /// Extract data from successful response
  static dynamic getData(Map<String, dynamic>? response) {
    return response?['data'];
  }
  
  /// Extract message from response
  static String? getMessage(Map<String, dynamic>? response) {
    return response?['message'];
  }
}