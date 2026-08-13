// lib/design_system/molecules/quantity_stepper.dart
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import '../tokens/app_colors.dart';
import '../tokens/app_spacing.dart';
import '../tokens/app_typography.dart';

class QuantityStepper extends StatelessWidget {
  const QuantityStepper({
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

  bool get _canDecrement => quantity > min;
  bool get _canIncrement => max == null || quantity < max!;

  @override
  Widget build(BuildContext context) {
    return Container(
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
          _StepperButton(
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
          _StepperButton(
            icon: Symbols.add,
            tooltip: 'Menge erhöhen',
            onPressed: _canIncrement ? () => onChanged(quantity + 1) : null,
          ),
        ],
      ),
    );
  }
}

class _StepperButton extends StatelessWidget {
  const _StepperButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      tooltip: tooltip,
      icon: Icon(icon),
      iconSize: AppSpacing.iconItemListTileSize,
      color: AppColors.textPrimary,
      disabledColor: AppColors.textQuaternaryLight,
      constraints: const BoxConstraints(
        minWidth: AppSpacing.minTapTarget,
        minHeight: AppSpacing.minTapTarget,
      ),
    );
  }
}
