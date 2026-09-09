import 'package:flutter/material.dart';

import '../../models/demoscanoption.dart';
import '../tokens/app_colors.dart';
import '../tokens/app_spacing.dart';
import '../tokens/app_typography.dart';

/// Ein einzelner Button im Wareneingang-Scanner-Grid: dunkle Kachel mit
/// farbigem Icon und Label einer [DemoScanOption].
///
/// Meldet den Tap nur ueber [onTap] nach aussen. Ist [enabled] false, ist er
/// gedimmt und reagiert nicht — analog zu [DemoOptionTile] fuer die
/// Listen-Ansicht.
class DemoScenarioButton extends StatelessWidget {
  const DemoScenarioButton({
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
      child: Material(
        color: AppColors.white,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
          side: BorderSide(
            color: AppColors.border,
            width: AppSpacing.fieldBorderWidth,
          ),
        ),
        child: InkWell(
          onTap: enabled ? onTap : null,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  option.icon,
                  size: AppSpacing.iconSize,
                  color: option.color ?? AppColors.textSecondary,
                ),
                const SizedBox(width: 10),
                Flexible(
                  child: Text(
                    option.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.secondaryButtonLabel.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
