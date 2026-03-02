import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/user_model.dart';
import '../models/review_model.dart';
import '../models/service_package_model.dart';
import '../services/firestore_service.dart';
import '../services/sound_service.dart';
import '../services/package_service.dart';
import '../widgets/custom_button.dart';
import '../theme/app_colors.dart';
import 'messages_coming_soon_screen.dart';
import 'booking_confirmation_screen.dart';

/// Caregiver Detail Screen
/// 
/// Displays comprehensive information about a selected caregiver including:
/// - Profile header with photo, name, location, and availability status
/// - Quick info cards (experience, completed bookings, schedule)
/// - About section with bio
/// - Services offered with icons
/// - Specialties and certifications
/// - Availability schedule
/// - Customer reviews with ratings
/// - Action buttons (message, book now)
/// - Booking dialog for service selection
/// 
/// Design Principles:
/// - Solid colors only (Navy, Orange, Sky Blue, Light Blue)
/// - 8px grid spacing system
/// - Montserrat font family
/// - Responsive layout with CustomScrollView
/// - Professional information hierarchy
/// - Interactive booking flow
/// 
/// Theme Colors:
/// - Background: AppColors.surface (white)
/// - AppBar: AppColors.primary (navy)
/// - Accent elements: AppColors.secondary (orange)
/// - Info cards: AppColors.accent (sky blue)
/// - Success states: AppColors.success (green)
class CaregiverDetailScreen extends StatefulWidget {
  final UserModel caregiver;

  const CaregiverDetailScreen({super.key, required this.caregiver});

  @override
  State<CaregiverDetailScreen> createState() => _CaregiverDetailScreenState();
}

class _CaregiverDetailScreenState extends State<CaregiverDetailScreen> {
  // ============================================================================
  // STATE VARIABLES
  // ============================================================================

  final FirestoreService _firestoreService = FirestoreService();
  final SoundService _soundService = SoundService();
  List<ReviewModel> _reviews = [];
  bool _isLoadingReviews = true;

  // ============================================================================
  // LIFECYCLE METHODS
  // ============================================================================

  @override
  void initState() {
    super.initState();
    _loadReviews();
  }

  // ============================================================================
  // DATA LOADING
  // ============================================================================

  /// Loads reviews for the caregiver from Firestore
  Future<void> _loadReviews() async {
    try {
      final reviews = await _firestoreService.getCaregiverReviews(widget.caregiver.uid);
      if (mounted) {
        setState(() {
          _reviews = reviews;
          _isLoadingReviews = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingReviews = false;
        });
      }
    }
  }

  // ============================================================================
  // ACTION HANDLERS
  // ============================================================================

  /// Handles favorite button press
  void _handleFavorite() {
    _soundService.playTap();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Added to favorites!'),
        backgroundColor: AppColors.success,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  /// Handles share button press
  void _handleShare() {
    _soundService.playTap();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Share profile'),
        backgroundColor: AppColors.info,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  /// Handles message button press
  Future<void> _handleMessage() async {
    _soundService.playClick();
    
    // Navigate to Coming Soon screen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const MessagesComingSoonScreen(),
      ),
    );
  }

  // ============================================================================
  // BUILD METHOD
  // ============================================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: CustomScrollView(
        slivers: [
          _buildAppBar(),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 24),
                  _buildQuickInfo(),
                  const SizedBox(height: 24),
                  _buildAboutSection(),
                  const SizedBox(height: 24),
                  _buildServicesSection(),
                  const SizedBox(height: 24),
                  _buildSpecialtiesSection(),
                  const SizedBox(height: 24),
                  _buildCertificationsSection(),
                  const SizedBox(height: 24),
                  _buildAvailabilitySection(),
                  const SizedBox(height: 24),
                  _buildReviewsSection(),
                  const SizedBox(height: 24),
                  _buildActionButtons(),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================================
  // UI BUILDERS - APP BAR
  // ============================================================================

  /// Builds the collapsible app bar with profile photo
  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 200,
      pinned: true,
      backgroundColor: AppColors.primary,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () {
          _soundService.playTap();
          Navigator.pop(context);
        },
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.favorite_border, color: Colors.white),
          onPressed: _handleFavorite,
        ),
        IconButton(
          icon: const Icon(Icons.share, color: Colors.white),
          onPressed: _handleShare,
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          color: AppColors.primary, // Solid color, no gradient
          child: Center(
            child: Stack(
              children: [
                widget.caregiver.photoUrl != null && widget.caregiver.photoUrl!.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: widget.caregiver.photoUrl!,
                        imageBuilder: (context, imageProvider) => CircleAvatar(
                          radius: 60,
                          backgroundColor: AppColors.surface,
                          backgroundImage: imageProvider,
                        ),
                        placeholder: (context, url) => CircleAvatar(
                          radius: 60,
                          backgroundColor: AppColors.surface,
                          child: const CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                          ),
                        ),
                        errorWidget: (context, url, error) {
                          debugPrint('Error loading profile image: $error');
                          return CircleAvatar(
                            radius: 60,
                            backgroundColor: AppColors.surface,
                            child: const Icon(
                              Icons.person,
                              size: 60,
                              color: AppColors.primary,
                            ),
                          );
                        },
                      )
                    : CircleAvatar(
                        radius: 60,
                        backgroundColor: AppColors.surface,
                        child: const Icon(
                          Icons.person,
                          size: 60,
                          color: AppColors.primary,
                        ),
                      ),
                if (widget.caregiver.isVerified == true)
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: AppColors.success,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.verified,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================================
  // UI BUILDERS - HEADER SECTION
  // ============================================================================

  /// Builds the header with name, location, rating, and price
  Widget _buildHeader() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          widget.caregiver.name,
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Montserrat',
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      if (widget.caregiver.isVerified == true) ...[
                        const SizedBox(width: 8),
                        const Icon(
                          Icons.verified,
                          color: AppColors.success,
                          size: 24,
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.location_on, size: 16, color: AppColors.textTertiary),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          widget.caregiver.location ?? 'Location not specified',
                          style: const TextStyle(
                            fontSize: 14,
                            fontFamily: 'Montserrat',
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: widget.caregiver.isAvailable == true
                    ? AppColors.success.withValues(alpha: 0.1)
                    : AppColors.error.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                widget.caregiver.isAvailable == true ? 'Available' : 'Busy',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Montserrat',
                  color: widget.caregiver.isAvailable == true
                      ? AppColors.success
                      : AppColors.error,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            const Icon(Icons.star, color: AppColors.warning, size: 20),
            const SizedBox(width: 4),
            Text(
              widget.caregiver.rating?.toStringAsFixed(1) ?? '0.0',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                fontFamily: 'Montserrat',
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              '(${widget.caregiver.completedBookings ?? 0} reviews)',
              style: const TextStyle(
                fontSize: 14,
                fontFamily: 'Montserrat',
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ============================================================================
  // UI BUILDERS - QUICK INFO CARDS
  // ============================================================================

  /// Builds the quick info cards (experience, completed, schedule)
  Widget _buildQuickInfo() {
    return Row(
      children: [
        Expanded(
          child: _buildInfoCard(
            Icons.work_outline,
            '${widget.caregiver.yearsOfExperience ?? 0} Years',
            'Experience',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildInfoCard(
            Icons.check_circle_outline,
            '${widget.caregiver.completedBookings ?? 0}',
            'Completed',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildInfoCard(
            Icons.schedule,
            'Flexible',
            'Schedule',
          ),
        ),
      ],
    );
  }

  /// Builds a single info card
  Widget _buildInfoCard(IconData icon, String value, String label) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.accent.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.accent.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        children: [
          Icon(icon, color: AppColors.accent, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              fontFamily: 'Montserrat',
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontFamily: 'Montserrat',
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================================
  // UI BUILDERS - ABOUT SECTION
  // ============================================================================

  /// Builds the about section with bio
  Widget _buildAboutSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'About',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            fontFamily: 'Montserrat',
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          widget.caregiver.bio ?? 'No bio available',
          style: const TextStyle(
            fontSize: 14,
            fontFamily: 'Montserrat',
            color: AppColors.textSecondary,
            height: 1.6,
          ),
        ),
      ],
    );
  }

  // ============================================================================
  // UI BUILDERS - SERVICES SECTION
  // ============================================================================

  /// Builds the services offered section
  Widget _buildServicesSection() {
    if (widget.caregiver.services == null || widget.caregiver.services!.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Services Offered',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            fontFamily: 'Montserrat',
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: widget.caregiver.services!.map((service) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _getServiceIcon(service),
                    size: 16,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    service,
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Montserrat',
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  // ============================================================================
  // UI BUILDERS - SPECIALTIES SECTION
  // ============================================================================

  /// Builds the specialties section
  Widget _buildSpecialtiesSection() {
    if (widget.caregiver.specialties == null || widget.caregiver.specialties!.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Specialties',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            fontFamily: 'Montserrat',
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: widget.caregiver.specialties!.map((specialty) {
            return Chip(
              label: Text(specialty),
              backgroundColor: AppColors.success.withValues(alpha: 0.1),
              labelStyle: const TextStyle(
                color: AppColors.success,
                fontWeight: FontWeight.w600,
                fontFamily: 'Montserrat',
                fontSize: 12,
              ),
              side: BorderSide.none,
            );
          }).toList(),
        ),
      ],
    );
  }

  // ============================================================================
  // UI BUILDERS - CERTIFICATIONS SECTION
  // ============================================================================

  /// Builds the certifications section
  Widget _buildCertificationsSection() {
    if (widget.caregiver.certifications == null || widget.caregiver.certifications!.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Certifications',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            fontFamily: 'Montserrat',
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        ...widget.caregiver.certifications!.map((cert) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.workspace_premium,
                    color: AppColors.warning,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    cert,
                    style: const TextStyle(
                      fontSize: 14,
                      fontFamily: 'Montserrat',
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  // ============================================================================
  // UI BUILDERS - AVAILABILITY SECTION
  // ============================================================================

  /// Builds the availability schedule section
  Widget _buildAvailabilitySection() {
    if (widget.caregiver.availability == null || widget.caregiver.availability!.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Availability',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            fontFamily: 'Montserrat',
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.border,
            ),
          ),
          child: Column(
            children: widget.caregiver.availability!.entries.map((entry) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: AppColors.border,
                      width: 1,
                    ),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      entry.key,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Montserrat',
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      entry.value,
                      style: const TextStyle(
                        fontSize: 14,
                        fontFamily: 'Montserrat',
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  // ============================================================================
  // UI BUILDERS - REVIEWS SECTION
  // ============================================================================

  /// Builds the reviews section with customer feedback
  Widget _buildReviewsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Reviews',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                fontFamily: 'Montserrat',
                color: AppColors.textPrimary,
              ),
            ),
            if (_reviews.isNotEmpty)
              TextButton(
                onPressed: () {
                  _soundService.playTap();
                  // Show all reviews
                },
                child: const Text(
                  'See All',
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    color: AppColors.primary,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        if (_isLoadingReviews)
          const Center(
            child: CircularProgressIndicator(
              color: AppColors.primary,
            ),
          )
        else if (_reviews.isEmpty)
          const Text(
            'No reviews yet',
            style: TextStyle(
              fontSize: 14,
              fontFamily: 'Montserrat',
              color: AppColors.textSecondary,
            ),
          )
        else
          ..._reviews.take(3).map((review) => _buildReviewCard(review)),
      ],
    );
  }

  /// Builds a single review card
  Widget _buildReviewCard(ReviewModel review) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.border,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                child: Text(
                  review.ownerName[0].toUpperCase(),
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Montserrat',
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.ownerName,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Montserrat',
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      DateFormat('MMM dd, yyyy').format(review.createdAt),
                      style: const TextStyle(
                        fontSize: 12,
                        fontFamily: 'Montserrat',
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  const Icon(Icons.star, color: AppColors.warning, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    review.rating.toStringAsFixed(1),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Montserrat',
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            review.comment,
            style: const TextStyle(
              fontSize: 14,
              fontFamily: 'Montserrat',
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================================
  // UI BUILDERS - ACTION BUTTONS
  // ============================================================================

  /// Builds the action buttons (message, book now)
  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: CustomButton(
            text: 'Message',
            backgroundColor: AppColors.surface,
            textColor: AppColors.primary,
            onPressed: _handleMessage,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: CustomButton(
            text: 'Book Now',
            onPressed: widget.caregiver.isAvailable == true
                ? () => _showBookingDialog(context)
                : null,
          ),
        ),
      ],
    );
  }

  // ============================================================================
  // BOOKING DIALOG
  // ============================================================================

  /// Shows the booking dialog for service and package selection
  void _showBookingDialog(BuildContext context) {
    _soundService.playClick();
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => _ServicePackageSelectionScreen(
          caregiver: widget.caregiver,
        ),
      ),
    );
  }

  // ============================================================================
  // HELPER METHODS
  // ============================================================================

  /// Returns the appropriate icon for a service
  IconData _getServiceIcon(String service) {
    switch (service.toLowerCase()) {
      case 'dog walking':
        return Icons.directions_walk;
      case 'pet sitting':
        return Icons.home;
      case 'grooming':
        return Icons.content_cut;
      case 'training':
        return Icons.school;
      case 'vet visit':
      case 'medication administration':
        return Icons.local_hospital;
      case 'pet transportation':
        return Icons.directions_car;
      case 'overnight care':
        return Icons.nightlight;
      case 'bathing':
        return Icons.shower;
      case 'nail trimming':
        return Icons.cut;
      default:
        return Icons.pets;
    }
  }
}


// ============================================================================
// SERVICE & PACKAGE SELECTION SCREEN (FOR DIRECT BOOKING FROM CAREGIVER PROFILE)
// ============================================================================

/// Service and Package Selection Screen for direct booking from caregiver profile
class _ServicePackageSelectionScreen extends StatefulWidget {
  final UserModel caregiver;

  const _ServicePackageSelectionScreen({required this.caregiver});

  @override
  State<_ServicePackageSelectionScreen> createState() => _ServicePackageSelectionScreenState();
}

class _ServicePackageSelectionScreenState extends State<_ServicePackageSelectionScreen> {
  String? _selectedService;
  ServicePackageModel? _selectedPackage;
  List<ServicePackageModel>? _cachedPackages;
  bool _isLoadingPackages = false;
  
  final PackageService _packageService = PackageService();
  final SoundService _soundService = SoundService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: const Text(
          'Select Service & Package',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontFamily: 'Montserrat',
          ),
        ),
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Caregiver info card
                    _buildCaregiverCard(),
                    const SizedBox(height: 24),
                    
                    // Service selection
                    const Text(
                      'Choose Service',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                        fontFamily: 'Montserrat',
                        letterSpacing: -0.4,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Select the service you need',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                        fontFamily: 'Montserrat',
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Service cards
                    ...?widget.caregiver.services?.map((service) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _buildServiceCard(service),
                    )),
                    
                    // Package selection (shown after service selected)
                    if (_selectedService != null) ...[
                      const SizedBox(height: 24),
                      const Text(
                        'Choose Package',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                          fontFamily: 'Montserrat',
                          letterSpacing: -0.4,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Select the package that best fits your needs',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                          fontFamily: 'Montserrat',
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      if (_isLoadingPackages)
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.all(32.0),
                            child: CircularProgressIndicator(color: AppColors.primary),
                          ),
                        )
                      else if (_cachedPackages != null && _cachedPackages!.isNotEmpty)
                        ..._cachedPackages!.map((package) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: _buildPackageCard(package),
                        ))
                      else
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.all(32.0),
                            child: Text(
                              'No packages available for this service',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                                fontFamily: 'Montserrat',
                              ),
                            ),
                          ),
                        ),
                    ],
                  ],
                ),
              ),
            ),
            
            // Continue button (shown when both service and package selected)
            if (_selectedService != null && _selectedPackage != null)
              _buildContinueButton(),
          ],
        ),
      ),
    );
  }

  /// Build caregiver info card
  Widget _buildCaregiverCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primaryContainer,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: AppColors.primary,
            backgroundImage: widget.caregiver.photoUrl != null
                ? NetworkImage(widget.caregiver.photoUrl!)
                : null,
            child: widget.caregiver.photoUrl == null
                ? const Icon(Icons.person, color: Colors.white, size: 30)
                : null,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        widget.caregiver.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                          fontFamily: 'Montserrat',
                        ),
                      ),
                    ),
                    if (widget.caregiver.isVerified == true)
                      const Icon(
                        Icons.verified,
                        size: 18,
                        color: AppColors.success,
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.star, size: 14, color: AppColors.star),
                    const SizedBox(width: 4),
                    Text(
                      widget.caregiver.rating?.toStringAsFixed(1) ?? 'N/A',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                        fontFamily: 'Montserrat',
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${widget.caregiver.yearsOfExperience ?? 0} years exp',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[600],
                        fontFamily: 'Montserrat',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Build service card
  Widget _buildServiceCard(String service) {
    final isSelected = _selectedService == service;

    return GestureDetector(
      onTap: () async {
        _soundService.playTap();
        setState(() {
          _selectedService = service;
          _selectedPackage = null; // Reset package selection
          _isLoadingPackages = true;
        });
        
        // Load packages for selected service
        try {
          final packages = await _packageService.getPackagesForService(service);
          setState(() {
            _cachedPackages = packages;
            _isLoadingPackages = false;
          });
        } catch (e) {
          setState(() {
            _cachedPackages = [];
            _isLoadingPackages = false;
          });
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.grey[200]!,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: isSelected ? 0.06 : 0.03),
              blurRadius: isSelected ? 12 : 8,
              offset: Offset(0, isSelected ? 4 : 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : AppColors.primaryContainer,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                _getServiceIcon(service),
                color: isSelected ? Colors.white : AppColors.primary,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                service,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? AppColors.primary : AppColors.textPrimary,
                  fontFamily: 'Montserrat',
                ),
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check_circle,
                color: AppColors.primary,
                size: 24,
              ),
          ],
        ),
      ),
    );
  }

  /// Build package card
  Widget _buildPackageCard(ServicePackageModel package) {
    final isSelected = _selectedPackage?.id == package.id;

    return GestureDetector(
      onTap: () {
        _soundService.playTap();
        setState(() {
          _selectedPackage = package;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.grey[200]!,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: isSelected ? 0.06 : 0.03),
              blurRadius: isSelected ? 12 : 8,
              offset: Offset(0, isSelected ? 4 : 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            package.packageName,
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                              fontFamily: 'Montserrat',
                            ),
                          ),
                          if (package.isPopular) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text(
                                'POPULAR',
                                style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                  letterSpacing: 0.5,
                                  fontFamily: 'Montserrat',
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(
                        package.duration,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                          fontFamily: 'Montserrat',
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '₹${package.price.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                        fontFamily: 'Montserrat',
                      ),
                    ),
                    if (package.discount != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF4CAF50).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          package.discount!,
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF4CAF50),
                            fontFamily: 'Montserrat',
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              package.description,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[600],
                fontFamily: 'Montserrat',
              ),
            ),
            const SizedBox(height: 12),
            Divider(height: 1, color: Colors.grey[200]),
            const SizedBox(height: 12),
            const Text(
              'Includes:',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
                fontFamily: 'Montserrat',
              ),
            ),
            const SizedBox(height: 10),
            ...package.features.map((feature) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                children: [
                  Container(
                    width: 18,
                    height: 18,
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primary : Colors.grey[200],
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.check_rounded,
                      size: 12,
                      color: isSelected ? Colors.white : Colors.grey[500],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      feature,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[700],
                        fontFamily: 'Montserrat',
                      ),
                    ),
                  ),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }

  /// Build continue button
  Widget _buildContinueButton() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey[200]!)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _selectedService!,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                        fontFamily: 'Montserrat',
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      _selectedPackage!.packageName,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                        fontFamily: 'Montserrat',
                      ),
                    ),
                  ],
                ),
                Text(
                  '₹${_selectedPackage!.price.toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                    fontFamily: 'Montserrat',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  _soundService.playClick();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => BookingConfirmationScreen(
                        selectedCaregiver: widget.caregiver,
                        serviceType: _selectedService!,
                        selectedPackage: _selectedPackage!,
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Continue to Booking',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Montserrat',
                      ),
                    ),
                    SizedBox(width: 8),
                    Icon(Icons.arrow_forward_rounded, size: 18),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Get service icon
  IconData _getServiceIcon(String service) {
    switch (service.toLowerCase()) {
      case 'dog walking':
        return Icons.directions_walk;
      case 'dog sitting':
      case 'pet sitting':
        return Icons.home;
      case 'dog grooming':
      case 'grooming':
        return Icons.content_cut;
      case 'dog training':
      case 'training':
        return Icons.school;
      case 'vet visit':
      case 'vet visit companion':
        return Icons.local_hospital;
      case 'dog transportation':
        return Icons.directions_car;
      default:
        return Icons.pets;
    }
  }
}
