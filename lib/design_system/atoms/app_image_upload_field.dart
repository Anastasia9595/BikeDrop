// lib/design_system/atoms/app_image_upload_field.dart
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:dotted_border/dotted_border.dart';
import '../tokens/app_colors.dart';
import '../tokens/app_spacing.dart';
import '../tokens/app_typography.dart';

class AppImageUploadField extends StatelessWidget {
  const AppImageUploadField({required this.onTap, this.image, super.key});

  final VoidCallback onTap;

  /// Wenn gesetzt, wird das Bild anstelle des Upload-Platzhalters
  /// angezeigt. Bleibt weiterhin über [onTap] antippbar (z. B. um das
  /// Bild zu ändern). Woher das Bild kommt (Netzwerk, lokale Datei)
  /// entscheidet der Aufrufer.
  final ImageProvider? image;

  @override
  Widget build(BuildContext context) {
    final image = this.image;
    if (image != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
          child: Image(
            image: image,
            width: double.infinity,
            height: AppSpacing.imageUploadFieldHeight,
            fit: BoxFit.cover,
          ),
        ),
      );
    }

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
