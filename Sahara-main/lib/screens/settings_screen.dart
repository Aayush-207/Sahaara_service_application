import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import '../theme/app_colors.dart';
import '../services/sound_service.dart';
import '../services/permission_service.dart';
import '../providers/auth_provider.dart';
import 'login_screen_enhanced.dart';

/// Settings Screen - Enhanced
/// 
/// Comprehensive settings with all app preferences:
/// - Account settings (password, delete account)
/// - Preferences (notifications, sounds, theme)
/// - Permissions (location, camera, photos)
/// - Data & Privacy
/// - Support & Help
/// - App information
/// 
/// Design:
/// - Material Design 3
/// - Montserrat font
/// - 8pt grid spacing
/// - Industry standard switches and toggles
/// - Organized sections with clear hierarchy

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final SoundService _soundService = SoundService();
  final PermissionService _permissionService = PermissionService();
  
  bool _notificationsEnabled = true;
  bool _soundEnabled = true;
  bool _locationEnabled = true;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Check permission statuses
    final hasLocation = await _permissionService.hasLocationPermission();
    
    if (mounted) {
      setState(() {
        _notificationsEnabled = prefs.getBool('notifications_enabled') ?? true;
        _soundEnabled = prefs.getBool('sound_enabled') ?? true;
        _locationEnabled = hasLocation;
        _isLoading = false;
      });
    }
  }

  Future<void> _saveNotificationSetting(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifications_enabled', value);
    
    setState(() {
      _notificationsEnabled = value;
    });
    
    if (value) {
      // Capture permission service before async operation
      final permissionService = _permissionService;
      
      // Request notification permission if enabling
      // ignore: use_build_context_synchronously
      final granted = await permissionService.requestNotificationPermission(context);
      if (!granted && mounted) {
        // Update state after async operation
        setState(() {
          _notificationsEnabled = false;
        });
        await prefs.setBool('notifications_enabled', false);
      }
    }
  }

  Future<void> _saveSoundSetting(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('sound_enabled', value);
    
    if (mounted) {
      setState(() {
        _soundEnabled = value;
      });
      
      if (value) {
        _soundService.playSuccess();
      }
    }
  }

  void _showSignOutDialog() {
    _soundService.playTap();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Sign Out',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            fontFamily: 'Montserrat',
          ),
        ),
        content: const Text(
          'Are you sure you want to sign out?',
          style: TextStyle(
            fontSize: 14,
            fontFamily: 'Montserrat',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
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
              Navigator.pop(context);
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
              backgroundColor: AppColors.error.withValues(alpha: 0.1),
            ),
            child: const Text(
              'Sign Out',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.error,
                fontFamily: 'Montserrat',
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showChangePasswordDialog() {
    _soundService.playTap();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Change Password',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            fontFamily: 'Montserrat',
          ),
        ),
        content: const Text(
          'Password reset link will be sent to your email address.',
          style: TextStyle(
            fontSize: 14,
            fontFamily: 'Montserrat',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
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
              final navigator = Navigator.of(context);
              final messenger = ScaffoldMessenger.of(context);
              final authProvider = Provider.of<AuthProvider>(context, listen: false);
              
              navigator.pop();
              
              try {
                // Send password reset email
                await authProvider.sendPasswordResetEmail();
                
                if (!mounted) return;
                
                messenger.showSnackBar(
                  const SnackBar(
                    content: Text('Password reset email sent! Check your inbox.'),
                    backgroundColor: AppColors.success,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              } catch (e) {
                if (!mounted) return;
                
                messenger.showSnackBar(
                  SnackBar(
                    content: Text('Failed to send reset email: $e'),
                    backgroundColor: AppColors.error,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            style: TextButton.styleFrom(
              backgroundColor: AppColors.primary.withValues(alpha: 0.1),
            ),
            child: const Text(
              'Send Email',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
                fontFamily: 'Montserrat',
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog() {
    _soundService.playTap();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Delete Account',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            fontFamily: 'Montserrat',
            color: AppColors.error,
          ),
        ),
        content: const Text(
          'Are you sure you want to delete your account? This action cannot be undone and all your data will be permanently deleted.',
          style: TextStyle(
            fontSize: 14,
            fontFamily: 'Montserrat',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
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
              final navigator = Navigator.of(context);
              final messenger = ScaffoldMessenger.of(context);
              final authProvider = Provider.of<AuthProvider>(context, listen: false);
              
              navigator.pop();
              
              try {
                // Delete account
                await authProvider.deleteAccount();
                
                if (!mounted) return;
                
                // Navigate to login screen
                navigator.pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (route) => false,
                );
                
                messenger.showSnackBar(
                  const SnackBar(
                    content: Text('Account deleted successfully'),
                    backgroundColor: AppColors.success,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              } catch (e) {
                if (!mounted) return;
                
                messenger.showSnackBar(
                  SnackBar(
                    content: Text('Failed to delete account: $e'),
                    backgroundColor: AppColors.error,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            style: TextButton.styleFrom(
              backgroundColor: AppColors.error.withValues(alpha: 0.1),
            ),
            child: const Text(
              'Delete',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.error,
                fontFamily: 'Montserrat',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _manageLocationPermission() async {
    final granted = await _permissionService.requestLocationPermission(context);
    
    setState(() {
      _locationEnabled = granted;
    });
    
    if (!granted && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Location permission is required to find nearby caregivers'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: const Text(
          'Settings',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            fontFamily: 'Montserrat',
          ),
        ),
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            _soundService.playTap();
            Navigator.pop(context);
          },
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Account Section
                  _buildSectionTitle('Account'),
                  const SizedBox(height: 12),
                  _buildActionCard(
                    icon: Icons.lock_outline,
                    title: 'Change Password',
                    subtitle: 'Update your password',
                    onTap: _showChangePasswordDialog,
                    color: AppColors.primary,
                  ),
                  const SizedBox(height: 32),
                  
                  // Preferences Section
                  _buildSectionTitle('Preferences'),
                  const SizedBox(height: 12),
                  _buildSettingCard(
                    icon: Icons.notifications_outlined,
                    title: 'Push Notifications',
                    subtitle: 'Booking updates and reminders',
                    value: _notificationsEnabled,
                    onChanged: _saveNotificationSetting,
                    color: AppColors.primary,
                  ),
                  const SizedBox(height: 12),
                  _buildSettingCard(
                    icon: Icons.volume_up_outlined,
                    title: 'Sound',
                    subtitle: 'App sounds and effects',
                    value: _soundEnabled,
                    onChanged: _saveSoundSetting,
                    color: AppColors.secondary,
                  ),
                  const SizedBox(height: 32),
                  
                  // Privacy & Security Section
                  _buildSectionTitle('Privacy & Security'),
                  const SizedBox(height: 12),
                  _buildPermissionCard(
                    icon: Icons.location_on_outlined,
                    title: 'Location',
                    subtitle: _locationEnabled 
                        ? 'Enabled'
                        : 'Disabled',
                    isEnabled: _locationEnabled,
                    onTap: _manageLocationPermission,
                    color: AppColors.accent,
                  ),
                  const SizedBox(height: 32),
                  
                  // About Section
                  _buildSectionTitle('About'),
                  const SizedBox(height: 12),
                  _buildInfoCard(
                    icon: Icons.info_outline,
                    title: 'Version',
                    subtitle: '1.0.0',
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(height: 32),
                  
                  // Danger Zone
                  _buildSectionTitle('Danger Zone'),
                  const SizedBox(height: 12),
                  _buildActionCard(
                    icon: Icons.logout,
                    title: 'Sign Out',
                    subtitle: 'Sign out of your account',
                    onTap: _showSignOutDialog,
                    color: AppColors.error,
                  ),
                  const SizedBox(height: 12),
                  _buildActionCard(
                    icon: Icons.delete_forever_outlined,
                    title: 'Delete Account',
                    subtitle: 'Permanently delete your account',
                    onTap: _showDeleteAccountDialog,
                    color: AppColors.error,
                  ),
                  const SizedBox(height: 100), // Bottom padding
                ],
              ),
            ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: AppColors.textSecondary,
          fontFamily: 'Montserrat',
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildSettingCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required Function(bool) onChanged,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border, width: 1),
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
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                    fontFamily: 'Montserrat',
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                    fontFamily: 'Montserrat',
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: (newValue) {
              _soundService.playTap();
              onChanged(newValue);
            },
            activeTrackColor: color.withValues(alpha: 0.5),
            activeThumbColor: color,
          ),
        ],
      ),
    );
  }

  Widget _buildPermissionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isEnabled,
    required VoidCallback onTap,
    required Color color,
  }) {
    return InkWell(
      onTap: () {
        _soundService.playTap();
        onTap();
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border, width: 1),
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
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                      fontFamily: 'Montserrat',
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                      fontFamily: 'Montserrat',
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
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

  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required Color color,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border, width: 1),
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
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                      fontFamily: 'Montserrat',
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                      fontFamily: 'Montserrat',
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
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

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border, width: 1),
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
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                    fontFamily: 'Montserrat',
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                    fontFamily: 'Montserrat',
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
