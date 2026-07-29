// lib/design_system/widgets/app_text_field.dart
import 'package:flutter/material.dart';
import '../app_colors.dart';
import '../app_spacing.dart';
import '../app_typography.dart';

class AppTextField extends StatelessWidget {
  const AppTextField({
    required this.label,
    this.controller,
    this.errorText,
    this.obscureText = false,
    this.keyboardType,
    this.onChanged,
    super.key,
  });

  final String label;
  final TextEditingController? controller;
  final String? errorText;
  final bool obscureText;
  final TextInputType? keyboardType;
  final ValueChanged<String>? onChanged;

  bool get _hasError => errorText != null && errorText!.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final borderColor = _hasError ? AppColors.accent : AppColors.border;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label.toUpperCase(), style: AppTypography.fieldLabel),
        const SizedBox(height: 6),
        SizedBox(
          height: AppSpacing.fieldHeight,
          child: TextField(
            controller: controller,
            obscureText: obscureText,
            keyboardType: keyboardType,
            onChanged: onChanged,
            style: AppTypography.body.copyWith(color: AppColors.textPrimary),
            decoration: InputDecoration(
              contentPadding: EdgeInsets.symmetric(horizontal: AppSpacing.screenPaddingH),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSpacing.buttonRadius),
                borderSide: BorderSide(color: borderColor, width: AppSpacing.fieldBorderWidth),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSpacing.buttonRadius),
                borderSide: BorderSide(color: borderColor, width: AppSpacing.fieldBorderWidth),
              ),
            ),
          ),
        ),
        if (_hasError) ...[
          const SizedBox(height: 4),
          Text(
            errorText!,
            style: AppTypography.body.copyWith(color: AppColors.accentPressed, fontSize: 12),
          ),
        ],
      ],
    );
  }
}
