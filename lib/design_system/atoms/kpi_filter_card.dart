import 'package:flutter/material.dart';

import '../tokens/app_colors.dart';
import '../tokens/app_typography.dart';

/// Generischer Filter-Chip: farbiger Punkt, Label und Anzahl, filtert eine
/// Liste beim Antippen darauf. Kennt keine Domäne — Farbe/Label/Tint kommen
/// als primitive Parameter vom Aufrufer (z.B. aus [ArticleStatus] oder
/// `ReceivingScanStatus` gebaut), damit dieselbe Kachel für mehrere
/// Status-Enums wiederverwendbar ist.
///
/// Im Ruhezustand weiss mit duennem Rahmen, im ausgewaehlten Zustand ein
/// zarter Farbton ([tint]) als Hintergrund. Der Punkt traegt in beiden
/// Zustaenden die volle [color].
class KpiFilterCard extends StatelessWidget {
  const KpiFilterCard({
    super.key,
    required this.value,
    required this.label,
    required this.color,
    required this.tint,
    this.selected = false,
    this.onTap,
  });

  final int value;
  final String label;
  final Color color;
  final Color tint;

  /// Markiert den Chip als aktiven Filter.
  final bool selected;

  final VoidCallback? onTap;

  static const double _borderWidth = 1.5;
  static const double _paddingH = 16;
  static const double _paddingV = 10;
  static const double _dotSize = 8;
  static const double _dotGap = 8;
  static const double _valueGap = 6;

  @override
  Widget build(BuildContext context) {
    final borderColor = selected ? color : AppColors.border;
    final backgroundColor = selected ? tint : AppColors.white;
    final textColor = selected ? color : AppColors.textPrimary;

    return Material(
      color: backgroundColor,
      shape: const StadiumBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        customBorder: const StadiumBorder(),
        child: Container(
          decoration: ShapeDecoration(
            shape: StadiumBorder(
              side: BorderSide(color: borderColor, width: _borderWidth),
            ),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: _paddingH,
            vertical: _paddingV,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: _dotSize,
                height: _dotSize,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
              const SizedBox(width: _dotGap),
              Text(
                label,
                style: AppTypography.kpiLabel.copyWith(color: textColor),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(width: _valueGap),
              Text(
                value.toString(),
                style: AppTypography.kpiLabel.copyWith(
                  color: textColor,
                  fontWeight: FontWeight.w800,
                ),
                maxLines: 1,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
