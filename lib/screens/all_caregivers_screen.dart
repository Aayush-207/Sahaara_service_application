import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/user_model.dart';
import '../services/firestore_service.dart';
import '../widgets/filter_bottom_sheet.dart';
import '../providers/auth_provider.dart';
import '../providers/favorites_provider.dart';
import 'caregiver_detail_screen.dart';
import '../theme/app_colors.dart';

class AllCaregiversScreen extends StatefulWidget {
  final String? serviceType;

  const AllCaregiversScreen({super.key, this.serviceType});

  @override
  State<AllCaregiversScreen> createState() => _AllCaregiversScreenState();
}

class _AllCaregiversScreenState extends State<AllCaregiversScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  List<UserModel> _allCaregivers = [];
  List<UserModel> _filteredCaregivers = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCaregivers();
  }

  Future<void> _loadCaregivers() async {
    setState(() => _isLoading = true);
    
    final caregivers = await _firestoreService.getTopCaregivers(limit: 50);
    
    setState(() {
      _allCaregivers = caregivers;
      _filteredCaregivers = widget.serviceType != null
          ? caregivers.where((c) => 
              c.services?.any((s) => s.toLowerCase().contains(widget.serviceType!.toLowerCase())) ?? false
            ).toList()
          : caregivers;
      _isLoading = false;
    });
  }

  void _applyFilters(Map<String, dynamic> filters) {
    setState(() {
      _filteredCaregivers = _allCaregivers.where((caregiver) {
        // Rating filter
        final rating = caregiver.rating ?? 0.0;
        if (rating < filters['rating']) {
          return false;
        }

        // Service filter
        final selectedServices = filters['services'] as List<String>;
        if (selectedServices.isNotEmpty) {
          final hasService = caregiver.services?.any((service) =>
            selectedServices.any((selected) => 
              service.toLowerCase().contains(selected.toLowerCase())
            )
          ) ?? false;
          if (!hasService) return false;
        }

        return true;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: Text(
          widget.serviceType ?? 'All Caregivers',
          style: const TextStyle(
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.w700,
          ),
        ),
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.tune_rounded),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (_) => FilterBottomSheet(
                  onApplyFilters: _applyFilters,
                ),
              );
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: AppColors.textPrimary,
                strokeWidth: 2,
              ),
            )
          : _filteredCaregivers.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  onRefresh: _loadCaregivers,
                  color: AppColors.textPrimary,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(20),
                    itemCount: _filteredCaregivers.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: _buildCaregiverCard(_filteredCaregivers[index]),
                      );
                    },
                  ),
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
              Icons.person_search_rounded,
              size: 52,
              color: Colors.grey[400],
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'No caregivers found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
              fontFamily: 'Montserrat',
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Try adjusting your filters',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              fontFamily: 'Montserrat',
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _filteredCaregivers = _allCaregivers;
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.textPrimary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Clear Filters',
              style: TextStyle(fontFamily: 'Montserrat'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCaregiverCard(UserModel caregiver) {
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
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.textPrimary, Color(0xFF2A2A2A)],
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: caregiver.photoUrl != null && caregiver.photoUrl!.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: caregiver.photoUrl!,
                            fit: BoxFit.cover,
                            width: 52,
                            height: 52,
                            placeholder: (context, url) => Container(
                              color: AppColors.textPrimary,
                              child: const Center(
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              ),
                            ),
                            errorWidget: (context, url, error) {
                              debugPrint('Error loading caregiver image: $error');
                              return const Icon(Icons.person_rounded, size: 24, color: Colors.white);
                            },
                          )
                        : const Icon(Icons.person_rounded, size: 24, color: Colors.white),
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
                              color: AppColors.textPrimary,
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.star_rounded, size: 13, color: AppColors.textPrimary),
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
                    ],
                  ),
                ),
                Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${caregiver.yearsOfExperience ?? 0} yrs exp',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.secondary,
                            fontFamily: 'Montserrat',
                          ),
                        ),
                      ],
                    ),
                    Consumer<FavoritesProvider>(
                      builder: (context, favProvider, _) {
                        final authProvider = Provider.of<AuthProvider>(context, listen: false);
                        final userId = authProvider.currentUser?.uid ?? '';
                        final isFav = favProvider.isFavorite(caregiver.uid);
                        
                        return IconButton(
                          icon: Icon(
                            isFav ? Icons.favorite : Icons.favorite_border,
                            color: isFav ? AppColors.error : AppColors.textTertiary,
                            size: 20,
                          ),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          onPressed: () async {
                            if (userId.isEmpty) return;
                            await favProvider.toggleFavorite(userId, caregiver.uid);
                          },
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
            if (caregiver.services != null && caregiver.services!.isNotEmpty) ...[
              const SizedBox(height: 10),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: caregiver.services!.take(3).map((service) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      service,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Montserrat',
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
