import 'package:flutter/material.dart';
import 'dart:async';
import '../models/user_model.dart';
import '../services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  StreamSubscription? _authSubscription;
  
  UserModel? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _currentUser != null;

  AuthProvider() {
    _authSubscription = _authService.authStateChanges.listen((user) async {
      if (user != null) {
        _currentUser = await _authService.getUserData(user.uid);
      } else {
        _currentUser = null;
      }
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }

  Future<bool> signUp({
    required String email,
    required String password,
    required String name,
    required String userType,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _currentUser = await _authService.signUp(
        email: email,
        password: password,
        name: name,
        userType: userType,
      );
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _currentUser = await _authService.signIn(
        email: email,
        password: password,
      );
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> signOut() async {
    await _authService.signOut();
    _currentUser = null;
    notifyListeners();
  }

  Future<bool> signInWithGoogle({String userType = 'owner'}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _currentUser = await _authService.signInWithGoogle(userType: userType);
      _isLoading = false;
      notifyListeners();
      return _currentUser != null;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> resetPassword(String email) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _authService.resetPassword(email);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Refresh current user data from Firestore
  Future<void> refreshUser() async {
    if (_currentUser != null) {
      try {
        debugPrint('🔄 Refreshing user data for UID: ${_currentUser!.uid}');
        _currentUser = await _authService.getUserData(_currentUser!.uid);
        debugPrint('✅ User data refreshed - photoUrl: ${_currentUser?.photoUrl}');
        notifyListeners();
      } catch (e) {
        debugPrint('❌ Error refreshing user data: $e');
      }
    } else {
      debugPrint('⚠️  Cannot refresh user - no current user');
    }
  }

  /// Update user profile in Firestore
  Future<void> updateUserProfile(Map<String, dynamic> data) async {
    if (_currentUser == null) {
      throw Exception('No user logged in');
    }

    _isLoading = true;
    notifyListeners();

    try {
      await _authService.updateUserProfile(_currentUser!.uid, data);
      
      // Refresh user data from Firestore to get updated values
      await refreshUser();
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  /// Send password reset email
  Future<void> sendPasswordResetEmail() async {
    if (_currentUser == null || _currentUser!.email.isEmpty) {
      throw Exception('No user logged in');
    }
    
    try {
      await _authService.resetPassword(_currentUser!.email);
    } catch (e) {
      rethrow;
    }
  }

  /// Delete user account
  Future<void> deleteAccount() async {
    if (_currentUser == null) {
      throw Exception('No user logged in');
    }
    
    _isLoading = true;
    notifyListeners();
    
    try {
      await _authService.deleteAccount(_currentUser!.uid);
      _currentUser = null;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }
}

