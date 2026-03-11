import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

/// Booking Status Service - Automatically updates booking status based on time
/// 
/// Status Flow:
/// 1. pending -> confirmed (manual by caregiver)
/// 2. confirmed -> in_progress (auto when scheduled time arrives)
/// 3. in_progress -> completed (auto after duration + 30 min buffer)
/// 
/// Features:
/// - Monitors all confirmed bookings
/// - Auto-starts service at scheduled time
/// - Auto-completes service after duration
/// - Runs check every minute
class BookingStatusService {
  static final BookingStatusService _instance = BookingStatusService._internal();
  factory BookingStatusService() => _instance;
  BookingStatusService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Timer? _statusCheckTimer;
  bool _isRunning = false;

  /// Start the automatic status update service
  void startService() {
    if (_isRunning) {
      debugPrint('⚠️ Booking status service already running');
      return;
    }

    debugPrint('🚀 Starting booking status service...');
    _isRunning = true;

    // Run immediately
    _checkAndUpdateBookingStatuses();

    // Then run every minute
    _statusCheckTimer = Timer.periodic(
      const Duration(minutes: 1),
      (_) => _checkAndUpdateBookingStatuses(),
    );
  }

  /// Stop the automatic status update service
  void stopService() {
    debugPrint('🛑 Stopping booking status service...');
    _statusCheckTimer?.cancel();
    _statusCheckTimer = null;
    _isRunning = false;
  }

  /// Check and update all booking statuses
  Future<void> _checkAndUpdateBookingStatuses() async {
    try {
      final now = DateTime.now();
      debugPrint('⏰ Checking booking statuses at ${now.toString()}');

      // Get all confirmed bookings that should start
      await _startConfirmedBookings(now);

      // Get all in_progress bookings that should complete
      await _completeInProgressBookings(now);

      debugPrint('✅ Booking status check completed');
    } catch (e) {
      debugPrint('❌ Error checking booking statuses: $e');
    }
  }

  /// Start confirmed bookings when scheduled time arrives
  Future<void> _startConfirmedBookings(DateTime now) async {
    try {
      // Get confirmed bookings where scheduled time has passed
      final snapshot = await _firestore
          .collection('bookings')
          .where('status', isEqualTo: 'confirmed')
          .get();

      int startedCount = 0;

      for (final doc in snapshot.docs) {
        final data = doc.data();
        final scheduledDate = _parseDateTime(data['scheduledDate']);

        if (scheduledDate != null && scheduledDate.isBefore(now)) {
          // Start the service
          await doc.reference.update({
            'status': 'in_progress',
            'actualStartTime': Timestamp.now(),
          });
          startedCount++;
          debugPrint('▶️ Started booking ${doc.id}');
        }
      }

      if (startedCount > 0) {
        debugPrint('✅ Started $startedCount booking(s)');
      }
    } catch (e) {
      debugPrint('❌ Error starting confirmed bookings: $e');
    }
  }

  /// Complete in_progress bookings after duration + buffer
  Future<void> _completeInProgressBookings(DateTime now) async {
    try {
      // Get in_progress bookings
      final snapshot = await _firestore
          .collection('bookings')
          .where('status', isEqualTo: 'in_progress')
          .get();

      int completedCount = 0;

      for (final doc in snapshot.docs) {
        final data = doc.data();
        final scheduledDate = _parseDateTime(data['scheduledDate']);
        final duration = data['duration'] as String?;

        if (scheduledDate != null && duration != null) {
          // Parse duration and calculate end time
          final durationMinutes = _parseDuration(duration);
          final bufferMinutes = 30; // 30 minute buffer after scheduled end
          final endTime = scheduledDate.add(
            Duration(minutes: durationMinutes + bufferMinutes),
          );

          if (endTime.isBefore(now)) {
            // Complete the service
            await doc.reference.update({
              'status': 'completed',
              'actualEndTime': Timestamp.now(),
            });
            completedCount++;
            debugPrint('✅ Completed booking ${doc.id}');
          }
        }
      }

      if (completedCount > 0) {
        debugPrint('✅ Completed $completedCount booking(s)');
      }
    } catch (e) {
      debugPrint('❌ Error completing in_progress bookings: $e');
    }
  }

  /// Parse DateTime from various formats
  DateTime? _parseDateTime(dynamic value) {
    try {
      if (value is Timestamp) {
        return value.toDate();
      } else if (value is String) {
        return DateTime.parse(value);
      }
      return null;
    } catch (e) {
      debugPrint('❌ Error parsing date: $e');
      return null;
    }
  }

  /// Parse duration string to minutes
  /// Examples: "30 minutes", "1 hour", "2 hours", "1.5 hours"
  int _parseDuration(String duration) {
    try {
      final lower = duration.toLowerCase();

      // Extract number
      final numberMatch = RegExp(r'[\d.]+').firstMatch(lower);
      if (numberMatch == null) return 60; // Default 1 hour

      final number = double.parse(numberMatch.group(0)!);

      // Check if hours or minutes
      if (lower.contains('hour')) {
        return (number * 60).round();
      } else if (lower.contains('min')) {
        return number.round();
      } else if (lower.contains('day')) {
        return (number * 24 * 60).round();
      }

      // Default to minutes
      return number.round();
    } catch (e) {
      debugPrint('❌ Error parsing duration "$duration": $e');
      return 60; // Default 1 hour
    }
  }

  /// Manually update booking status (for testing or manual control)
  Future<bool> updateBookingStatus(String bookingId, String newStatus) async {
    try {
      final updates = <String, dynamic>{
        'status': newStatus,
      };

      if (newStatus == 'in_progress') {
        updates['actualStartTime'] = Timestamp.now();
      } else if (newStatus == 'completed') {
        updates['actualEndTime'] = Timestamp.now();
      }

      await _firestore.collection('bookings').doc(bookingId).update(updates);
      debugPrint('✅ Updated booking $bookingId to $newStatus');
      return true;
    } catch (e) {
      debugPrint('❌ Error updating booking status: $e');
      return false;
    }
  }

  /// Get service status
  bool get isRunning => _isRunning;
}
