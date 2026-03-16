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
  final DateTime? actualStartTime;
  final DateTime? actualEndTime;

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
    this.actualStartTime,
    this.actualEndTime,
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
      actualStartTime: map['actualStartTime'] != null
          ? (map['actualStartTime'] is Timestamp 
              ? (map['actualStartTime'] as Timestamp).toDate()
              : DateTime.parse(map['actualStartTime']))
          : null,
      actualEndTime: map['actualEndTime'] != null
          ? (map['actualEndTime'] is Timestamp 
              ? (map['actualEndTime'] as Timestamp).toDate()
              : DateTime.parse(map['actualEndTime']))
          : null,
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
      'scheduledDate': Timestamp.fromDate(scheduledDate),
      'status': status,
      'price': price,
      'notes': notes,
      'createdAt': Timestamp.fromDate(createdAt),
      'cancellationReason': cancellationReason,
      'actualStartTime': actualStartTime != null ? Timestamp.fromDate(actualStartTime!) : null,
      'actualEndTime': actualEndTime != null ? Timestamp.fromDate(actualEndTime!) : null,
    };
  }
}

