import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Password Strength Indicator Widget
/// 
/// Displays visual feedback for password strength with:
/// - Color-coded strength levels
/// - Progress bar
/// - Strength label
/// - Requirements checklist
class PasswordStrengthIndicator extends StatelessWidget {
  final String password;
  final bool showRequirements;

  const PasswordStrengthIndicator({
    super.key,
    required this.password,
    this.showRequirements = true,
  });

  @override
  Widget build(BuildContext context) {
    final strength = _calculateStrength(password);
    final requirements = _getRequirements(password);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Strength bar
        Row(
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: strength.progress,
                  backgroundColor: AppColors.border,
                  valueColor: AlwaysStoppedAnimation<Color>(strength.color),
                  minHeight: 6,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              strength.label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: strength.color,
                fontFamily: 'Montserrat',
              ),
            ),
          ],
        ),
        
        // Requirements checklist
        if (showRequirements && password.isNotEmpty) ...[
          const SizedBox(height: 12),
          ...requirements.map((req) => _buildRequirement(req)),
        ],
      ],
    );
  }

  Widget _buildRequirement(PasswordRequirement req) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Icon(
            req.isMet ? Icons.check_circle_rounded : Icons.circle_outlined,
            size: 16,
            color: req.isMet ? AppColors.success : AppColors.textTertiary,
          ),
          const SizedBox(width: 8),
          Text(
            req.label,
            style: TextStyle(
              fontSize: 12,
              color: req.isMet ? AppColors.textSecondary : AppColors.textTertiary,
              fontFamily: 'Montserrat',
            ),
          ),
        ],
      ),
    );
  }

  PasswordStrength _calculateStrength(String password) {
    if (password.isEmpty) {
      return PasswordStrength(
        progress: 0.0,
        color: AppColors.border,
        label: '',
      );
    }

    int score = 0;
    
    // Length check
    if (password.length >= 6) score++;
    if (password.length >= 8) score++;
    if (password.length >= 12) score++;
    
    // Character variety
    if (password.contains(RegExp(r'[a-z]'))) score++;
    if (password.contains(RegExp(r'[A-Z]'))) score++;
    if (password.contains(RegExp(r'[0-9]'))) score++;
    if (password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) score++;

    if (score <= 2) {
      return PasswordStrength(
        progress: 0.25,
        color: AppColors.error,
        label: 'Weak',
      );
    } else if (score <= 4) {
      return PasswordStrength(
        progress: 0.5,
        color: AppColors.warning,
        label: 'Fair',
      );
    } else if (score <= 6) {
      return PasswordStrength(
        progress: 0.75,
        color: AppColors.info,
        label: 'Good',
      );
    } else {
      return PasswordStrength(
        progress: 1.0,
        color: AppColors.success,
        label: 'Strong',
      );
    }
  }

  List<PasswordRequirement> _getRequirements(String password) {
    return [
      PasswordRequirement(
        label: 'At least 6 characters',
        isMet: password.length >= 6,
      ),
      PasswordRequirement(
        label: 'Contains uppercase letter',
        isMet: password.contains(RegExp(r'[A-Z]')),
      ),
      PasswordRequirement(
        label: 'Contains lowercase letter',
        isMet: password.contains(RegExp(r'[a-z]')),
      ),
      PasswordRequirement(
        label: 'Contains number',
        isMet: password.contains(RegExp(r'[0-9]')),
      ),
    ];
  }
}

class PasswordStrength {
  final double progress;
  final Color color;
  final String label;

  PasswordStrength({
    required this.progress,
    required this.color,
    required this.label,
  });
}

class PasswordRequirement {
  final String label;
  final bool isMet;

  PasswordRequirement({
    required this.label,
    required this.isMet,
  });
}
