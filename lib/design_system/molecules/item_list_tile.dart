import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
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
    super.key,
  });

  final String title;
  final int quantity;
  final Category category;
  final ImageProvider? image;
  final VoidCallback? onTap;
  final ItemStatus status;

  String get _statusLabel => switch (status) {
    ItemStatus.imShop => 'Im Shop',
    ItemStatus.fehlt => 'Fehlt',
    ItemStatus.bestellt => 'Bestellt',
  };

  @override
  Widget build(BuildContext context) {
    final thumbnailImage = image;

    final content = Padding(
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
              width: AppSpacing.iconButtonSize,
              height: AppSpacing.iconButtonSize,
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
                  children: [
                    CategoryBadge(category: category),
                    const SizedBox(width: 8),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: AppColors.statusColors[status]!,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _statusLabel,
                          style: AppTypography.body.copyWith(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                '$quantity',
                style: AppTypography.listNumber.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                'Stk.',
                style: AppTypography.listNumber.copyWith(
                  fontSize: 12,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ],
      ),
    );

    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
      ),
      clipBehavior: Clip.antiAlias,
      child:
          onTap != null
              ? Material(
                type: MaterialType.transparency,
                child: InkWell(onTap: onTap, child: content),
              )
              : content,
    );
  }
}
