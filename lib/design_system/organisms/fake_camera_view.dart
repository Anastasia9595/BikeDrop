import 'package:flutter/material.dart';

import '../../models/demoscanoption.dart';
import '../atoms/text_divider.dart';
import '../design_system.dart';

/// Rein praesentationale Anzeige des simulierten Scans.
///
/// Haelt selbst keinen State: Ob gerade ein Scan laeuft, sagt allein
/// [activeEan] — null bedeutet idle. Das Timing der Scan-Sequenz und das
/// Ausloesen des Scans liegen beim aufrufenden Screen, hier wird ein Tap
/// nur ueber [onOptionTap] nach aussen gemeldet.
class FakeCameraView extends StatelessWidget {
  const FakeCameraView({
    required this.demoOptions,
    required this.activeEan,
    required this.onOptionTap,
    required this.onTapWithoutBarcode,
    super.key,
  });

  final List<DemoScanOption> demoOptions;

  final void Function() onTapWithoutBarcode;

  /// null = idle, sonst die EAN, die gerade "gescannt" wird.
  final String? activeEan;

  final void Function(DemoScanOption option) onOptionTap;

  @override
  Widget build(BuildContext context) {
    final ean = activeEan;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ScannerFrame(
          content: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: ean == null
                ? Container(
                    key: const ValueKey('idle'),
                    color: Colors.grey.shade900,
                  )
                : Center(
                    key: ValueKey(ean),
                    child: BarcodeWidget(ean: ean, barColor: Colors.white),
                  ),
          ),
        ),
        const SizedBox(height: 12),
        ...demoOptions.map(
          (option) => DemoOptionTile(
            option: option,
            enabled: ean == null,
            onTap: () => onOptionTap(option),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.screenSpacingH,
          ),
          child: TextDivider(text: 'oder'),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.screenSpacingH,
          ),
          child: AppSecondaryButton(
            label: 'Keine EAN scannen',
            icon: Icons.add,
            onPressed: onTapWithoutBarcode,
          ),
        ),
      ],
    );
  }
}
