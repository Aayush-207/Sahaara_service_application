import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';
import '../theme/app_colors.dart';
import '../services/sound_service.dart';
import '../utils/validators.dart';
import 'home_screen.dart';
import 'login_screen_enhanced.dart';

/// Signup Screen - Industry Standard Implementation
/// 
/// Design Standards Applied:
/// - Logo: 80-100px - Authentication Standard
/// - Title: 32px Headline Large - Typography Scale
/// - Subtitle: 14px Body Medium - Typography Scale
/// - Input fields: 56px height - Touch Target Standard
/// - Buttons: 56px height - Touch Target Standard
/// - Form spacing: 20px between fields - 8pt grid
/// - Horizontal padding: 24px - 8pt grid

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _soundService = SoundService();
  
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _setupStatusBar();
    _initAnimations();
    _startAnimation();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _animationController.dispose();
    super.dispose();
  }

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

  Future<void> _handleSignup() async {
    _soundService.playClick();
    FocusScope.of(context).unfocus();
    
    if (_formKey.currentState!.validate()) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      
      try {
        final success = await authProvider.signUp(
          email: _emailController.text.trim(),
          password: _passwordController.text,
          name: _nameController.text.trim(),
          userType: 'owner',
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
          if (!context.mounted) return;
          _showErrorSnackBar(authProvider.errorMessage ?? 'Signup failed. Please try again.');
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

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.textPrimary),
          onPressed: () {
            _soundService.playTap();
            Navigator.pop(context);
          },
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 8),
                    
                    // Logo
                    _buildLogo(),
                    const SizedBox(height: 32),
                    
                    // Title - Headline Large (32px)
                    const Text(
                      'Create Account',
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
                      'Join Sahara and find the best care for your pet',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.w400,
                        height: 1.43,
                      ),
                    ),
                    const SizedBox(height: 32),
                    
                    // Name field
                    CustomTextField(
                      controller: _nameController,
                      labelText: 'Full Name',
                      hintText: 'Enter your full name',
                      prefixIcon: Icons.person_outline_rounded,
                      validator: Validators.validateName,
                    ),
                    const SizedBox(height: 20),
                    
                    // Email field
                    CustomTextField(
                      controller: _emailController,
                      labelText: 'Email',
                      hintText: 'Enter your email',
                      prefixIcon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                      validator: Validators.validateEmail,
                    ),
                    const SizedBox(height: 20),
                    
                    // Password field
                    CustomTextField(
                      controller: _passwordController,
                      labelText: 'Password',
                      hintText: 'Create a password',
                      prefixIcon: Icons.lock_outline_rounded,
                      obscureText: true,
                      validator: Validators.validateSignupPassword,
                    ),
                    const SizedBox(height: 20),
                    
                    // Confirm password field
                    CustomTextField(
                      controller: _confirmPasswordController,
                      labelText: 'Confirm Password',
                      hintText: 'Re-enter your password',
                      prefixIcon: Icons.lock_outline_rounded,
                      obscureText: true,
                      validator: (value) => Validators.validatePasswordConfirmation(
                        value,
                        _passwordController.text,
                      ),
                    ),
                    const SizedBox(height: 32),
                    
                    // Create account button
                    CustomButton(
                      text: 'Create Account',
                      onPressed: _handleSignup,
                      isLoading: authProvider.isLoading,
                      icon: Icons.arrow_forward_rounded,
                    ),
                    const SizedBox(height: 16),
                    
                    // Terms text - Body Small (12px)
                    Text(
                      'By creating an account, you agree to our Terms of Service and Privacy Policy',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textTertiary,
                        fontFamily: 'Montserrat',
                        height: 1.33,
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // Login link
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Already have an account? ',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 14,
                            fontFamily: 'Montserrat',
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            _soundService.playTap();
                            Navigator.pushReplacement(
                              context,
                              PageRouteBuilder(
                                pageBuilder: (context, animation, secondaryAnimation) => 
                                    const LoginScreen(),
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
                            'Sign In',
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

  Widget _buildLogo() {
    const logoSize = 90.0;
    
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
}
