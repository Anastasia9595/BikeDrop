// lib/design_system/atoms/app_icon_button.dart
import 'package:flutter/material.dart';
import '../tokens/app_colors.dart';
import '../tokens/app_spacing.dart';

class AppIconButton extends StatelessWidget {
  const AppIconButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    super.key,
  });

  final IconData icon;

  /// Wird als Tooltip und zugleich als Screenreader-Label verwendet.
  final String tooltip;

  /// `null` schaltet den Button inaktiv.
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      tooltip: tooltip,
      icon: Icon(icon),
      iconSize: AppSpacing.iconSize,
      color: AppColors.textPrimary,
      disabledColor: AppColors.textQuaternaryLight,
      constraints: const BoxConstraints(
        minWidth: AppSpacing.minTapTarget,
        minHeight: AppSpacing.minTapTarget,
      ),
    );
  }
}
