import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../models/user_model.dart';
import '../services/firestore_service.dart';
import '../theme/app_colors.dart';
import 'package:intl/intl.dart';

/// Tracking Screen - Track pet location and service status
/// 
/// Features:
/// - Google Maps view to show pet's current location
/// - Real-time location tracking
/// - Timeline view showing service progress
/// - Service status indicators (Grooming, Cleaning, Bathing, Training)
class TrackingScreen extends StatefulWidget {
  const TrackingScreen({super.key});

  @override
  State<TrackingScreen> createState() => _TrackingScreenState();
}

class _TrackingScreenState extends State<TrackingScreen> {
  late GoogleMapController _mapController;
  
  // Sample data for tracking (in a real app, this would come from Firestore)
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
            // Location Map
            _buildLocationMap(),
            
            // Service Timeline
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
          // Section Title
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
          
          // Map Container
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
                initialCameraPosition: const CameraPosition(
                  target: LatLng(19.0760, 72.8777), // Mumbai, India
                  zoom: 15,
                ),
                onMapCreated: (controller) {
                  _mapController = controller;
                },
                myLocationEnabled: true,
                myLocationButtonEnabled: true,
                mapType: MapType.normal,
              ),
            ),
          ),
          
          // Pet Location Info
          const SizedBox(height: 12),
          Container(
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
                      const Text(
                        'Grooming Salon, Bandra, Mumbai',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textPrimary,
                          fontFamily: 'Montserrat',
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Updated 5 minutes ago',
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
          // Section Title
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
          
          // Timeline
          _buildTimeline(),
        ],
      ),
    );
  }

  /// Build timeline widget showing service progress
  Widget _buildTimeline() {
    return Column(
      children: List.generate(activities.length, (index) {
        final activity = activities[index];
        final isCompleted = activity.status == 'completed';
        final isInProgress = activity.status == 'in_progress';

        return Column(
          children: [
            // Timeline Item
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Timeline connector
                Column(
                  children: [
                    // Circle indicator
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
                    
                    // Vertical line (if not last)
                    if (index < activities.length - 1)
                      Container(
                        width: 2,
                        height: 50,
                        color: Colors.grey[300],
                      ),
                  ],
                ),
                
                const SizedBox(width: 16),
                
                // Content
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(
                      color: isInProgress
                          ? AppColors.secondary.withValues(alpha: 0.08)
                          : isCompleted
                              ? Colors.green.withValues(alpha: 0.04)
                              : Colors.grey.withValues(alpha: 0.04),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isInProgress
                            ? AppColors.secondary.withValues(alpha: 0.2)
                            : isCompleted
                                ? Colors.green.withValues(alpha: 0.2)
                                : Colors.grey.withValues(alpha: 0.1),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Service name and status badge
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
                        
                        // Description
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
                        
                        // Time information
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

  /// Build status badge widget
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

  /// Get status color based on service status
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

  /// Get status icon based on service status
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

  /// Format activity time for display
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

/// Model for service activities
class ServiceActivity {
  final String service;
  final String status; // 'completed', 'in_progress', 'pending'
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
