import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'onboarding_screen_enhanced.dart';
import 'permissions_screen.dart';
import 'home_screen.dart';
import '../theme/app_colors.dart';

/// Splash Screen - Industry Standard Implementation
/// 
/// Design Standards Applied:
/// - Logo: 120-160px (20-25% screen width) - Material Design
/// - App Name: 32px Headline Large - Typography Scale
/// - Tagline: 14px Body Medium - Typography Scale
/// - Progress: 4px height, 200px width - Component Standards
/// - Version: 11px Label Small - Typography Scale
/// - Spacing: 8pt grid system (8, 16, 24, 32px)
/// - Animation: 2.8s total duration - UX Best Practice
/// - Transitions: 300-500ms - Industry Standard
/// 
/// Accessibility:
/// - WCAG AA contrast ratios
/// - Semantic structure
/// - Smooth animations
/// - Clear visual hierarchy

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  // ============================================================================
  // ANIMATION CONTROLLERS
  // ============================================================================
  
  late AnimationController _logoController;
  late AnimationController _textController;
  late AnimationController _progressController;
  
  late Animation<double> _logoScaleAnimation;
  late Animation<double> _logoFadeAnimation;
  late Animation<double> _textFadeAnimation;
  late Animation<Offset> _textSlideAnimation;
  late Animation<double> _progressAnimation;

  // ============================================================================
  // LIFECYCLE
  // ============================================================================

  @override
  void initState() {
    super.initState();
    _setupStatusBar();
    _initAnimations();
    _startAnimationSequence();
    _scheduleNavigation();
  }

  @override
  void dispose() {
    _logoController.dispose();
    _textController.dispose();
    _progressController.dispose();
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
    // Logo animation (1000ms) - Industry standard
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    // Text animation (700ms)
    _textController = AnimationController(
      duration: const Duration(milliseconds: 700),
      vsync: this,
    );
    
    // Progress animation (1800ms)
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 1800),
      vsync: this,
    );
    
    _logoScaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.easeOutCubic),
    );
    
    _logoFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
      ),
    );
    
    _textFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _textController, curve: Curves.easeIn),
    );
    
    _textSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _textController, curve: Curves.easeOutCubic),
    );
    
    _progressAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _progressController, curve: Curves.easeInOut),
    );
  }

  void _startAnimationSequence() {
    _logoController.forward();
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) _textController.forward();
    });
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) _progressController.forward();
    });
  }

  void _scheduleNavigation() {
    Timer(const Duration(milliseconds: 2800), () async {
      if (!mounted) return;
      
      // Check Firebase auth state first
      final firebaseUser = FirebaseAuth.instance.currentUser;
      
      if (firebaseUser != null) {
        // User is logged in, go directly to home
        debugPrint('🔐 User already logged in: ${firebaseUser.email}');
        
        // Navigate to home screen
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => 
                const HomeScreen(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
            transitionDuration: const Duration(milliseconds: 500),
          ),
        );
        return;
      }
      
      // No user logged in, proceed with normal flow
      debugPrint('🔓 No user logged in, showing onboarding');
      
      // Check if this is first launch
      final prefs = await SharedPreferences.getInstance();
      final isFirstLaunch = prefs.getBool('isFirstLaunch') ?? true;
      
      if (isFirstLaunch) {
        // Show permissions screen on first launch
        if (!mounted) return;
        await Navigator.push<bool>(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => 
                const PermissionsScreen(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
            transitionDuration: const Duration(milliseconds: 500),
          ),
        );
        
        // Mark as not first launch
        await prefs.setBool('isFirstLaunch', false);
      }
      
      // Navigate to onboarding
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => 
              const OnboardingScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: const Duration(milliseconds: 500),
        ),
      );
    });
  }

  // ============================================================================
  // BUILD
  // ============================================================================

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Stack(
          children: [
            // Center content - Logo and App Name
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildAnimatedLogo(size),
                  const SizedBox(height: 8), // Reduced space between logo and name
                  _buildAnimatedText(),
                ],
              ),
            ),
            
            // Bottom section - Progress and Version
            Positioned(
              left: 0,
              right: 0,
              bottom: 32,
              child: _buildBottomSection(),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================================
  // UI COMPONENTS
  // ============================================================================

  Widget _buildAnimatedLogo(Size size) {
    // Industry standard: 20-25% of screen width, clamped 120-160px
    final logoSize = (size.width * 0.22).clamp(120.0, 160.0);
    
    return AnimatedBuilder(
      animation: _logoController,
      builder: (context, child) {
        return Opacity(
          opacity: _logoFadeAnimation.value,
          child: Transform.scale(
            scale: _logoScaleAnimation.value,
            child: Container(
              width: logoSize,
              height: logoSize,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24), // Large radius
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.15),
                    blurRadius: 32,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Image.asset(
                  'assets/images/logo.png',
                  fit: BoxFit.contain,
                  alignment: Alignment.center,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Icon(
                        Icons.pets_rounded,
                        size: logoSize * 0.5,
                        color: Colors.white,
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAnimatedText() {
    return AnimatedBuilder(
      animation: _textController,
      builder: (context, child) {
        return SlideTransition(
          position: _textSlideAnimation,
          child: Opacity(
            opacity: _textFadeAnimation.value,
            child: Column(
              children: [
                // App name - Headline Large (32px) - Material Design 3
                const Text(
                  'Sahara',
                  style: TextStyle(
                    fontSize: 32, // Headline Large
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                    letterSpacing: -0.5,
                    fontFamily: 'Montserrat',
                    height: 1.0, // Reduced line height for tighter spacing
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4), // Minimal space
                
                // Tagline - Body Medium (14px) - Material Design 3
                Text(
                  'Your Pet\'s Support & Care',
                  style: TextStyle(
                    fontSize: 14, // Body Medium
                    color: AppColors.textSecondary,
                    letterSpacing: 0.25,
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.w400,
                    height: 1.43, // 20px line height
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBottomSection() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Progress bar - 4px height (industry standard)
        AnimatedBuilder(
          animation: _progressController,
          builder: (context, child) {
            return Center(
              child: SizedBox(
                width: 200, // Fixed width for consistency
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(2),
                  child: LinearProgressIndicator(
                    value: _progressAnimation.value,
                    minHeight: 4, // Industry standard
                    backgroundColor: AppColors.border,
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      AppColors.secondary,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 16), // Reduced spacing
        
        // Version - Label Small (11px) - Material Design 3
        Center(
          child: Text(
            'Version 1.0.0',
            style: TextStyle(
              fontSize: 11, // Label Small
              color: AppColors.textTertiary,
              fontFamily: 'Montserrat',
              fontWeight: FontWeight.w400,
              letterSpacing: 0.5,
              height: 1.45, // 16px line height
            ),
          ),
        ),
      ],
    );
  }
}
