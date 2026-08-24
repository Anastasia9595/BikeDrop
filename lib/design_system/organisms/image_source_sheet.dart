import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../enums/image_source_option.dart';
import '../tokens/app_colors.dart';
import '../tokens/app_spacing.dart';
import '../tokens/app_typography.dart';

/// Bottom Sheet zur Auswahl der Bildquelle (S6 – Artikelbild).
/// Gibt die gewaehlte Quelle zurueck bzw. null, wenn abgebrochen wurde.
class ImageSourceSheet {
  const ImageSourceSheet._();

  static Future<ImageSourceOption?> show(BuildContext context) {
    return showModalBottomSheet<ImageSourceOption>(
      context: context,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSpacing.dialogRadius),
        ),
      ),
      builder: (context) => const _ImageSourceSheetContent(),
    );
  }
}

class _ImageSourceSheetContent extends StatelessWidget {
  const _ImageSourceSheetContent();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: AppSpacing.screenSpacingV,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.screenPaddingH,
              ),
              child: Text('Bild hinzufügen', style: AppTypography.heading),
            ),
            const SizedBox(height: AppSpacing.fieldGap),
            _SourceTile(
              icon: Symbols.photo_camera,
              label: 'Foto aufnehmen',
              source: ImageSourceOption.camera,
            ),
            _SourceTile(
              icon: Symbols.photo_library,
              label: 'Aus Galerie wählen',
              source: ImageSourceOption.gallery,
            ),
          ],
        ),
      ),
    );
  }
}

class _SourceTile extends StatelessWidget {
  const _SourceTile({
    required this.icon,
    required this.label,
    required this.source,
  });

  final IconData icon;
  final String label;
  final ImageSourceOption source;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.screenPaddingH,
      ),
      leading: Icon(
        icon,
        size: AppSpacing.iconSize,
        color: AppColors.textPrimary,
      ),
      title: Text(
        label,
        style: AppTypography.body.copyWith(color: AppColors.textPrimary),
      ),
      onTap: () => Navigator.of(context).pop(source),
    );
  }
}
