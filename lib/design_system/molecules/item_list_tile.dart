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
    required this.timestampLabel,
    this.image,
    this.onTap,
    super.key,
  });

  final String title;
  final int quantity;
  final Category category;
  final String timestampLabel;
  final ImageProvider? image;
  final VoidCallback? onTap;

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
                    Text(
                      timestampLabel,
                      style: AppTypography.body.copyWith(
                        fontSize: 12,
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(width: AppSpacing.listRowGap),
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$quantity',
                style: AppTypography.listNumber.copyWith(color: AppColors.textPrimary),
              ),
              const SizedBox(height: 4),
              Icon(
                Symbols.visibility,
                size: AppTypography.listNumber.fontSize,
                color: AppColors.accent,
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
      child: onTap != null
          ? Material(
              type: MaterialType.transparency,
              child: InkWell(onTap: onTap, child: content),
            )
          : content,
    );
  }
}
