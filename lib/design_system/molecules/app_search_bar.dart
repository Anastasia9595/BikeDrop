import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import '../tokens/app_colors.dart';
import '../tokens/app_spacing.dart';
import '../tokens/app_typography.dart';

/// Gefülltes, pillenförmiges Suchfeld für Listen-Screens. Zeigt einen
/// Löschen-Button, sobald Text eingegeben wurde.
///
/// Der [controller] wird vom Aufrufer verwaltet (z. B. über einen
/// Riverpod-Provider) — dieses Widget besitzt ihn nicht und disposed ihn
/// nicht.
class AppSearchBar extends StatelessWidget {
  const AppSearchBar({
    required this.controller,
    this.onChanged,
    this.onClear,
    this.placeholder,
    super.key,
  });

  final TextEditingController controller;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onClear;
  final String? placeholder;

  void _clear() {
    controller.clear();
    onChanged?.call('');
    onClear?.call();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: AppSpacing.minTapTarget,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(
          color: AppColors.border,
          width: AppSpacing.fieldBorderWidth,
        ),
        borderRadius: BorderRadius.circular(AppSpacing.minTapTarget / 2),
      ),
      child: Row(
        children: [
          Icon(
            Symbols.search,
            size: AppSpacing.iconSize,
            color: AppColors.textSecondary,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              style: AppTypography.body.copyWith(color: AppColors.textPrimary),
              decoration: InputDecoration(
                isCollapsed: true,
                contentPadding: EdgeInsets.zero,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                errorBorder: InputBorder.none,
                disabledBorder: InputBorder.none,
                focusedErrorBorder: InputBorder.none,
                hintText: placeholder,
                hintStyle: AppTypography.body.copyWith(
                  color: AppColors.textQuaternary,
                ),
              ),
            ),
          ),
          ValueListenableBuilder<TextEditingValue>(
            valueListenable: controller,
            builder: (context, value, _) {
              if (value.text.isEmpty) return const SizedBox.shrink();
              return InkWell(
                onTap: _clear,
                customBorder: const CircleBorder(),
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: Icon(
                    Symbols.close,
                    size: AppSpacing.iconSize,
                    color: AppColors.textSecondary,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
