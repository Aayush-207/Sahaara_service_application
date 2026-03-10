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
      debugPrint('Fetching top caregivers (limit: $limit)');
      
      // Get all caregivers and sort in memory to avoid index requirements
      final snapshot = await _firestore
          .collection('users')
          .where('userType', isEqualTo: 'caregiver')
          .get();

      final caregivers = snapshot.docs
          .map((doc) => UserModel.fromMap(doc.data(), doc.id))
          .toList();
      
      if (caregivers.isEmpty) {
        debugPrint('No caregivers found');
        return [];
      }
      
      // Sort by rating in memory
      caregivers.sort((a, b) => (b.rating ?? 0).compareTo(a.rating ?? 0));
      
      final result = caregivers.take(limit).toList();
      debugPrint('Found ${result.length} top caregivers');
      return result;
    } catch (e) {
      debugPrint('Error getting top caregivers: $e');
      return [];
    }
  }

  // Get top rated caregivers as a stream for real-time updates
  Stream<List<UserModel>> getTopCaregiversStream({int limit = 10}) {
    return getCaregivers().map((caregivers) {
      // Sort by rating in memory
      caregivers.sort((a, b) => (b.rating ?? 0).compareTo(a.rating ?? 0));
      return caregivers.take(limit).toList();
    });
  }

  // Search caregivers by service
  Future<List<UserModel>> searchCaregiversByService(String service) async {
    try {
      // Normalize service name for matching
      final normalizedService = _normalizeServiceName(service);
      
      final snapshot = await _firestore
          .collection('users')
          .where('userType', isEqualTo: 'caregiver')
          .get();

      return snapshot.docs
          .map((doc) => UserModel.fromMap(doc.data(), doc.id))
          .where((user) {
            if (user.services == null) return false;
            // Check if caregiver has the service (accounting for variations like "Training" vs "Dog Training")
            return user.services!.any((caregiverService) => 
              _normalizeServiceName(caregiverService).contains(normalizedService) ||
              normalizedService.contains(_normalizeServiceName(caregiverService))
            );
          })
          .toList();
    } catch (e) {
      debugPrint('Error searching caregivers by service: $e');
      return [];
    }
  }

  /// Normalize service names to handle variations (e.g., "Training" -> "training")
  String _normalizeServiceName(String service) {
    return service.toLowerCase().trim();
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
          .snapshots()
          .map((snapshot) {
            final bookings = snapshot.docs
                .map((doc) => BookingModel.fromMap(doc.data(), doc.id))
                .toList();
            // Sort by date in memory to avoid index requirement
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
          .snapshots()
          .map((snapshot) {
            final bookings = snapshot.docs
                .map((doc) => BookingModel.fromMap(doc.data(), doc.id))
                .toList();
            // Sort by date in memory to avoid index requirement
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

  // ============================================================================
  // CHAT METHODS
  // ============================================================================

  /// Get or create a chat room between owner and caregiver
  Future<String?> getOrCreateChatRoom({
    required String ownerId,
    required String caregiverId,
    required String ownerName,
    required String caregiverName,
    required String? caregiverPhotoUrl,
    required String? caregiverEmail,
  }) async {
    try {
      // Check if chat room exists
      final snapshot = await _firestore
          .collection('chat_rooms')
          .where('ownerId', isEqualTo: ownerId)
          .where('caregiverId', isEqualTo: caregiverId)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        return snapshot.docs.first.id;
      }

      // Create new chat room
      final chatRoomRef = await _firestore.collection('chat_rooms').add({
        'ownerId': ownerId,
        'caregiverId': caregiverId,
        'ownerName': ownerName,
        'caregiverName': caregiverName,
        'caregiverPhotoUrl': caregiverPhotoUrl,
        'caregiverEmail': caregiverEmail,
        'createdAt': Timestamp.now(),
        'lastMessageAt': Timestamp.now(),
        'lastMessage': '',
        'unreadCount': 0,
      });

      return chatRoomRef.id;
    } catch (e) {
      debugPrint('Error creating chat room: $e');
      return null;
    }
  }

  /// Send a message in a chat room
  Future<bool> sendChatMessage({
    required String chatRoomId,
    required String senderId,
    required String senderName,
    required String message,
  }) async {
    try {
      debugPrint('📤 Sending message to chat room: $chatRoomId');
      
      // First verify the chat room exists
      final roomDoc = await _firestore
          .collection('chat_rooms')
          .doc(chatRoomId)
          .get();
      
      if (!roomDoc.exists) {
        debugPrint('❌ Chat room does not exist: $chatRoomId');
        throw Exception('Chat room not found. Please refresh and try again.');
      }
      
      // Add message
      await _firestore
          .collection('chat_rooms')
          .doc(chatRoomId)
          .collection('messages')
          .add({
        'chatRoomId': chatRoomId,
        'senderId': senderId,
        'senderName': senderName,
        'message': message,
        'timestamp': Timestamp.now(),
        'isRead': false,
        'imageUrl': null,
      });

      // Update last message in chat room
      await _firestore.collection('chat_rooms').doc(chatRoomId).update({
        'lastMessage': message,
        'lastMessageAt': Timestamp.now(),
      });

      debugPrint('✅ Message sent successfully');
      return true;
    } catch (e) {
      debugPrint('❌ Error sending message: $e');
      return false;
    }
  }

  /// Get messages stream for a chat room
  Stream<List<Map<String, dynamic>>> getChatMessages(String chatRoomId) {
    debugPrint('📥 Getting messages for chat room: $chatRoomId');
    
    return _firestore
        .collection('chat_rooms')
        .doc(chatRoomId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots()
        .map((snapshot) {
          final messages = snapshot.docs
              .map((doc) => {...doc.data(), 'id': doc.id})
              .toList();
          debugPrint('✅ Retrieved ${messages.length} messages');
          return messages;
        });
  }

  // ============================================================================
  // REPORT METHODS
  // ============================================================================

  /// Submit a report against a caregiver
  Future<bool> submitReport({
    required String reporterId,
    required String reporterName,
    required String caregiverId,
    required String caregiverName,
    required String reason,
    required String description,
  }) async {
    try {
      await _firestore.collection('caregiver_reports').add({
        'reporterId': reporterId,
        'reporterName': reporterName,
        'caregiverId': caregiverId,
        'caregiverName': caregiverName,
        'reason': reason,
        'description': description,
        'createdAt': Timestamp.now(),
        'status': 'pending',
        'adminNotes': null,
      });

      return true;
    } catch (e) {
      debugPrint('Error submitting report: $e');
      return false;
    }
  }

  /// Get reports for a caregiver (admin only)
  Future<List<Map<String, dynamic>>> getCaregiverReports(String caregiverId) async {
    try {
      final snapshot = await _firestore
          .collection('caregiver_reports')
          .where('caregiverId', isEqualTo: caregiverId)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => {...doc.data(), 'id': doc.id})
          .toList();
    } catch (e) {
      debugPrint('Error getting reports: $e');
      return [];
    }
  }
}


