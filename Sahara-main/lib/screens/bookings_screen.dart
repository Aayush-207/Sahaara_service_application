import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/firestore_service.dart';
import '../services/sound_service.dart';
import '../models/booking_model.dart';
import 'package:intl/intl.dart';
import '../theme/app_colors.dart';

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
/// - Booking cards with all details
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

        if (filteredBookings.isEmpty) {
          return _buildEmptyState(status);
        }

        return RefreshIndicator(
          onRefresh: () async {
            setState(() {});
          },
          color: AppColors.primary,
          child: ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: filteredBookings.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _buildBookingCard(filteredBookings[index]),
              );
            },
          ),
        );
      },
    );
  }

  // ============================================================================
  // UI BUILDERS - BOOKING CARD
  // ============================================================================

  /// Builds a single booking card
  Widget _buildBookingCard(BookingModel booking) {
    final dateFormat = DateFormat('MMM dd, yyyy');
    final timeFormat = DateFormat('hh:mm a');

    Color statusColor;
    IconData statusIcon;
    
    switch (booking.status) {
      case 'confirmed':
        statusColor = AppColors.success;
        statusIcon = Icons.check_circle_rounded;
        break;
      case 'completed':
        statusColor = AppColors.info;
        statusIcon = Icons.done_all_rounded;
        break;
      case 'cancelled':
        statusColor = AppColors.error;
        statusIcon = Icons.cancel_rounded;
        break;
      default:
        statusColor = AppColors.warning;
        statusIcon = Icons.schedule_rounded;
    }

    return InkWell(
      onTap: () {
        _soundService.playTap();
        // Navigate to booking details
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border, width: 1),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with status
            Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: AppColors.primary, // Solid color, no gradient
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.pets_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        booking.serviceType,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                          fontFamily: 'Montserrat',
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        booking.packageName,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                          fontFamily: 'Montserrat',
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(statusIcon, size: 14, color: statusColor),
                      const SizedBox(width: 4),
                      Text(
                        booking.status.toUpperCase(),
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: statusColor,
                          fontFamily: 'Montserrat',
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            
            // Date and Time
            Row(
              children: [
                Expanded(
                  child: _buildInfoRow(
                    Icons.calendar_today_rounded,
                    'Date',
                    dateFormat.format(booking.scheduledDate),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildInfoRow(
                    Icons.access_time_rounded,
                    'Time',
                    timeFormat.format(booking.scheduledDate),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            
            // Price
            _buildInfoRow(
              Icons.payments_rounded,
              'Price',
              '₹${booking.price.toStringAsFixed(0)}',
            ),
            
            // Notes if available
            if (booking.notes != null && booking.notes!.isNotEmpty) ...[
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.note_rounded,
                      size: 14,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        booking.notes!,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                          fontFamily: 'Montserrat',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Builds an info row with icon, label, and value
  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 14, color: AppColors.textTertiary),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 10,
                color: AppColors.textTertiary,
                fontFamily: 'Montserrat',
              ),
            ),
            const SizedBox(height: 1),
            Text(
              value,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
                fontFamily: 'Montserrat',
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ============================================================================
  // UI BUILDERS - EMPTY STATE
  // ============================================================================

  /// Builds the empty state for a specific status
  Widget _buildEmptyState(String status) {
    String message;
    IconData icon;
    
    switch (status) {
      case 'upcoming':
        message = 'No upcoming bookings';
        icon = Icons.event_busy_rounded;
        break;
      case 'completed':
        message = 'No completed bookings yet';
        icon = Icons.done_all_rounded;
        break;
      default:
        message = 'No cancelled bookings';
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
          const Text(
            'Book a service to get started',
            style: TextStyle(
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
}
