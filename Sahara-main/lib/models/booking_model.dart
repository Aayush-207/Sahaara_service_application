import 'package:cloud_firestore/cloud_firestore.dart';

class BookingModel {
  final String id;
  final String ownerId;
  final String caregiverId;
  final String petId; // ID of the dog for this booking
  final String serviceType;
  final String packageName;
  final String duration;
  final DateTime scheduledDate;
  final String status;
  final double price;
  final String? notes;
  final DateTime createdAt;
  final String? cancellationReason;

  BookingModel({
    required this.id,
    required this.ownerId,
    required this.caregiverId,
    required this.petId,
    required this.serviceType,
    required this.packageName,
    required this.duration,
    required this.scheduledDate,
    required this.status,
    required this.price,
    this.notes,
    required this.createdAt,
    this.cancellationReason,
  });

  factory BookingModel.fromMap(Map<String, dynamic> map, String id) {
    return BookingModel(
      id: id,
      ownerId: map['ownerId'] ?? '',
      caregiverId: map['caregiverId'] ?? '',
      petId: map['petId'] ?? '',
      serviceType: map['serviceType'] ?? '',
      packageName: map['packageName'] ?? '',
      duration: map['duration'] ?? '',
      scheduledDate: map['scheduledDate'] != null
          ? (map['scheduledDate'] is Timestamp 
              ? (map['scheduledDate'] as Timestamp).toDate()
              : DateTime.parse(map['scheduledDate']))
          : DateTime.now(),
      status: map['status'] ?? 'pending',
      price: map['price']?.toDouble() ?? 0.0,
      notes: map['notes'],
      createdAt: map['createdAt'] != null
          ? (map['createdAt'] is Timestamp 
              ? (map['createdAt'] as Timestamp).toDate()
              : DateTime.parse(map['createdAt']))
          : DateTime.now(),
      cancellationReason: map['cancellationReason'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'ownerId': ownerId,
      'caregiverId': caregiverId,
      'petId': petId,
      'serviceType': serviceType,
      'packageName': packageName,
      'duration': duration,
      'scheduledDate': scheduledDate.toIso8601String(),
      'status': status,
      'price': price,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
      'cancellationReason': cancellationReason,
    };
  }
}

