import 'package:cloud_firestore/cloud_firestore.dart';

class PetModel {
  final String id;
  final String ownerId;
  final String name;
  final String type; // Always "Dog" for this app
  final String breed;
  final int age;
  final double weight;
  final String? gender;
  final String? color;
  final String? photoUrl;
  final String? medicalNotes;
  final List<String>? vaccinations;
  final bool isNeutered;
  final DateTime createdAt;
  final DateTime? updatedAt;

  PetModel({
    required this.id,
    required this.ownerId,
    required this.name,
    required this.type,
    required this.breed,
    required this.age,
    required this.weight,
    this.gender,
    this.color,
    this.photoUrl,
    this.medicalNotes,
    this.vaccinations,
    this.isNeutered = false,
    required this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toMap({bool includeId = true}) {
    final map = {
      'ownerId': ownerId,
      'name': name,
      'type': type,
      'breed': breed,
      'age': age,
      'weight': weight,
      'gender': gender,
      'color': color,
      'photoUrl': photoUrl,
      'medicalNotes': medicalNotes,
      'vaccinations': vaccinations,
      'isNeutered': isNeutered,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
    
    if (includeId) {
      map['id'] = id;
    }
    
    return map;
  }

  factory PetModel.fromMap(Map<String, dynamic> map, String id) {
    return PetModel(
      id: id,
      ownerId: map['ownerId'] ?? '',
      name: map['name'] ?? '',
      type: map['type'] ?? '',
      breed: map['breed'] ?? '',
      age: map['age'] ?? 0,
      weight: (map['weight'] ?? 0).toDouble(),
      gender: map['gender'],
      color: map['color'],
      photoUrl: map['photoUrl'],
      medicalNotes: map['medicalNotes'],
      vaccinations: map['vaccinations'] != null 
          ? List<String>.from(map['vaccinations']) 
          : null,
      isNeutered: map['isNeutered'] ?? false,
      createdAt: map['createdAt'] != null
          ? (map['createdAt'] is Timestamp 
              ? (map['createdAt'] as Timestamp).toDate()
              : DateTime.parse(map['createdAt']))
          : DateTime.now(),
      updatedAt: map['updatedAt'] != null
          ? (map['updatedAt'] is Timestamp 
              ? (map['updatedAt'] as Timestamp).toDate()
              : DateTime.parse(map['updatedAt']))
          : null,
    );
  }

  PetModel copyWith({
    String? id,
    String? ownerId,
    String? name,
    String? type,
    String? breed,
    int? age,
    double? weight,
    String? gender,
    String? color,
    String? photoUrl,
    String? medicalNotes,
    List<String>? vaccinations,
    bool? isNeutered,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PetModel(
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      name: name ?? this.name,
      type: type ?? this.type,
      breed: breed ?? this.breed,
      age: age ?? this.age,
      weight: weight ?? this.weight,
      gender: gender ?? this.gender,
      color: color ?? this.color,
      photoUrl: photoUrl ?? this.photoUrl,
      medicalNotes: medicalNotes ?? this.medicalNotes,
      vaccinations: vaccinations ?? this.vaccinations,
      isNeutered: isNeutered ?? this.isNeutered,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

