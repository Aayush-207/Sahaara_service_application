import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../providers/auth_provider.dart';
import '../providers/favorites_provider.dart';
import '../models/user_model.dart';
import '../services/sound_service.dart';
import '../theme/app_colors.dart';
import 'service_selection_screen.dart';
import 'caregiver_detail_screen.dart';

/// Favourites Screen - Display all favourite caregivers
/// 
/// This screen displays all caregivers marked as favorites by the user.
/// Users can view caregiver information, book services, or remove from favorites.
/// 
/// Features:
/// - List of all favourite caregivers in card format
/// - Caregiver information (name, photo, rating, services)
/// - Quick book button for each caregiver
/// - Remove from favorites button
/// - Empty state when no favorites
/// - Loading state while fetching data
/// - Pull-to-refresh functionality
class FavouritesScreen extends StatefulWidget {
  const FavouritesScreen({super.key});

  @override
  State<FavouritesScreen> createState() => _FavouritesScreenState();
}

class _FavouritesScreenState extends State<FavouritesScreen> {
  final SoundService _soundService = SoundService();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userId = authProvider.currentUser?.uid;

    if (userId != null) {
      await Provider.of<FavoritesProvider>(context, listen: false)
          .loadFavorites(userId);
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final favoritesProvider = Provider.of<FavoritesProvider>(context);
    final userId = authProvider.currentUser?.uid;

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: const Text(
          'Favourite Caregivers',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontFamily: 'Montserrat',
          ),
        ),
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  color: AppColors.primary,
                  strokeWidth: 2,
                ),
              )
            : favoritesProvider.favoriteCaregivers.isEmpty
                ? _buildEmptyState()
                : RefreshIndicator(
                    onRefresh: _loadFavorites,
                    color: AppColors.primary,
                    child: ListView.separated(
                      padding: const EdgeInsets.all(20),
                      itemCount: favoritesProvider.favoriteCaregivers.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final caregiver =
                            favoritesProvider.favoriteCaregivers[index];
                        return _buildCaregiverCard(
                          context,
                          caregiver,
                          userId,
                          favoritesProvider,
                        );
                      },
                    ),
                  ),
      ),
    );
  }

  /// Build empty state when no favorites
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: AppColors.background,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.favorite_outline_rounded,
              size: 52,
              color: AppColors.textTertiary,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'No favourite caregivers yet',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
              fontFamily: 'Montserrat',
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Add caregivers to your favorites for quick access',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
              fontFamily: 'Montserrat',
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 28),
          ElevatedButton(
            onPressed: () {
              _soundService.playTap();
              Navigator.of(context).pushReplacementNamed('/');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: 32,
                vertical: 12,
              ),
            ),
            child: const Text(
              'Browse Caregivers',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontFamily: 'Montserrat',
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Build individual caregiver card
  Widget _buildCaregiverCard(
    BuildContext context,
    UserModel caregiver,
    String? userId,
    FavoritesProvider favoritesProvider,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!, width: 1),
        boxShadow: [
          BoxShadow(
            color: AppColors.textPrimary.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          children: [
            // Header with profile and info
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Profile Picture
                GestureDetector(
                  onTap: () {
                    _soundService.playTap();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            CaregiverDetailScreen(caregiver: caregiver),
                      ),
                    );
                  },
                  child: Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      image: caregiver.photoUrl != null &&
                              caregiver.photoUrl!.isNotEmpty
                          ? DecorationImage(
                              image: CachedNetworkImageProvider(
                                caregiver.photoUrl!,
                              ),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    child: caregiver.photoUrl == null ||
                            caregiver.photoUrl!.isEmpty
                        ? Icon(
                            Icons.person_rounded,
                            size: 28,
                            color: AppColors.primary.withValues(alpha: 0.6),
                          )
                        : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              caregiver.name,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                                fontFamily: 'Montserrat',
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (caregiver.isVerified ?? false) ...[
                            const SizedBox(width: 6),
                            Icon(
                              Icons.verified_rounded,
                              size: 18,
                              color: AppColors.success,
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),
                      // Rating and completed bookings
                      Row(
                        children: [
                          Icon(
                            Icons.star_rounded,
                            size: 14,
                            color: Colors.amber[600],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${caregiver.rating?.toStringAsFixed(1) ?? 'N/A'} • ${caregiver.completedBookings ?? 0} bookings',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                              fontFamily: 'Montserrat',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      // Location
                      if (caregiver.location != null) ...[
                        Row(
                          children: [
                            const Icon(
                              Icons.location_on_rounded,
                              size: 12,
                              color: AppColors.textTertiary,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                caregiver.location!,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textTertiary,
                                  fontFamily: 'Montserrat',
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Services
            if (caregiver.services != null && caregiver.services!.isNotEmpty) ...[
              Align(
                alignment: Alignment.centerLeft,
                child: Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: caregiver.services!.map((service) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        service,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: AppColors.primary,
                          fontFamily: 'Montserrat',
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 12),
            ],

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      _soundService.playTap();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ServiceSelectionScreen(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                    child: const Text(
                      'Book',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        fontFamily: 'Montserrat',
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: IconButton(
                    onPressed: () async {
                      _soundService.playTap();
                      if (userId != null) {
                        await favoritesProvider.removeFavorite(
                          userId,
                          caregiver.uid,
                        );
                        if (mounted && context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Removed from favorites',
                              ),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        }
                      }
                    },
                    icon: const Icon(
                      Icons.favorite_rounded,
                      color: AppColors.error,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
