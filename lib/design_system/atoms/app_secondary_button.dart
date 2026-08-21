import 'package:flutter/material.dart';
import '../tokens/app_colors.dart';
import '../tokens/app_spacing.dart';
import '../tokens/app_typography.dart';

class AppSecondaryButton extends StatelessWidget {
  const AppSecondaryButton({
    required this.label,
    required this.onPressed,
    this.icon,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: AppSpacing.primaryButtonHeight,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: AppColors.white,
          foregroundColor: AppColors.textPrimary,
          side: BorderSide(
            color: AppColors.border,
            width: AppSpacing.fieldBorderWidth,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.buttonRadius),
          ),
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.screenPaddingH),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                textAlign: icon == null ? TextAlign.center : TextAlign.start,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.buttonLabel.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            if (icon != null)
              Icon(
                icon,
                size: AppSpacing.iconSize,
                weight: 700,
                color: AppColors.textPrimary,
              ),
          ],
        ),
      ),
    );
  }
}
