import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../models/service_package_model.dart';
import '../models/user_model.dart';
import '../services/firestore_service.dart';
import 'booking_confirmation_screen.dart';

/// Caregiver Selection Screen - Browse and select pet caregivers
/// 
/// This screen allows users to browse available caregivers for their selected
/// service and package, then choose one to proceed with booking.
/// 
/// Design Principles:
/// - Package summary at top for context
/// - Card-based caregiver list with selection state
/// - Visual indicators for verified and available caregivers
/// - Busy caregivers shown but disabled
/// - Sticky bottom bar with continue button
/// - Consistent theme colors (Navy primary)
/// - Responsive layout for all screen sizes
/// - 8px grid spacing system
/// - Smooth animations on selection
/// 
/// Features:
/// - Package summary card at top
/// - Caregiver cards with selection state
/// - Verified badge for verified caregivers
/// - Availability status (Available/Busy)
/// - Rating and booking count display
/// - Location display
/// - Selected caregiver indicator (checkmark)
/// - Empty state when no caregivers available
/// - Continue button (only shown when caregiver selected)
/// - Navigation to booking confirmation
/// 
/// Backend Integration:
/// - FirestoreService.searchCaregiversByService() - Fetches caregivers by service
/// - Returns List with UserModel caregiver data
/// - Loading state with CircularProgressIndicator
/// - Empty state handling
/// 
/// Navigation Flow:
/// Package Selection → Caregiver Selection → Booking Confirmation
/// 
/// Theme Colors Used:
/// - Background: Surface (white)
/// - AppBar: Default with Text Primary
/// - Package summary: Primary (Navy)
/// - Selected border: Text Primary (Navy)
/// - Unselected border: Border (light gray)
/// - Verified badge: Success (green)
/// - Busy badge: Error (red) with light background
/// - Caregiver avatar: Primary (Navy)
/// - Selected checkmark: Primary (Navy)
/// - Continue button: Primary (Navy)
/// 
/// Animations:
/// - Card selection: 200ms border and shadow transition
/// - Opacity: 0.5 for busy caregivers
class CaregiverSelectionScreen extends StatefulWidget {
  /// Service type selected from previous screens
  final String serviceType;
  
  /// Package selected from previous screen
  final ServicePackageModel selectedPackage;

  const CaregiverSelectionScreen({
    super.key,
    required this.serviceType,
    required this.selectedPackage,
  });

  @override
  State<CaregiverSelectionScreen> createState() => _CaregiverSelectionScreenState();
}

class _CaregiverSelectionScreenState extends State<CaregiverSelectionScreen> {
  // ============================================================================
  // STATE VARIABLES
  // ============================================================================
  
  /// Firestore service for data fetching
  final FirestoreService _firestoreService = FirestoreService();
  
  /// Currently selected caregiver (null if none selected)
  UserModel? _selectedCaregiver;
  
  /// List of caregivers
  List<UserModel> _caregivers = [];
  
  /// Loading state
  bool _isLoading = true;
  
  /// Error message
  String? _errorMessage;

  // ============================================================================
  // LIFECYCLE METHODS
  // ============================================================================
  
  @override
  void initState() {
    super.initState();
    _loadCaregivers();
  }
  
  /// Load caregivers once on screen init
  Future<void> _loadCaregivers() async {
    try {
      final caregivers = await _firestoreService.searchCaregiversByService(widget.serviceType);
      if (mounted) {
        setState(() {
          _caregivers = caregivers;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to load caregivers: $e';
          _isLoading = false;
        });
      }
    }
  }

  // ============================================================================
  // BUILD METHOD
  // ============================================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: const Text(
          'Select Caregiver',
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
        child: Column(
          children: [
            // Package summary card at top
            _buildPackageSummary(),
            
            // Caregiver list with loading/empty states
            Expanded(
              child: _buildCaregiverList(),
            ),
            
            // Sticky bottom bar with continue button (only shown when caregiver selected)
            if (_selectedCaregiver != null) _buildContinueButton(),
          ],
        ),
      ),
    );
  }
  
  /// Build caregiver list based on loading state
  Widget _buildCaregiverList() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: AppColors.primary,
          strokeWidth: 2,
        ),
      );
    }
    
    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              size: 48,
              color: AppColors.error,
            ),
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 15,
                color: AppColors.textSecondary,
                fontFamily: 'Montserrat',
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _isLoading = true;
                  _errorMessage = null;
                });
                _loadCaregivers();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }
    
    if (_caregivers.isEmpty) {
      return _buildEmptyState();
    }
    
    return ListView.builder(
      padding: const EdgeInsets.all(24),
      itemCount: _caregivers.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: _buildCaregiverCard(_caregivers[index]),
        );
      },
    );
  }

  // ============================================================================
  // UI BUILDER METHODS
  // ============================================================================

  /// Build package summary card at top
  Widget _buildPackageSummary() {
    return Container(
      margin: const EdgeInsets.all(24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Selected Package',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white70,
                    fontFamily: 'Montserrat',
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.selectedPackage.packageName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    fontFamily: 'Montserrat',
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  widget.selectedPackage.duration,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.white70,
                    fontFamily: 'Montserrat',
                  ),
                ),
              ],
            ),
          ),
          Text(
            '₹${widget.selectedPackage.price.toStringAsFixed(0)}',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              fontFamily: 'Montserrat',
            ),
          ),
        ],
      ),
    );
  }

  /// Build empty state when no caregivers available
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.textTertiary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.person_search_rounded,
              size: 48,
              color: AppColors.textTertiary,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'No caregivers available',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
              fontFamily: 'Montserrat',
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try selecting a different service',
            style: TextStyle(
              fontSize: 15,
              color: AppColors.textSecondary,
              fontFamily: 'Montserrat',
            ),
          ),
        ],
      ),
    );
  }

  /// Build individual caregiver card with selection state
  Widget _buildCaregiverCard(UserModel caregiver) {
    final isSelected = _selectedCaregiver?.uid == caregiver.uid;
    final isAvailable = caregiver.isAvailable == true;

    return GestureDetector(
      onTap: isAvailable
          ? () {
              setState(() {
                _selectedCaregiver = caregiver;
              });
            }
          : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.textPrimary : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: isSelected ? 0.08 : 0.04),
              blurRadius: isSelected ? 16 : 10,
              offset: Offset(0, isSelected ? 6 : 4),
            ),
          ],
        ),
        child: Opacity(
          opacity: isAvailable ? 1.0 : 0.5,
          child: Row(
            children: [
              // Caregiver avatar with verified badge
              Stack(
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.person_rounded,
                      size: 32,
                      color: Colors.white,
                    ),
                  ),
                  if (caregiver.isVerified == true)
                    Positioned(
                      right: -2,
                      top: -2,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: AppColors.success,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.check_rounded,
                          size: 12,
                          color: Colors.white,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 16),
              
              // Caregiver info
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
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                              fontFamily: 'Montserrat',
                            ),
                          ),
                        ),
                        if (!isAvailable)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.error.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              'Busy',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: AppColors.error,
                                fontFamily: 'Montserrat',
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(
                          Icons.star_rounded,
                          size: 16,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${caregiver.rating?.toStringAsFixed(1) ?? '0.0'} • ${caregiver.completedBookings ?? 0} bookings',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                            fontFamily: 'Montserrat',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      caregiver.location ?? 'Location not specified',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textTertiary,
                        fontFamily: 'Montserrat',
                      ),
                    ),
                  ],
                ),
              ),
              
              // Selected indicator
              if (isSelected)
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_rounded,
                    size: 20,
                    color: Colors.white,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  /// Build sticky bottom bar with continue button
  Widget _buildContinueButton() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppColors.border)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => BookingConfirmationScreen(
                    serviceType: widget.serviceType,
                    selectedPackage: widget.selectedPackage,
                    selectedCaregiver: _selectedCaregiver!,
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 0,
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Continue to Booking',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Montserrat',
                  ),
                ),
                SizedBox(width: 8),
                Icon(Icons.arrow_forward_rounded, size: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
