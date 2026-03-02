import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Standardized Empty State Widget
/// 
/// Provides consistent empty state UI across the app with:
/// - Illustration icon
/// - Title and description
/// - Optional action button
/// - Consistent styling with theme colors
class EmptyStateWidget extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final String? actionButtonText;
  final VoidCallback? onActionPressed;

  const EmptyStateWidget({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    this.actionButtonText,
    this.onActionPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: AppColors.primaryContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 60,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 24),
            
            // Title
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
                fontFamily: 'Montserrat',
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            
            // Description
            Text(
              description,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
                fontFamily: 'Montserrat',
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            
            // Action button
            if (actionButtonText != null && onActionPressed != null) ...[
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: onActionPressed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  actionButtonText!,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Montserrat',
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

/// Predefined empty states for common scenarios

class NoBookingsEmptyState extends StatelessWidget {
  final VoidCallback? onBookNow;

  const NoBookingsEmptyState({
    super.key,
    this.onBookNow,
  });

  @override
  Widget build(BuildContext context) {
    return EmptyStateWidget(
      icon: Icons.calendar_today_rounded,
      title: 'No Bookings Yet',
      description: 'You haven\'t made any bookings yet.\nStart by booking a service for your pet!',
      actionButtonText: 'Book Now',
      onActionPressed: onBookNow,
    );
  }
}

class NoPetsEmptyState extends StatelessWidget {
  final VoidCallback? onAddPet;

  const NoPetsEmptyState({
    super.key,
    this.onAddPet,
  });

  @override
  Widget build(BuildContext context) {
    return EmptyStateWidget(
      icon: Icons.pets_rounded,
      title: 'No Dogs Added',
      description: 'Add your dogs to get started with\nbooking care services for them.',
      actionButtonText: 'Add Dog',
      onActionPressed: onAddPet,
    );
  }
}

class NoCaregiversEmptyState extends StatelessWidget {
  final VoidCallback? onRefresh;

  const NoCaregiversEmptyState({
    super.key,
    this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return EmptyStateWidget(
      icon: Icons.person_search_rounded,
      title: 'No Caregivers Found',
      description: 'We couldn\'t find any caregivers\nmatching your search criteria.',
      actionButtonText: 'Refresh',
      onActionPressed: onRefresh,
    );
  }
}

class NoMessagesEmptyState extends StatelessWidget {
  const NoMessagesEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return const EmptyStateWidget(
      icon: Icons.chat_bubble_outline_rounded,
      title: 'No Messages',
      description: 'You don\'t have any messages yet.\nStart a conversation with a caregiver!',
    );
  }
}

class NoNotificationsEmptyState extends StatelessWidget {
  const NoNotificationsEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return const EmptyStateWidget(
      icon: Icons.notifications_none_rounded,
      title: 'No Notifications',
      description: 'You\'re all caught up!\nWe\'ll notify you when something new happens.',
    );
  }
}

class SearchEmptyState extends StatelessWidget {
  final String searchQuery;

  const SearchEmptyState({
    super.key,
    required this.searchQuery,
  });

  @override
  Widget build(BuildContext context) {
    return EmptyStateWidget(
      icon: Icons.search_off_rounded,
      title: 'No Results Found',
      description: 'We couldn\'t find anything matching\n"$searchQuery"',
    );
  }
}
