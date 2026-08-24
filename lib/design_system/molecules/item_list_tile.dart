import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import '../../enums/category.dart';
import '../../enums/article_status.dart';
import '../atoms/category_badge.dart';
import '../atoms/quantity_display.dart';
import '../atoms/status_indicator.dart';
import '../tokens/app_colors.dart';
import '../tokens/app_spacing.dart';
import '../tokens/app_typography.dart';

class ItemListTile extends StatelessWidget {
  const ItemListTile({
    required this.title,
    required this.quantity,
    required this.category,
    required this.unit,
    this.image,
    this.onTap,
    required this.status,
    this.reorderedQuantity,
    this.isPublic = true,
    this.onQuantityTap,
    super.key,
  });

  final String title;
  final int quantity;
  final String unit;
  final Category category;
  final ImageProvider? image;
  final VoidCallback? onTap;
  final ArticleStatus status;

  /// Öffnet das Mengen-Bearbeiten-Bottom-Sheet (S2). Der Tap wird vom
  /// inneren InkWell konsumiert und schlägt nicht auf [onTap] durch.
  final VoidCallback? onQuantityTap;

  /// Nachbestellte Menge, relevant nur bei [ArticleStatus.bestellt].
  final int? reorderedQuantity;

  /// Ob der Artikel für Kunden im Shop sichtbar ist. Normalfall ist
  /// sichtbar (true) — der Sichtbarkeits-Status wird nur bei false angezeigt.
  final bool isPublic;

  /// Bestand-Status-Slot. Null im Normalfall (vorrätig), da die
  /// Mengenanzeige diesen Fall bereits abdeckt.
  Widget? _buildStockStatus() {
    switch (status) {
      case ArticleStatus.inStock:
        return null;
      case ArticleStatus.fehlt:
        return StatusIndicator(
          color: AppColors.statusColors[ArticleStatus.fehlt]!,
          label: ArticleStatus.fehlt.label,
        );
      case ArticleStatus.bestellt:
        return StatusIndicator(
          color: AppColors.statusColors[ArticleStatus.bestellt]!,
          label: 'Bestellt +${reorderedQuantity ?? 0}',
        );
    }
  }

  /// Sichtbarkeits-Status-Slot. Null im Normalfall (online sichtbar).
  Widget? _buildVisibilityStatus() {
    if (isPublic) return null;
    return const StatusIndicator(
      icon: Icons.visibility_off_outlined,
      color: AppColors.textSecondary,
      label: 'Nicht online',
    );
  }

  @override
  Widget build(BuildContext context) {
    final thumbnailImage = image;
    final stockStatus = _buildStockStatus();
    final visibilityStatus = _buildVisibilityStatus();

    final content = ConstrainedBox(
      constraints: const BoxConstraints(minHeight: AppSpacing.listRowMinHeight),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.screenPaddingH,
          vertical: AppSpacing.listRowPaddingV,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(AppSpacing.photoTileRadius),
              child: Container(
                width: AppSpacing.listThumbnailSize,
                height: AppSpacing.listThumbnailSize,
                color: AppColors.surface,
                alignment: Alignment.center,
                child: thumbnailImage != null
                    ? Image(image: thumbnailImage, fit: BoxFit.cover)
                    : Icon(Symbols.image, color: AppColors.textQuaternaryLight),
              ),
            ),
            SizedBox(width: AppSpacing.listRowGap),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (visibilityStatus != null) ...[
                    const SizedBox(height: 4),
                    visibilityStatus,
                  ],
                  Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.body.copyWith(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CategoryBadge(category: category),
                      if (stockStatus != null) ...[
                        const SizedBox(width: 12),
                        stockStatus,
                      ],
                    ],
                  ),
                ],
              ),
            ),
            QuantityDisplay(
              quantity: quantity,
              unit: unit,
              onTap: onQuantityTap,
            ),
          ],
        ),
      ),
    );

    return onTap != null
        ? Material(
            type: MaterialType.transparency,
            child: InkWell(onTap: onTap, child: content),
          )
        : content;
  }
}
