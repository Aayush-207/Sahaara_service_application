import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:permission_handler/permission_handler.dart' as ph;

/// Location Provider - Manages location state across the app
/// 
/// Features:
/// - Request location permission
/// - Get current location
/// - Store and update location
/// - Handle location errors
/// - Check location service availability
class LocationProvider with ChangeNotifier {
  // State variables
  Position? _currentPosition;
  String? _currentAddress;
  bool _isLoading = false;
  String? _errorMessage;
  bool _permissionGranted = false;

  // Getters
  Position? get currentPosition => _currentPosition;
  String? get currentAddress => _currentAddress;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get permissionGranted => _permissionGranted;
  
  String get locationDisplay {
    if (_currentAddress != null) {
      return _currentAddress!;
    }
    if (_currentPosition != null) {
      return '${_currentPosition!.latitude.toStringAsFixed(2)}°, ${_currentPosition!.longitude.toStringAsFixed(2)}°';
    }
    return 'Location not available';
  }

  /// Check if location services are enabled
  Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  /// Check location permission status
  Future<LocationPermission> checkPermissionStatus() async {
    return await Geolocator.checkPermission();
  }

  /// Request location permission
  Future<bool> requestLocationPermission() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Check if location service is enabled
      final enabled = await isLocationServiceEnabled();
      if (!enabled) {
        debugPrint('Location services are disabled');
        _errorMessage = 'Location services are disabled. Please enable them in settings.';
        _isLoading = false;
        notifyListeners();
        // Try to open location settings
        await Geolocator.openLocationSettings();
        return false;
      }

      // **IMPORTANT**: Use permission_handler for permission dialog on Android
      // This ensures the system permission dialog is properly shown
      debugPrint('Requesting location permission...');
      final permissionStatus = await ph.Permission.location.request();
      
      debugPrint('Permission status: $permissionStatus');
      
      if (permissionStatus.isGranted) {
        // Permission granted, get location
        _permissionGranted = true;
        debugPrint('Location permission granted');
        await getCurrentLocation();
        _isLoading = false;
        notifyListeners();
        return true;
      } else if (permissionStatus.isDenied) {
        _errorMessage = 'Location permission denied. Please try again.';
        debugPrint('Location permission denied by user');
        _isLoading = false;
        notifyListeners();
        return false;
      } else if (permissionStatus.isPermanentlyDenied) {
        _errorMessage = 'Location permission is permanently disabled. Please enable it in settings.';
        debugPrint('Location permission permanently denied');
        _isLoading = false;
        notifyListeners();
        // Open app settings for user to enable permission manually
        await ph.openAppSettings();
        return false;
      }
      
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      debugPrint('Error requesting location permission: $e');
      _errorMessage = 'Error requesting location permission: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Get current location
  Future<bool> getCurrentLocation() async {
    try {
      // High accuracy for precise location
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 0,
        ),
      );

      _currentPosition = position;
      _errorMessage = null;
      
      // Try to get address from coordinates
      await _getAddressFromCoordinates(position.latitude, position.longitude);
      
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error getting current location: $e');
      _errorMessage = 'Error getting location: $e';
      notifyListeners();
      return false;
    }
  }

  /// Get address from latitude and longitude using reverse geocoding
  Future<void> _getAddressFromCoordinates(double latitude, double longitude) async {
    try {
      // Use reverse geocoding to get actual place names
      List<Placemark> placemarks = await placemarkFromCoordinates(latitude, longitude);
      
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        
        // Build address string with locality and administrative area
        // Format: "Locality, Administrative Area" (e.g., "Loni, Pune")
        List<String> addressParts = [];
        
        if (place.locality != null && place.locality!.isNotEmpty) {
          addressParts.add(place.locality!);
        } else if (place.subLocality != null && place.subLocality!.isNotEmpty) {
          addressParts.add(place.subLocality!);
        }
        
        if (place.administrativeArea != null && place.administrativeArea!.isNotEmpty) {
          addressParts.add(place.administrativeArea!);
        } else if (place.subAdministrativeArea != null && place.subAdministrativeArea!.isNotEmpty) {
          addressParts.add(place.subAdministrativeArea!);
        }
        
        // Fallback to country if nothing else is available
        if (addressParts.isEmpty && place.country != null) {
          addressParts.add(place.country!);
        }
        
        _currentAddress = addressParts.isEmpty 
            ? 'Location found' 
            : addressParts.join(', ');
        
        debugPrint('Reverse geocoded address: $_currentAddress');
      } else {
        _currentAddress = 'Location found';
      }
      
      notifyListeners();
    } catch (e) {
      debugPrint('Error getting address from coordinates: $e');
      // Fallback to coordinates if geocoding fails
      _currentAddress = 'Lat: ${latitude.toStringAsFixed(4)}, Lng: ${longitude.toStringAsFixed(4)}';
      notifyListeners();
    }
  }

  /// Get location string for display
  String getLocationString() {
    if (_currentAddress != null && _currentAddress!.isNotEmpty) {
      return _currentAddress!;
    }
    if (_currentPosition != null) {
      return '${_currentPosition!.latitude.toStringAsFixed(4)}°, ${_currentPosition!.longitude.toStringAsFixed(4)}°';
    }
    return 'Locating...';
  }

  /// Clear location data
  void clearLocation() {
    _currentPosition = null;
    _currentAddress = null;
    _permissionGranted = false;
    notifyListeners();
  }
}
