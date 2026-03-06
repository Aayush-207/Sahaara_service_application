import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

/// Favorites Provider
/// Manages user's favorite caregivers
class FavoritesProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  List<UserModel> _favoriteCaregivers = [];
  bool _isLoading = false;
  String? _error;

  List<UserModel> get favoriteCaregivers => _favoriteCaregivers;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Load user's favorites from user document
  Future<void> loadFavorites(String userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final userDoc = await _firestore.collection('users').doc(userId).get();
      
      if (userDoc.exists) {
        final data = userDoc.data() as Map<String, dynamic>;
        final favoriteIds = List<String>.from(data['favoriteCaregiversIds'] ?? []);

        // Load caregiver details
        final caregivers = <UserModel>[];
        for (final id in favoriteIds) {
          final doc = await _firestore.collection('users').doc(id).get();
          if (doc.exists) {
            caregivers.add(UserModel.fromMap(doc.data()!, doc.id));
          }
        }

        _favoriteCaregivers = caregivers;
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      debugPrint('Error loading favorites: $e');
    }
  }

  /// Check if caregiver is favorited
  bool isFavorite(String caregiverId) {
    return _favoriteCaregivers.any((c) => c.uid == caregiverId);
  }

  /// Add caregiver to favorites
  Future<bool> addFavorite(String userId, String caregiverId) async {
    try {
      if (isFavorite(caregiverId)) {
        return true;
      }

      final userRef = _firestore.collection('users').doc(userId);
      
      await userRef.update({
        'favoriteCaregiversIds': FieldValue.arrayUnion([caregiverId])
      });

      // Reload favorites
      await loadFavorites(userId);
      return true;
    } catch (e) {
      debugPrint('Error adding favorite: $e');
      return false;
    }
  }

  /// Remove caregiver from favorites
  Future<bool> removeFavorite(String userId, String caregiverId) async {
    try {
      final userRef = _firestore.collection('users').doc(userId);
      
      await userRef.update({
        'favoriteCaregiversIds': FieldValue.arrayRemove([caregiverId])
      });

      // Reload favorites
      await loadFavorites(userId);
      return true;
    } catch (e) {
      debugPrint('Error removing favorite: $e');
      return false;
    }
  }

  /// Toggle favorite status
  Future<bool> toggleFavorite(String userId, String caregiverId) async {
    if (isFavorite(caregiverId)) {
      return await removeFavorite(userId, caregiverId);
    } else {
      return await addFavorite(userId, caregiverId);
    }
  }

  /// Clear all favorites (for logout)
  void clear() {
    _favoriteCaregivers = [];
    _isLoading = false;
    _error = null;
    notifyListeners();
  }
}
