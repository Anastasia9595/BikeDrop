// lib/design_system/molecules/quantity_stepper.dart
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import '../atoms/app_icon_button.dart';
import '../tokens/app_colors.dart';
import '../tokens/app_spacing.dart';
import '../tokens/app_typography.dart';

class QuantityStepper extends StatelessWidget {
  const QuantityStepper({
    required this.label,
    required this.quantity,
    required this.onChanged,
    this.min = 0,
    this.max,
    super.key,
  });

  final int quantity;
  final ValueChanged<int> onChanged;
  final int min;
  final int? max;
  final String label;

  bool get _canDecrement => quantity > min;
  bool get _canIncrement => max == null || quantity < max!;

  @override
  Widget build(BuildContext context) {
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
        Container(
          height: AppSpacing.fieldHeight,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppSpacing.buttonRadius),
            border: Border.all(
              color: AppColors.border,
              width: AppSpacing.fieldBorderWidth,
            ),
          ),
          child: Row(
            children: [
              AppIconButton(
                icon: Symbols.remove,
                tooltip: 'Menge verringern',
                onPressed: _canDecrement ? () => onChanged(quantity - 1) : null,
              ),
              Expanded(
                child: Center(
                  child: Text(
                    '$quantity',
                    style: AppTypography.listNumber.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ),
              AppIconButton(
                icon: Symbols.add,
                tooltip: 'Menge erhöhen',
                onPressed: _canIncrement ? () => onChanged(quantity + 1) : null,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
