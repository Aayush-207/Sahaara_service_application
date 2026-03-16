import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

/// Permission Service
/// 
/// Handles all app permissions including:
/// - Camera access
/// - Photo library access
/// - Location access
/// - Notifications
/// 
/// Features:
/// - Request permissions with user-friendly dialogs
/// - Check permission status
/// - Open app settings if permission denied
/// - Handle permission rationale
class PermissionService {
  // ============================================================================
  // CAMERA PERMISSIONS
  // ============================================================================
  
  /// Request camera permission
  Future<bool> requestCameraPermission(BuildContext context) async {
    final status = await Permission.camera.status;
    
    if (status.isGranted) {
      return true;
    }
    
    if (status.isDenied) {
      final result = await Permission.camera.request();
      return result.isGranted;
    }
    
    if (status.isPermanentlyDenied) {
      if (context.mounted) {
        await _showPermissionDeniedDialog(
          context,
          'Camera Permission',
          'Camera access is required to take photos. Please enable it in settings.',
        );
      }
      return false;
    }
    
    return false;
  }
  
  /// Check if camera permission is granted
  Future<bool> hasCameraPermission() async {
    return await Permission.camera.isGranted;
  }
  
  // ============================================================================
  // PHOTO LIBRARY PERMISSIONS
  // ============================================================================
  
  /// Request photo library permission
  Future<bool> requestPhotosPermission(BuildContext context) async {
    final status = await Permission.photos.status;
    
    if (status.isGranted || status.isLimited) {
      return true;
    }
    
    if (status.isDenied) {
      final result = await Permission.photos.request();
      return result.isGranted || result.isLimited;
    }
    
    if (status.isPermanentlyDenied) {
      if (context.mounted) {
        await _showPermissionDeniedDialog(
          context,
          'Photos Permission',
          'Photo library access is required to select images. Please enable it in settings.',
        );
      }
      return false;
    }
    
    return false;
  }
  
  /// Check if photos permission is granted
  Future<bool> hasPhotosPermission() async {
    final status = await Permission.photos.status;
    return status.isGranted || status.isLimited;
  }
  
  // ============================================================================
  // LOCATION PERMISSIONS
  // ============================================================================
  
  /// Request location permission
  Future<bool> requestLocationPermission(BuildContext context) async {
    final status = await Permission.location.status;
    
    if (status.isGranted) {
      return true;
    }
    
    if (status.isDenied) {
      final result = await Permission.location.request();
      return result.isGranted;
    }
    
    if (status.isPermanentlyDenied) {
      if (context.mounted) {
        await _showPermissionDeniedDialog(
          context,
          'Location Permission',
          'Location access is required to find nearby caregivers. Please enable it in settings.',
        );
      }
      return false;
    }
    
    return false;
  }
  
  /// Check if location permission is granted
  Future<bool> hasLocationPermission() async {
    return await Permission.location.isGranted;
  }
  
  // ============================================================================
  // NOTIFICATION PERMISSIONS
  // ============================================================================
  
  /// Request notification permission
  Future<bool> requestNotificationPermission(BuildContext context) async {
    final status = await Permission.notification.status;
    
    if (status.isGranted) {
      return true;
    }
    
    if (status.isDenied) {
      final result = await Permission.notification.request();
      return result.isGranted;
    }
    
    if (status.isPermanentlyDenied) {
      if (context.mounted) {
        await _showPermissionDeniedDialog(
          context,
          'Notification Permission',
          'Notification access is required to receive booking updates. Please enable it in settings.',
        );
      }
      return false;
    }
    
    return false;
  }
  
  /// Check if notification permission is granted
  Future<bool> hasNotificationPermission() async {
    return await Permission.notification.isGranted;
  }
  
  // ============================================================================
  // MULTIPLE PERMISSIONS
  // ============================================================================
  
  /// Request all essential permissions at app startup
  Future<Map<Permission, PermissionStatus>> requestEssentialPermissions() async {
    return await [
      Permission.photos,
      Permission.camera,
      Permission.location,
      Permission.notification,
    ].request();
  }
  
  /// Check all essential permissions status
  Future<Map<Permission, PermissionStatus>> checkEssentialPermissions() async {
    return {
      Permission.photos: await Permission.photos.status,
      Permission.camera: await Permission.camera.status,
      Permission.location: await Permission.location.status,
      Permission.notification: await Permission.notification.status,
    };
  }
  
  // ============================================================================
  // HELPER METHODS
  // ============================================================================
  
  /// Show permission denied dialog with option to open settings
  Future<void> _showPermissionDeniedDialog(
    BuildContext context,
    String title,
    String message,
  ) async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          title,
          style: const TextStyle(
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.w700,
          ),
        ),
        content: Text(
          message,
          style: const TextStyle(
            fontFamily: 'Montserrat',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(fontFamily: 'Montserrat'),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              openAppSettings();
            },
            child: const Text(
              'Open Settings',
              style: TextStyle(fontFamily: 'Montserrat'),
            ),
          ),
        ],
      ),
    );
  }
  
  /// Open app settings
  Future<void> openSettings() async {
    await openAppSettings();
  }
}
