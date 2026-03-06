import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/booking_provider.dart';
import '../services/firestore_service.dart';
import '../services/sound_service.dart';
import '../models/booking_model.dart';
import '../models/user_model.dart';
import '../theme/app_colors.dart';
import '../widgets/booking_card.dart';
import '../widgets/cancel_booking_dialogs.dart';

/// Bookings Screen
/// 
/// Displays user's bookings organized by status in tabs:
/// - Upcoming: pending and confirmed bookings
/// - Completed: finished bookings
/// - Cancelled: cancelled bookings
/// 
/// Features:
/// - Tab-based navigation for different booking statuses
/// - Real-time booking data with StreamBuilder
/// - Pull-to-refresh functionality
/// - Booking cards with caregiver information
/// - Cancellation flow with dialogs
/// - Empty states for each tab
/// - Error handling with retry
/// 
/// Design Principles:
/// - Solid colors only (Navy, Orange, Sky Blue, Light Blue)
/// - 8px grid spacing system
/// - Montserrat font family
/// - Clean card-based layout
/// - Professional status indicators
/// - Responsive design
/// 
/// Theme Colors:
/// - Background: AppColors.surface (white)
/// - Tab indicator: AppColors.primary (navy)
/// - Status colors: success (green), info (blue), error (red), warning (amber)
/// - Cards: White with AppColors.border
class BookingsScreen extends StatefulWidget {
  const BookingsScreen({super.key});

  @override
  State<BookingsScreen> createState() => _BookingsScreenState();
}

class _BookingsScreenState extends State<BookingsScreen> with SingleTickerProviderStateMixin {
  // ============================================================================
  // STATE VARIABLES
  // ============================================================================

  late TabController _tabController;
  final FirestoreService _firestoreService = FirestoreService();
  final SoundService _soundService = SoundService();

  // ============================================================================
  // LIFECYCLE METHODS
  // ============================================================================

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // ============================================================================
  // BUILD METHOD
  // ============================================================================

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final userId = authProvider.currentUser?.uid ?? '';

    // If no user ID, show login prompt
    if (userId.isEmpty) {
      return Scaffold(
        backgroundColor: AppColors.surface,
        body: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.login_rounded, size: 52, color: AppColors.textTertiary),
                const SizedBox(height: 16),
                const Text(
                  'Please login to view bookings',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                    fontFamily: 'Montserrat',
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildTabBar(),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildBookingsList(userId, 'upcoming'),
                  _buildBookingsList(userId, 'completed'),
                  _buildBookingsList(userId, 'cancelled'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================================
  // UI BUILDERS - HEADER
  // ============================================================================

  /// Builds the screen header
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'My Bookings',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.5,
                    fontFamily: 'Montserrat',
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Track your pet care appointments',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================================
  // UI BUILDERS - TAB BAR
  // ============================================================================

  /// Builds the tab bar for booking status filtering
  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(10),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        labelColor: Colors.white,
        unselectedLabelColor: AppColors.textSecondary,
        labelStyle: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          fontFamily: 'Montserrat',
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          fontFamily: 'Montserrat',
        ),
        onTap: (index) {
          _soundService.playTap();
        },
        tabs: const [
          Tab(text: 'Upcoming'),
          Tab(text: 'Completed'),
          Tab(text: 'Cancelled'),
        ],
      ),
    );
  }

  // ============================================================================
  // UI BUILDERS - BOOKINGS LIST
  // ============================================================================

  /// Builds the bookings list for a specific status
  Widget _buildBookingsList(String userId, String status) {
    return StreamBuilder<List<BookingModel>>(
      stream: _firestoreService.getUserBookings(userId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(
              color: AppColors.primary,
              strokeWidth: 2,
            ),
          );
        }

        if (snapshot.hasError) {
          return _buildErrorState();
        }

        final allBookings = snapshot.data ?? [];
        final filteredBookings = allBookings.where((booking) {
          if (status == 'upcoming') {
            return booking.status == 'pending' || booking.status == 'confirmed';
          } else if (status == 'completed') {
            return booking.status == 'completed';
          } else {
            return booking.status == 'cancelled';
          }
        }).toList();

        // Add default completed booking to completed section
        if (status == 'completed') {
          final defaultBooking = _createDefaultCompletedBooking();
          filteredBookings.add(defaultBooking);
        }

        if (filteredBookings.isEmpty) {
          return _buildEmptyState(status);
        }

        return RefreshIndicator(
          onRefresh: () async {
            // Refresh the stream by waiting briefly
            await Future.delayed(const Duration(milliseconds: 300));
          },
          color: AppColors.primary,
          child: ListView.separated(
            padding: const EdgeInsets.all(20),
            itemCount: filteredBookings.length,
            separatorBuilder: (context, index) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final booking = filteredBookings[index];
              return _buildSingleBookingCard(booking);
            },
          ),
        );
      },
    );
  }



  // ============================================================================
  // UI BUILDERS - BOOKING CARD
  // ============================================================================

  /// Builds a single booking card with caregiver data loading
  Widget _buildSingleBookingCard(BookingModel booking) {
    return FutureBuilder<UserModel?>(
      future: _firestoreService.getUserById(booking.caregiverId),
      builder: (context, snapshot) {
        return BookingCard(
          booking: booking,
          caregiver: snapshot.data,
          onCancel: (booking.status == 'pending' || booking.status == 'confirmed')
              ? () => _handleCancelBooking(booking)
              : null,
          onTap: () {
            _soundService.playTap();
          },
        );
      },
    );
  }

  // ============================================================================
  // CANCELLATION FLOW
  // ============================================================================

  /// Handles the complete cancellation flow
  Future<void> _handleCancelBooking(BookingModel booking) async {
    // Show confirmation dialog
    final confirmed = await CancelBookingDialogs.showConfirmationDialog(
      context,
      bookingId: booking.id,
    );

    if (confirmed != true || !mounted) return;

    // Show reason selection dialog
    final reason = await CancelBookingDialogs.showReasonSelectionDialog(context);

    if (reason == null || !mounted) return;

    // Perform cancellation
    _performCancellation(booking.id, reason);
  }

  /// Performs the actual cancellation
  Future<void> _performCancellation(String bookingId, String reason) async {
    try {
      final bookingProvider = Provider.of<BookingProvider>(context, listen: false);
      
      // Show loading
      if (!mounted) return;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(
            color: AppColors.primary,
            strokeWidth: 2,
          ),
        ),
      );

      // Perform cancellation
      final success = await bookingProvider.cancelBookingWithReason(bookingId, reason);

      if (!mounted) return;
      Navigator.of(context).pop(); // Close loading dialog

      if (success) {
        _soundService.playTap();
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Booking cancelled successfully'),
            backgroundColor: AppColors.success,
            duration: Duration(seconds: 2),
          ),
        );
      } else {
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to cancel booking'),
            backgroundColor: AppColors.error,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      Navigator.of(context).pop(); // Close loading dialog
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: AppColors.error,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  // ============================================================================
  // UI BUILDERS - EMPTY STATE
  // ============================================================================

  /// Builds the empty state for a specific status
  Widget _buildEmptyState(String status) {
    String message;
    String submessage;
    IconData icon;
    
    switch (status) {
      case 'upcoming':
        message = 'No upcoming bookings';
        submessage = 'Book a caregiver to get started';
        icon = Icons.event_busy_rounded;
        break;
      case 'completed':
        message = 'No completed bookings yet';
        submessage = 'Your completed bookings will appear here';
        icon = Icons.done_all_rounded;
        break;
      default:
        message = 'No cancelled bookings';
        submessage = 'Your cancelled bookings will appear here';
        icon = Icons.cancel_rounded;
    }

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
              icon,
              size: 52,
              color: AppColors.textTertiary,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            message,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
              fontFamily: 'Montserrat',
            ),
          ),
          const SizedBox(height: 6),
          Text(
            submessage,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
              fontFamily: 'Montserrat',
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================================
  // UI BUILDERS - ERROR STATE
  // ============================================================================

  /// Builds the error state with retry button
  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline_rounded,
            size: 52,
            color: AppColors.error,
          ),
          const SizedBox(height: 16),
          const Text(
            'Failed to load bookings',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
              fontFamily: 'Montserrat',
            ),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: () {
              _soundService.playTap();
              setState(() {});
            },
            child: const Text(
              'Try Again',
              style: TextStyle(
                color: AppColors.primary,
                fontFamily: 'Montserrat',
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================================
  // DEFAULT BOOKING HELPER
  // ============================================================================

  /// Creates a default completed booking for demonstration
  BookingModel _createDefaultCompletedBooking() {
    return BookingModel(
      id: 'default_booking_001',
      ownerId: '', // Will be populated by userId context
      caregiverId: 'caregiver_priya_sharma', // Use first caregiver from seed data
      petId: 'default_pet_max', // Sample pet ID
      serviceType: 'Dog Walking',
      packageName: 'Premium Trail Walk',
      scheduledDate: DateTime.now().subtract(const Duration(days: 7)),
      status: 'completed',
      price: 500.0,
      duration: '60 minutes',
      notes: 'Great walk! Max enjoyed the trail.',
      createdAt: DateTime.now().subtract(const Duration(days: 8)),
      cancellationReason: null,
    );
  }
}

