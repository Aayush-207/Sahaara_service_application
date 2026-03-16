import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class ActionMenuItem {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? iconColor;

  ActionMenuItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.iconColor,
  });
}

class ActionMenuWidget extends StatelessWidget {
  final List<ActionMenuItem> items;
  final bool showCloseButton;
  final VoidCallback? onClose;

  const ActionMenuWidget({
    super.key,
    required this.items,
    this.showCloseButton = true,
    this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 40,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ...items.asMap().entries.map((entry) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: entry.key < items.length - 1 ? 12 : 0,
              ),
              child: _buildActionButton(entry.value),
            );
          }),
          if (showCloseButton) ...[
            const SizedBox(height: 16),
            _buildCloseButton(),
          ],
        ],
      ),
    );
  }

  Widget _buildActionButton(ActionMenuItem item) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: item.onTap,
        borderRadius: BorderRadius.circular(50),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(50),
            border: Border.all(
              color: AppColors.border,
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  item.icon,
                  size: 20,
                  color: item.iconColor ?? AppColors.textSecondary,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  item.label,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                    fontFamily: 'Montserrat',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCloseButton() {
    return GestureDetector(
      onTap: onClose,
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          border: Border.all(
            color: AppColors.primary,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Icon(
          Icons.close_rounded,
          color: AppColors.primary,
          size: 28,
        ),
      ),
    );
  }
}

// Example usage widget
class ActionMenuExample extends StatelessWidget {
  const ActionMenuExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ActionMenuWidget(
        items: [
          ActionMenuItem(
            icon: Icons.star_rounded,
            label: 'Rate a store',
            onTap: () {
              // Handle rate action
            },
          ),
          ActionMenuItem(
            icon: Icons.remove_red_eye_rounded,
            label: 'Add a image',
            onTap: () {
              // Handle add image action
            },
          ),
          ActionMenuItem(
            icon: Icons.edit_rounded,
            label: 'Write a review',
            onTap: () {
              // Handle write review action
            },
          ),
        ],
        onClose: () {
          Navigator.pop(context);
        },
      ),
    );
  }
}
