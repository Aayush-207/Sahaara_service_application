import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/favorite_model.dart';
import '../models/user_model.dart';

/// Favorites Provider
/// Manages user's favorite caregivers
class FavoritesProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  List<FavoriteModel> _favorites = [];
  List<UserModel> _favoriteCaregivers = [];
  bool _isLoading = false;
  String? _error;

  List<FavoriteModel> get favorites => _favorites;
  List<UserModel> get favoriteCaregivers => _favoriteCaregivers;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Load user's favorites
  Future<void> loadFavorites(String userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final snapshot = await _firestore
          .collection('user_favorites')
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();

      _favorites = snapshot.docs
          .map((doc) => FavoriteModel.fromFirestore(doc))
          .toList();

      // Load caregiver details
      await _loadFavoriteCaregivers();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      debugPrint('Error loading favorites: $e');
    }
  }

  /// Load favorite caregivers details
  Future<void> _loadFavoriteCaregivers() async {
    if (_favorites.isEmpty) {
      _favoriteCaregivers = [];
      return;
    }

    try {
      final caregiverIds = _favorites.map((f) => f.caregiverId).toList();
      
      final caregivers = <UserModel>[];
      for (final id in caregiverIds) {
        final doc = await _firestore.collection('users').doc(id).get();
        if (doc.exists) {
          caregivers.add(UserModel.fromMap(doc.data()!, doc.id));
        }
      }

      _favoriteCaregivers = caregivers;
    } catch (e) {
      debugPrint('Error loading favorite caregivers: $e');
    }
  }

  /// Check if caregiver is favorited
  bool isFavorite(String caregiverId) {
    return _favorites.any((f) => f.caregiverId == caregiverId);
  }

  /// Add caregiver to favorites
  Future<bool> addFavorite(String userId, String caregiverId) async {
    try {
      // Check if already favorited
      if (isFavorite(caregiverId)) {
        return true;
      }

      final favorite = FavoriteModel(
        id: '', // Will be set by Firestore
        userId: userId,
        caregiverId: caregiverId,
        createdAt: DateTime.now(),
      );

      final docRef = await _firestore
          .collection('user_favorites')
          .add(favorite.toMap());

      // Add to local list
      _favorites.add(favorite.copyWith(id: docRef.id));
      
      // Reload caregivers
      await _loadFavoriteCaregivers();
      
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error adding favorite: $e');
      return false;
    }
  }

  /// Remove caregiver from favorites
  Future<bool> removeFavorite(String userId, String caregiverId) async {
    try {
      final favorite = _favorites.firstWhere(
        (f) => f.userId == userId && f.caregiverId == caregiverId,
      );

      await _firestore
          .collection('user_favorites')
          .doc(favorite.id)
          .delete();

      // Remove from local list
      _favorites.removeWhere((f) => f.id == favorite.id);
      _favoriteCaregivers.removeWhere((c) => c.uid == caregiverId);
      
      notifyListeners();
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
    _favorites = [];
    _favoriteCaregivers = [];
    _isLoading = false;
    _error = null;
    notifyListeners();
  }
}
