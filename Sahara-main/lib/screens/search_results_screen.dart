import 'package:flutter/material.dart';
import '../models/user_model.dart';
import 'caregiver_detail_screen.dart';
import '../theme/app_colors.dart';

class SearchResultsScreen extends StatelessWidget {
  final String query;
  final List<UserModel> results;

  const SearchResultsScreen({
    super.key,
    required this.query,
    required this.results,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: Text(
          'Search: "$query"',
          style: const TextStyle(
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.w700,
          ),
        ),
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      body: results.isEmpty
          ? _buildEmptyState()
          : ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: results.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _buildCaregiverCard(context, results[index]),
                );
              },
            ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.search_off_rounded,
              size: 52,
              color: Colors.grey[400],
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'No results found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
              fontFamily: 'Montserrat',
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Try searching with different keywords',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              fontFamily: 'Montserrat',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCaregiverCard(BuildContext context, UserModel caregiver) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => CaregiverDetailScreen(caregiver: caregiver),
          ),
        );
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(14),
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
        child: Row(
          children: [
            // Profile Picture
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
                image: caregiver.photoUrl != null && caregiver.photoUrl!.isNotEmpty
                    ? DecorationImage(
                        image: NetworkImage(caregiver.photoUrl!),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: caregiver.photoUrl == null || caregiver.photoUrl!.isEmpty
                  ? Icon(
                      Icons.person_rounded,
                      size: 24,
                      color: AppColors.primary.withValues(alpha: 0.6),
                    )
                  : null,
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
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                            fontFamily: 'Montserrat',
                          ),
                        ),
                      ),
                      if (caregiver.isVerified == true)
                        const Icon(
                          Icons.verified_rounded,
                          size: 16,
                          color: AppColors.primary,
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.star_rounded, size: 13, color: Colors.amber),
                      const SizedBox(width: 4),
                      Text(
                        '${caregiver.rating?.toStringAsFixed(1) ?? '0.0'} • ${caregiver.completedBookings ?? 0} bookings',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                          fontFamily: 'Montserrat',
                        ),
                      ),
                    ],
                  ),
                  if (caregiver.location != null) ...[
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        Icon(Icons.location_on_outlined, size: 12, color: Colors.grey[500]),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            caregiver.location!,
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey[500],
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
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.secondary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '${caregiver.yearsOfExperience ?? 0} yrs',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.secondary,
                      fontFamily: 'Montserrat',
                    ),
                  ),
                ),
                if (caregiver.isAvailable == true) ...[
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.success.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            color: AppColors.success,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Text(
                          'Available',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w600,
                            color: AppColors.success,
                            fontFamily: 'Montserrat',
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
