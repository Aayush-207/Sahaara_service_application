import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_colors.dart';
import '../services/sound_service.dart';

/// Notification Settings Screen
/// Allows users to configure notification preferences
class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() => _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState extends State<NotificationSettingsScreen> {
  final SoundService _soundService = SoundService();
  
  // Notification preferences
  bool _bookingNotifications = true;
  bool _messageNotifications = true;
  bool _promotionalNotifications = false;
  bool _reminderNotifications = true;
  bool _statusUpdateNotifications = true;
  bool _soundEnabled = true;
  bool _vibrationEnabled = true;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  /// Load notification preferences from SharedPreferences
  Future<void> _loadPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        _bookingNotifications = prefs.getBool('notif_bookings') ?? true;
        _messageNotifications = prefs.getBool('notif_messages') ?? true;
        _promotionalNotifications = prefs.getBool('notif_promotional') ?? false;
        _reminderNotifications = prefs.getBool('notif_reminders') ?? true;
        _statusUpdateNotifications = prefs.getBool('notif_status_updates') ?? true;
        _soundEnabled = prefs.getBool('notif_sound') ?? true;
        _vibrationEnabled = prefs.getBool('notif_vibration') ?? true;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading notification preferences: $e');
      setState(() => _isLoading = false);
    }
  }

  /// Save notification preference
  Future<void> _savePreference(String key, bool value) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(key, value);
    } catch (e) {
      debugPrint('Error saving preference: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Notification Settings',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
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
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionHeader('Notification Types'),
                  const SizedBox(height: 12),
                  _buildNotificationTile(
                    'Booking Updates',
                    'Get notified about booking confirmations and changes',
                    Icons.calendar_today_rounded,
                    _bookingNotifications,
                    (value) {
                      setState(() => _bookingNotifications = value);
                      _savePreference('notif_bookings', value);
                    },
                  ),
                  _buildNotificationTile(
                    'Messages',
                    'Receive notifications for new messages',
                    Icons.message_rounded,
                    _messageNotifications,
                    (value) {
                      setState(() => _messageNotifications = value);
                      _savePreference('notif_messages', value);
                    },
                  ),
                  _buildNotificationTile(
                    'Status Updates',
                    'Get updates when service status changes',
                    Icons.update_rounded,
                    _statusUpdateNotifications,
                    (value) {
                      setState(() => _statusUpdateNotifications = value);
                      _savePreference('notif_status_updates', value);
                    },
                  ),
                  _buildNotificationTile(
                    'Reminders',
                    'Receive reminders for upcoming bookings',
                    Icons.alarm_rounded,
                    _reminderNotifications,
                    (value) {
                      setState(() => _reminderNotifications = value);
                      _savePreference('notif_reminders', value);
                    },
                  ),
                  _buildNotificationTile(
                    'Promotions & Offers',
                    'Get notified about special offers and discounts',
                    Icons.local_offer_rounded,
                    _promotionalNotifications,
                    (value) {
                      setState(() => _promotionalNotifications = value);
                      _savePreference('notif_promotional', value);
                    },
                  ),
                  const SizedBox(height: 24),
                  _buildSectionHeader('Notification Behavior'),
                  const SizedBox(height: 12),
                  _buildNotificationTile(
                    'Sound',
                    'Play sound for notifications',
                    Icons.volume_up_rounded,
                    _soundEnabled,
                    (value) {
                      setState(() => _soundEnabled = value);
                      _savePreference('notif_sound', value);
                    },
                  ),
                  _buildNotificationTile(
                    'Vibration',
                    'Vibrate for notifications',
                    Icons.vibration_rounded,
                    _vibrationEnabled,
                    (value) {
                      setState(() => _vibrationEnabled = value);
                      _savePreference('notif_vibration', value);
                    },
                  ),
                  const SizedBox(height: 24),
                  _buildInfoCard(),
                ],
              ),
            ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
        fontFamily: 'Montserrat',
      ),
    );
  }

  Widget _buildNotificationTile(
    String title,
    String subtitle,
    IconData icon,
    bool value,
    Function(bool) onChanged,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: SwitchListTile(
        value: value,
        onChanged: (newValue) {
          _soundService.playTap();
          onChanged(newValue);
        },
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, size: 20, color: AppColors.primary),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                  fontFamily: 'Montserrat',
                ),
              ),
            ),
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(left: 44, top: 4),
          child: Text(
            subtitle,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
              fontFamily: 'Montserrat',
            ),
          ),
        ),
        activeThumbColor: AppColors.primary,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.info.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.info.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline_rounded, color: AppColors.info, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'You can change these settings anytime. Some notifications may be required for important updates.',
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
                fontFamily: 'Montserrat',
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
