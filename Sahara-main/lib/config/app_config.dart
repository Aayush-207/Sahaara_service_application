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
  
  // Validation
  static bool get isCloudinaryConfigured => 
      cloudinaryCloudName.isNotEmpty && 
      cloudinaryUploadPreset.isNotEmpty;
}
