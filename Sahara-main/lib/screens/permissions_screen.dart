import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../services/permission_service.dart';
import '../services/sound_service.dart';

/// Permissions Screen
/// 
/// Shown on first app launch to request essential permissions:
/// - Camera (for taking photos)
/// - Photos (for selecting images)
/// - Location (for finding nearby caregivers)
/// - Notifications (for booking updates)
/// 
/// Features:
/// - Clear explanation of why each permission is needed
/// - Skip option (permissions can be requested later)
/// - Continue button to request all permissions
/// - Individual permission cards with icons
/// 
/// Design:
/// - Material Design 3
/// - Montserrat font
/// - Navy, Orange, Sky Blue theme
/// - 8pt grid spacing
class PermissionsScreen extends StatefulWidget {
  const PermissionsScreen({super.key});

  @override
  State<PermissionsScreen> createState() => _PermissionsScreenState();
}

class _PermissionsScreenState extends State<PermissionsScreen> {
  final PermissionService _permissionService = PermissionService();
  final SoundService _soundService = SoundService();
  bool _isRequesting = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 40),
              
              // Icon
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.security_rounded,
                  size: 50,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 32),
              
              // Title
              const Text(
                'Permissions Required',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                  fontFamily: 'Montserrat',
                  height: 1.2,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              
              // Subtitle
              Text(
                'To provide you with the best experience, Sahara needs access to the following:',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                  fontFamily: 'Montserrat',
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              
              // Required badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.star_rounded,
                      size: 16,
                      color: AppColors.error,
                    ),
                    SizedBox(width: 4),
                    Text(
                      'Location & Notifications are required',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.error,
                        fontFamily: 'Montserrat',
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              
              // Permission cards
              Expanded(
                child: ListView(
                  children: [
                    _buildPermissionCard(
                      icon: Icons.location_on_rounded,
                      title: 'Location',
                      description: 'Find nearby caregivers and services',
                      color: AppColors.accent,
                      isRequired: true,
                    ),
                    const SizedBox(height: 16),
                    _buildPermissionCard(
                      icon: Icons.notifications_rounded,
                      title: 'Notifications',
                      description: 'Receive booking updates and reminders',
                      color: AppColors.tertiary,
                      isRequired: true,
                    ),
                    const SizedBox(height: 16),
                    _buildPermissionCard(
                      icon: Icons.camera_alt_rounded,
                      title: 'Camera',
                      description: 'Take photos for your profile and pets',
                      color: AppColors.primary,
                      isRequired: false,
                    ),
                    const SizedBox(height: 16),
                    _buildPermissionCard(
                      icon: Icons.photo_library_rounded,
                      title: 'Photos',
                      description: 'Select images from your gallery',
                      color: AppColors.secondary,
                      isRequired: false,
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Continue button
              ElevatedButton(
                onPressed: _isRequesting ? null : _requestPermissions,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: _isRequesting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text(
                        'Grant Permissions',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Montserrat',
                        ),
                      ),
              ),
              const SizedBox(height: 12),
              
              // Info text
              Text(
                'Camera and Photos can be granted later when needed',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textTertiary,
                  fontFamily: 'Montserrat',
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPermissionCard({
    required IconData icon,
    required String title,
    required String description,
    required Color color,
    required bool isRequired,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isRequired ? AppColors.error.withValues(alpha: 0.3) : AppColors.border,
          width: isRequired ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              size: 24,
              color: color,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                        fontFamily: 'Montserrat',
                      ),
                    ),
                    if (isRequired) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.error,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'REQUIRED',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            fontFamily: 'Montserrat',
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                    fontFamily: 'Montserrat',
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _requestPermissions() async {
    setState(() {
      _isRequesting = true;
    });

    _soundService.playClick();

    // Capture permission service before async operations
    final permissionService = _permissionService;

    try {
      // Request MANDATORY permissions first (Location and Notifications)
      // ignore: use_build_context_synchronously
      final locationGranted = await permissionService.requestLocationPermission(context);
      // ignore: use_build_context_synchronously
      final notificationGranted = await permissionService.requestNotificationPermission(context);

      if (!mounted) return;

      // Check if mandatory permissions are granted
      if (!locationGranted || !notificationGranted) {
        _soundService.playError();
        
        // Show error dialog
        await showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            title: const Text(
              'Required Permissions',
              style: TextStyle(
                fontFamily: 'Montserrat',
                fontWeight: FontWeight.w700,
              ),
            ),
            content: const Text(
              'Location and Notification permissions are required to use Sahara. '
              'Location helps you find nearby caregivers, and notifications keep you updated on bookings.',
              style: TextStyle(fontFamily: 'Montserrat'),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context, false); // Exit app
                },
                child: const Text(
                  'Exit App',
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    color: AppColors.error,
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _requestPermissions(); // Try again
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                ),
                child: const Text(
                  'Try Again',
                  style: TextStyle(fontFamily: 'Montserrat'),
                ),
              ),
            ],
          ),
        );
        return;
      }

      // Request optional permissions (Camera and Photos)
      // ignore: use_build_context_synchronously
      await permissionService.requestCameraPermission(context);
      // ignore: use_build_context_synchronously
      await permissionService.requestPhotosPermission(context);

      if (!mounted) return;

      // Capture navigator before async operations
      final navigator = Navigator.of(context);

      _soundService.playSuccess();
      navigator.pop(true);
    } catch (e) {
      if (!mounted) return;

      // Capture messenger before showing snackbar
      final messenger = ScaffoldMessenger.of(context);

      _soundService.playError();
      messenger.showSnackBar(
        SnackBar(
          content: Text('Error requesting permissions: $e'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isRequesting = false;
        });
      }
    }
  }
}
