import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../models/pet_model.dart';
import '../services/pet_service.dart';

/// Pet Provider - Manages pet state across the app
/// 
/// Features:
/// - Fetch user pets
/// - Add new pets
/// - Update pet information
/// - Delete pets
/// - Upload pet photos
/// - Cache pets locally
class PetProvider with ChangeNotifier {
  final PetService _petService = PetService();
  
  // State variables
  List<PetModel> _pets = [];
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  List<PetModel> get pets => _pets;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  int get petCount => _pets.length;
  bool get hasPets => _pets.isNotEmpty;

  // Get pet by ID
  PetModel? getPetById(String petId) {
    try {
      return _pets.firstWhere((pet) => pet.id == petId);
    } catch (e) {
      return null;
    }
  }

  // Get pets by type
  List<PetModel> getPetsByType(String type) {
    return _pets.where((pet) => pet.type.toLowerCase() == type.toLowerCase()).toList();
  }

  /// Load user pets
  Future<void> loadUserPets(String userId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _pets = await _petService.getUserPets(userId);
      _isLoading = false;
      notifyListeners();
    } catch (error) {
      _errorMessage = 'Failed to load pets: $error';
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Add new pet
  Future<bool> addPet(PetModel pet) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      debugPrint('PetProvider: Adding pet ${pet.name}');
      final newPetId = await _petService.addPet(pet);
      debugPrint('PetProvider: Pet added with ID: $newPetId');
      
      // Create a new pet object with the Firebase-generated ID
      final addedPet = pet.copyWith(id: newPetId);
      
      // Add to local list instead of reloading
      _pets.insert(0, addedPet);
      
      _isLoading = false;
      notifyListeners();
      debugPrint('PetProvider: Pet added to local list successfully');
      return true;
    } catch (e) {
      debugPrint('PetProvider: Error adding pet: $e');
      _errorMessage = 'Failed to add pet: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Update pet information
  Future<bool> updatePet(PetModel pet) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      debugPrint('PetProvider: Updating pet ${pet.name} (ID: ${pet.id})');
      
      if (pet.id.isEmpty) {
        throw Exception('Cannot update pet: Pet ID is empty');
      }
      
      await _petService.updatePet(pet);
      debugPrint('PetProvider: Pet updated successfully');
      
      // Update in local list instead of reloading
      final index = _pets.indexWhere((p) => p.id == pet.id);
      if (index != -1) {
        _pets[index] = pet;
      }
      
      _isLoading = false;
      notifyListeners();
      debugPrint('PetProvider: Local list updated');
      return true;
    } catch (e) {
      debugPrint('PetProvider: Error updating pet: $e');
      _errorMessage = 'Failed to update pet: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Delete pet
  Future<bool> deletePet(String petId) async {
    // Find the pet to get ownerId before deletion
    final pet = getPetById(petId);
    if (pet == null) {
      _errorMessage = 'Pet not found';
      return false;
    }
    
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _petService.deletePet(petId);
      debugPrint('PetProvider: Pet deleted from Firestore');
      
      // Remove from local list instead of reloading
      _pets.removeWhere((p) => p.id == petId);
      
      _isLoading = false;
      notifyListeners();
      debugPrint('PetProvider: Pet removed from local list');
      return true;
    } catch (e) {
      debugPrint('PetProvider: Error deleting pet: $e');
      _errorMessage = 'Failed to delete pet: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Refresh pets
  Future<void> refreshPets(String userId) async {
    loadUserPets(userId);
  }

  /// Clear all pets (for logout)
  void clearPets() {
    _pets = [];
    notifyListeners();
  }
}
