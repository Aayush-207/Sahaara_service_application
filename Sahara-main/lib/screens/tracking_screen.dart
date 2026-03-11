import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/auth_provider.dart';
import '../providers/location_provider.dart';
import '../theme/app_colors.dart';
import 'package:intl/intl.dart';
import '../services/firestore_service.dart';
import '../models/booking_model.dart';
import '../models/user_model.dart';
import 'dart:async';

/// Tracking Screen - Track pet location and service status
/// 
/// Features:
/// - Real-time booking tracking from Firestore
/// - Live map with caregiver and pet locations
/// - Service timeline with booking status
/// - Active booking details
/// - Caregiver contact information
/// - Auto-refresh every 30 seconds
class TrackingScreen extends StatefulWidget {
  const TrackingScreen({super.key});

  @override
  State<TrackingScreen> createState() => _TrackingScreenState();
}

class _TrackingScreenState extends State<TrackingScreen> {
  GoogleMapController? _mapController;
  final Set<Marker> _markers = {};
  final FirestoreService _firestoreService = FirestoreService();
  Timer? _refreshTimer;
  
  // Selected booking for tracking
  BookingModel? _selectedBooking;
  UserModel? _selectedCaregiver;

  // Default location (Mumbai, India)
  static const CameraPosition _defaultPosition = CameraPosition(
    target: LatLng(19.0760, 72.8777),
    zoom: 14,
  );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeLocation();
      _startAutoRefresh();
    });
  }
  
  /// Start auto-refresh timer (every 30 seconds)
  void _startAutoRefresh() {
    // Only refresh location, not the entire widget
    _refreshTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      if (mounted && _selectedBooking != null) {
        // Silently update markers without rebuilding entire widget
        final locationProvider = context.read<LocationProvider>();
        locationProvider.getCurrentLocation().then((_) {
          if (mounted) {
            _updateMarkers(locationProvider);
          }
        });
      }
    });
  }

  /// Initialize location and markers
  Future<void> _initializeLocation() async {
    try {
      final locationProvider = context.read<LocationProvider>();
      await locationProvider.getCurrentLocation();
      if (mounted) {
        setState(() {
          _updateMarkers(locationProvider);
        });
      }
    } catch (e) {
      debugPrint('Error initializing location: $e');
    }
  }

  /// Update map markers based on location
  void _updateMarkers(LocationProvider locationProvider) {
    final newMarkers = <Marker>{};

    // Add pet/owner location marker
    final petLocation = locationProvider.currentPosition;
    if (petLocation != null) {
      newMarkers.add(
        Marker(
          markerId: const MarkerId('pet_location'),
          position: LatLng(petLocation.latitude, petLocation.longitude),
          infoWindow: InfoWindow(
            title: 'Your Location',
            snippet: locationProvider.currentAddress ?? 'Current Location',
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        ),
      );
      
      // Move camera to pet location only on initial load
      if (_markers.isEmpty) {
        _mapController?.animateCamera(
          CameraUpdate.newLatLng(
            LatLng(petLocation.latitude, petLocation.longitude),
          ),
        );
      }
    }
    
    // Add caregiver location marker if booking is active
    if (_selectedBooking != null && _selectedCaregiver != null) {
      // Simulate caregiver location near pet (in real app, this would come from caregiver's live location)
      final caregiverLat = (petLocation?.latitude ?? 19.0760) + 0.005;
      final caregiverLng = (petLocation?.longitude ?? 72.8777) + 0.005;
      
      newMarkers.add(
        Marker(
          markerId: const MarkerId('caregiver_location'),
          position: LatLng(caregiverLat, caregiverLng),
          infoWindow: InfoWindow(
            title: _selectedCaregiver!.name,
            snippet: 'Caregiver Location',
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
        ),
      );
    }
    
    // Only update state if markers actually changed
    if (mounted && _markers.length != newMarkers.length) {
      setState(() {
        _markers.clear();
        _markers.addAll(newMarkers);
      });
    }
  }

  @override
  void dispose() {
    _mapController?.dispose();
    _refreshTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final currentUser = authProvider.currentUser;

    if (currentUser == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.surface,
          elevation: 0,
          title: const Text(
            'Pet Tracking',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
              fontFamily: 'Montserrat',
            ),
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.lock_outline, size: 64, color: AppColors.textTertiary),
              const SizedBox(height: 16),
              const Text(
                'Please login to view tracking',
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.textSecondary,
                  fontFamily: 'Montserrat',
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: const Text(
          'Pet Tracking',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
            fontFamily: 'Montserrat',
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: AppColors.textPrimary),
            onPressed: _initializeLocation,
            tooltip: 'Refresh',
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            height: 1,
            color: AppColors.border,
          ),
        ),
      ),
      body: StreamBuilder<List<BookingModel>>(
        stream: _firestoreService.getUserBookings(currentUser.uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return _buildEmptyState();
          }

          final bookings = snapshot.data!;
          
          // Filter active bookings (confirmed or in_progress)
          final activeBookings = bookings.where((b) => 
            b.status == 'confirmed' || b.status == 'in_progress'
          ).toList();

          if (activeBookings.isEmpty) {
            return _buildNoActiveBookings();
          }

          // Auto-select first active booking if none selected
          if (_selectedBooking == null && activeBookings.isNotEmpty) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _selectBooking(activeBookings.first);
            });
          }

          return Column(
            children: [
              // Booking selector if multiple active bookings
              if (activeBookings.length > 1)
                _buildBookingSelector(activeBookings),
              
              // Main content
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      _buildLocationMap(),
                      if (_selectedBooking != null) ...[
                        _buildBookingDetails(),
                        _buildServiceTimeline(),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
  
  /// Select a booking for tracking
  Future<void> _selectBooking(BookingModel booking) async {
    try {
      // Fetch caregiver details
      final caregiver = await _firestoreService.getUserById(booking.caregiverId);
      
      if (mounted) {
        setState(() {
          _selectedBooking = booking;
          _selectedCaregiver = caregiver;
        });
        
        // Update markers
        final locationProvider = context.read<LocationProvider>();
        _updateMarkers(locationProvider);
      }
    } catch (e) {
      debugPrint('Error selecting booking: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to load booking details'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }
  
  /// Make a phone call to the caregiver
  Future<void> _makeCall() async {
    if (_selectedCaregiver == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No caregiver selected'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }
    
    final phoneNumber = _selectedCaregiver!.phone;
    if (phoneNumber == null || phoneNumber.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Caregiver phone number not available'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }
    
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    
    try {
      if (await canLaunchUrl(launchUri)) {
        await launchUrl(launchUri);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Unable to make call'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('Error making call: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to initiate call'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }
  
  /// Build booking selector dropdown
  Widget _buildBookingSelector(List<BookingModel> bookings) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          const Icon(Icons.pets_rounded, color: AppColors.primary, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedBooking?.id,
                hint: const Text('Select booking to track'),
                isExpanded: true,
                items: bookings.map((booking) {
                  return DropdownMenuItem(
                    value: booking.id,
                    child: Text(
                      '${booking.serviceType} - ${DateFormat('MMM dd, hh:mm a').format(booking.scheduledDate)}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontFamily: 'Montserrat',
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  final booking = bookings.firstWhere((b) => b.id == value);
                  _selectBooking(booking);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  /// Build empty state
  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.location_off_rounded,
                size: 64,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'No Bookings Yet',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
                fontFamily: 'Montserrat',
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Book a service to start tracking your pet',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
                fontFamily: 'Montserrat',
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  /// Build no active bookings state
  Widget _buildNoActiveBookings() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.accent.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.schedule_rounded,
                size: 64,
                color: AppColors.accent,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'No Active Services',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
                fontFamily: 'Montserrat',
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'You have no active bookings to track right now',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
                fontFamily: 'Montserrat',
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build location map section
  Widget _buildLocationMap() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Live Location',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                  fontFamily: 'Montserrat',
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Text(
                      'LIVE',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: Colors.green,
                        fontFamily: 'Montserrat',
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            height: 300,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border, width: 1),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: GoogleMap(
                initialCameraPosition: _defaultPosition,
                onMapCreated: (GoogleMapController controller) {
                  try {
                    _mapController = controller;
                    debugPrint('✅ Google Maps initialized successfully');
                  } catch (e) {
                    debugPrint('❌ Error in onMapCreated: $e');
                  }
                },
                markers: _markers,
                myLocationEnabled: true,
                myLocationButtonEnabled: true,
                mapType: MapType.normal,
                zoomControlsEnabled: true,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Consumer<LocationProvider>(
            builder: (context, locationProvider, _) {
              return Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.2),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.location_on_rounded,
                        color: AppColors.primary,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Your Location',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textSecondary,
                              fontFamily: 'Montserrat',
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            locationProvider.currentAddress ??
                                'Fetching location...',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textPrimary,
                              fontFamily: 'Montserrat',
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            locationProvider.isLoading
                                ? 'Updating...'
                                : 'Updated ${_getTimeAgo(DateTime.now())}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textTertiary,
                              fontFamily: 'Montserrat',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
  
  /// Build booking details section
  Widget _buildBookingDetails() {
    if (_selectedBooking == null || _selectedCaregiver == null) {
      return const SizedBox.shrink();
    }
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Caregiver avatar
              CircleAvatar(
                radius: 28,
                backgroundImage: _selectedCaregiver!.photoUrl != null
                    ? NetworkImage(_selectedCaregiver!.photoUrl!)
                    : null,
                backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                child: _selectedCaregiver!.photoUrl == null
                    ? Text(
                        _selectedCaregiver!.name[0].toUpperCase(),
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _selectedCaregiver!.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                        fontFamily: 'Montserrat',
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        const Icon(Icons.star, size: 14, color: AppColors.star),
                        const SizedBox(width: 4),
                        Text(
                          _selectedCaregiver!.rating?.toStringAsFixed(1) ?? '0.0',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textSecondary,
                            fontFamily: 'Montserrat',
                          ),
                        ),
                        if (_selectedCaregiver!.location != null) ...[
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              '• ${_selectedCaregiver!.location}',
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppColors.textSecondary,
                                fontFamily: 'Montserrat',
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              // Call button
              IconButton(
                onPressed: () => _makeCall(),
                icon: const Icon(Icons.phone_rounded),
                style: IconButton.styleFrom(
                  backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                  foregroundColor: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Divider(height: 1, color: AppColors.border),
          const SizedBox(height: 16),
          // Service details
          _buildDetailRow(
            Icons.pets_rounded,
            'Service',
            _selectedBooking!.serviceType,
          ),
          const SizedBox(height: 12),
          _buildDetailRow(
            Icons.calendar_today_rounded,
            'Scheduled',
            DateFormat('MMM dd, hh:mm a').format(_selectedBooking!.scheduledDate),
          ),
          const SizedBox(height: 12),
          _buildDetailRow(
            Icons.access_time_rounded,
            'Duration',
            _selectedBooking!.duration,
          ),
          const SizedBox(height: 12),
          _buildDetailRow(
            Icons.currency_rupee_rounded,
            'Price',
            '₹${_selectedBooking!.price.toStringAsFixed(0)}',
          ),
        ],
      ),
    );
  }
  
  /// Build detail row
  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(icon, size: 16, color: AppColors.primary),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                  fontFamily: 'Montserrat',
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                  fontFamily: 'Montserrat',
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Build service timeline section
  Widget _buildServiceTimeline() {
    if (_selectedBooking == null) {
      return const SizedBox.shrink();
    }
    
    // Generate timeline based on booking status
    final activities = _generateTimelineActivities(_selectedBooking!);
    
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Service Timeline',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
              fontFamily: 'Montserrat',
            ),
          ),
          const SizedBox(height: 16),
          _buildTimeline(activities),
        ],
      ),
    );
  }
  
  /// Generate timeline activities based on booking
  List<TimelineActivity> _generateTimelineActivities(BookingModel booking) {
    final now = DateTime.now();
    final scheduledTime = booking.scheduledDate;
    
    final activities = <TimelineActivity>[];
    
    // Booking confirmed
    activities.add(TimelineActivity(
      title: 'Booking Confirmed',
      description: 'Your booking has been confirmed by ${_selectedCaregiver?.name ?? 'caregiver'}',
      time: booking.createdAt,
      status: 'completed',
      icon: Icons.check_circle_rounded,
    ));
    
    // Service started
    if (booking.status == 'in_progress') {
      activities.add(TimelineActivity(
        title: 'Service Started',
        description: '${booking.serviceType} service is now in progress',
        time: scheduledTime,
        status: 'in_progress',
        icon: Icons.play_circle_rounded,
      ));
      
      activities.add(TimelineActivity(
        title: 'Service Completion',
        description: 'Estimated completion time',
        time: scheduledTime.add(const Duration(hours: 2)),
        status: 'pending',
        icon: Icons.schedule_rounded,
      ));
    } else if (booking.status == 'confirmed') {
      activities.add(TimelineActivity(
        title: 'Service Scheduled',
        description: '${booking.serviceType} service will start soon',
        time: scheduledTime,
        status: scheduledTime.isBefore(now) ? 'in_progress' : 'pending',
        icon: Icons.schedule_rounded,
      ));
      
      if (scheduledTime.isAfter(now)) {
        activities.add(TimelineActivity(
          title: 'Caregiver Arrival',
          description: 'Caregiver will arrive at scheduled time',
          time: scheduledTime,
          status: 'pending',
          icon: Icons.directions_walk_rounded,
        ));
      }
    }
    
    return activities;
  }

  /// Build timeline widget
  Widget _buildTimeline(List<TimelineActivity> activities) {
    return Column(
      children: List.generate(activities.length, (index) {
        final activity = activities[index];

        return Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _getStatusColor(activity.status),
                        boxShadow: [
                          BoxShadow(
                            color: _getStatusColor(activity.status)
                                .withValues(alpha: 0.3),
                            blurRadius: 8,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Icon(
                        activity.icon,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    if (index < activities.length - 1)
                      Container(
                        width: 2,
                        height: 50,
                        color: AppColors.border,
                      ),
                  ],
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(
                      color: activity.status == 'in_progress'
                          ? AppColors.secondary.withValues(alpha: 0.08)
                          : activity.status == 'completed'
                              ? AppColors.success.withValues(alpha: 0.04)
                              : AppColors.textTertiary.withValues(alpha: 0.04),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: activity.status == 'in_progress'
                            ? AppColors.secondary.withValues(alpha: 0.2)
                            : activity.status == 'completed'
                                ? AppColors.success.withValues(alpha: 0.2)
                                : AppColors.textTertiary.withValues(alpha: 0.1),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                activity.title,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                  fontFamily: 'Montserrat',
                                ),
                              ),
                            ),
                            _buildStatusBadge(activity.status),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          activity.description,
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                            fontFamily: 'Montserrat',
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(
                              Icons.access_time_rounded,
                              size: 14,
                              color: AppColors.textTertiary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _formatTimelineTime(activity),
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                                fontFamily: 'Montserrat',
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      }),
    );
  }

  /// Build status badge
  Widget _buildStatusBadge(String status) {
    Color bgColor;
    Color textColor;
    String label;
    IconData icon;

    switch (status) {
      case 'completed':
        bgColor = AppColors.success.withValues(alpha: 0.15);
        textColor = AppColors.success;
        label = 'Done';
        icon = Icons.check_circle_rounded;
        break;
      case 'in_progress':
        bgColor = AppColors.secondary.withValues(alpha: 0.15);
        textColor = AppColors.secondary;
        label = 'In Progress';
        icon = Icons.hourglass_bottom_rounded;
        break;
      case 'pending':
        bgColor = AppColors.textTertiary.withValues(alpha: 0.15);
        textColor = AppColors.textSecondary;
        label = 'Pending';
        icon = Icons.schedule_rounded;
        break;
      default:
        bgColor = AppColors.textTertiary.withValues(alpha: 0.1);
        textColor = AppColors.textSecondary;
        label = 'Unknown';
        icon = Icons.help_outline_rounded;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: textColor),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: textColor,
              fontFamily: 'Montserrat',
            ),
          ),
        ],
      ),
    );
  }

  /// Get status color
  Color _getStatusColor(String status) {
    switch (status) {
      case 'completed':
        return AppColors.success;
      case 'in_progress':
        return AppColors.secondary;
      case 'pending':
        return AppColors.textTertiary;
      default:
        return AppColors.textTertiary;
    }
  }

  /// Format timeline time
  String _formatTimelineTime(TimelineActivity activity) {
    final now = DateTime.now();
    final time = activity.time;
    
    if (activity.status == 'completed') {
      return _getTimeAgo(time);
    } else if (activity.status == 'in_progress') {
      return 'Started ${_getTimeAgo(time)}';
    } else {
      if (time.isAfter(now)) {
        final diff = time.difference(now);
        if (diff.inMinutes < 60) {
          return 'In ${diff.inMinutes} minutes';
        } else if (diff.inHours < 24) {
          return 'In ${diff.inHours} hours';
        } else {
          return DateFormat('MMM dd, hh:mm a').format(time);
        }
      } else {
        return DateFormat('hh:mm a').format(time);
      }
    }
  }
  
  /// Get time ago string
  String _getTimeAgo(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);
    
    if (diff.inSeconds < 60) {
      return 'just now';
    } else if (diff.inMinutes < 60) {
      return '${diff.inMinutes}m ago';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}h ago';
    } else if (diff.inDays < 7) {
      return '${diff.inDays}d ago';
    } else {
      return DateFormat('MMM dd').format(time);
    }
  }
}

/// Timeline Activity Model
class TimelineActivity {
  final String title;
  final String description;
  final DateTime time;
  final String status;
  final IconData icon;

  TimelineActivity({
    required this.title,
    required this.description,
    required this.time,
    required this.status,
    required this.icon,
  });
}
