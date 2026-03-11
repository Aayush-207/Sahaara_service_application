import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Application Configuration
/// 
/// This file contains all configuration constants for the app.
/// Configuration is loaded from environment variables (.env file).
class AppConfig {
  // Cloudinary Configuration
  // Loaded from .env file
  static String get cloudinaryCloudName => 
      dotenv.env['CLOUDINARY_CLOUD_NAME'] ?? '';
  
  static String get cloudinaryUploadPreset => 
      dotenv.env['CLOUDINARY_UPLOAD_PRESET'] ?? '';
  
  // App Configuration
  static const String appName = 'Sahara Pet Care';
  static const String appPrimaryColor = '#1A2332';
  
  // Contact Information
  static String get supportEmail => 
      dotenv.env['SUPPORT_EMAIL'] ?? 'support@sahara.com';
  
  static String get supportPhone => 
      dotenv.env['SUPPORT_PHONE'] ?? '+91 98765 43210';
  
  static String get privacyEmail => 
      dotenv.env['PRIVACY_EMAIL'] ?? 'privacy@sahara.com';
  
  static String get companyAddress => 
      dotenv.env['COMPANY_ADDRESS'] ?? '123 Pet Care Street, Bengaluru, Karnataka 560001, India';
  
  // Validation
  static bool get isCloudinaryConfigured => 
      cloudinaryCloudName.isNotEmpty && 
      cloudinaryUploadPreset.isNotEmpty;
}
