import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../enums/article_status.dart';
import '../tokens/app_colors.dart';
import '../tokens/app_spacing.dart';
import '../tokens/app_typography.dart';

extension on ArticleStatus {
  IconData get icon => switch (this) {
    ArticleStatus.inStock => Symbols.order_approve_rounded,
    ArticleStatus.bestellt => Symbols.delivery_truck_speed_rounded,
    ArticleStatus.fehlt => Symbols.cancel_rounded,
  };
}

/// Kachel auf dem Overview-Screen: zeigt die Anzahl der Artikel in einem
/// Status und filtert die Liste beim Antippen darauf.
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

  /// Markiert die Karte als aktiven Filter — sichtbar ueber einen Ring in
  /// der Vordergrundfarbe.
  final bool selected;

  final VoidCallback? onTap;

  /// Staerke des Auswahl-Rings. Der Ring liegt *innerhalb* der Kachel, das
  /// Padding ist um dieselbe Staerke reduziert — so sitzt der Inhalt in
  /// beiden Zustaenden an derselben Stelle und die Zeile springt nicht.
  static const double _ringWidth = 3;

  /// Innenabstand der Kachel. Enger als [AppSpacing.screenPaddingH], damit
  /// drei Kacheln nebeneinander auch auf schmalen Geraeten Platz haben.
  static const double _padding = 12;

  static const double _iconSize = 18;
  static const double _iconGap = 6;

  @override
  Widget build(BuildContext context) {
    final foreground = AppColors.statusOnColors[status]!;

    return Material(
      color: AppColors.statusColors[status],
      borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: selected ? foreground : Colors.transparent,
              width: _ringWidth,
            ),
            borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
          ),
          padding: const EdgeInsets.all(_padding - _ringWidth),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Header(status: status, foreground: foreground),
              const SizedBox(height: 16),
              Text(
                value.toString(),
                style: AppTypography.kpiValue.copyWith(color: foreground),
                maxLines: 1,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Icon und Label ueber der Kennzahl. Passen beide nicht nebeneinander —
/// drei Kacheln auf einem 320-dp-Geraet lassen jeder nur rund 88 dp — dann
/// entfaellt das Icon, denn das Label traegt die Bedeutung.
class _Header extends StatelessWidget {
  const _Header({required this.status, required this.foreground});

  final ArticleStatus status;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    final style = AppTypography.kpiLabel.copyWith(color: foreground);
    final label = Text(status.label, style: style, maxLines: 1);

    return LayoutBuilder(
      builder: (context, constraints) {
        // Gemessen wird das *laengste* aller Status-Labels, nicht das eigene:
        // die drei Kacheln sind gleich breit und sollen sich deshalb auch
        // gleich entscheiden — sonst behaelt "Fehlt" sein Icon, waehrend
        // "Bestellt" seins verliert.
        final widestLabel = ArticleStatus.values
            .map(
              (s) => (TextPainter(
                text: TextSpan(text: s.label, style: style),
                textDirection: Directionality.of(context),
                textScaler: MediaQuery.textScalerOf(context),
                maxLines: 1,
              )..layout()).width,
            )
            .reduce((a, b) => a > b ? a : b);

        final fitsWithIcon =
            widestLabel + KpiFilterCard._iconSize + KpiFilterCard._iconGap <=
            constraints.maxWidth;

        if (!fitsWithIcon) {
          return SizedBox(
            width: double.infinity,
            child: Text(
              status.label,
              style: style,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          );
        }

        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              status.icon,
              size: KpiFilterCard._iconSize,
              color: foreground,
            ),
            const SizedBox(width: KpiFilterCard._iconGap),
            Flexible(child: label),
          ],
        );
      },
    );
  }
}
