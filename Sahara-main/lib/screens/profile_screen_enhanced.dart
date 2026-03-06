import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../providers/auth_provider.dart';
import '../models/user_model.dart';
import '../services/sound_service.dart';
import 'login_screen_enhanced.dart';
import 'edit_profile_screen.dart';
import 'settings_screen.dart';
import 'help_support_screen.dart';
import 'privacy_policy_screen.dart';
import 'admin_seed_screen.dart';
import 'favourites_screen.dart';
import '../theme/app_colors.dart';

/// Profile Screen - Industry Standard Implementation
/// 
/// Design Standards Applied:
/// - Avatar: 80px - Profile Standard
/// - Name: 20px Title Large - Typography Scale
/// - Email: 14px Body Medium - Typography Scale
/// - Badge: 12px Label Small - Typography Scale
/// - Menu items: 56px height - Touch Target Standard
/// - Menu title: 16px Title Medium - Typography Scale
/// - Menu subtitle: 12px Body Small - Typography Scale
/// - Icons: 24px - Component Standard
/// - Spacing: 8pt grid (8, 12, 16, 24px)
/// 
/// Accessibility:
/// - WCAG AA contrast ratios
/// - Touch targets ≥48px
/// - Clear visual hierarchy

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    // Refresh user data when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      authProvider.refreshUser();
    });
  }

  @override
  Widget build(BuildContext context) {
    // Listen to changes in AuthProvider to update UI when user data changes
    final authProvider = Provider.of<AuthProvider>(context, listen: true);
    final user = authProvider.currentUser;
    
    debugPrint('🔄 Profile Screen Build - User photoUrl: ${user?.photoUrl}');

    if (user == null) {
      return Scaffold(
        backgroundColor: AppColors.surface,
        body: const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            final authProvider = Provider.of<AuthProvider>(context, listen: false);
            await authProvider.refreshUser();
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              children: [
                _buildHeader(user),
                _buildMenuSection(context),
                const SizedBox(height: 100), // Bottom nav clearance
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================================
  // HEADER
  // ============================================================================

  Widget _buildHeader(UserModel user) {
    // Debug: Print photoUrl to see if it exists
    debugPrint('📸 Profile Screen - User photoUrl: ${user.photoUrl}');
    debugPrint('📸 Profile Screen - photoUrl isEmpty: ${user.photoUrl?.isEmpty ?? true}');
    debugPrint('📸 Profile Screen - photoUrl isNotEmpty: ${user.photoUrl?.isNotEmpty ?? false}');
    
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 32), // 8pt grid
      child: Column(
        children: [
          // Avatar - 100px (balanced size for profile)
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(25),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.2),
                width: 2.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.15),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(22.5),
              child: user.photoUrl != null && user.photoUrl!.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: user.photoUrl!,
                      key: ValueKey(user.photoUrl), // Force rebuild when URL changes
                      fit: BoxFit.cover,
                      width: 100,
                      height: 100,
                      placeholder: (context, url) {
                        debugPrint('⏳ Loading image from: $url');
                        return Container(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          child: const Center(
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                AppColors.primary,
                              ),
                            ),
                          ),
                        );
                      },
                      errorWidget: (context, url, error) {
                        debugPrint('❌ Error loading image from: $url');
                        debugPrint('❌ Error details: $error');
                        return Container(
                          color: AppColors.primary,
                          child: const Icon(
                            Icons.person_rounded,
                            size: 50,
                            color: Colors.white,
                          ),
                        );
                      },
                    )
                  : Container(
                      color: AppColors.primary,
                      child: const Icon(
                        Icons.person_rounded,
                        size: 50,
                        color: Colors.white,
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 16), // 8pt grid
          
          // Name - Title Large (20px)
          Text(
            user.name,
            style: const TextStyle(
              fontSize: 20, // Title Large
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
              fontFamily: 'Montserrat',
              letterSpacing: -0.3,
              height: 1.4, // 28px line height
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4), // 8pt grid
          
          // Email - Body Medium (14px)
          Text(
            user.email,
            style: TextStyle(
              fontSize: 14, // Body Medium
              color: AppColors.textSecondary,
              fontFamily: 'Montserrat',
              fontWeight: FontWeight.w400,
              height: 1.43, // 20px line height
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12), // 8pt grid
          
          // User Type Badge - Label Small (12px)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.primaryContainer,
              borderRadius: BorderRadius.circular(20), // Pill shape
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.1),
                width: 1,
              ),
            ),
            child: Text(
              user.userType == 'caregiver' ? 'Caregiver' : 'Pet Owner',
              style: TextStyle(
                fontSize: 12, // Label Small
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
                fontFamily: 'Montserrat',
                letterSpacing: 0.5,
                height: 1.33, // 16px line height
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================================
  // MENU SECTION
  // ============================================================================

  Widget _buildMenuSection(BuildContext context) {
    final soundService = SoundService();
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16), // 8pt grid
      child: Column(
        children: [
          _buildMenuItem(
            context: context,
            soundService: soundService,
            icon: Icons.person_outline_rounded,
            title: 'Edit Profile',
            subtitle: 'Update your information',
            onTap: () async {
              // Capture auth provider before navigation
              final authProvider = Provider.of<AuthProvider>(context, listen: false);
              
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const EditProfileScreen()),
              );
              // Refresh user data when returning from edit profile
              if (mounted) {
                await authProvider.refreshUser();
              }
            },
          ),
          const SizedBox(height: 8), // 8pt grid
          
          _buildMenuItem(
            context: context,
            soundService: soundService,
            icon: Icons.favorite_rounded,
            title: 'Favourite Caregivers',
            subtitle: 'View your favourite caregivers',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const FavouritesScreen()),
              );
            },
          ),
          const SizedBox(height: 8),
          
          _buildMenuItem(
            context: context,
            soundService: soundService,
            icon: Icons.settings_outlined,
            title: 'Settings',
            subtitle: 'App preferences and permissions',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              );
            },
          ),
          const SizedBox(height: 8),
          
          _buildMenuItem(
            context: context,
            soundService: soundService,
            icon: Icons.help_outline_rounded,
            title: 'Help & Support',
            subtitle: 'Get help and support',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const HelpSupportScreen()),
              );
            },
          ),
          const SizedBox(height: 8),
          
          _buildMenuItem(
            context: context,
            soundService: soundService,
            icon: Icons.privacy_tip_outlined,
            title: 'Privacy Policy',
            subtitle: 'Read our privacy policy',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const PrivacyPolicyScreen()),
              );
            },
          ),
          const SizedBox(height: 8),
          
          _buildMenuItem(
            context: context,
            soundService: soundService,
            icon: Icons.settings_suggest_rounded,
            title: 'Seed Database',
            subtitle: 'Add sample caregivers & packages',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AdminSeedScreen()),
              );
            },
          ),
          const SizedBox(height: 8),
          
          _buildMenuItem(
            context: context,
            soundService: soundService,
            icon: Icons.logout_rounded,
            title: 'Logout',
            subtitle: 'Sign out of your account',
            isDestructive: true,
            onTap: () => _showLogoutDialog(context),
          ),
        ],
      ),
    );
  }

  // ============================================================================
  // MENU ITEM
  // ============================================================================

  Widget _buildMenuItem({
    required BuildContext context,
    required SoundService soundService,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return InkWell(
      onTap: () {
        soundService.playTap();
        onTap();
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        height: 72, // Industry standard list item height
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDestructive 
                ? AppColors.error.withValues(alpha: 0.2)
                : AppColors.border,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Icon container - 48x48px
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isDestructive
                    ? AppColors.error.withValues(alpha: 0.1)
                    : AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: isDestructive ? AppColors.error : AppColors.primary,
                size: 24, // Standard icon size
              ),
            ),
            const SizedBox(width: 16), // 8pt grid
            
            // Text content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Title - Title Medium (16px)
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16, // Title Medium
                      fontWeight: FontWeight.w600,
                      color: isDestructive 
                          ? AppColors.error 
                          : AppColors.textPrimary,
                      fontFamily: 'Montserrat',
                      height: 1.5, // 24px line height
                    ),
                  ),
                  const SizedBox(height: 2),
                  
                  // Subtitle - Body Small (12px)
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12, // Body Small
                      color: AppColors.textSecondary,
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.w400,
                      height: 1.33, // 16px line height
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            
            // Arrow icon - 20px
            Icon(
              Icons.chevron_right_rounded,
              color: AppColors.textTertiary,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================================
  // LOGOUT DIALOG
  // ============================================================================

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            'Logout',
            style: TextStyle(
              fontSize: 20, // Title Large
              fontWeight: FontWeight.w700,
              fontFamily: 'Montserrat',
            ),
          ),
          content: const Text(
            'Are you sure you want to logout?',
            style: TextStyle(
              fontSize: 14, // Body Medium
              fontFamily: 'Montserrat',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                minimumSize: const Size(48, 48),
              ),
              child: Text(
                'Cancel',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                  fontFamily: 'Montserrat',
                ),
              ),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(dialogContext);
                final authProvider = Provider.of<AuthProvider>(context, listen: false);
                await authProvider.signOut();
                if (context.mounted) {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                    (route) => false,
                  );
                }
              },
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                minimumSize: const Size(48, 48),
                backgroundColor: AppColors.error.withValues(alpha: 0.1),
              ),
              child: const Text(
                'Logout',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.error,
                  fontFamily: 'Montserrat',
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
