import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/service_package_model.dart';

class PackageService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Get packages for a specific service type from Firestore
  Future<List<ServicePackageModel>> getPackagesForService(String serviceType) async {
    try {
      final snapshot = await _firestore
          .collection('service_packages')
          .where('serviceType', isEqualTo: serviceType)
          .get();

      return snapshot.docs
          .map((doc) => ServicePackageModel.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      debugPrint('Error fetching packages: $e');
      return [];
    }
  }

  /// Get all service types
  Future<List<String>> getAllServiceTypes() async {
    try {
      final snapshot = await _firestore.collection('service_packages').get();
      
      final serviceTypes = <String>{};
      for (var doc in snapshot.docs) {
        final serviceType = doc.data()['serviceType'] as String?;
        if (serviceType != null) {
          serviceTypes.add(serviceType);
        }
      }
      
      return serviceTypes.toList();
    } catch (e) {
      debugPrint('Error fetching service types: $e');
      return ['Dog Walking', 'Pet Sitting', 'Grooming', 'Vet Visit'];
    }
  }

  /// Get package by ID
  Future<ServicePackageModel?> getPackageById(String packageId) async {
    try {
      final doc = await _firestore
          .collection('service_packages')
          .doc(packageId)
          .get();

      if (doc.exists) {
        return ServicePackageModel.fromMap(doc.data()!, doc.id);
      }
      return null;
    } catch (e) {
      debugPrint('Error fetching package: $e');
      return null;
    }
  }

  /// Get all packages
  Future<List<ServicePackageModel>> getAllPackages() async {
    try {
      final snapshot = await _firestore.collection('service_packages').get();
      
      return snapshot.docs
          .map((doc) => ServicePackageModel.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      debugPrint('Error fetching all packages: $e');
      return [];
    }
  }
}
