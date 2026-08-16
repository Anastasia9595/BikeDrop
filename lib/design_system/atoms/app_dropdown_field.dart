// lib/design_system/atoms/app_dropdown_field.dart
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import '../tokens/app_colors.dart';
import '../tokens/app_spacing.dart';
import '../tokens/app_typography.dart';

class AppDropdownField<T> extends StatelessWidget {
  const AppDropdownField({
    required this.label,
    required this.items,
    required this.itemLabel,
    required this.onChanged,
    this.value,
    this.errorText,
    super.key,
  });

  final String label;
  final List<T> items;
  final String Function(T) itemLabel;
  final ValueChanged<T?> onChanged;
  final T? value;
  final String? errorText;

  bool get _hasError => errorText != null && errorText!.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final borderColor = _hasError ? AppColors.accent : AppColors.border;
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppSpacing.buttonRadius),
      borderSide: BorderSide(
        color: borderColor,
        width: AppSpacing.fieldBorderWidth,
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTypography.fieldLabel,
        ),
        const SizedBox(height: 6),
        SizedBox(
          height: AppSpacing.fieldHeight,
          child: InputDecorator(
            decoration: InputDecoration(
              contentPadding: EdgeInsets.symmetric(
                horizontal: AppSpacing.screenPaddingH,
              ),
              border: border,
              enabledBorder: border,
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<T>(
                value: value,
                items: [
                  for (final item in items)
                    DropdownMenuItem<T>(
                      value: item,
                      child: Text(
                        itemLabel(item),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                ],
                onChanged: onChanged,
                isExpanded: true,
                icon: const Icon(
                  Symbols.keyboard_arrow_down,
                  color: AppColors.textSecondary,
                ),
                style: AppTypography.body.copyWith(
                  color: AppColors.textPrimary,
                ),
                dropdownColor: AppColors.white,
                borderRadius: BorderRadius.circular(AppSpacing.buttonRadius),
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
