import 'package:flutter/material.dart';
import '../../enums/category.dart';
import '../tokens/app_colors.dart';
import '../tokens/app_typography.dart';

class CategoryBadge extends StatelessWidget {
  const CategoryBadge({required this.category, super.key});

  final Category category;

  @override
  Widget build(BuildContext context) {
    final pair = AppColors.categoryColors[category]!;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
      decoration: BoxDecoration(
        color: pair.background,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        category.label.toUpperCase(),
        style: AppTypography.categoryBadgeLabel.copyWith(color: pair.text),
      ),
    );
  }
}
