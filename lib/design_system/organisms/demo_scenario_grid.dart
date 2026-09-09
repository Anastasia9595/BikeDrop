import 'package:flutter/material.dart';

import '../../models/demoscanoption.dart';
import '../atoms/demo_scenario_button.dart';
import '../tokens/app_colors.dart';
import '../tokens/app_spacing.dart';
import '../tokens/app_typography.dart';

/// Die Demo-Szenarien des Wareneingang-Scanners als 2-Spalten-Grid aus
/// [DemoScenarioButton]-Kacheln, unter der Kicker-Ueberschrift
/// "DEMO-SZENARIEN".
///
/// Zustandslos: welche Optionen es gibt, ob gerade ein Scan laeuft und was
/// ein Tipp ausloest, entscheidet der aufrufende Screen.
class DemoScenarioGrid extends StatelessWidget {
  const DemoScenarioGrid({
    required this.options,
    required this.activeEan,
    required this.onOptionTap,
    super.key,
  });

  final List<DemoScanOption> options;

  /// null = idle, sonst die EAN, die gerade "gescannt" wird.
  final String? activeEan;

  final ValueChanged<DemoScanOption> onOptionTap;

  @override
  Widget build(BuildContext context) {
    final enabled = activeEan == null;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.screenPaddingH,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'DEMO-SZENARIEN',
            style: AppTypography.sectionKicker.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.listRowGap),
          for (var i = 0; i < options.length; i += 2)
            Padding(
              padding: EdgeInsets.only(
                top: i == 0 ? 0 : AppSpacing.listRowGap,
              ),
              child: Row(
                children: [
                  for (var j = i; j < i + 2 && j < options.length; j++) ...[
                    if (j > i) const SizedBox(width: AppSpacing.listRowGap),
                    Expanded(
                      child: DemoScenarioButton(
                        option: options[j],
                        enabled: enabled,
                        onTap: () => onOptionTap(options[j]),
                      ),
                    ),
                  ],
                ],
              ),
            ),
        ],
      ),
    );
  }
}
