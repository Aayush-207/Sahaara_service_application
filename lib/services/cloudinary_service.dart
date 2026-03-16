import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../config/app_config.dart';

/// Cloudinary Service
/// Handles image uploads to Cloudinary
class CloudinaryService {
  // Get from app_config.dart (which reads from .env or uses defaults)
  static String get cloudName => AppConfig.cloudinaryCloudName;
  static String get uploadPreset => AppConfig.cloudinaryUploadPreset;

  /// Upload image to Cloudinary
  /// Returns the secure URL of the uploaded image
  Future<String?> uploadImage(File imageFile, {String folder = 'sahara'}) async {
    // Validate configuration before attempting upload
    if (!CloudinaryService.isConfigured()) {
      debugPrint('❌ Cloudinary is not configured. Check .env file.');
      throw Exception('Cloudinary configuration missing. Please check your .env file.');
    }

    try {
      final url = Uri.parse(
        'https://api.cloudinary.com/v1_1/$cloudName/image/upload',
      );

      final request = http.MultipartRequest('POST', url);
      
      // Add upload preset
      request.fields['upload_preset'] = uploadPreset;
      
      // Add folder
      request.fields['folder'] = folder;
      
      // Add timestamp for unique filenames
      request.fields['timestamp'] = DateTime.now().millisecondsSinceEpoch.toString();

      // Add image file
      request.files.add(
        await http.MultipartFile.fromPath('file', imageFile.path),
      );

      debugPrint('📤 Uploading image to Cloudinary...');
      
      final response = await request.send().timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw Exception('Upload timeout. Please check your internet connection.');
        },
      );
      
      final responseData = await response.stream.toBytes();
      final responseString = String.fromCharCodes(responseData);
      
      if (response.statusCode == 200) {
        final jsonResponse = json.decode(responseString);
        final secureUrl = jsonResponse['secure_url'] as String;
        
        debugPrint('✅ Image uploaded successfully: $secureUrl');
        return secureUrl;
      } else {
        debugPrint('❌ Upload failed: ${response.statusCode}');
        debugPrint('Response: $responseString');
        throw Exception('Upload failed with status ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('❌ Error uploading image: $e');
      rethrow;
    }
  }

  /// Upload multiple images
  Future<List<String>> uploadMultipleImages(
    List<File> imageFiles, {
    String folder = 'sahara',
  }) async {
    final urls = <String>[];
    
    for (final file in imageFiles) {
      final url = await uploadImage(file, folder: folder);
      if (url != null) {
        urls.add(url);
      }
    }
    
    return urls;
  }

  /// Delete image from Cloudinary (requires public_id)
  /// Note: This requires authentication, so it's better to handle deletions
  /// from a backend server. For now, we'll just remove the URL from Firestore.
  Future<bool> deleteImage(String publicId) async {
    // This would require API key and secret, which should not be in client code
    // Implement this on your backend server
    debugPrint('⚠️  Image deletion should be handled by backend');
    return false;
  }

  /// Extract public_id from Cloudinary URL
  String? getPublicIdFromUrl(String url) {
    try {
      final uri = Uri.parse(url);
      final pathSegments = uri.pathSegments;
      
      // Find the index of 'upload' in the path
      final uploadIndex = pathSegments.indexOf('upload');
      if (uploadIndex == -1) return null;
      
      // Get everything after 'upload' and version (v1234567890)
      final relevantSegments = pathSegments.sublist(uploadIndex + 2);
      
      // Join and remove file extension
      final publicId = relevantSegments.join('/').split('.').first;
      
      return publicId;
    } catch (e) {
      debugPrint('Error extracting public_id: $e');
      return null;
    }
  }

  /// Validate Cloudinary configuration
  static bool isConfigured() {
    return AppConfig.isCloudinaryConfigured;
  }
}
