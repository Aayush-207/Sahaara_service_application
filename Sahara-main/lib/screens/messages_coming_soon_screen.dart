import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Messages Coming Soon Screen
/// 
/// Placeholder screen for the messaging feature that's under development.
/// Shows a friendly "Coming Soon" message with an illustration.
class MessagesComingSoonScreen extends StatelessWidget {
  const MessagesComingSoonScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Messages',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
            fontFamily: 'Montserrat',
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            height: 1,
            color: AppColors.border,
          ),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icon illustration
              Container(
                padding: const EdgeInsets.all(40),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.chat_bubble_outline_rounded,
                  size: 80,
                  color: AppColors.primary.withValues(alpha: 0.4),
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Coming Soon title
              const Text(
                'Coming Soon',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                  fontFamily: 'Montserrat',
                  letterSpacing: -0.5,
                ),
              ),
              
              const SizedBox(height: 12),
              
              // Description
              Text(
                'We\'re working on bringing you a seamless messaging experience to connect with caregivers.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                  fontFamily: 'Montserrat',
                  height: 1.5,
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Feature highlights
              _buildFeatureItem(
                icon: Icons.chat_rounded,
                title: 'Real-time Chat',
                description: 'Instant messaging with caregivers',
              ),
              
              const SizedBox(height: 16),
              
              _buildFeatureItem(
                icon: Icons.image_rounded,
                title: 'Share Photos',
                description: 'Send pictures of your pets',
              ),
              
              const SizedBox(height: 16),
              
              _buildFeatureItem(
                icon: Icons.notifications_active_rounded,
                title: 'Push Notifications',
                description: 'Never miss a message',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureItem({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              size: 24,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                    fontFamily: 'Montserrat',
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[600],
                    fontFamily: 'Montserrat',
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
