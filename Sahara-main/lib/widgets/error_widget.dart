import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Standardized Error Widget
/// 
/// Provides consistent error UI across the app with:
/// - Error icon
/// - Error message
/// - Optional retry button
/// - Consistent styling with theme colors
class ErrorDisplayWidget extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;
  final IconData icon;
  final String? retryButtonText;

  const ErrorDisplayWidget({
    super.key,
    required this.message,
    this.onRetry,
    this.icon = Icons.error_outline_rounded,
    this.retryButtonText,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Error icon
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.errorContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 40,
                color: AppColors.error,
              ),
            ),
            const SizedBox(height: 24),
            
            // Error message
            Text(
              message,
              style: const TextStyle(
                fontSize: 16,
                color: AppColors.textPrimary,
                fontFamily: 'Montserrat',
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
            
            // Retry button
            if (onRetry != null) ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded, size: 20),
                label: Text(retryButtonText ?? 'Try Again'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Inline error message (for forms, etc.)
class InlineErrorWidget extends StatelessWidget {
  final String message;
  final IconData icon;

  const InlineErrorWidget({
    super.key,
    required this.message,
    this.icon = Icons.error_outline_rounded,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.errorContainer,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: AppColors.error,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.error,
                fontFamily: 'Montserrat',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Network error widget
class NetworkErrorWidget extends StatelessWidget {
  final VoidCallback? onRetry;

  const NetworkErrorWidget({
    super.key,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return ErrorDisplayWidget(
      message: 'No internet connection.\nPlease check your network and try again.',
      icon: Icons.wifi_off_rounded,
      onRetry: onRetry,
      retryButtonText: 'Retry',
    );
  }
}
