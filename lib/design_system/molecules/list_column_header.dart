import 'package:flutter/material.dart';
import '../tokens/app_colors.dart';
import '../tokens/app_spacing.dart';
import '../tokens/app_typography.dart';

class ListColumnHeader extends StatelessWidget {
  const ListColumnHeader({required this.label, super.key});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: AppTypography.columnHeaderLabel.copyWith(
            color: AppColors.textTertiary,
          ),
        ),
        Divider(color: AppColors.divider, thickness: AppSpacing.dividerWeight),
      ],
    );
  }
}
