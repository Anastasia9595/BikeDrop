// lib/design_system/atoms/app_segment.dart
import 'package:flutter/material.dart';
import '../tokens/app_colors.dart';
import '../tokens/app_spacing.dart';
import '../tokens/app_typography.dart';

class AppSegment extends StatelessWidget {
  const AppSegment({
    required this.label,
    required this.selected,
    required this.onTap,
    this.dotColor,
    super.key,
  });

  final String label;
  final bool selected;

  /// `null` schaltet das Segment inaktiv (z. B. das bereits ausgewählte).
  final VoidCallback? onTap;

  /// Optionaler Status-Punkt vor dem Label (z. B. orange/grün). Traegt in
  /// beiden Zustaenden (ausgewaehlt/nicht ausgewaehlt) die volle Farbe —
  /// nur Hintergrund/Text des Segments aendern sich bei Auswahl.
  final Color? dotColor;

  static const double _dotSize = 8;
  static const double _dotGap = 8;

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(
      AppSpacing.buttonRadius - AppSpacing.fieldBorderWidth,
    );

    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        onTap: onTap,
        borderRadius: borderRadius,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? AppColors.textPrimary : Colors.transparent,
            borderRadius: borderRadius,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (dotColor != null) ...[
                Container(
                  width: _dotSize,
                  height: _dotSize,
                  decoration: BoxDecoration(
                    color: dotColor,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: _dotGap),
              ],
              Flexible(
                child: Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.secondaryButtonLabel.copyWith(
                    color: selected ? AppColors.white : AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
