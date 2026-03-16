import 'package:cloud_firestore/cloud_firestore.dart';

class ReviewModel {
  final String id;
  final String caregiverId;
  final String ownerId;
  final String ownerName;
  final double rating;
  final String comment;
  final DateTime createdAt;
  final String? ownerPhotoUrl;

  ReviewModel({
    required this.id,
    required this.caregiverId,
    required this.ownerId,
    required this.ownerName,
    required this.rating,
    required this.comment,
    required this.createdAt,
    this.ownerPhotoUrl,
  });

  factory ReviewModel.fromMap(Map<String, dynamic> map, String id) {
    return ReviewModel(
      id: id,
      caregiverId: map['caregiverId'] ?? '',
      ownerId: map['ownerId'] ?? '',
      ownerName: map['ownerName'] ?? '',
      rating: map['rating']?.toDouble() ?? 0.0,
      comment: map['comment'] ?? '',
      createdAt: map['createdAt'] != null
          ? (map['createdAt'] is Timestamp 
              ? (map['createdAt'] as Timestamp).toDate()
              : DateTime.parse(map['createdAt']))
          : DateTime.now(),
      ownerPhotoUrl: map['ownerPhotoUrl'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'caregiverId': caregiverId,
      'ownerId': ownerId,
      'ownerName': ownerName,
      'rating': rating,
      'comment': comment,
      'createdAt': Timestamp.fromDate(createdAt),
      'ownerPhotoUrl': ownerPhotoUrl,
    };
  }
}

