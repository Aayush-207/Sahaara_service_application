import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../services/sound_service.dart';

/// Cancel Booking Dialog Utilities
/// 
/// Provides dialog widgets for the booking cancellation flow:
/// 1. Confirmation Dialog - Asks for confirmation with Go Back / Confirm options
/// 2. Reason Selection Dialog - Shows common cancellation reasons + Other option
class CancelBookingDialogs {
  static const List<String> cancellationReasons = [
    'Plans changed',
    'Found another caregiver',
    'Emergency came up',
    'Pet got sick',
    'Schedule conflict',
    'Too expensive',
  ];

  /// Shows confirmation dialog before proceeding with cancellation
  static Future<bool?> showConfirmationDialog(
    BuildContext context, {
    required String bookingId,
  }) {
    final soundService = SoundService();

    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'Cancel Booking?',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
              fontFamily: 'Montserrat',
            ),
          ),
          content: const Text(
            'Are you sure you want to cancel this booking? This action cannot be undone.',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
              fontFamily: 'Montserrat',
              height: 1.5,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                soundService.playTap();
                Navigator.of(context).pop(false);
              },
              style: TextButton.styleFrom(
                foregroundColor: AppColors.textSecondary,
              ),
              child: const Text(
                'Go Back',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Montserrat',
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                soundService.playTap();
                Navigator.of(context).pop(true);
              },
              style: TextButton.styleFrom(
                foregroundColor: AppColors.error,
              ),
              child: const Text(
                'Confirm',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'Montserrat',
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  /// Shows reason selection dialog
  static Future<String?> showReasonSelectionDialog(
    BuildContext context,
  ) {
    final soundService = SoundService();
    String? selectedReason;
    final textController = TextEditingController();

    return showDialog<String?>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: const Text(
                'Why are you cancelling?',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                  fontFamily: 'Montserrat',
                ),
              ),
              content: SizedBox(
                width: double.maxFinite,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Common Reasons List
                      ...cancellationReasons.map((reason) {
                        final isSelected = selectedReason == reason;
                        return GestureDetector(
                          onTap: () {
                            soundService.playTap();
                            setState(() {
                              selectedReason = isSelected ? null : reason;
                              if (isSelected) {
                                textController.clear();
                              }
                            });
                          },
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: isSelected ? AppColors.primary.withValues(alpha: 0.1) : AppColors.background,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: isSelected ? AppColors.primary : AppColors.border,
                                width: 1.5,
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 20,
                                  height: 20,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: isSelected ? AppColors.primary : AppColors.textTertiary,
                                      width: 2,
                                    ),
                                  ),
                                  child: isSelected
                                      ? const Icon(
                                          Icons.check,
                                          size: 12,
                                          color: AppColors.primary,
                                        )
                                      : null,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    reason,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                                      color: AppColors.textPrimary,
                                      fontFamily: 'Montserrat',
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                      const SizedBox(height: 12),

                      // Other option with text box
                      GestureDetector(
                        onTap: () {
                          soundService.playTap();
                          setState(() {
                            selectedReason = selectedReason == 'other' ? null : 'other';
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: selectedReason == 'other' ? AppColors.primary.withValues(alpha: 0.1) : AppColors.background,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: selectedReason == 'other' ? AppColors.primary : AppColors.border,
                              width: 1.5,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 20,
                                height: 20,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: selectedReason == 'other' ? AppColors.primary : AppColors.textTertiary,
                                    width: 2,
                                  ),
                                ),
                                child: selectedReason == 'other'
                                    ? const Icon(
                                        Icons.check,
                                        size: 12,
                                        color: AppColors.primary,
                                      )
                                    : null,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'Other',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: selectedReason == 'other' ? FontWeight.w600 : FontWeight.w500,
                                    color: AppColors.textPrimary,
                                    fontFamily: 'Montserrat',
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Text input for "Other" reason
                      if (selectedReason == 'other') ...[
                        const SizedBox(height: 12),
                        TextField(
                          controller: textController,
                          maxLines: 3,
                          maxLength: 200,
                          decoration: InputDecoration(
                            hintText: 'Please tell us why...',
                            hintStyle: const TextStyle(
                              fontSize: 14,
                              color: AppColors.textTertiary,
                              fontFamily: 'Montserrat',
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(color: AppColors.border),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(color: AppColors.primary, width: 2),
                            ),
                            contentPadding: const EdgeInsets.all(12),
                            counterText: '',
                          ),
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.textPrimary,
                            fontFamily: 'Montserrat',
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    soundService.playTap();
                    Navigator.of(context).pop(null);
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.textSecondary,
                  ),
                  child: const Text(
                    'Back',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Montserrat',
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: selectedReason == null
                      ? null
                      : () {
                          soundService.playTap();
                          String finalReason = selectedReason!;
                          if (selectedReason == 'other') {
                            finalReason = textController.text.isEmpty
                                ? 'Other'
                                : textController.text;
                          }
                          Navigator.of(context).pop(finalReason);
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.error,
                    disabledBackgroundColor: AppColors.textTertiary.withValues(alpha: 0.3),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'Cancel Booking',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      fontFamily: 'Montserrat',
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
