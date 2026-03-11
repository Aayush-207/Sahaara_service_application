import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/firestore_service.dart';
import '../services/booking_status_service.dart';
import '../models/booking_model.dart';
import '../theme/app_colors.dart';
import 'package:intl/intl.dart';

/// Booking Status Test Screen - For testing automatic status updates
/// 
/// Features:
/// - View all bookings
/// - Manually change status
/// - Create test bookings
/// - Monitor service status
class BookingStatusTestScreen extends StatefulWidget {
  const BookingStatusTestScreen({super.key});

  @override
  State<BookingStatusTestScreen> createState() => _BookingStatusTestScreenState();
}

class _BookingStatusTestScreenState extends State<BookingStatusTestScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  final BookingStatusService _statusService = BookingStatusService();

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final currentUser = authProvider.currentUser;

    if (currentUser == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Booking Status Test')),
        body: const Center(child: Text('Please login first')),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Booking Status Test',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontFamily: 'Montserrat',
          ),
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          // Service status indicator
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _statusService.isRunning
                      ? Colors.green.withValues(alpha: 0.2)
                      : Colors.red.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: _statusService.isRunning ? Colors.green : Colors.red,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _statusService.isRunning ? 'ACTIVE' : 'STOPPED',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: _statusService.isRunning ? Colors.green : Colors.red,
                        fontFamily: 'Montserrat',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      body: StreamBuilder<List<BookingModel>>(
        stream: _firestoreService.getUserBookings(currentUser.uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text('No bookings found'),
            );
          }

          final bookings = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: bookings.length,
            itemBuilder: (context, index) {
              final booking = bookings[index];
              return _buildBookingCard(booking);
            },
          );
        },
      ),
    );
  }

  Widget _buildBookingCard(BookingModel booking) {
    final now = DateTime.now();
    final isScheduledPast = booking.scheduledDate.isBefore(now);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        booking.serviceType,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Montserrat',
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        booking.packageName,
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                          fontFamily: 'Montserrat',
                        ),
                      ),
                    ],
                  ),
                ),
                _buildStatusBadge(booking.status),
              ],
            ),
            const SizedBox(height: 12),
            Divider(height: 1, color: AppColors.border),
            const SizedBox(height: 12),

            // Details
            _buildDetailRow('Scheduled', DateFormat('MMM dd, hh:mm a').format(booking.scheduledDate)),
            const SizedBox(height: 8),
            _buildDetailRow('Duration', booking.duration),
            const SizedBox(height: 8),
            _buildDetailRow('Price', '₹${booking.price.toStringAsFixed(0)}'),
            
            if (booking.actualStartTime != null) ...[
              const SizedBox(height: 8),
              _buildDetailRow(
                'Started',
                DateFormat('MMM dd, hh:mm a').format(booking.actualStartTime!),
                color: Colors.green,
              ),
            ],
            
            if (booking.actualEndTime != null) ...[
              const SizedBox(height: 8),
              _buildDetailRow(
                'Completed',
                DateFormat('MMM dd, hh:mm a').format(booking.actualEndTime!),
                color: Colors.blue,
              ),
            ],

            const SizedBox(height: 12),
            Divider(height: 1, color: AppColors.border),
            const SizedBox(height: 12),

            // Status change buttons
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (booking.status == 'pending')
                  _buildStatusButton(
                    'Confirm',
                    Colors.blue,
                    () => _updateStatus(booking.id, 'confirmed'),
                  ),
                if (booking.status == 'confirmed')
                  _buildStatusButton(
                    'Start Service',
                    Colors.green,
                    () => _updateStatus(booking.id, 'in_progress'),
                  ),
                if (booking.status == 'in_progress')
                  _buildStatusButton(
                    'Complete',
                    Colors.purple,
                    () => _updateStatus(booking.id, 'completed'),
                  ),
                if (booking.status != 'cancelled' && booking.status != 'completed')
                  _buildStatusButton(
                    'Cancel',
                    Colors.red,
                    () => _updateStatus(booking.id, 'cancelled'),
                  ),
              ],
            ),

            // Warning if scheduled time passed but not started
            if (isScheduledPast && booking.status == 'confirmed') ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.warning_rounded, color: Colors.orange, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Scheduled time passed. Should auto-start soon.',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.orange[800],
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

  Widget _buildDetailRow(String label, String value, {Color? color}) {
    return Row(
      children: [
        Text(
          '$label: ',
          style: TextStyle(
            fontSize: 13,
            color: AppColors.textSecondary,
            fontFamily: 'Montserrat',
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: color ?? AppColors.textPrimary,
              fontFamily: 'Montserrat',
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    String label;

    switch (status) {
      case 'pending':
        color = Colors.grey;
        label = 'Pending';
        break;
      case 'confirmed':
        color = Colors.blue;
        label = 'Confirmed';
        break;
      case 'in_progress':
        color = Colors.green;
        label = 'In Progress';
        break;
      case 'completed':
        color = Colors.purple;
        label = 'Completed';
        break;
      case 'cancelled':
        color = Colors.red;
        label = 'Cancelled';
        break;
      default:
        color = Colors.grey;
        label = status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: color,
          fontFamily: 'Montserrat',
        ),
      ),
    );
  }

  Widget _buildStatusButton(String label, Color color, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        elevation: 0,
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          fontFamily: 'Montserrat',
        ),
      ),
    );
  }

  Future<void> _updateStatus(String bookingId, String newStatus) async {
    try {
      final success = await _statusService.updateBookingStatus(bookingId, newStatus);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success
                  ? 'Status updated to $newStatus'
                  : 'Failed to update status',
            ),
            backgroundColor: success ? Colors.green : Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
