import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/location_provider.dart';
import '../theme/app_colors.dart';
import 'package:intl/intl.dart';

/// Tracking Screen - Track pet location and service status
class TrackingScreen extends StatefulWidget {
  const TrackingScreen({super.key});

  @override
  State<TrackingScreen> createState() => _TrackingScreenState();
}

class _TrackingScreenState extends State<TrackingScreen> {
  GoogleMapController? _mapController;
  Set<Marker> _markers = {};

  // Default location (Mumbai, India)
  static const CameraPosition _defaultPosition = CameraPosition(
    target: LatLng(19.0760, 72.8777),
    zoom: 15,
  );

  // Sample data for tracking
  final List<ServiceActivity> activities = [
    ServiceActivity(
      service: 'Grooming',
      status: 'completed',
      startTime: DateTime.now().subtract(const Duration(hours: 4)),
      endTime: DateTime.now().subtract(const Duration(hours: 2)),
      description: 'Hair trimming and styling completed',
    ),
    ServiceActivity(
      service: 'Cleaning/Bathing',
      status: 'in_progress',
      startTime: DateTime.now().subtract(const Duration(hours: 2)),
      endTime: null,
      description: 'Dog is being bathed and cleaned',
    ),
    ServiceActivity(
      service: 'Training',
      status: 'pending',
      startTime: DateTime.now().add(const Duration(hours: 1)),
      endTime: null,
      description: 'Training session scheduled',
    ),
    ServiceActivity(
      service: 'Vaccination',
      status: 'pending',
      startTime: DateTime.now().add(const Duration(hours: 3)),
      endTime: null,
      description: 'Vet appointment for vaccination',
    ),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeLocation();
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
    _markers.clear();

    final petLocation = locationProvider.currentPosition;
    if (petLocation != null) {
      _markers.add(
        Marker(
          markerId: const MarkerId('pet_location'),
          position: LatLng(petLocation.latitude, petLocation.longitude),
          infoWindow: InfoWindow(
            title: 'Pet Location',
            snippet: locationProvider.currentAddress ?? 'Current Location',
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        ),
      );
    } else {
      // Add default marker if no location available
      _markers.add(
        const Marker(
          markerId: MarkerId('default_location'),
          position: LatLng(19.0760, 72.8777),
          infoWindow: InfoWindow(
            title: 'Pet Location',
            snippet: 'Mumbai, India',
          ),
        ),
      );
    }
  }

  @override
  void dispose() {
    _mapController?.dispose();
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
          backgroundColor: Colors.white,
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
              Icon(Icons.lock_outline, size: 64, color: Colors.grey[400]),
              const SizedBox(height: 16),
              Text(
                'Please login to view tracking',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
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
        backgroundColor: Colors.white,
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
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            height: 1,
            color: AppColors.border,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildLocationMap(),
            _buildServiceTimeline(),
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
          const Text(
            'Current Location',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
              fontFamily: 'Montserrat',
            ),
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
                            'Pet Location',
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
                                : 'Updated just now',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[500],
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

  /// Build service timeline section
  Widget _buildServiceTimeline() {
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
          _buildTimeline(),
        ],
      ),
    );
  }

  /// Build timeline widget
  Widget _buildTimeline() {
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
                        _getStatusIcon(activity.status),
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    if (index < activities.length - 1)
                      Container(
                        width: 2,
                        height: 50,
                        color: Colors.grey[300],
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
                              ? Colors.green.withValues(alpha: 0.04)
                              : Colors.grey.withValues(alpha: 0.04),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: activity.status == 'in_progress'
                            ? AppColors.secondary.withValues(alpha: 0.2)
                            : activity.status == 'completed'
                                ? Colors.green.withValues(alpha: 0.2)
                                : Colors.grey.withValues(alpha: 0.1),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              activity.service,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                                fontFamily: 'Montserrat',
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
                            Icon(
                              Icons.access_time_rounded,
                              size: 14,
                              color: Colors.grey[500],
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _formatActivityTime(activity),
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
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
        bgColor = Colors.green.withValues(alpha: 0.15);
        textColor = Colors.green[700]!;
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
        bgColor = Colors.grey.withValues(alpha: 0.15);
        textColor = Colors.grey[700]!;
        label = 'Pending';
        icon = Icons.schedule_rounded;
        break;
      default:
        bgColor = Colors.grey.withValues(alpha: 0.1);
        textColor = Colors.grey[600]!;
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
        return Colors.green;
      case 'in_progress':
        return AppColors.secondary;
      case 'pending':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  /// Get status icon
  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'completed':
        return Icons.check_rounded;
      case 'in_progress':
        return Icons.animation_rounded;
      case 'pending':
        return Icons.schedule_rounded;
      default:
        return Icons.help_outline_rounded;
    }
  }

  /// Format activity time
  String _formatActivityTime(ServiceActivity activity) {
    if (activity.status == 'pending') {
      return 'Starts ${DateFormat('hh:mm a').format(activity.startTime)}';
    } else if (activity.status == 'in_progress') {
      return 'Started ${DateFormat('hh:mm a').format(activity.startTime)}';
    } else {
      return '${DateFormat('hh:mm a').format(activity.startTime)} - ${DateFormat('hh:mm a').format(activity.endTime!)}';
    }
  }
}

/// Service Activity Model
class ServiceActivity {
  final String service;
  final String status;
  final DateTime startTime;
  final DateTime? endTime;
  final String description;

  ServiceActivity({
    required this.service,
    required this.status,
    required this.startTime,
    required this.endTime,
    required this.description,
  });
}
