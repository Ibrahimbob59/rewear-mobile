import '../config/app_config.dart';

class Validators {
  // Email Validation
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    
    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email';
    }
    
    return null;
  }

  // Password Validation
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    
    if (value.length < AppConfig.minPasswordLength) {
      return 'Password must be at least ${AppConfig.minPasswordLength} characters';
    }
    
    final passwordRegex = RegExp(AppConfig.passwordPattern);
    
    if (!passwordRegex.hasMatch(value)) {
      return 'Password must contain uppercase, lowercase, number and special character';
    }
    
    return null;
  }

  // Name Validation
  static String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Name is required';
    }
    
    if (value.length < 2) {
      return 'Name must be at least 2 characters';
    }
    
    return null;
  }

  // Phone Validation
  static String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone number is required';
    }
    
    final phoneRegex = RegExp(r'^\+?[1-9]\d{7,14}$');
    
    if (!phoneRegex.hasMatch(value)) {
      return 'Please enter a valid phone number';
    }
    
    return null;
  }

  // OTP Validation
  static String? validateOTP(String? value) {
    if (value == null || value.isEmpty) {
      return 'Verification code is required';
    }
    
    if (value.length != AppConfig.otpLength) {
      return 'Please enter a valid ${AppConfig.otpLength}-digit code';
    }
    
    if (!RegExp(r'^\d+$').hasMatch(value)) {
      return 'Verification code must contain only numbers';
    }
    
    return null;
  }

  // Password Confirmation Validation
  static String? validatePasswordConfirmation(String? value, String? password) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    
    if (value != password) {
      return 'Passwords do not match';
    }
    
    return null;
  }

  // Password Strength
  static double getPasswordStrength(String password) {
    if (password.isEmpty) return 0.0;
    
    double strength = 0.0;
    
    // Length
    if (password.length >= 8) strength += 0.2;
    if (password.length >= 12) strength += 0.1;
    
    // Has lowercase
    if (password.contains(RegExp(r'[a-z]'))) strength += 0.2;
    
    // Has uppercase
    if (password.contains(RegExp(r'[A-Z]'))) strength += 0.2;
    
    // Has number
    if (password.contains(RegExp(r'\d'))) strength += 0.2;
    
    // Has special character
    if (password.contains(RegExp(r'[@$!%*?&]'))) strength += 0.1;
    
    return strength.clamp(0.0, 1.0);
  }
}