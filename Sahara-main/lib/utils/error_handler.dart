import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Global Error Handler
/// Provides consistent error handling across the app
class ErrorHandler {
  /// Show error snackbar
  static void showError(BuildContext context, String message, {Duration? duration}) {
    if (!context.mounted) return;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: duration ?? const Duration(seconds: 4),
        action: SnackBarAction(
          label: 'Dismiss',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  /// Show success snackbar
  static void showSuccess(BuildContext context, String message, {Duration? duration}) {
    if (!context.mounted) return;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_outline, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: duration ?? const Duration(seconds: 3),
      ),
    );
  }

  /// Show warning snackbar
  static void showWarning(BuildContext context, String message, {Duration? duration}) {
    if (!context.mounted) return;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.warning_amber_rounded, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.warning,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: duration ?? const Duration(seconds: 3),
      ),
    );
  }

  /// Parse Firebase error messages to user-friendly text
  static String parseFirebaseError(dynamic error) {
    final errorMessage = error.toString().toLowerCase();
    
    if (errorMessage.contains('network')) {
      return 'Network error. Please check your internet connection.';
    } else if (errorMessage.contains('permission-denied')) {
      return 'Permission denied. Please check your account permissions.';
    } else if (errorMessage.contains('not-found')) {
      return 'The requested data was not found.';
    } else if (errorMessage.contains('already-exists')) {
      return 'This item already exists.';
    } else if (errorMessage.contains('invalid-email')) {
      return 'Invalid email address.';
    } else if (errorMessage.contains('user-not-found')) {
      return 'User not found. Please check your credentials.';
    } else if (errorMessage.contains('wrong-password')) {
      return 'Incorrect password. Please try again.';
    } else if (errorMessage.contains('weak-password')) {
      return 'Password is too weak. Use at least 6 characters.';
    } else if (errorMessage.contains('email-already-in-use')) {
      return 'This email is already registered.';
    } else if (errorMessage.contains('too-many-requests')) {
      return 'Too many attempts. Please try again later.';
    } else if (errorMessage.contains('timeout')) {
      return 'Request timed out. Please try again.';
    }
    
    return 'An error occurred. Please try again.';
  }

  /// Show error dialog with retry option
  static Future<bool?> showErrorDialog(
    BuildContext context, {
    required String title,
    required String message,
    bool showRetry = true,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.errorContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.error_outline,
                color: AppColors.error,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                ),
              ),
            ),
          ],
        ),
        content: Text(
          message,
          style: const TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 14,
            color: AppColors.textSecondary,
          ),
        ),
        actions: [
          if (showRetry)
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primary,
              ),
              child: const Text(
                'Retry',
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.textSecondary,
            ),
            child: const Text(
              'Cancel',
              style: TextStyle(
                fontFamily: 'Montserrat',
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
