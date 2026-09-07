import 'package:flutter/material.dart';

import '../../enums/article_status.dart';
import '../tokens/app_colors.dart';
import '../tokens/app_typography.dart';

/// Filter-Chip auf dem Overview-Screen: zeigt einen farbigen Punkt,
/// Status-Label und Anzahl, und filtert die Liste beim Antippen darauf.
///
/// Angelehnt an schlichte Status-Chips: im Ruhezustand weiss mit duennem
/// Rahmen, im ausgewaehlten Zustand ein zarter Farbton der Statusfarbe als
/// Hintergrund mit farbigem Rahmen. Der Punkt traegt in beiden Zustaenden
/// die volle Statusfarbe.
class KpiFilterCard extends StatelessWidget {
  const KpiFilterCard({
    super.key,
    required this.value,
    required this.status,
    this.selected = false,
    this.onTap,
  });

  final int value;
  final ArticleStatus status;

  /// Markiert den Chip als aktiven Filter.
  final bool selected;

  final VoidCallback? onTap;

  static const double _borderWidth = 1.5;

  /// Innenabstand des Chips.
  static const double _paddingH = 16;
  static const double _paddingV = 10;

  static const double _dotSize = 8;
  static const double _dotGap = 8;
  static const double _valueGap = 6;

  @override
  Widget build(BuildContext context) {
    final dotColor = AppColors.statusColors[status]!;
    final borderColor = selected ? dotColor : AppColors.border;
    final backgroundColor = selected
        ? AppColors.statusColorTints[status]!
        : AppColors.white;
    final textColor = selected ? dotColor : AppColors.textPrimary;

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
                decoration: BoxDecoration(
                  color: dotColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: _dotGap),
              Text(
                status.label,
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
