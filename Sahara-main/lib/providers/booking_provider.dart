import 'package:flutter/material.dart';
import 'dart:async';
import '../models/booking_model.dart';
import '../services/firestore_service.dart';

/// Booking Provider - Manages booking state across the app
/// 
/// Features:
/// - Fetch user bookings
/// - Fetch caregiver bookings
/// - Create new bookings
/// - Update booking status
/// - Cancel bookings
/// - Cache bookings locally
/// - Real-time updates via streams
class BookingProvider with ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  
  // State variables
  List<BookingModel> _userBookings = [];
  List<BookingModel> _caregiverBookings = [];
  bool _isLoading = false;
  String? _errorMessage;
  StreamSubscription? _userBookingsSubscription;
  StreamSubscription? _caregiverBookingsSubscription;

  // Getters
  List<BookingModel> get userBookings => _userBookings;
  List<BookingModel> get caregiverBookings => _caregiverBookings;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Get bookings by status
  List<BookingModel> getUserBookingsByStatus(String status) {
    return _userBookings.where((b) => b.status == status).toList();
  }

  List<BookingModel> getCaregiverBookingsByStatus(String status) {
    return _caregiverBookings.where((b) => b.status == status).toList();
  }

  // Get upcoming bookings
  List<BookingModel> get upcomingUserBookings {
    final now = DateTime.now();
    return _userBookings
        .where((b) => b.scheduledDate.isAfter(now) && b.status != 'cancelled')
        .toList();
  }

  // Get past bookings
  List<BookingModel> get pastUserBookings {
    final now = DateTime.now();
    return _userBookings
        .where((b) => b.scheduledDate.isBefore(now) || b.status == 'completed')
        .toList();
  }

  @override
  void dispose() {
    _userBookingsSubscription?.cancel();
    _caregiverBookingsSubscription?.cancel();
    super.dispose();
  }

  /// Load user bookings with real-time updates
  void loadUserBookings(String userId) {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    _userBookingsSubscription?.cancel();
    _userBookingsSubscription = _firestoreService
        .getUserBookings(userId)
        .listen(
          (bookings) {
            _userBookings = bookings;
            _isLoading = false;
            notifyListeners();
          },
          onError: (error) {
            _errorMessage = 'Failed to load bookings: $error';
            _isLoading = false;
            notifyListeners();
          },
        );
  }

  /// Load caregiver bookings with real-time updates
  void loadCaregiverBookings(String caregiverId) {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    _caregiverBookingsSubscription?.cancel();
    _caregiverBookingsSubscription = _firestoreService
        .getCaregiverBookings(caregiverId)
        .listen(
          (bookings) {
            _caregiverBookings = bookings;
            _isLoading = false;
            notifyListeners();
          },
          onError: (error) {
            _errorMessage = 'Failed to load bookings: $error';
            _isLoading = false;
            notifyListeners();
          },
        );
  }

  /// Create new booking
  Future<String?> createBooking(BookingModel booking) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final bookingId = await _firestoreService.createBooking(booking);
      _isLoading = false;
      notifyListeners();
      return bookingId;
    } catch (e) {
      _errorMessage = 'Failed to create booking: $e';
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  /// Update booking status
  Future<bool> updateBookingStatus(String bookingId, String status) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _firestoreService.updateBookingStatus(bookingId, status);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to update booking: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Cancel booking
  Future<bool> cancelBooking(String bookingId) async {
    return await updateBookingStatus(bookingId, 'cancelled');
  }

  /// Cancel booking with reason
  Future<bool> cancelBookingWithReason(String bookingId, String reason) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _firestoreService.cancelBookingWithReason(bookingId, reason);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to cancel booking: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Confirm booking
  Future<bool> confirmBooking(String bookingId) async {
    return await updateBookingStatus(bookingId, 'confirmed');
  }

  /// Complete booking
  Future<bool> completeBooking(String bookingId) async {
    return await updateBookingStatus(bookingId, 'completed');
  }

  /// Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Refresh bookings
  Future<void> refreshUserBookings(String userId) async {
    loadUserBookings(userId);
  }

  Future<void> refreshCaregiverBookings(String caregiverId) async {
    loadCaregiverBookings(caregiverId);
  }
}
