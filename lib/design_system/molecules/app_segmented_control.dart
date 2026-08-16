// lib/design_system/molecules/app_segmented_control.dart
import 'package:flutter/material.dart';
import '../atoms/app_segment.dart';
import '../tokens/app_colors.dart';
import '../tokens/app_spacing.dart';
import '../tokens/app_typography.dart';

class AppSegmentedControl<T> extends StatelessWidget {
  const AppSegmentedControl({
    required this.options,
    required this.labelBuilder,
    required this.value,
    required this.onChanged,
    this.label,
    super.key,
  });

  final List<T> options;
  final String Function(T) labelBuilder;
  final T value;
  final ValueChanged<T> onChanged;
  final String? label;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(
            label!.toUpperCase(),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.fieldLabel,
          ),
          const SizedBox(height: 6),
        ],
        Container(
          height: AppSpacing.fieldHeight,
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppSpacing.buttonRadius),
            border: Border.all(
              color: AppColors.border,
              width: AppSpacing.fieldBorderWidth,
            ),
          ),
          child: Row(
            children: [
              for (final option in options)
                Expanded(
                  child: AppSegment(
                    label: labelBuilder(option),
                    selected: option == value,
                    onTap:
                        option == value ? null : () => onChanged(option),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
