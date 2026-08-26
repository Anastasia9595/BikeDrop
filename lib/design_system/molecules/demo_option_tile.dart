import 'package:flutter/material.dart';

import '../../models/demoscanoption.dart';
import '../tokens/app_colors.dart';
import '../tokens/app_typography.dart';

/// Eine antippbare Zeile im Demo-Scanner: Icon, Label und Untertitel einer
/// [DemoScanOption].
///
/// Meldet den Tap nur ueber [onTap] nach aussen — was danach passiert, weiss
/// die Kachel nicht. Ist [enabled] false, ist sie gedimmt und reagiert nicht.
class DemoOptionTile extends StatelessWidget {
  const DemoOptionTile({
    required this.option,
    required this.enabled,
    required this.onTap,
    super.key,
  });

  final DemoScanOption option;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: enabled ? 1 : 0.4,
      child: InkWell(
        onTap: enabled ? onTap : null,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Icon(option.icon, color: AppColors.textSecondary),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      option.label,
                      style: AppTypography.body.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      option.subtitle,
                      style: AppTypography.body.copyWith(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
