class ApiResponse<T> {
  final bool success;
  final String message;
  final T? data;
  final Map<String, dynamic>? errors;
  
  ApiResponse({
    required this.success,
    required this.message,
    this.data,
    this.errors,
  });
  
  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic)? fromJsonT,
  ) {
    return ApiResponse<T>(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null && fromJsonT != null 
          ? fromJsonT(json['data']) 
          : json['data'],
      errors: json['errors'],
    );
  }
  
  bool get hasErrors => errors != null && errors!.isNotEmpty;
  
  String get firstError {
    if (!hasErrors) return message;
    final firstKey = errors!.keys.first;
    final errorList = errors![firstKey];
    if (errorList is List && errorList.isNotEmpty) {
      return errorList.first.toString();
    }
    return message;
  }
}