import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../models/booking_model.dart';
import '../models/review_model.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get user by ID
  Future<UserModel?> getUserById(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      if (doc.exists) {
        return UserModel.fromMap(doc.data()!, doc.id);
      }
      return null;
    } catch (e) {
      debugPrint('Error getting user by ID: $e');
      return null;
    }
  }

  // Get all caregivers
  Stream<List<UserModel>> getCaregivers() {
    return _firestore
        .collection('users')
        .where('userType', isEqualTo: 'caregiver')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => UserModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  // Get top rated caregivers
  Future<List<UserModel>> getTopCaregivers({int limit = 10}) async {
    try {
      // Try with orderBy first
      final snapshot = await _firestore
          .collection('users')
          .where('userType', isEqualTo: 'caregiver')
          .orderBy('rating', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs
          .map((doc) => UserModel.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      debugPrint('Error with orderBy query, falling back to simple query: $e');
      // Fallback: Get all caregivers and sort in memory
      try {
        final snapshot = await _firestore
            .collection('users')
            .where('userType', isEqualTo: 'caregiver')
            .get();

        final caregivers = snapshot.docs
            .map((doc) => UserModel.fromMap(doc.data(), doc.id))
            .toList();
        
        // Sort by rating in memory
        caregivers.sort((a, b) => (b.rating ?? 0).compareTo(a.rating ?? 0));
        
        // Return limited results
        return caregivers.take(limit).toList();
      } catch (e2) {
        debugPrint('Error getting caregivers: $e2');
        return [];
      }
    }
  }

  // Search caregivers by service
  Future<List<UserModel>> searchCaregiversByService(String service) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .where('userType', isEqualTo: 'caregiver')
          .where('services', arrayContains: service)
          .get();

      return snapshot.docs
          .map((doc) => UserModel.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      return [];
    }
  }

  // Search caregivers by location
  Future<List<UserModel>> searchCaregiversByLocation(String location) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .where('userType', isEqualTo: 'caregiver')
          .get();

      return snapshot.docs
          .map((doc) => UserModel.fromMap(doc.data(), doc.id))
          .where((user) => user.location?.toLowerCase().contains(location.toLowerCase()) ?? false)
          .toList();
    } catch (e) {
      return [];
    }
  }

  // Get available caregivers
  Future<List<UserModel>> getAvailableCaregivers() async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .where('userType', isEqualTo: 'caregiver')
          .where('isAvailable', isEqualTo: true)
          .get();

      return snapshot.docs
          .map((doc) => UserModel.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      return [];
    }
  }

  // Create booking
  Future<String> createBooking(BookingModel booking) async {
    // Create a map without the id field for new bookings
    final bookingData = booking.toMap();
    bookingData.remove('id'); // Remove empty id field
    
    final doc = await _firestore.collection('bookings').add(bookingData);
    return doc.id;
  }

  // Get user bookings
  Stream<List<BookingModel>> getUserBookings(String userId) {
    try {
      return _firestore
          .collection('bookings')
          .where('ownerId', isEqualTo: userId)
          .orderBy('scheduledDate', descending: true)
          .snapshots()
          .handleError((error) {
            debugPrint('Error with orderBy query: $error');
            // Fallback to query without orderBy
            return _firestore
                .collection('bookings')
                .where('ownerId', isEqualTo: userId)
                .snapshots();
          })
          .map((snapshot) {
            final bookings = snapshot.docs
                .map((doc) => BookingModel.fromMap(doc.data(), doc.id))
                .toList();
            // Sort in memory if orderBy failed
            bookings.sort((a, b) => b.scheduledDate.compareTo(a.scheduledDate));
            return bookings;
          });
    } catch (e) {
      debugPrint('Error getting user bookings: $e');
      // Return empty stream on error
      return Stream.value([]);
    }
  }

  // Get caregiver bookings
  Stream<List<BookingModel>> getCaregiverBookings(String caregiverId) {
    try {
      return _firestore
          .collection('bookings')
          .where('caregiverId', isEqualTo: caregiverId)
          .orderBy('scheduledDate', descending: true)
          .snapshots()
          .handleError((error) {
            debugPrint('Error with orderBy query: $error');
            // Fallback to query without orderBy
            return _firestore
                .collection('bookings')
                .where('caregiverId', isEqualTo: caregiverId)
                .snapshots();
          })
          .map((snapshot) {
            final bookings = snapshot.docs
                .map((doc) => BookingModel.fromMap(doc.data(), doc.id))
                .toList();
            // Sort in memory if orderBy failed
            bookings.sort((a, b) => b.scheduledDate.compareTo(a.scheduledDate));
            return bookings;
          });
    } catch (e) {
      debugPrint('Error getting caregiver bookings: $e');
      // Return empty stream on error
      return Stream.value([]);
    }
  }

  // Update booking status
  Future<void> updateBookingStatus(String bookingId, String status) async {
    await _firestore.collection('bookings').doc(bookingId).update({
      'status': status,
    });
  }

  // Cancel booking with reason
  Future<void> cancelBookingWithReason(String bookingId, String reason) async {
    await _firestore.collection('bookings').doc(bookingId).update({
      'status': 'cancelled',
      'cancellationReason': reason,
    });
  }

  // Update user profile
  Future<void> updateUserProfile(String uid, Map<String, dynamic> data) async {
    await _firestore.collection('users').doc(uid).update(data);
  }

  // Get caregiver reviews
  Future<List<ReviewModel>> getCaregiverReviews(String caregiverId) async {
    try {
      // Try with orderBy first
      final snapshot = await _firestore
          .collection('reviews')
          .where('caregiverId', isEqualTo: caregiverId)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => ReviewModel.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      debugPrint('Error with orderBy query, falling back: $e');
      // Fallback: Get without orderBy and sort in memory
      try {
        final snapshot = await _firestore
            .collection('reviews')
            .where('caregiverId', isEqualTo: caregiverId)
            .get();

        final reviews = snapshot.docs
            .map((doc) => ReviewModel.fromMap(doc.data(), doc.id))
            .toList();
        
        // Sort by createdAt in memory
        reviews.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        
        return reviews;
      } catch (e2) {
        debugPrint('Error getting reviews: $e2');
        return [];
      }
    }
  }

  // Add review
  Future<void> addReview(ReviewModel review) async {
    await _firestore.collection('reviews').add(review.toMap());
  }

  // Get payment by booking ID (deprecated - payments removed)
  // Kept for backward compatibility
  Future<dynamic> getPaymentByBookingId(String bookingId) async {
    return null;
  }

  // Update payment status (deprecated - payments removed)
  // Kept for backward compatibility
  Future<void> updatePaymentStatus(String paymentId, String status) async {
    // No-op
  }
}

