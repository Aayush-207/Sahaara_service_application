import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:async';
import '../providers/auth_provider.dart';
import '../providers/favorites_provider.dart';
import '../providers/location_provider.dart';
import '../services/firestore_service.dart';
import '../models/user_model.dart';
import '../widgets/filter_bottom_sheet.dart';
import 'caregiver_detail_screen.dart';
import 'profile_screen_enhanced.dart';
import 'bookings_screen.dart';
import 'all_caregivers_screen.dart';
import 'search_results_screen.dart';
import 'service_selection_screen.dart';
import 'package_selection_screen.dart';
import 'my_pets_screen.dart';
import 'messages_coming_soon_screen.dart';
import 'notifications_screen.dart';
import '../theme/app_colors.dart';

/// Home Screen - Main app entry point after authentication
/// 
/// This is the primary screen users see after logging in. It provides:
/// - Bottom navigation with 4 tabs (Home, Pets, Bookings, Profile)
/// - Quick actions floating menu (Add Pet, Book Service, Find Caregivers)
/// - Home tab with services, caregivers, tips, and testimonials
/// 
/// Design Principles:
/// - Modern bottom navigation with Navy background
/// - Floating action button for quick actions
/// - Smooth animations and transitions
/// - Consistent theme colors (Navy, Orange, Sky Blue)
/// - Responsive layout for all screen sizes
/// - 8px grid spacing system
/// - Pull-to-refresh functionality
/// 
/// Features:
/// - Tab navigation (Home, My Pets, Bookings, Profile)
/// - Quick actions overlay with animated buttons
/// - Search functionality with filters
/// - Service cards (Dog Walking, Pet Sitting, Grooming, Vet Visit)
/// - Top caregivers list from Firestore
/// - Featured promotions
/// - Pet care tips
/// - User testimonials
/// - Notification bell
/// 
/// Backend Integration:
/// - FirestoreService.getTopCaregivers() - Fetches caregiver list
/// - AuthProvider.currentUser - Gets logged-in user data
/// - Search functionality with query filtering
/// 
/// Theme Colors Used:
/// - Background: Surface (white)
/// - Bottom nav: Primary (Navy)
/// - Active tab: Secondary (Orange)
/// - Inactive tab: White with 50% opacity
/// - FAB: White with Secondary icon
/// - Service cards: Primary, Secondary, Accent, Tertiary
/// - Notification button: Accent (Sky Blue)
/// - Cards: White with subtle shadows
/// 
/// Animations:
/// - Tab selection: 180ms with easeInOutCubic
/// - FAB rotation: 180ms (45° when open)
/// - Quick actions: Staggered 280-340ms with easeOutCubic
/// - Overlay fade: 180ms
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  // ============================================================================
  // STATE VARIABLES
  // ============================================================================
  
  /// Current selected tab index (0-3)
  int _selectedIndex = 0;
  
  /// Quick actions overlay visibility
  bool _showQuickActions = false;

  // ============================================================================
  // BUILD METHOD
  // ============================================================================

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      const HomeTab(),
      const MyPetsScreen(),
      const BookingsScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      body: Stack(
        children: [
          // Main content
          screens[_selectedIndex],
          
          // Quick actions overlay - always in tree, controlled by visibility
          IgnorePointer(
            ignoring: !_showQuickActions,
            child: AnimatedOpacity(
              opacity: _showQuickActions ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 180),
              child: Stack(
                children: [
                  // Dark overlay background
                  GestureDetector(
                    onTap: () {
                      if (mounted) {
                        setState(() => _showQuickActions = false);
                      }
                    },
                    child: Container(
                      color: AppColors.primary.withValues(alpha: 0.35),
                    ),
                  ),
                  // Floating action buttons
                  _buildQuickActionsOverlay(),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildModernBottomNav(),
    );
  }

  // ============================================================================
  // UI BUILDER METHODS
  // ============================================================================

  /// Build modern bottom navigation bar with elevated center FAB
  Widget _buildModernBottomNav() {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.topCenter,
      children: [
        // Bottom navigation bar
        Container(
          decoration: BoxDecoration(
            color: AppColors.primary,
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.2),
                blurRadius: 16,
                offset: const Offset(0, -4),
              ),
            ],
            border: Border(
              top: BorderSide(
                color: Colors.white.withValues(alpha: 0.08),
                width: 0.5,
              ),
            ),
          ),
          child: SafeArea(
            top: false,
            child: SizedBox(
              height: 75,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    _buildNavItem(Icons.home_rounded, 'Home', 0),
                    _buildNavItem(Icons.pets_rounded, 'Pets', 1),
                    const SizedBox(width: 72), // Space for elevated FAB
                    _buildNavItem(Icons.calendar_today_rounded, 'Bookings', 2),
                    _buildNavItem(Icons.person_rounded, 'Profile', 3),
                  ],
                ),
              ),
            ),
          ),
        ),
        
        // Elevated center FAB
        Positioned(
          top: -12,
          child: _buildElevatedCenterButton(),
        ),
      ],
    );
  }

  /// Build navigation item (Home, Pets, Bookings, Profile)
  Widget _buildNavItem(IconData icon, String label, int index) {
    final isSelected = _selectedIndex == index;
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => setState(() => _selectedIndex = index),
          borderRadius: BorderRadius.circular(12),
          splashColor: Colors.white.withValues(alpha: 0.04),
          highlightColor: Colors.transparent,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  curve: Curves.easeInOutCubic,
                  child: Icon(
                    icon,
                    color: isSelected 
                        ? Colors.white 
                        : Colors.white.withValues(alpha: 0.50),
                    size: 24,
                  ),
                ),
                const SizedBox(height: 2),
                AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 180),
                  curve: Curves.easeInOutCubic,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    color: isSelected 
                        ? AppColors.secondary 
                        : Colors.white.withValues(alpha: 0.50),
                    letterSpacing: 0.05,
                    fontFamily: 'Montserrat',
                    height: 1.15,
                  ),
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Build elevated center floating action button
  Widget _buildElevatedCenterButton() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          if (mounted) {
            setState(() => _showQuickActions = !_showQuickActions);
          }
        },
        borderRadius: BorderRadius.circular(32),
        splashColor: AppColors.secondaryLight.withValues(alpha: 0.3),
        highlightColor: Colors.transparent,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOutCubic,
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            gradient: _showQuickActions 
                ? AppColors.secondaryGradient
                : const LinearGradient(
                    colors: [Colors.white, Colors.white],
                  ),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.secondary.withValues(alpha: 0.2),
                blurRadius: 10,
                offset: const Offset(0, 3),
                spreadRadius: 0,
              ),
            ],
            border: Border.all(
              color: Colors.white,
              width: 3,
            ),
          ),
          child: AnimatedRotation(
            turns: _showQuickActions ? 0.125 : 0,
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOutCubic,
            child: Icon(
              Icons.add_rounded,
              color: _showQuickActions ? Colors.white : AppColors.secondary,
              size: 32,
              semanticLabel: 'Quick Actions',
            ),
          ),
        ),
      ),
    );
  }

  /// Build quick actions overlay with animated buttons
  Widget _buildQuickActionsOverlay() {
    return Positioned.fill(
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 80, left: 18, right: 18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: _showQuickActions ? 1.0 : 0.0),
                duration: const Duration(milliseconds: 280),
                curve: Curves.easeOutCubic,
                builder: (context, value, child) {
                  return Transform.translate(
                    offset: Offset(0, 20 * (1 - value)),
                    child: Opacity(
                      opacity: value,
                      child: _buildFloatingPillButton(
                        icon: Icons.pets_rounded,
                        label: 'Add a Pet',
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: _showQuickActions ? 1.0 : 0.0),
                duration: const Duration(milliseconds: 310),
                curve: Curves.easeOutCubic,
                builder: (context, value, child) {
                  return Transform.translate(
                    offset: Offset(0, 20 * (1 - value)),
                    child: Opacity(
                      opacity: value,
                      child: _buildFloatingPillButton(
                        icon: Icons.calendar_month_rounded,
                        label: 'Book a Service',
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: _showQuickActions ? 1.0 : 0.0),
                duration: const Duration(milliseconds: 340),
                curve: Curves.easeOutCubic,
                builder: (context, value, child) {
                  return Transform.translate(
                    offset: Offset(0, 20 * (1 - value)),
                    child: Opacity(
                      opacity: value,
                      child: _buildFloatingPillButton(
                        icon: Icons.search_rounded,
                        label: 'Find Caregivers',
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Build individual floating pill button
  Widget _buildFloatingPillButton({
    required IconData icon,
    required String label,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          if (!mounted) return;
          
          // Close overlay
          setState(() => _showQuickActions = false);
          
          // Perform action immediately (overlay stays in tree, just invisible)
          if (label.contains('Pet')) {
            // Switch to Pets tab
            setState(() => _selectedIndex = 1);
          } else if (label.contains('Service')) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ServiceSelectionScreen()),
            );
          } else if (label.contains('Caregivers')) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AllCaregiversScreen()),
            );
          }
        },
        borderRadius: BorderRadius.circular(28),
        splashColor: Colors.grey.withValues(alpha: 0.08),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: AppColors.textPrimary.withValues(alpha: 0.05),
                blurRadius: 12,
                offset: const Offset(0, 2),
                spreadRadius: 0,
              ),
              BoxShadow(
                color: AppColors.textPrimary.withValues(alpha: 0.02),
                blurRadius: 5,
                offset: const Offset(0, 1),
                spreadRadius: 0,
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: AppColors.secondary,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: 22,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                    fontFamily: 'Montserrat',
                    letterSpacing: -0.2,
                    height: 1.2,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// HOME TAB - Main content screen
// ============================================================================

/// HomeTab - Main content tab with services, caregivers, and tips
/// 
/// This tab displays the primary home screen content including:
/// - Welcome header with user name
/// - Search bar with filters
/// - Service cards (Dog Walking, Pet Sitting, Grooming, Vet Visit)
/// - Top caregivers list from Firestore
/// - Featured promotions
/// - Pet care tips
/// - User testimonials
/// 
/// Backend Integration:
/// - FirestoreService.getTopCaregivers() - Fetches caregiver list
/// - Search functionality with query filtering
/// - Pull-to-refresh to reload data
class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  // ============================================================================
  // STATE VARIABLES
  // ============================================================================
  
  /// Firestore service for data fetching
  final FirestoreService _firestoreService = FirestoreService();
  
  /// Search text controller
  final TextEditingController _searchController = TextEditingController();
  
  /// Debounce timer for search
  Timer? _debounceTimer;
  
  /// Search suggestions
  List<UserModel> _searchSuggestions = [];
  
  /// Show suggestions overlay
  bool _showSuggestions = false;

  // ============================================================================
  // LIFECYCLE METHODS
  // ============================================================================

  @override
  void initState() {
    super.initState();
    _loadFavorites();
    _searchController.addListener(_onSearchChanged);
    
    // Automatically request location permission on app load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _requestLocationAutomatically();
    });
  }
  
  /// Automatically request location permission when user lands on home
  Future<void> _requestLocationAutomatically() async {
    try {
      final locationProvider = Provider.of<LocationProvider>(context, listen: false);
      
      // Only request if not already granted
      if (!locationProvider.permissionGranted) {
        debugPrint('Auto-requesting location permission...');
        await locationProvider.requestLocationPermission();
      }
    } catch (e) {
      debugPrint('Error auto-requesting location: $e');
    }
  }

  /// Build location permission bottom sheet
  Widget _buildLocationPermissionSheet() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
              margin: const EdgeInsets.only(bottom: 20),
            ),
            // Icon
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                color: AppColors.accent.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.location_on_rounded,
                size: 36,
                color: AppColors.accent,
              ),
            ),
            const SizedBox(height: 16),
            // Title
            Text(
              'Allow Location Access',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
                fontFamily: 'Montserrat',
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            // Description
            Text(
              'We need your location to show nearby caregivers and provide personalized service recommendations.',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                fontFamily: 'Montserrat',
                fontWeight: FontWeight.w400,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            // Allow button
            Consumer<LocationProvider>(
              builder: (context, locationProvider, _) {
                return SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: locationProvider.isLoading
                        ? null
                        : () async {
                            final success = await locationProvider.requestLocationPermission();
                            if (mounted && success) {
                              Navigator.pop(context);
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.secondary,
                      disabledBackgroundColor: Colors.grey[300],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: locationProvider.isLoading
                        ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white.withValues(alpha: 0.8),
                              ),
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            'Allow Location Access',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                              fontFamily: 'Montserrat',
                              letterSpacing: -0.2,
                            ),
                          ),
                  ),
                );
              },
            ),
            const SizedBox(height: 12),
            // Dismiss button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                style: TextButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: Colors.grey[300]!),
                  ),
                ),
                child: const Text(
                  'Not Now',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                    fontFamily: 'Montserrat',
                    letterSpacing: -0.2,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Load user's favorites
  void _loadFavorites() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final favProvider = Provider.of<FavoritesProvider>(context, listen: false);
    final userId = authProvider.currentUser?.uid;
    
    if (userId != null) {
      favProvider.loadFavorites(userId);
    }
  }
  
  /// Handle search text changes with debounce
  void _onSearchChanged() {
    if (_debounceTimer?.isActive ?? false) _debounceTimer!.cancel();
    
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      if (_searchController.text.trim().isNotEmpty) {
        _fetchSearchSuggestions(_searchController.text);
      } else {
        setState(() {
          _showSuggestions = false;
          _searchSuggestions = [];
        });
      }
    });
  }
  
  /// Fetch search suggestions
  Future<void> _fetchSearchSuggestions(String query) async {
    if (query.trim().isEmpty) return;
    
    try {
      final caregivers = await _firestoreService.getTopCaregivers(limit: 50);
      final results = caregivers.where((c) {
        final queryLower = query.toLowerCase();
        return c.name.toLowerCase().contains(queryLower) ||
               (c.services?.any((s) => s.toLowerCase().contains(queryLower)) ?? false) ||
               (c.location ?? '').toLowerCase().contains(queryLower);
      }).take(5).toList();
      
      if (mounted) {
        setState(() {
          _searchSuggestions = results;
          _showSuggestions = results.isNotEmpty;
        });
      }
    } catch (e) {
      debugPrint('Error fetching suggestions: $e');
    }
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  // ============================================================================
  // BUILD METHOD
  // ============================================================================

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final userName = authProvider.currentUser?.name.split(' ').first ?? 'There';

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            setState(() {});
          },
          color: AppColors.secondary,
          child: CustomScrollView(
            slivers: [
              // Scrollable header with greeting and location
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                  child: _buildStickyHeader(userName),
                ),
              ),
              SliverToBoxAdapter(child: _buildSearchBar()),
              SliverToBoxAdapter(child: _buildServices()),
              SliverToBoxAdapter(child: _buildFeaturedSection()),
              SliverToBoxAdapter(child: _buildTopCaregivers()),
              SliverToBoxAdapter(child: _buildTipsSection()),
              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          ),
        ),
      ),
    );
  }

  /// Build sticky header with greeting and location
  Widget _buildStickyHeader(String userName) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Greeting row with messages
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Greeting text
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          'Hello, $userName!',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                            letterSpacing: -0.5,
                            fontFamily: 'Montserrat',
                            height: 1.2,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Icon(
                        Icons.waving_hand_rounded,
                        size: 22,
                        color: Color(0xFFFFB74D),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Location Display
                  Consumer<LocationProvider>(
                    builder: (context, locationProvider, _) {
                      return AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        child: Container(
                          key: ValueKey(locationProvider.permissionGranted),
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.accent.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: AppColors.accent.withValues(alpha: 0.2),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.location_on_rounded,
                                size: 16,
                                color: AppColors.accent,
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  locationProvider.isLoading
                                      ? 'Getting location...'
                                      : locationProvider.permissionGranted
                                          ? locationProvider.getLocationString()
                                          : 'Requesting location...',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.accent,
                                    fontFamily: 'Montserrat',
                                    fontWeight: FontWeight.w500,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (locationProvider.isLoading)
                                Padding(
                                  padding: const EdgeInsets.only(left: 6),
                                  child: SizedBox(
                                    width: 12,
                                    height: 12,
                                    child: CircularProgressIndicator(
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        AppColors.accent.withValues(alpha: 0.6),
                                      ),
                                      strokeWidth: 1.5,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            // Notifications button
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const NotificationsScreen(),
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(50),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  child: Icon(
                    Icons.notifications_outlined,
                    size: 24,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ============================================================================
  // UI BUILDER METHODS
  // ============================================================================

  /// Build search bar with filter button
  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
      child: Column(
        children: [
          Container(
            height: 52,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: TextField(
              controller: _searchController,
              style: const TextStyle(
                fontSize: 15,
                fontFamily: 'Montserrat',
              ),
              decoration: InputDecoration(
                hintText: 'Search caregivers, services...',
                hintStyle: TextStyle(
                  color: Colors.grey[500],
                  fontSize: 15,
                  fontFamily: 'Montserrat',
                ),
                prefixIcon: Icon(Icons.search_rounded, color: Colors.grey[600], size: 20),
                suffixIcon: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_searchController.text.isNotEmpty)
                      IconButton(
                        icon: Icon(Icons.clear_rounded, color: Colors.grey[600], size: 18),
                        onPressed: () {
                          setState(() {
                            _searchController.clear();
                            _showSuggestions = false;
                            _searchSuggestions = [];
                          });
                        },
                      ),
                    IconButton(
                      icon: Icon(Icons.tune_rounded, color: Colors.grey[600], size: 20),
                      onPressed: () {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                          builder: (_) => FilterBottomSheet(
                            onApplyFilters: (filters) {
                              setState(() {});
                            },
                          ),
                        );
                      },
                    ),
                  ],
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
              onChanged: (value) {
                setState(() {}); // Update UI to show/hide clear button
              },
              onSubmitted: (query) => _performSearch(query),
            ),
          ),
          // Search suggestions dropdown
          if (_showSuggestions && _searchSuggestions.isNotEmpty)
            Container(
              margin: const EdgeInsets.only(top: 4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: _searchSuggestions.length,
                separatorBuilder: (_, __) => Divider(height: 1, color: Colors.grey[200]),
                itemBuilder: (context, index) {
                  final caregiver = _searchSuggestions[index];
                  return ListTile(
                    dense: true,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    leading: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                        image: caregiver.photoUrl != null && caregiver.photoUrl!.isNotEmpty
                            ? DecorationImage(
                                image: NetworkImage(caregiver.photoUrl!),
                                fit: BoxFit.cover,
                              )
                            : null,
                      ),
                      child: caregiver.photoUrl == null || caregiver.photoUrl!.isEmpty
                          ? Icon(
                              Icons.person_rounded,
                              size: 20,
                              color: AppColors.primary.withValues(alpha: 0.6),
                            )
                          : null,
                    ),
                    title: Text(
                      caregiver.name,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Montserrat',
                      ),
                    ),
                    subtitle: Text(
                      caregiver.location ?? 'No location',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                        fontFamily: 'Montserrat',
                      ),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.star_rounded, size: 14, color: Colors.amber),
                        const SizedBox(width: 2),
                        Text(
                          caregiver.rating?.toStringAsFixed(1) ?? '0.0',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Montserrat',
                          ),
                        ),
                      ],
                    ),
                    onTap: () {
                      setState(() {
                        _showSuggestions = false;
                        _searchController.clear();
                      });
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => CaregiverDetailScreen(caregiver: caregiver),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  /// Perform search and navigate to results
  Future<void> _performSearch(String query) async {
    if (query.trim().isEmpty) return;
    
    // Show loading indicator
    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      ),
    );
    
    try {
      // Fetch all caregivers
      final caregivers = await _firestoreService.getTopCaregivers(limit: 100);
      
      // Filter results based on query
      final results = caregivers.where((c) {
        final queryLower = query.toLowerCase();
        final nameLower = c.name.toLowerCase();
        final locationLower = (c.location ?? '').toLowerCase();
        final bioLower = (c.bio ?? '').toLowerCase();
        
        // Search in name, services, location, and bio
        return nameLower.contains(queryLower) ||
               (c.services?.any((s) => s.toLowerCase().contains(queryLower)) ?? false) ||
               locationLower.contains(queryLower) ||
               bioLower.contains(queryLower);
      }).toList();
      
      // Sort by relevance (name matches first, then others)
      results.sort((a, b) {
        final queryLower = query.toLowerCase();
        final aNameMatch = a.name.toLowerCase().contains(queryLower);
        final bNameMatch = b.name.toLowerCase().contains(queryLower);
        
        if (aNameMatch && !bNameMatch) return -1;
        if (!aNameMatch && bNameMatch) return 1;
        
        // If both match or both don't match, sort by rating
        return (b.rating ?? 0).compareTo(a.rating ?? 0);
      });
      
      if (!mounted) return;
      
      // Close loading dialog
      Navigator.pop(context);
      
      // Navigate to results
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => SearchResultsScreen(
            query: query,
            results: results,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      
      // Close loading dialog
      Navigator.pop(context);
      
      // Show error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Search failed: ${e.toString()}'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  /// Build services grid section
  Widget _buildServices() {
    final services = [
      ServiceData(
        'Dog Walking',
        Icons.directions_walk_rounded,
        'Take your pet for a walk',
        '₹299',
      ),
      ServiceData(
        'Pet Sitting',
        Icons.home_rounded,
        'Pet care while you are away',
        '₹499',
      ),
      ServiceData(
        'Grooming',
        Icons.content_cut_rounded,
        'Professional grooming service',
        '₹599',
      ),
      ServiceData(
        'Training',
        Icons.school_rounded,
        'Train your pet effectively',
        '₹799',
      ),
      ServiceData(
        'Vet Visit',
        Icons.local_hospital_rounded,
        'Visit to veterinarian',
        '₹699',
      ),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Services',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
              fontFamily: 'Montserrat',
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 14),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.9,
            ),
            itemCount: services.length,
            itemBuilder: (context, index) {
              return _buildServiceCard(services[index]);
            },
          ),
        ],
      ),
    );
  }

  /// Build individual service card
  Widget _buildServiceCard(ServiceData service) {
    return InkWell(
      onTap: () {
        // Navigate directly to package selection for the specific service
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
        padding: const EdgeInsets.all(13),
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
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(11),
              ),
              child: Icon(service.icon, size: 22, color: Colors.white),
            ),
            const SizedBox(width: 11),
            Expanded(
              child: Text(
                service.title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                  fontFamily: 'Montserrat',
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build top caregivers section with Firestore data
  Widget _buildTopCaregivers() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Top Caregivers',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                  fontFamily: 'Montserrat',
                  letterSpacing: -0.3,
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AllCaregiversScreen()),
                  );
                },
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text(
                  'See All',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    fontFamily: 'Montserrat',
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          FutureBuilder<List<UserModel>>(
            future: _firestoreService.getTopCaregivers(limit: 5),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: CircularProgressIndicator(
                      color: AppColors.textPrimary,
                      strokeWidth: 2,
                    ),
                  ),
                );
              }

              final caregivers = snapshot.data ?? [];
              if (caregivers.isEmpty) {
                return _buildEmptyCaregivers();
              }

              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: caregivers.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _buildCaregiverCard(caregivers[index]),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  /// Build empty state when no caregivers found
  Widget _buildEmptyCaregivers() {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          Icon(
            Icons.people_outline,
            size: 64,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 16),
          Text(
            'No caregivers available',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
              fontFamily: 'Montserrat',
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Check back soon for available caregivers',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
              fontFamily: 'Montserrat',
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// Build individual caregiver card
  Widget _buildCaregiverCard(UserModel caregiver) {
    final displayName = caregiver.name;
    final displayRating = caregiver.rating?.toStringAsFixed(1) ?? '0.0';
    final displayWalks = caregiver.completedBookings?.toString() ?? '0';

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => CaregiverDetailScreen(caregiver: caregiver),
          ),
        );
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border, width: 1),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: caregiver.photoUrl != null && caregiver.photoUrl!.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: caregiver.photoUrl!,
                        fit: BoxFit.cover,
                        width: 56,
                        height: 56,
                        placeholder: (context, url) => Container(
                          color: AppColors.primary,
                          child: const Center(
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          ),
                        ),
                        errorWidget: (context, url, error) {
                          debugPrint('Error loading caregiver image: $error');
                          return const Icon(Icons.person_rounded, size: 28, color: Colors.white);
                        },
                      )
                    : const Icon(Icons.person_rounded, size: 28, color: Colors.white),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    displayName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                      fontFamily: 'Montserrat',
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.star_rounded, size: 14, color: AppColors.warning),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          '$displayRating • $displayWalks bookings',
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                            fontFamily: 'Montserrat',
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Consumer<FavoritesProvider>(
              builder: (context, favProvider, _) {
                final authProvider = Provider.of<AuthProvider>(context, listen: false);
                final userId = authProvider.currentUser?.uid ?? '';
                final isFav = favProvider.isFavorite(caregiver.uid);
                
                return IconButton(
                  icon: Icon(
                    isFav ? Icons.favorite : Icons.favorite_border,
                    color: isFav ? AppColors.error : AppColors.textTertiary,
                    size: 22,
                  ),
                  onPressed: () async {
                    if (userId.isEmpty) return;
                    
                    final success = await favProvider.toggleFavorite(userId, caregiver.uid);
                    if (success) {
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            isFav ? 'Removed from favorites' : 'Added to favorites',
                            style: const TextStyle(fontFamily: 'Montserrat'),
                          ),
                          backgroundColor: isFav ? AppColors.textSecondary : AppColors.success,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    }
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  /// Build featured promotion section
  Widget _buildFeaturedSection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Featured This Week',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
              fontFamily: 'Montserrat',
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 14),
          InkWell(
            onTap: () {
              // Navigate to premium care details
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Premium Care - 20% off first booking!'),
                  backgroundColor: AppColors.primary,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.secondary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Premium Care',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            fontFamily: 'Montserrat',
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Get 20% off on your first booking with verified caregivers',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.white.withValues(alpha: 0.85),
                            fontFamily: 'Montserrat',
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'Learn More',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                              fontFamily: 'Montserrat',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.star_rounded,
                      size: 32,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Build pet care tips section with 2-column vertical layout
  Widget _buildTipsSection() {
    final tips = [
      // Seasonal Tips
      {
        'icon': Icons.wb_sunny_rounded,
        'title': 'Summer Heat Protection',
        'description': 'Walk early morning or late evening. Keep water bowls filled and avoid hot pavements.',
      },
      {
        'icon': Icons.water_drop_rounded,
        'title': 'Monsoon Care',
        'description': 'Dry paws thoroughly after walks. Watch for skin infections and keep indoor play options ready.',
      },
      // Common Tips
      {
        'icon': Icons.restaurant_rounded,
        'title': 'Balanced Nutrition',
        'description': 'Feed age-appropriate food. Avoid spicy human food and maintain consistent meal times.',
      },
      {
        'icon': Icons.vaccines_rounded,
        'title': 'Vaccination Schedule',
        'description': 'Keep rabies and distemper vaccines current. Annual boosters are essential for immunity.',
      },
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Pet Care Tips',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
              fontFamily: 'Montserrat',
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 14),
          // 2-column grid layout
          GridView.builder(
            padding: EdgeInsets.zero,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.85,
            ),
            itemCount: tips.length,
            itemBuilder: (context, index) {
              final tip = tips[index];
              return InkWell(
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${tip['title']} - Learn more about pet care'),
                      backgroundColor: AppColors.primary,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      duration: const Duration(seconds: 2),
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 46,
                        height: 46,
                        decoration: BoxDecoration(
                          color: AppColors.accent,
                          borderRadius: BorderRadius.circular(11),
                        ),
                        child: Icon(
                          tip['icon'] as IconData,
                          size: 22,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        tip['title'] as String,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                          fontFamily: 'Montserrat',
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Expanded(
                        child: Text(
                          tip['description'] as String,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                            fontFamily: 'Montserrat',
                            height: 1.3,
                          ),
                          maxLines: 4,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}





