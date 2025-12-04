class AppConstants {
  // API Endpoints
  static const String loginEndpoint = '/auth/login';
  static const String registerCodeEndpoint = '/auth/register-code';
  static const String registerEndpoint = '/auth/register';
  static const String resendCodeEndpoint = '/auth/resend-code';
  static const String refreshTokenEndpoint = '/auth/refresh-token';
  static const String validateTokenEndpoint = '/auth/validate';
  static const String logoutEndpoint = '/auth/logout';
  static const String logoutAllEndpoint = '/auth/logout-all';
  static const String getMeEndpoint = '/auth/me';
  static const String updateProfileEndpoint = '/auth/profile';
  static const String changePasswordEndpoint = '/auth/password';
  static const String deleteAccountEndpoint = '/user/delete-account';
  
  // Error Messages
  static const String networkError = 'Network error. Please check your connection.';
  static const String serverError = 'Server error. Please try again later.';
  static const String unknownError = 'An unknown error occurred.';
  static const String invalidCredentials = 'Invalid email or password.';
  static const String accountLocked = 'Account locked due to too many failed attempts.';
  static const String tokenExpired = 'Session expired. Please login again.';
  
  // Success Messages
  static const String loginSuccess = 'Login successful!';
  static const String registerSuccess = 'Registration successful!';
  static const String otpSent = 'Verification code sent to your email.';
  static const String profileUpdated = 'Profile updated successfully.';
  static const String passwordChanged = 'Password changed successfully.';
  
  // Validation Messages
  static const String emailRequired = 'Email is required';
  static const String emailInvalid = 'Please enter a valid email';
  static const String passwordRequired = 'Password is required';
  static const String passwordTooShort = 'Password must be at least 8 characters';
  static const String passwordWeak = 'Password must contain uppercase, lowercase, number and special character';
  static const String passwordMismatch = 'Passwords do not match';
  static const String nameRequired = 'Name is required';
  static const String phoneRequired = 'Phone number is required';
  static const String phoneInvalid = 'Please enter a valid phone number';
  static const String otpRequired = 'Verification code is required';
  static const String otpInvalid = 'Please enter a valid 6-digit code';
  
  // User Types
  static const String userTypeUser = 'user';
  static const String userTypeCharity = 'charity';
  
  // Device Info
  static String getDeviceName() {
    // You can enhance this with device_info_plus package
    return 'Flutter App';
  }
}