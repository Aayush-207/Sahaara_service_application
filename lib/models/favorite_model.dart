import 'package:cloud_firestore/cloud_firestore.dart';

/// Favorite Model
/// Represents a user's favorite caregiver
class FavoriteModel {
  final String id;
  final String userId;
  final String caregiverId;
  final DateTime createdAt;

  FavoriteModel({
    required this.id,
    required this.userId,
    required this.caregiverId,
    required this.createdAt,
  });

  /// Create from Firestore document
  factory FavoriteModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return FavoriteModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      caregiverId: data['caregiverId'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  /// Convert to Firestore map
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'caregiverId': caregiverId,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  /// Create copy with modifications
  FavoriteModel copyWith({
    String? id,
    String? userId,
    String? caregiverId,
    DateTime? createdAt,
  }) {
    return FavoriteModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      caregiverId: caregiverId ?? this.caregiverId,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
