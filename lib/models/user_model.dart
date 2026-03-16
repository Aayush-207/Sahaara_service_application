import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String email;
  final String name;
  final String userType;
  final String? photoUrl;
  final String? phone;
  final double? rating;
  final int? completedBookings;
  final DateTime createdAt;
  
  // Enhanced fields
  final String? bio;
  final List<String>? services;
  final double? hourlyRate;
  final String? location;
  final int? yearsOfExperience;
  final bool? isVerified;
  final bool? isAvailable;
  final Map<String, String>? availability;
  final List<String>? certifications;
  final List<String>? specialties;

  UserModel({
    required this.uid,
    required this.email,
    required this.name,
    required this.userType,
    this.photoUrl,
    this.phone,
    this.rating,
    this.completedBookings,
    required this.createdAt,
    this.bio,
    this.services,
    this.hourlyRate,
    this.location,
    this.yearsOfExperience,
    this.isVerified,
    this.isAvailable,
    this.availability,
    this.certifications,
    this.specialties,
  });

  factory UserModel.fromMap(Map<String, dynamic> map, String uid) {
    return UserModel(
      uid: uid,
      email: map['email'] ?? '',
      name: map['name'] ?? '',
      userType: map['userType'] ?? 'owner',
      photoUrl: map['photoUrl'],
      phone: map['phone'],
      rating: map['rating']?.toDouble(),
      completedBookings: map['completedBookings'],
      createdAt: map['createdAt'] != null 
          ? (map['createdAt'] is Timestamp 
              ? (map['createdAt'] as Timestamp).toDate()
              : DateTime.parse(map['createdAt']))
          : DateTime.now(),
      bio: map['bio'],
      services: map['services'] != null ? List<String>.from(map['services']) : null,
      hourlyRate: map['hourlyRate']?.toDouble(),
      location: map['location'],
      yearsOfExperience: map['yearsOfExperience'],
      isVerified: map['isVerified'],
      isAvailable: map['isAvailable'],
      availability: map['availability'] != null 
          ? Map<String, String>.from(map['availability']) 
          : null,
      certifications: map['certifications'] != null 
          ? List<String>.from(map['certifications']) 
          : null,
      specialties: map['specialties'] != null 
          ? List<String>.from(map['specialties']) 
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'name': name,
      'userType': userType,
      'photoUrl': photoUrl,
      'phone': phone,
      'rating': rating,
      'completedBookings': completedBookings,
      'createdAt': Timestamp.fromDate(createdAt),
      'bio': bio,
      'services': services,
      'hourlyRate': hourlyRate,
      'location': location,
      'yearsOfExperience': yearsOfExperience,
      'isVerified': isVerified,
      'isAvailable': isAvailable,
      'availability': availability,
      'certifications': certifications,
      'specialties': specialties,
    };
  }
}

