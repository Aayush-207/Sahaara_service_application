import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class CustomTextField extends StatefulWidget {
  final TextEditingController controller;
  final String labelText;
  final String? hintText;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final bool obscureText;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final VoidCallback? onSuffixIconTap;
  final int maxLines;
  final bool enabled;

  const CustomTextField({
    super.key,
    required this.controller,
    required this.labelText,
    this.hintText,
    this.prefixIcon,
    this.suffixIcon,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.onSuffixIconTap,
    this.maxLines = 1,
    this.enabled = true,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  bool _obscureText = false;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.obscureText;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.labelText,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
            fontFamily: 'Montserrat',
          ),
        ),
        const SizedBox(height: 8),
        RepaintBoundary(
          child: TextFormField(
            controller: widget.controller,
            obscureText: _obscureText,
            keyboardType: widget.keyboardType,
            validator: widget.validator,
            maxLines: widget.maxLines,
            enabled: widget.enabled,
            style: const TextStyle(
              fontSize: 15,
              color: AppColors.textPrimary,
              fontFamily: 'Montserrat',
            ),
            decoration: InputDecoration(
              hintText: widget.hintText ?? widget.labelText,
              hintStyle: const TextStyle(
                color: AppColors.textTertiary,
                fontSize: 15,
                fontFamily: 'Montserrat',
              ),
              prefixIcon: widget.prefixIcon != null
                  ? Icon(
                      widget.prefixIcon,
                      color: AppColors.textTertiary,
                    )
                  : null,
              suffixIcon: widget.obscureText
                  ? IconButton(
                      icon: Icon(
                        _obscureText ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                        color: AppColors.textTertiary,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureText = !_obscureText;
                        });
                      },
                    )
                  : widget.suffixIcon != null
                      ? IconButton(
                          icon: Icon(widget.suffixIcon, color: AppColors.textTertiary),
                          onPressed: widget.onSuffixIconTap,
                        )
                      : null,
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.primary, width: 2),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.error),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.error, width: 2),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            ),
          ),
        ),
      ],
    );
  }
}
