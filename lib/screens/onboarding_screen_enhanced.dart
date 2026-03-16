import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'login_screen_enhanced.dart';
import '../theme/app_colors.dart';

/// Onboarding Screen - Industry Standard Implementation
/// 
/// Design Standards Applied:
/// - Icon: 140-180px (30-35% screen width) - Material Design
/// - Title: 32px Headline Large - Typography Scale
/// - Description: 16px Body Large - Typography Scale
/// - Button: 56px height - Touch Target Standard
/// - Indicator: 8px inactive, 32px active - Component Standard
/// - Horizontal padding: 24px - 8pt grid
/// - Vertical spacing: 48px - 8pt grid
/// - Animation: 300-400ms - Industry Standard
/// 
/// Accessibility:
/// - WCAG AA contrast ratios
/// - Touch targets ≥48px
/// - Semantic structure
/// - Clear visual hierarchy

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> with TickerProviderStateMixin {
  // ============================================================================
  // STATE
  // ============================================================================
  
  final PageController _pageController = PageController();
  int _currentPage = 0;
  
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  final List<OnboardingData> _pages = [
    OnboardingData(
      icon: Icons.verified_user_rounded,
      iconColor: AppColors.primary, // Navy
      title: 'Verified Caregivers',
      description: 'Connect with trusted and verified pet care professionals in your area',
    ),
    OnboardingData(
      icon: Icons.location_on_rounded,
      iconColor: AppColors.secondary, // Orange
      title: 'Real-Time Tracking',
      description: 'Monitor your pet\'s walks and activities with live GPS tracking',
    ),
    OnboardingData(
      icon: Icons.notifications_active_rounded,
      iconColor: AppColors.accent, // Sky Blue
      title: 'Stay Updated',
      description: 'Get instant updates and photos during your pet\'s care sessions',
    ),
  ];

  // ============================================================================
  // LIFECYCLE
  // ============================================================================

  @override
  void initState() {
    super.initState();
    _setupStatusBar();
    _initAnimations();
    _startInitialAnimation();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  // ============================================================================
  // SETUP
  // ============================================================================

  void _setupStatusBar() {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
    );
  }

  void _initAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 700),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeIn),
    );
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
    );
  }

  void _startInitialAnimation() {
    _fadeController.forward();
    _slideController.forward();
  }

  // ============================================================================
  // HANDLERS
  // ============================================================================

  void _onPageChanged(int index) {
    if (_currentPage != index) {
      setState(() => _currentPage = index);
    }
  }

  void _skipToLogin() {
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => 
            const LoginScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
  }

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOutCubic,
      );
    } else {
      _skipToLogin();
    }
  }

  // ============================================================================
  // BUILD
  // ============================================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Column(
          children: [
            // Skip button - 48px touch target
            _buildSkipButton(),
            
            // Pages
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: _onPageChanged,
                itemCount: _pages.length,
                physics: const PageScrollPhysics(),
                scrollDirection: Axis.horizontal,
                itemBuilder: (context, index) => _buildPage(_pages[index]),
              ),
            ),
            
            // Indicator - 8pt grid spacing
            _buildIndicator(),
            const SizedBox(height: 32), // 8pt grid
            
            // Button - 56px height (industry standard)
            _buildButton(),
            const SizedBox(height: 48), // 8pt grid
          ],
        ),
      ),
    );
  }

  // ============================================================================
  // UI COMPONENTS
  // ============================================================================

  Widget _buildSkipButton() {
    return Padding(
      padding: const EdgeInsets.only(top: 16, right: 16),
      child: Align(
        alignment: Alignment.topRight,
        child: TextButton(
          onPressed: _skipToLogin,
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            minimumSize: const Size(48, 48), // Touch target standard
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Text(
            'Skip',
            style: TextStyle(
              fontSize: 14, // Label Large
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
              fontFamily: 'Montserrat',
              letterSpacing: 0.1,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPage(OnboardingData data) {
    final size = MediaQuery.of(context).size;
    // Industry standard: 30-35% of screen width, clamped 140-180px
    final iconSize = (size.width * 0.32).clamp(140.0, 180.0);
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24), // 8pt grid
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Animated icon
          FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: Container(
                width: iconSize,
                height: iconSize,
                decoration: BoxDecoration(
                  color: data.iconColor,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: data.iconColor.withValues(alpha: 0.25),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Icon(
                  data.icon,
                  size: iconSize * 0.45,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 48), // 8pt grid
          
          // Title - Headline Large (32px)
          FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: Text(
                data.title,
                style: const TextStyle(
                  fontSize: 32, // Headline Large
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.5,
                  fontFamily: 'Montserrat',
                  height: 1.25, // 40px line height
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          
          const SizedBox(height: 16), // 8pt grid
          
          // Description - Body Large (16px)
          FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  data.description,
                  style: TextStyle(
                    fontSize: 16, // Body Large
                    color: AppColors.textSecondary,
                    height: 1.5, // 24px line height
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.w400,
                    letterSpacing: 0.15,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        _pages.length,
        (index) => AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          margin: const EdgeInsets.symmetric(horizontal: 4), // 8pt grid
          width: _currentPage == index ? 32 : 8, // Active: 32px, Inactive: 8px
          height: 8,
          decoration: BoxDecoration(
            color: _currentPage == index
                ? AppColors.secondary // Orange for active
                : AppColors.border, // Light gray for inactive
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ),
    );
  }

  Widget _buildButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24), // 8pt grid
      child: SizedBox(
        width: double.infinity,
        height: 56, // Industry standard button height
        child: ElevatedButton(
          onPressed: _nextPage,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.secondary,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16), // Large radius
            ),
            elevation: 0,
            shadowColor: AppColors.secondary.withValues(alpha: 0.3),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _currentPage < _pages.length - 1 ? 'Next' : 'Get Started',
                style: const TextStyle(
                  fontSize: 16, // Body Large
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Montserrat',
                  letterSpacing: 0.15,
                ),
              ),
              const SizedBox(width: 8), // 8pt grid
              Icon(
                _currentPage < _pages.length - 1 
                    ? Icons.arrow_forward_rounded 
                    : Icons.check_rounded,
                size: 20, // Medium icon
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// DATA MODEL
// ============================================================================

class OnboardingData {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String description;

  OnboardingData({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.description,
  });
}
