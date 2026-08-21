import 'package:flutter/material.dart';
import '../tokens/app_colors.dart';
import '../tokens/app_spacing.dart';
import '../tokens/app_typography.dart';

class AppPrimaryButton extends StatelessWidget {
  const AppPrimaryButton({
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
    final disabled = onPressed == null;

    return Opacity(
      opacity: disabled ? 0.45 : 1.0,
      child: Container(
        width: double.infinity,
        height: AppSpacing.primaryButtonHeight,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppSpacing.buttonRadius),
          boxShadow:
              disabled
                  ? const []
                  : [
                    BoxShadow(
                      color: AppColors.accent.withValues(alpha: 0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 9),
                    ),
                  ],
        ),
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.accent,
            disabledBackgroundColor: AppColors.accent,
            foregroundColor: AppColors.white,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSpacing.buttonRadius),
            ),
            padding: EdgeInsets.symmetric(
              horizontal: AppSpacing.screenPaddingH,
            ),
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
                    color: AppColors.white,
                  ),
                ),
              ),
              if (icon != null)
                Icon(
                  icon,
                  size: AppTypography.buttonLabel.fontSize! * 1.5,
                  weight: 700,
                  color: AppColors.white,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
