import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../enums/article_status.dart';
import '../tokens/app_colors.dart';
import '../tokens/app_typography.dart';

extension on ArticleStatus {
  IconData get icon => switch (this) {
    ArticleStatus.inStock => Symbols.order_approve_rounded,
    ArticleStatus.bestellt => Symbols.delivery_truck_speed_rounded,
    ArticleStatus.fehlt => Symbols.cancel_rounded,
  };
}

/// Filter-Chip auf dem Overview-Screen: zeigt Icon, Status-Label und Anzahl
/// und filtert die Liste beim Antippen darauf.
///
/// Hintergrund ist die gesaettigte Statusfarbe, Icon und Schrift stehen in
/// [AppColors.statusOnColors] — auf Gelb also dunkles Ink statt Weiss.
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

  /// Markiert den Chip als aktiven Filter — sichtbar ueber einen Ring in
  /// dunklem Ink. Ein Ring in der Vordergrundfarbe (Weiss) waere hier
  /// sinnlos: Text und Icon sind ebenfalls weiss, der Ring wuerde optisch
  /// mit ihnen verschmelzen statt sich vom Chip abzuheben.
  final bool selected;

  final VoidCallback? onTap;

  /// Staerke des Auswahl-Rings. Der Ring liegt *innerhalb* des Chips, das
  /// Padding ist um dieselbe Staerke reduziert — so sitzt der Inhalt in
  /// beiden Zustaenden an derselben Stelle und die Zeile springt nicht.
  static const double _ringWidth = 3;

  /// Innenabstand des Chips.
  static const double _paddingH = 14;
  static const double _paddingV = 10;

  static const double _iconSize = 18;
  static const double _iconGap = 6;
  static const double _valueGap = 6;

  @override
  Widget build(BuildContext context) {
    final foreground = AppColors.statusOnColors[status]!;

    return Material(
      color: AppColors.statusColors[status],
      shape: const StadiumBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        customBorder: const StadiumBorder(),
        child: Container(
          decoration: ShapeDecoration(
            shape: StadiumBorder(
              side: BorderSide(
                color: selected ? AppColors.textPrimary : Colors.transparent,
                width: _ringWidth,
                // Ohne strokeAlignInside liegt die Haelfte des Rings ausser-
                // halb dieses Containers und wird vom Clip.antiAlias des
                // umschliessenden Material weggeschnitten — auf Weiss-auf-
                // Gruen/Rot war davon praktisch nichts mehr zu sehen.
                strokeAlign: BorderSide.strokeAlignInside,
              ),
            ),
          ),
          padding: EdgeInsets.symmetric(
            horizontal: _paddingH - _ringWidth,
            vertical: _paddingV - _ringWidth,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(status.icon, size: _iconSize, color: foreground),
              const SizedBox(width: _iconGap),
              Text(
                status.label,
                style: AppTypography.kpiLabel.copyWith(color: foreground),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(width: _valueGap),
              Text(
                value.toString(),
                style: AppTypography.kpiLabel.copyWith(
                  color: foreground,
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
