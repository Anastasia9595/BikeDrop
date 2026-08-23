import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import '../../enums/category.dart';
import '../../enums/article_status.dart';
import '../atoms/category_badge.dart';
import '../tokens/app_colors.dart';
import '../tokens/app_spacing.dart';
import '../tokens/app_typography.dart';

class ItemListTile extends StatelessWidget {
  const ItemListTile({
    required this.title,
    required this.quantity,
    required this.category,
    this.image,
    this.onTap,
    required this.status,
    this.reorderedQuantity,
    this.isPublic = true,
    super.key,
  });

  final String title;
  final int quantity;
  final Category category;
  final ImageProvider? image;
  final VoidCallback? onTap;
  final ArticleStatus status;

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
        return _StatusIndicator(
          color: AppColors.statusColors[ArticleStatus.fehlt]!,
          label: ArticleStatus.fehlt.label,
        );
      case ArticleStatus.bestellt:
        return _StatusIndicator(
          color: AppColors.statusColors[ArticleStatus.bestellt]!,
          label: 'Bestellt +${reorderedQuantity ?? 0}',
        );
    }
  }

  /// Sichtbarkeits-Status-Slot. Null im Normalfall (online sichtbar).
  Widget? _buildVisibilityStatus() {
    if (isPublic) return null;
    return const _StatusIndicator(
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
                child:
                    thumbnailImage != null
                        ? Image(image: thumbnailImage, fit: BoxFit.cover)
                        : Icon(
                          Symbols.image,
                          color: AppColors.textQuaternaryLight,
                        ),
              ),
            ),
            SizedBox(width: AppSpacing.listRowGap),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      CategoryBadge(category: category),
                      if (stockStatus != null) ...[
                        const SizedBox(width: 12),
                        stockStatus,
                      ],
                      if (visibilityStatus != null) ...[
                        SizedBox(width: stockStatus != null ? 8 : 12),
                        visibilityStatus,
                      ],
                    ],
                  ),
                ],
              ),
            ),
            _QuantityDisplay(quantity: quantity),
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

/// Mengenanzeige rechts in der Zeile: Zahl mit tabellarischen Ziffern,
/// damit die Spalte beim Scrollen nicht durch unterschiedlich breite
/// Ziffern flimmert, plus kleineres graues Einheiten-Label.
class _QuantityDisplay extends StatelessWidget {
  const _QuantityDisplay({required this.quantity});

  final int quantity;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          '$quantity',
          style: AppTypography.listNumber.copyWith(
            color: AppColors.textPrimary,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
        const SizedBox(width: 4),
        Text(
          'Stk.',
          style: AppTypography.listNumber.copyWith(
            fontSize: 11,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

/// Ein einzelner Status-Slot in der Meta-Zeile: Punkt oder Icon in der
/// Status-Farbe, Label immer in der bisherigen sekundären Textfarbe.
/// Farbe ist damit nie der einzige Träger — das Label steht immer daneben.
class _StatusIndicator extends StatelessWidget {
  const _StatusIndicator({required this.color, required this.label, this.icon});

  final Color color;
  final String label;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final marker =
        icon != null
            ? Icon(icon, size: 14, color: color)
            : Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            );

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        marker,
        const SizedBox(width: 6),
        Text(
          label,
          style: AppTypography.body.copyWith(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}
