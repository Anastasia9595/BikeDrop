import 'package:flutter/material.dart';

import '../../enums/article_status.dart';
import '../atoms/kpi_filter_card.dart';
import '../tokens/app_spacing.dart';

/// Die drei Status-Kacheln nebeneinander, wie sie unter der Suchleiste des
/// Overview-Screens stehen.
///
/// Zustandslos: welche Zahlen die Kacheln zeigen, welche als Filter aktiv ist
/// und was ein Tipp ausloest, entscheidet der aufrufende Screen. Dieses
/// Widget kennt weder Repository noch Provider.
class KpiFilterRow extends StatelessWidget {
  const KpiFilterRow({
    super.key,
    required this.counts,
    this.selected,
    this.onStatusTap,
  });

  /// Anzahl je Status. Fehlt ein Status, zeigt seine Kachel 0.
  final Map<ArticleStatus, int> counts;

  /// Der als Filter aktive Status, oder `null` fuer "kein Filter".
  final ArticleStatus? selected;

  /// Wird mit dem angetippten Status gerufen. Ist der Callback `null`, sind
  /// die Kacheln reine Anzeige.
  final ValueChanged<ArticleStatus>? onStatusTap;

  /// Bewusst nicht `ArticleStatus.values`: die Kacheln laufen von "alles gut"
  /// nach "Problem" — gruen, gelb, rot. Die Enum-Reihenfolge waere gruen,
  /// rot, gelb.
  static const order = [
    ArticleStatus.inStock,
    ArticleStatus.bestellt,
    ArticleStatus.fehlt,
  ];

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (final status in order) ...[
          Expanded(
            child: KpiFilterCard(
              value: counts[status] ?? 0,
              status: status,
              selected: selected == status,
              onTap: onStatusTap == null ? null : () => onStatusTap!(status),
            ),
          ),
          if (status != order.last)
            const SizedBox(width: AppSpacing.listRowGap),
        ],
      ],
    );
  }
}
