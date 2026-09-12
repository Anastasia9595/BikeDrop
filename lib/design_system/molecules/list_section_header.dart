import 'package:flutter/material.dart';

import '../tokens/app_colors.dart';
import '../tokens/app_spacing.dart';
import '../tokens/app_typography.dart';

/// Ueberschrift eines Abschnitts einer gruppierten Liste (z.B. "Ergänzung
/// nötig (3)") — rein informativ, kein eigenes Tap-Ziel.
class ListSectionHeader extends StatelessWidget {
  const ListSectionHeader({
    required this.title,
    required this.count,
    super.key,
  });

  final String title;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenPaddingH,
        12,
        AppSpacing.screenPaddingH,
        8,
      ),
      child: Text(
        '${title.toUpperCase()} ($count)',
        style: AppTypography.listTile.copyWith(color: AppColors.textPrimary),
      ),
    );
  }
}
