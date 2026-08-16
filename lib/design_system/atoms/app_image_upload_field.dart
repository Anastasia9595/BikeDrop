// lib/design_system/atoms/app_image_upload_field.dart
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:dotted_border/dotted_border.dart';
import '../tokens/app_colors.dart';
import '../tokens/app_spacing.dart';
import '../tokens/app_typography.dart';

class AppImageUploadField extends StatelessWidget {
  const AppImageUploadField({required this.onTap, super.key});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
      child: DottedBorder(
        options: RoundedRectDottedBorderOptions(
          radius: Radius.circular(AppSpacing.cardRadius),
          color: AppColors.border,
          dashPattern: const [10, 5],
          strokeWidth: 2,
        ),
        child: SizedBox(
          width: double.infinity,
          height: AppSpacing.imageUploadFieldHeight,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: const BoxDecoration(
                  color: AppColors.surfaceDark,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Symbols.image,
                  size: AppSpacing.iconSize,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Zum Hochladen klicken',
                style: AppTypography.secondaryButtonLabel.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'JPG, PNG (max. 2 MB)',
                style: AppTypography.body.copyWith(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
