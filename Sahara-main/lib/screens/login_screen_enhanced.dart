import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';
import '../theme/app_colors.dart';
import '../services/sound_service.dart';
import '../utils/validators.dart';
import 'signup_screen_enhanced.dart';
import 'home_screen.dart';
import 'forgot_password_screen_enhanced.dart';

/// Login Screen - Industry Standard Implementation
/// 
/// Design Standards Applied:
/// - Logo: 80-100px - Authentication Standard
/// - Title: 32px Headline Large - Typography Scale
/// - Subtitle: 14px Body Medium - Typography Scale
/// - Input fields: 56px height - Touch Target Standard
/// - Buttons: 56px height - Touch Target Standard
/// - Form spacing: 20px between fields - 8pt grid
/// - Horizontal padding: 24px - 8pt grid
/// 
/// Accessibility:
/// - WCAG AA contrast ratios
/// - Touch targets ≥48px
/// - Form validation
/// - Error feedback

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  // ============================================================================
  // STATE
  // ============================================================================
  
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _soundService = SoundService();
  
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  // ============================================================================
  // LIFECYCLE
  // ============================================================================

  @override
  void initState() {
    super.initState();
    _setupStatusBar();
    _initAnimations();
    _startAnimation();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _animationController.dispose();
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
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
      ),
    );
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.2, 1.0, curve: Curves.easeOutCubic),
      ),
    );
  }

  void _startAnimation() {
    _animationController.forward();
  }

  // ============================================================================
  // HANDLERS
  // ============================================================================

  Future<void> _handleLogin() async {
    _soundService.playClick();
    FocusScope.of(context).unfocus();
    
    if (_formKey.currentState!.validate()) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      
      try {
        final success = await authProvider.signIn(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );

        if (!mounted) return;

        // Capture navigator before async operations
        final navigator = Navigator.of(context);

        if (success) {
          await _soundService.playSuccess();
          if (!mounted) return;
          
          navigator.pushReplacement(
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) => 
                  const HomeScreen(),
              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                return FadeTransition(opacity: animation, child: child);
              },
              transitionDuration: const Duration(milliseconds: 400),
            ),
          );
        } else {
          _soundService.playError();
          if (!mounted) return;
          _showErrorSnackBar(authProvider.errorMessage ?? 'Login failed. Please try again.');
        }
      } catch (e) {
        if (mounted) {
          _soundService.playError();
          _showErrorSnackBar('An unexpected error occurred. Please check your connection.');
        }
      }
    } else {
      _soundService.playError();
    }
  }

  Future<void> _handleGoogleSignIn() async {
    _soundService.playClick();
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final navigator = Navigator.of(context);
    
    try {
      final success = await authProvider.signInWithGoogle();
      if (!mounted) return;

      if (success) {
        await _soundService.playSuccess();
        if (!mounted) return;
        
        navigator.pushReplacement(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => 
                const HomeScreen(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
            transitionDuration: const Duration(milliseconds: 400),
          ),
        );
      } else {
        if (authProvider.errorMessage != null && authProvider.errorMessage!.isNotEmpty) {
          _soundService.playError();
          if (!context.mounted) return;
          _showErrorSnackBar(authProvider.errorMessage!);
        }
      }
    } catch (e) {
      if (mounted) {
        _soundService.playError();
        _showErrorSnackBar('Google Sign-In failed. Please try again.');
      }
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(message, style: const TextStyle(fontFamily: 'Montserrat')),
            ),
          ],
        ),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: 'Dismiss',
          textColor: Colors.white,
          onPressed: () => ScaffoldMessenger.of(context).hideCurrentSnackBar(),
        ),
      ),
    );
  }

  // ============================================================================
  // BUILD
  // ============================================================================

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 24),
                    
                    // Logo
                    _buildLogo(),
                    const SizedBox(height: 32),
                    
                    // Title - Headline Large (32px)
                    const Text(
                      'Welcome Back!',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                        letterSpacing: -0.5,
                        fontFamily: 'Montserrat',
                        height: 1.25,
                      ),
                    ),
                    const SizedBox(height: 8),
                    
                    // Subtitle - Body Medium (14px)
                    Text(
                      'Sign in to continue to Sahara',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.w400,
                        height: 1.43,
                      ),
                    ),
                    const SizedBox(height: 40),
                    
                    // Email field - 56px height
                    CustomTextField(
                      controller: _emailController,
                      labelText: 'Email',
                      hintText: 'Enter your email',
                      prefixIcon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                      validator: Validators.validateEmail,
                    ),
                    const SizedBox(height: 20),
                    
                    // Password field - 56px height
                    CustomTextField(
                      controller: _passwordController,
                      labelText: 'Password',
                      hintText: 'Enter your password',
                      prefixIcon: Icons.lock_outline_rounded,
                      obscureText: true,
                      validator: Validators.validateLoginPassword,
                    ),
                    const SizedBox(height: 12),
                    
                    // Forgot password
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {
                          _soundService.playTap();
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const ForgotPasswordScreen(),
                            ),
                          );
                        },
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                          minimumSize: const Size(48, 48),
                        ),
                        child: Text(
                          'Forgot Password?',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            fontFamily: 'Montserrat',
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // Sign in button - 56px height
                    CustomButton(
                      text: 'Sign In',
                      onPressed: _handleLogin,
                      isLoading: authProvider.isLoading,
                      icon: Icons.arrow_forward_rounded,
                    ),
                    const SizedBox(height: 24),
                    
                    // OR divider
                    Row(
                      children: [
                        Expanded(child: Divider(color: AppColors.border, thickness: 1)),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            'OR',
                            style: TextStyle(
                              color: AppColors.textTertiary,
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                              fontFamily: 'Montserrat',
                            ),
                          ),
                        ),
                        Expanded(child: Divider(color: AppColors.border, thickness: 1)),
                      ],
                    ),
                    const SizedBox(height: 24),
                    
                    // Google sign in
                    _buildSocialButton(
                      icon: Icons.g_mobiledata_rounded,
                      label: 'Continue with Google',
                      onTap: _handleGoogleSignIn,
                    ),
                    const SizedBox(height: 32),
                    
                    // Sign up link
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Don't have an account? ",
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 14,
                            fontFamily: 'Montserrat',
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            _soundService.playTap();
                            Navigator.push(
                              context,
                              PageRouteBuilder(
                                pageBuilder: (context, animation, secondaryAnimation) => 
                                    const SignupScreen(),
                                transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                  return FadeTransition(opacity: animation, child: child);
                                },
                                transitionDuration: const Duration(milliseconds: 300),
                              ),
                            );
                          },
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: Text(
                            'Sign Up',
                            style: TextStyle(
                              color: AppColors.primary,
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              fontFamily: 'Montserrat',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================================
  // UI COMPONENTS
  // ============================================================================

  Widget _buildLogo() {
    const logoSize = 90.0; // Industry standard for auth screens
    
    return Center(
      child: Container(
        width: logoSize,
        height: logoSize,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.15),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Image.asset(
            'assets/images/logo.png',
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(
                  Icons.pets_rounded,
                  size: 45,
                  color: Colors.white,
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildSocialButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        height: 56, // Industry standard
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border, width: 1.5),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 24, color: AppColors.textPrimary),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
                fontFamily: 'Montserrat',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
