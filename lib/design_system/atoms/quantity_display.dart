import 'package:flutter/material.dart';
import '../tokens/app_colors.dart';
import '../tokens/app_spacing.dart';
import '../tokens/app_typography.dart';

/// Mengenanzeige rechts in der Zeile: ein antippbares Feld (Zahl +
/// Chevron), das das Mengen-Bottom-Sheet öffnet, plus ein außenstehendes
/// "Stk."-Label fester Breite, damit die Spalte über alle Zeilen bündig
/// bleibt und beim Scrollen nicht flackert.
class QuantityDisplay extends StatelessWidget {
  const QuantityDisplay({required this.quantity, this.onTap, super.key});

  final int quantity;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          height: AppSpacing.minTapTarget,
          child: Center(
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(8),
              child: Container(
                constraints: const BoxConstraints(minWidth: 62),
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.border, width: 0.5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      '$quantity',
                      style: AppTypography.body.copyWith(
                        fontSize: 17,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textPrimary,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Icon(
                      Icons.keyboard_arrow_down,
                      size: 14,
                      color: AppColors.textSecondary,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 4),
        SizedBox(
          height: AppSpacing.minTapTarget,
          width: 28,
          child: Center(
            child: Text(
              'Stk.',
              maxLines: 1,
              softWrap: false,
              overflow: TextOverflow.visible,
              style: AppTypography.listNumber.copyWith(
                fontSize: 11,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
