import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../enums/receiving_scan_status.dart';
import '../../models/receivingcartitem.dart';
import '../tokens/app_colors.dart';
import '../tokens/app_spacing.dart';
import '../tokens/app_typography.dart';
import 'quantity_stepper.dart';

/// Eine gescannte Position im Wareneingangs-Warenkorb: farbiger Status-Kreis,
/// Name + EAN, und rechts entweder ein Mengen-Steller (bekannt/Katalog) oder
/// ein "Anlegen"-Button (unbekannt). Passt nicht zu [ItemListTile] — das hat
/// Kategorie-Badge/Thumbnail/`QuantityDisplay` fest verdrahtet und kennt
/// weder EAN-Untertitel noch den Status-Kreis.
class ReceivingCartItemTile extends StatelessWidget {
  const ReceivingCartItemTile({
    required this.item,
    required this.onQuantityChanged,
    required this.onAnlegenTap,
    super.key,
  });

  final ReceivingCartItem item;
  final ValueChanged<int> onQuantityChanged;
  final VoidCallback onAnlegenTap;

  String get _name {
    final resolved = item.resolvedArticle;
    if (resolved != null) return resolved.name;
    final catalog = item.catalogData;
    if (catalog != null) return catalog.name;
    return item.suggestedName ?? 'Unbekannter Artikel';
  }

  IconData get _icon => switch (item.scanStatus) {
    ReceivingScanStatus.inStock => Symbols.check_circle,
    ReceivingScanStatus.catalogMatch => Symbols.grid_view,
    ReceivingScanStatus.unknown => Symbols.question_mark_rounded,
  };

  @override
  Widget build(BuildContext context) {
    final status = item.scanStatus;
    final color = AppColors.receivingStatusColors[status]!;
    final isUnknown = status == ReceivingScanStatus.unknown;

    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: AppSpacing.listRowMinHeight),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.screenPaddingH,
          vertical: AppSpacing.listRowPaddingV,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: AppSpacing.listThumbnailSize,
              height: AppSpacing.listThumbnailSize,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Icon(_icon, color: color, size: AppSpacing.iconSize),
            ),
            const SizedBox(width: AppSpacing.listRowGap),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.body.copyWith(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'EAN ${item.ean}',
                    style: AppTypography.body.copyWith(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.listRowGap),
            if (isUnknown)
              SizedBox(
                width: 120,
                height: AppSpacing.fieldHeight,
                child: OutlinedButton(
                  onPressed: onAnlegenTap,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.textPrimary,
                    minimumSize: Size.zero,
                    side: const BorderSide(
                      color: AppColors.border,
                      width: AppSpacing.fieldBorderWidth,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        AppSpacing.buttonRadius,
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Symbols.add,
                        size: 14,
                        color: AppColors.textPrimary,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        'Anlegen',
                        style: AppTypography.secondaryButtonLabel.copyWith(
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              SizedBox(
                width: 120,
                child: QuantityStepper(
                  label: 'Menge',
                  showLabel: false,
                  quantity: item.quantity,
                  min: 1,
                  onChanged: onQuantityChanged,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
