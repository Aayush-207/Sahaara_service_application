import 'package:flutter/material.dart';
import '../models/service_package_model.dart';
import '../services/package_service.dart';
import 'caregiver_selection_screen.dart';
import '../theme/app_colors.dart';

/// Package Selection Screen - Choose service package tier
/// 
/// This screen allows users to select a package tier (Basic, Standard, Premium)
/// for their chosen service. Each package has different durations, features, and pricing.
/// 
/// Package Tiers:
/// - Basic: Entry-level service with essential features
/// - Standard: Most popular, balanced features and pricing
/// - Premium: Comprehensive service with all features
/// 
/// Design Principles:
/// - Card-based selection with visual feedback
/// - Clear pricing and feature comparison
/// - Popular badge for recommended packages
/// - Discount badges when applicable
/// - Sticky bottom bar with continue button
/// - Consistent theme colors (Navy primary)
/// - Responsive layout for all screen sizes
/// - 8px grid spacing system
/// - Smooth animations on selection
/// 
/// Features:
/// - Package cards with selection state
/// - Feature lists with checkmarks
/// - Popular package highlighting
/// - Discount display
/// - Selected package summary in bottom bar
/// - Continue button (only shown when package selected)
/// - Navigation to caregiver selection
/// 
/// Backend Integration:
/// - PackageService.getPackagesForService() - Fetches packages for service type
/// - Returns List with ServicePackageModel package data
/// - Static data (no Firestore dependency)
/// 
/// Navigation Flow:
/// Service Selection → Package Selection → Caregiver Selection → Booking
/// 
/// Theme Colors Used:
/// - Background: Surface (white)
/// - AppBar: Surface with Text Primary
/// - Selected border: Text Primary (Navy)
/// - Unselected border: Gray 200
/// - Popular badge: Text Primary (Navy)
/// - Discount badge: Green with light background
/// - Checkmarks: Text Primary when selected, Gray when not
/// - Continue button: Text Primary (Navy)
/// 
/// Animations:
/// - Card selection: 200ms border and shadow transition
/// - Checkmark color: Instant on selection
class PackageSelectionScreen extends StatefulWidget {
  /// Service type selected from previous screen
  final String serviceType;

  const PackageSelectionScreen({
    super.key,
    required this.serviceType,
  });

  @override
  State<PackageSelectionScreen> createState() => _PackageSelectionScreenState();
}

class _PackageSelectionScreenState extends State<PackageSelectionScreen> {
  // ============================================================================
  // STATE VARIABLES
  // ============================================================================
  
  /// Currently selected package (null if none selected)
  ServicePackageModel? _selectedPackage;
  
  /// Package service instance
  final PackageService _packageService = PackageService();
  
  /// Cached packages list to avoid refetching on setState
  List<ServicePackageModel>? _cachedPackages;
  
  /// Loading state
  bool _isLoading = true;

  // ============================================================================
  // LIFECYCLE METHODS
  // ============================================================================
  
  @override
  void initState() {
    super.initState();
    _loadPackages();
  }
  
  /// Load packages once and cache them, sorted by price
  Future<void> _loadPackages() async {
    try {
      debugPrint('📦 Loading packages for service: "${widget.serviceType}"');
      final packages = await _packageService.getPackagesForService(widget.serviceType);
      debugPrint('✅ Loaded ${packages.length} packages');
      
      // Sort packages by price in ascending order (lowest to highest)
      packages.sort((a, b) => a.price.compareTo(b.price));
      setState(() {
        _cachedPackages = packages;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('❌ Error loading packages: $e');
      setState(() {
        _cachedPackages = [];
        _isLoading = false;
      });
    }
  }

  // ============================================================================
  // BUILD METHOD
  // ============================================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: Text(
          widget.serviceType,
          style: const TextStyle(
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
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              )
            : _buildContent(),
      ),
    );
  }
  
  /// Build main content with cached packages
  Widget _buildContent() {
    final packages = _cachedPackages ?? [];
    
    if (packages.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.inventory_2_outlined, size: 64, color: AppColors.textTertiary),
            const SizedBox(height: 16),
            const Text(
              'No packages available',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
                fontFamily: 'Montserrat',
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'No packages found for "${widget.serviceType}"',
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textTertiary,
                fontFamily: 'Montserrat',
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  _isLoading = true;
                });
                _loadPackages();
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        // Scrollable package list
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header title
                const Text(
                  'Choose Your Package',
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
                  'Select the package that best fits your needs',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                    fontFamily: 'Montserrat',
                  ),
                ),
                const SizedBox(height: 24),
                
                // Package cards list
                ...packages.map((package) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _buildPackageCard(package),
                )),
              ],
            ),
          ),
        ),
        
        // Sticky bottom bar with continue button (only shown when package selected)
        if (_selectedPackage != null) _buildContinueButton(),
      ],
    );
  }

  // ============================================================================
  // UI BUILDER METHODS
  // ============================================================================

  /// Build individual package card with selection state
  Widget _buildPackageCard(ServicePackageModel package) {
    final isSelected = _selectedPackage?.id == package.id;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPackage = package;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.textPrimary : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.textPrimary.withValues(alpha: isSelected ? 0.06 : 0.03),
              blurRadius: isSelected ? 12 : 8,
              offset: Offset(0, isSelected ? 4 : 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Package header with name, popular badge, and price
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            package.packageName,
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                              fontFamily: 'Montserrat',
                            ),
                          ),
                          if (package.isPopular) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.textPrimary,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text(
                                'POPULAR',
                                style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.surface,
                                  letterSpacing: 0.5,
                                  fontFamily: 'Montserrat',
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(
                        package.duration,
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w500,
                          fontFamily: 'Montserrat',
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '₹${package.price.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                        fontFamily: 'Montserrat',
                      ),
                    ),
                    if (package.discount != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF4CAF50).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          package.discount!,
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF4CAF50),
                            fontFamily: 'Montserrat',
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 10),
            
            // Package description
            Text(
              package.description,
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
                fontFamily: 'Montserrat',
              ),
            ),
            const SizedBox(height: 12),
            Divider(height: 1, color: AppColors.border),
            const SizedBox(height: 12),
            
            // Features header
            const Text(
              'Includes:',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
                fontFamily: 'Montserrat',
              ),
            ),
            const SizedBox(height: 10),
            
            // Feature list with checkmarks
            ...package.features.map((feature) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                children: [
                  Container(
                    width: 18,
                    height: 18,
                    decoration: BoxDecoration(
                      color: isSelected 
                          ? AppColors.textPrimary 
                          : AppColors.border,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.check_rounded,
                      size: 12,
                      color: isSelected ? AppColors.surface : AppColors.textTertiary,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      feature,
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                        fontFamily: 'Montserrat',
                      ),
                    ),
                  ),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }

  /// Build sticky bottom bar with continue button
  Widget _buildContinueButton() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border)),
        boxShadow: [
          BoxShadow(
            color: AppColors.textPrimary.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Selected package summary
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Selected Package',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                        fontFamily: 'Montserrat',
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      _selectedPackage!.packageName,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                        fontFamily: 'Montserrat',
                      ),
                    ),
                  ],
                ),
                Text(
                  '₹${_selectedPackage!.price.toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                    fontFamily: 'Montserrat',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            
            // Continue button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CaregiverSelectionScreen(
                        serviceType: widget.serviceType,
                        selectedPackage: _selectedPackage!,
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.textPrimary,
                  foregroundColor: AppColors.surface,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Continue to Caregiver Selection',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Montserrat',
                      ),
                    ),
                    SizedBox(width: 8),
                    Icon(Icons.arrow_forward_rounded, size: 18),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


