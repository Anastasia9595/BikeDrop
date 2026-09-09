import 'package:flutter/material.dart';

import '../atoms/kpi_filter_card.dart';
import '../tokens/app_spacing.dart';

/// Ein Eintrag der [KpiFilterRow]: Zählwert plus die Optik seiner Kachel.
/// [key] identifiziert den Eintrag beim Antippen und bei "welcher ist
/// ausgewaehlt" — typischerweise ein Enum-Wert des Aufrufers (z.B.
/// `ArticleStatus.inStock` oder `ReceivingScanStatus.unknown`).
class KpiFilterEntry {
  const KpiFilterEntry({
    required this.key,
    required this.label,
    required this.color,
    required this.tint,
    required this.count,
  });

  final Object key;
  final String label;
  final Color color;
  final Color tint;
  final int count;
}

/// Beliebig viele Filter-Kacheln nebeneinander, wie sie unter der Suchleiste
/// des Overview-Screens oder im Kopf des Wareneingangs-Warenkorbs stehen.
///
/// Zustandslos: welche Eintraege es gibt, welcher als Filter aktiv ist und
/// was ein Tipp ausloest, entscheidet der aufrufende Screen. Dieses Widget
/// kennt kein Status-Enum und keine Farbtabelle.
class KpiFilterRow extends StatelessWidget {
  const KpiFilterRow({
    super.key,
    required this.entries,
    this.selectedKey,
    this.onEntryTap,
  });

  final List<KpiFilterEntry> entries;

  /// Der als Filter aktive Schluessel, oder `null` fuer "kein Filter".
  final Object? selectedKey;

  /// Wird mit dem Schluessel der angetippten Kachel gerufen. Ist der
  /// Callback `null`, sind die Kacheln reine Anzeige.
  final ValueChanged<Object>? onEntryTap;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.listRowGap,
      runSpacing: AppSpacing.listRowGap,
      children: [
        for (final entry in entries)
          KpiFilterCard(
            value: entry.count,
            label: entry.label,
            color: entry.color,
            tint: entry.tint,
            selected: selectedKey == entry.key,
            onTap: onEntryTap == null ? null : () => onEntryTap!(entry.key),
          ),
      ],
    );
  }
}
