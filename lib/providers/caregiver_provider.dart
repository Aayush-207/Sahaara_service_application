import 'package:flutter/material.dart';
import 'dart:async';
import '../models/user_model.dart';
import '../services/firestore_service.dart';

/// Caregiver Provider - Manages caregiver data and search
/// 
/// Features:
/// - Fetch all caregivers
/// - Fetch top-rated caregivers
/// - Search caregivers by service
/// - Search caregivers by location
/// - Filter available caregivers
/// - Cache caregivers locally
/// - Real-time updates via streams
class CaregiverProvider with ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  
  // State variables
  List<UserModel> _allCaregivers = [];
  List<UserModel> _topCaregivers = [];
  List<UserModel> _filteredCaregivers = [];
  bool _isLoading = false;
  String? _errorMessage;
  StreamSubscription? _caregiversSubscription;
  
  // Filter state
  String? _selectedService;
  String? _selectedLocation;
  bool _onlyAvailable = false;

  // Getters
  List<UserModel> get allCaregivers => _allCaregivers;
  List<UserModel> get topCaregivers => _topCaregivers;
  List<UserModel> get filteredCaregivers => _filteredCaregivers.isNotEmpty 
      ? _filteredCaregivers 
      : _allCaregivers;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get selectedService => _selectedService;
  String? get selectedLocation => _selectedLocation;
  bool get onlyAvailable => _onlyAvailable;
  bool get hasFilters => _selectedService != null || 
                         _selectedLocation != null || 
                         _onlyAvailable;

  // Get caregiver by ID
  UserModel? getCaregiverById(String caregiverId) {
    try {
      return _allCaregivers.firstWhere((c) => c.uid == caregiverId);
    } catch (e) {
      return null;
    }
  }

  @override
  void dispose() {
    _caregiversSubscription?.cancel();
    super.dispose();
  }

  /// Load all caregivers with real-time updates
  void loadAllCaregivers() {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    // Cancel existing subscription to prevent memory leaks
    _caregiversSubscription?.cancel();
    _caregiversSubscription = null;
    
    _caregiversSubscription = _firestoreService.getCaregivers().listen(
      (caregivers) {
        _allCaregivers = caregivers;
        _applyFilters();
        _isLoading = false;
        notifyListeners();
      },
      onError: (error) {
        _errorMessage = 'Failed to load caregivers: $error';
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  /// Load top-rated caregivers
  Future<void> loadTopCaregivers({int limit = 10}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _topCaregivers = await _firestoreService.getTopCaregivers(limit: limit);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to load top caregivers: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Search caregivers by service
  Future<void> searchByService(String service) async {
    _selectedService = service;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final results = await _firestoreService.searchCaregiversByService(service);
      _filteredCaregivers = results;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Search failed: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Search caregivers by location
  Future<void> searchByLocation(String location) async {
    _selectedLocation = location;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final results = await _firestoreService.searchCaregiversByLocation(location);
      _filteredCaregivers = results;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Search failed: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Filter available caregivers only
  void toggleAvailableOnly() {
    _onlyAvailable = !_onlyAvailable;
    _applyFilters();
    notifyListeners();
  }

  /// Apply all active filters
  void _applyFilters() {
    _filteredCaregivers = _allCaregivers;

    if (_selectedService != null) {
      _filteredCaregivers = _filteredCaregivers
          .where((c) => c.services?.contains(_selectedService) ?? false)
          .toList();
    }

    if (_selectedLocation != null) {
      _filteredCaregivers = _filteredCaregivers
          .where((c) => c.location?.toLowerCase().contains(_selectedLocation!.toLowerCase()) ?? false)
          .toList();
    }

    if (_onlyAvailable) {
      _filteredCaregivers = _filteredCaregivers
          .where((c) => c.isAvailable ?? false)
          .toList();
    }
  }

  /// Clear all filters
  void clearFilters() {
    _selectedService = null;
    _selectedLocation = null;
    _onlyAvailable = false;
    _filteredCaregivers = [];
    notifyListeners();
  }

  /// Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Refresh caregivers
  Future<void> refresh() async {
    loadAllCaregivers();
    await loadTopCaregivers();
  }

  /// Clear all data (for logout)
  void clear() {
    _allCaregivers = [];
    _topCaregivers = [];
    _filteredCaregivers = [];
    _selectedService = null;
    _selectedLocation = null;
    _onlyAvailable = false;
    _caregiversSubscription?.cancel();
    notifyListeners();
  }
}
