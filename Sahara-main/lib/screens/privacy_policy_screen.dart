import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../config/app_config.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: const Text(
          'Privacy Policy',
          style: TextStyle(
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.w700,
          ),
        ),
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Privacy Policy',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
                fontFamily: 'Montserrat',
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Last updated: February 24, 2026',
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textTertiary,
                fontFamily: 'Montserrat',
              ),
            ),
            const SizedBox(height: 24),
            _buildSection(
              title: '1. Information We Collect',
              content: 'We collect information you provide directly to us, including:\n\n'
                  '• Account information (name, email, phone number)\n'
                  '• Pet information (name, breed, age, medical details)\n'
                  '• Location data (when you use location-based features)\n'
                  '• Messages and communications with caregivers',
            ),
            _buildSection(
              title: '2. How We Use Your Information',
              content: 'We use the information we collect to:\n\n'
                  '• Provide, maintain, and improve our services\n'
                  '• Process and manage bookings\n'
                  '• Send you notifications and updates\n'
                  '• Verify caregiver credentials\n'
                  '• Respond to your requests and support needs\n'
                  '• Ensure safety and security of our platform',
            ),
            _buildSection(
              title: '3. Information Sharing',
              content: 'We share your information only in these circumstances:\n\n'
                  '• With caregivers when you book their services\n'
                  '• With service providers who help us operate our platform\n'
                  '• When required by law or to protect rights and safety\n'
                  '• With your consent or at your direction',
            ),
            _buildSection(
              title: '4. Data Security',
              content: 'We implement appropriate security measures to protect your information:\n\n'
                  '• Encryption of data in transit and at rest\n'
                  '• Regular security audits and updates\n'
                  '• Secure authentication and access controls\n'
                  '• Background checks for all caregivers\n'
                  '• Compliance with industry standards',
            ),
            _buildSection(
              title: '5. Your Rights',
              content: 'You have the right to:\n\n'
                  '• Access your personal information\n'
                  '• Correct inaccurate information\n'
                  '• Delete your account and data\n'
                  '• Opt-out of marketing communications\n'
                  '• Export your data\n'
                  '• Lodge a complaint with authorities',
            ),
            _buildSection(
              title: '6. Children\'s Privacy',
              content: 'Our services are not intended for children under 18. We do not knowingly collect information from children. If you believe we have collected information from a child, please contact us immediately.',
            ),
            _buildSection(
              title: '7. Changes to This Policy',
              content: 'We may update this privacy policy from time to time. We will notify you of any changes by posting the new policy on this page and updating the "Last updated" date.',
            ),
            _buildSection(
              title: '8. Contact Us',
              content: 'If you have questions about this privacy policy, please contact us:\n\n'
                  'Email: ${AppConfig.privacyEmail}\n'
                  'Phone: ${AppConfig.supportPhone}\n'
                  'Address: ${AppConfig.companyAddress}',
            ),
            const SizedBox(height: 28),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.accentContainer,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.accent.withValues(alpha: 0.2),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.info_outline_rounded,
                    color: AppColors.accent,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: const Text(
                      'By using Sahara, you agree to this privacy policy and our terms of service.',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                        fontFamily: 'Montserrat',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({required String title, required String content}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
              fontFamily: 'Montserrat',
            ),
          ),
          const SizedBox(height: 10),
          Text(
            content,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
              fontFamily: 'Montserrat',
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
