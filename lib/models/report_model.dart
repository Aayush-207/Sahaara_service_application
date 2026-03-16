import 'package:cloud_firestore/cloud_firestore.dart';

/// Report Model
/// Represents a report against a caregiver
class ReportModel {
  final String id;
  final String reporterId;
  final String reporterName;
  final String caregiverId;
  final String caregiverName;
  final String reason;
  final String description;
  final DateTime createdAt;
  final String status; // pending, reviewed, resolved, dismissed
  final String? adminNotes;

  ReportModel({
    required this.id,
    required this.reporterId,
    required this.reporterName,
    required this.caregiverId,
    required this.caregiverName,
    required this.reason,
    required this.description,
    required this.createdAt,
    this.status = 'pending',
    this.adminNotes,
  });

  factory ReportModel.fromMap(Map<String, dynamic> map, String id) {
    return ReportModel(
      id: id,
      reporterId: map['reporterId'] ?? '',
      reporterName: map['reporterName'] ?? '',
      caregiverId: map['caregiverId'] ?? '',
      caregiverName: map['caregiverName'] ?? '',
      reason: map['reason'] ?? '',
      description: map['description'] ?? '',
      createdAt: map['createdAt'] != null
          ? (map['createdAt'] is Timestamp
              ? (map['createdAt'] as Timestamp).toDate()
              : DateTime.parse(map['createdAt']))
          : DateTime.now(),
      status: map['status'] ?? 'pending',
      adminNotes: map['adminNotes'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'reporterId': reporterId,
      'reporterName': reporterName,
      'caregiverId': caregiverId,
      'caregiverName': caregiverName,
      'reason': reason,
      'description': description,
      'createdAt': Timestamp.fromDate(createdAt),
      'status': status,
      'adminNotes': adminNotes,
    };
  }
}

// Report reasons
const List<String> reportReasons = [
  'Hateful speech or discrimination',
  'Inappropriate behavior',
  'Safety concerns',
  'Unprofessional conduct',
  'Non-responsive to bookings',
  'Damaged pet or property',
  'Other',
];
