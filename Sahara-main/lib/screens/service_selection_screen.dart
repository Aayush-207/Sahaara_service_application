import 'package:flutter/material.dart';
import 'package_selection_screen.dart';
import '../theme/app_colors.dart';

/// Service Selection Screen - Choose pet care service type
/// 
/// This screen allows users to select which type of pet care service they need
/// before proceeding to package selection. It displays 4 main service categories:
/// 1. Dog Walking - Professional dog walking services
/// 2. Pet Sitting - In-home pet care and sitting
/// 3. Grooming - Professional grooming services
/// 4. Vet Visit - Vet appointment transportation
/// 
/// Design Principles:
/// - Clean, card-based layout
/// - Clear service descriptions and pricing
/// - Consistent theme colors (Navy primary)
/// - Responsive layout for all screen sizes
/// - 8px grid spacing system
/// - Smooth navigation transitions
/// 
/// Features:
/// - Service cards with icons, descriptions, and starting prices
/// - Direct navigation to package selection for chosen service
/// - Back navigation to previous screen
/// - Indian pricing (₹)
/// 
/// Navigation Flow:
/// Home → Service Selection → Package Selection → Caregiver Selection
/// 
/// Backend Integration:
/// - No backend dependencies (static service list)
/// - Service data passed to PackageSelectionScreen via navigation
/// 
/// Theme Colors Used:
/// - Background: Surface (white)
/// - AppBar: Surface with Text Primary
/// - Service icon containers: Primary (Navy)
/// - Card backgrounds: White with subtle shadows
/// - Text: Primary and Secondary text colors
/// - Arrow icons: Gray 400
/// 
/// Pricing (Indian Market):
/// - Dog Walking: From ₹200
/// - Pet Sitting: From ₹400
/// - Grooming: From ₹500
/// - Vet Visit: From ₹300
class ServiceSelectionScreen extends StatelessWidget {
  const ServiceSelectionScreen({super.key});

  // ============================================================================
  // BUILD METHOD
  // ============================================================================

  @override
  Widget build(BuildContext context) {
    // Service data with Indian pricing
    final services = [
      ServiceData(
        'Dog Walking',
        Icons.directions_walk_rounded,
        'Professional dog walking services',
        'From ₹200',
      ),
      ServiceData(
        'Pet Sitting',
        Icons.home_rounded,
        'In-home pet care and sitting',
        'From ₹400',
      ),
      ServiceData(
        'Grooming',
        Icons.content_cut_rounded,
        'Professional grooming services',
        'From ₹500',
      ),
      ServiceData(
        'Training',
        Icons.school_rounded,
        'Dog training and behavior',
        'From ₹600',
      ),
      ServiceData(
        'Vet Visit',
        Icons.local_hospital_rounded,
        'Vet appointment transportation',
        'From ₹300',
      ),
    ];

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: const Text(
          'Select Service',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontFamily: 'Montserrat',
          ),
        ),
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header title
              const Text(
                'What service do you need?',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                  fontFamily: 'Montserrat',
                  letterSpacing: -0.4,
                ),
              ),
              const SizedBox(height: 6),
              
              // Subtitle
              Text(
                'Choose a service to see available packages',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                  fontFamily: 'Montserrat',
                ),
              ),
              const SizedBox(height: 24),
              
              // Service cards list
              ...services.map((service) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _buildServiceCard(context, service),
              )),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================================
  // UI BUILDER METHODS
  // ============================================================================

  /// Build individual service card with navigation
  Widget _buildServiceCard(BuildContext context, ServiceData service) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => PackageSelectionScreen(
              serviceType: service.title,
            ),
          ),
        );
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[200]!, width: 1),
          boxShadow: [
            BoxShadow(
              color: AppColors.textPrimary.withValues(alpha: 0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                service.icon,
                size: 24,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    service.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                      fontFamily: 'Montserrat',
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    service.description,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                      fontFamily: 'Montserrat',
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    service.price,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                      fontFamily: 'Montserrat',
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 16,
              color: Colors.grey[400],
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// DATA MODEL
// ============================================================================

/// Service data model for service cards
class ServiceData {
  /// Service name (e.g., "Dog Walking")
  final String title;
  
  /// Icon to display in card
  final IconData icon;
  
  /// Service description text
  final String description;
  
  /// Starting price in Indian Rupees
  final String price;

  ServiceData(this.title, this.icon, this.description, this.price);
}
