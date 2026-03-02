import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';
import '../theme/app_colors.dart';
import '../services/sound_service.dart';
import '../utils/validators.dart';

/// Forgot Password Screen - Industry Standard Implementation
/// 
/// Design Standards Applied:
/// - Logo: 80-100px - Authentication Standard
/// - Title: 32px Headline Large - Typography Scale
/// - Subtitle: 14px Body Medium - Typography Scale
/// - Input field: 56px height - Touch Target Standard
/// - Button: 56px height - Touch Target Standard
/// - Horizontal padding: 24px - 8pt grid

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
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
    _emailController.dispose();
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

  Future<void> _handleResetPassword() async {
    _soundService.playClick();
    FocusScope.of(context).unfocus();
    
    if (_formKey.currentState!.validate()) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      
      try {
        final success = await authProvider.resetPassword(
          _emailController.text.trim(),
        );

        if (!mounted) return;

        if (success) {
          await _soundService.playSuccess();
          _showSuccessSnackBar('Password reset email sent! Check your inbox.');
          
          Future.delayed(const Duration(milliseconds: 1500), () {
            if (mounted) Navigator.pop(context);
          });
        } else {
          _soundService.playError();
          _showErrorSnackBar(authProvider.errorMessage ?? 'Failed to send reset email. Please try again.');
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

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_outline, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(message, style: const TextStyle(fontFamily: 'Montserrat')),
            ),
          ],
        ),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 4),
      ),
    );
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
                      'Forgot Password?',
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
                      'Enter your email address and we\'ll send you a link to reset your password.',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.w400,
                        height: 1.57,
                      ),
                    ),
                    const SizedBox(height: 40),
                    
                    // Email field
                    CustomTextField(
                      controller: _emailController,
                      labelText: 'Email',
                      hintText: 'Enter your email',
                      prefixIcon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                      validator: Validators.validateEmail,
                    ),
                    const SizedBox(height: 32),
                    
                    // Send reset link button
                    CustomButton(
                      text: 'Send Reset Link',
                      onPressed: _handleResetPassword,
                      isLoading: authProvider.isLoading,
                      icon: Icons.email_outlined,
                    ),
                    const SizedBox(height: 24),
                    
                    // Back to login link
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Remember your password? ',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 14,
                            fontFamily: 'Montserrat',
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            _soundService.playTap();
                            Navigator.pop(context);
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
