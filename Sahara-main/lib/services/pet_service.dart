import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/pet_model.dart';

class PetService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get user's pets from the correct subcollection path
  Future<List<PetModel>> getUserPets(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('pets')
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => PetModel.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      debugPrint('Error getting pets with orderBy: $e');
      // Fallback: try without orderBy if composite index doesn't exist
      try {
        final snapshot = await _firestore
            .collection('users')
            .doc(userId)
            .collection('pets')
            .get();

        final pets = snapshot.docs
            .map((doc) => PetModel.fromMap(doc.data(), doc.id))
            .toList();
        
        // Sort in memory
        pets.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        return pets;
      } catch (e2) {
        debugPrint('Error getting pets: $e2');
        return [];
      }
    }
  }

  // Add pet to the correct subcollection path
  Future<String> addPet(PetModel pet) async {
    try {
      debugPrint('Adding pet to Firestore: ${pet.name}');
      
      // Get pet data without ID
      final petData = pet.toMap(includeId: false);
      debugPrint('Pet data: $petData');
      
      final doc = await _firestore
          .collection('users')
          .doc(pet.ownerId)
          .collection('pets')
          .add(petData);
      debugPrint('Pet added successfully with ID: ${doc.id}');
      return doc.id;
    } catch (e) {
      debugPrint('Error adding pet: $e');
      rethrow;
    }
  }

  // Update pet in the correct subcollection path
  Future<void> updatePet(PetModel pet) async {
    try {
      if (pet.id.isEmpty) {
        throw Exception('Cannot update pet: Pet ID is empty');
      }
      
      debugPrint('Updating pet in Firestore: ${pet.name} (ID: ${pet.id})');
      
      // Get pet data without ID
      final petData = pet.toMap(includeId: false);
      
      await _firestore
          .collection('users')
          .doc(pet.ownerId)
          .collection('pets')
          .doc(pet.id)
          .update(petData);
      debugPrint('Pet updated successfully');
    } catch (e) {
      debugPrint('Error updating pet: $e');
      rethrow;
    }
  }

  // Delete pet from the correct subcollection path
  Future<void> deletePet(String userId, String petId) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('pets')
        .doc(petId)
        .delete();
  }

  // Get pet by ID from the correct subcollection path
  Future<PetModel?> getPetById(String userId, String petId) async {
    try {
      final doc = await _firestore
          .collection('users')
          .doc(userId)
          .collection('pets')
          .doc(petId)
          .get();
      if (doc.exists) {
        return PetModel.fromMap(doc.data()!, doc.id);
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}

