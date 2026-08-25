import 'package:flutter/material.dart';

import '../design_system.dart';

class TextDivider extends StatelessWidget {
  final String text;
  const TextDivider({required this.text, super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(child: Divider()),
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 8,
            vertical: AppSpacing.screenSpacingV,
          ),
          child: Text(
            text,
            style: TextStyle(
              fontSize: AppTypography.sectionKicker.fontSize,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        const Expanded(child: Divider(color: AppColors.divider)),
      ],
    );
  }
}
