// lib/design_system/atoms/app_text_field.dart
import 'package:flutter/material.dart';
import '../tokens/app_colors.dart';
import '../tokens/app_spacing.dart';
import '../tokens/app_typography.dart';

class AppTextField extends StatelessWidget {
  const AppTextField({
    required this.label,
    this.controller,
    this.errorText,
    this.obscureText = false,
    this.keyboardType,
    this.onChanged,
    this.suffixIcon,
    this.placeholder,
    this.minLines,
    this.maxLines,
    super.key,
  });

  final String label;
  final TextEditingController? controller;
  final String? errorText;
  final bool obscureText;
  final TextInputType? keyboardType;
  final ValueChanged<String>? onChanged;
  final Widget? suffixIcon;
  final String? placeholder;
  final int? minLines;

  /// `null` (Standard) lässt das Feld mit dem Text in die Höhe wachsen.
  /// `1` erzwingt ein einzeiliges Feld.
  final int? maxLines;

  bool get _hasError => errorText != null && errorText!.isNotEmpty;

  // Passwortfelder können technisch nicht mehrzeilig sein.
  int? get _effectiveMaxLines => obscureText ? 1 : maxLines;

  bool get _isMultiline => _effectiveMaxLines != 1;

  @override
  Widget build(BuildContext context) {
    final borderColor = _hasError ? AppColors.accent : AppColors.border;
    final lineHeight =
        AppTypography.body.fontSize! * (AppTypography.body.height ?? 1);
    // So bleibt eine einzelne Zeile exakt auf fieldHeight, jede weitere Zeile
    // vergrößert das Feld.
    final verticalPadding = (AppSpacing.fieldHeight - lineHeight) / 2;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTypography.fieldLabel,
        ),
        const SizedBox(height: AppSpacing.fieldLabelGap),
        ConstrainedBox(
          constraints: BoxConstraints(minHeight: AppSpacing.fieldHeight),
          child: TextField(
            controller: controller,
            obscureText: obscureText,
            keyboardType:
                keyboardType ?? (_isMultiline ? TextInputType.multiline : null),
            minLines: minLines,
            maxLines: _effectiveMaxLines,
            onChanged: onChanged,
            textAlignVertical: TextAlignVertical.center,
            style: AppTypography.body.copyWith(color: AppColors.textPrimary),
            decoration: InputDecoration(
              contentPadding: EdgeInsets.symmetric(
                horizontal: AppSpacing.screenPaddingH,
                vertical: verticalPadding,
              ),
              hintText: placeholder,
              suffixIcon: suffixIcon,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSpacing.buttonRadius),
                borderSide: BorderSide(
                  color: borderColor,
                  width: AppSpacing.fieldBorderWidth,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSpacing.buttonRadius),
                borderSide: BorderSide(
                  color: borderColor,
                  width: AppSpacing.fieldBorderWidth,
                ),
              ),
            ),
          ),
        ),
        if (_hasError) ...[
          const SizedBox(height: 4),
          Text(
            errorText!,
            style: AppTypography.body.copyWith(
              color: AppColors.accentPressed,
              fontSize: 12,
            ),
          ),
        ],
      ],
    );
  }
}
