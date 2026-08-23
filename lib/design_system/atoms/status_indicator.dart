import 'package:flutter/material.dart';
import '../tokens/app_colors.dart';
import '../tokens/app_typography.dart';

/// Ein einzelner Status-Slot: Punkt oder Icon in der Status-Farbe, Label
/// immer in der sekundären Textfarbe. Farbe ist damit nie der einzige
/// Träger — das Label steht immer daneben.
class StatusIndicator extends StatelessWidget {
  const StatusIndicator({
    required this.color,
    required this.label,
    this.icon,
    super.key,
  });

  final Color color;
  final String label;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final marker =
        icon != null
            ? Icon(icon, size: 14, color: color)
            : Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            );

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        marker,
        const SizedBox(width: 6),
        Text(
          label,
          style: AppTypography.body.copyWith(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}
