import 'package:flutter/material.dart';
import '../atoms/app_primary_button.dart';
import '../molecules/quantity_stepper.dart';
import '../tokens/app_colors.dart';
import '../tokens/app_spacing.dart';
import '../tokens/app_typography.dart';

/// Bottom Sheet zum Bearbeiten der Stückzahl eines Artikels (S2).
/// Kennt keine Domänenmodelle — Titel/Subtitel/Startwert kommen als
/// primitive Parameter vom Aufrufer, der neue Wert wird beim Bestätigen
/// zurückgegeben.
class QuantityEditSheet {
  const QuantityEditSheet._();

  static Future<int?> show(
    BuildContext context, {
    required String title,
    required String subtitle,
    required int initialQuantity,
    int min = 0,
    int? max,
  }) {
    return showModalBottomSheet<int>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSpacing.dialogRadius),
        ),
      ),
      builder:
          (context) => _QuantityEditSheetContent(
            title: title,
            subtitle: subtitle,
            initialQuantity: initialQuantity,
            min: min,
            max: max,
          ),
    );
  }
}

class _QuantityEditSheetContent extends StatefulWidget {
  const _QuantityEditSheetContent({
    required this.title,
    required this.subtitle,
    required this.initialQuantity,
    required this.min,
    this.max,
  });

  final String title;
  final String subtitle;
  final int initialQuantity;
  final int min;
  final int? max;

  @override
  State<_QuantityEditSheetContent> createState() =>
      _QuantityEditSheetContentState();
}

class _QuantityEditSheetContentState extends State<_QuantityEditSheetContent> {
  late int _quantity = widget.initialQuantity;

  int get _delta => _quantity - widget.initialQuantity;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: AppSpacing.screenPaddingH,
          right: AppSpacing.screenPaddingH,
          top: 12,
          bottom:
              AppSpacing.screenPaddingV +
              MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                widget.title,
                style: AppTypography.heading.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                widget.subtitle,
                style: AppTypography.body.copyWith(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                ),
              ),
            ),
            const SizedBox(height: 24),

            Align(
              alignment: Alignment.centerLeft,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text('MENGE', style: AppTypography.fieldLabel),
                  if (_delta != 0) ...[
                    const SizedBox(width: 8),
                    Text(
                      _delta > 0 ? '+$_delta' : '$_delta',
                      style: AppTypography.body.copyWith(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color:
                            _delta > 0
                                ? AppColors.statusColorSuccess
                                : AppColors.statusColorError,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 6),
            QuantityStepper(
              label: 'Menge',
              showLabel: false,
              showBorder: false,
              quantity: _quantity,
              editable: true,
              min: widget.min,
              max: widget.max,
              onChanged: (value) => setState(() => _quantity = value),
            ),

            const SizedBox(height: 24),
            AppPrimaryButton(
              label: 'Bestand auf $_quantity setzen',
              onPressed:
                  _delta != 0
                      ? () => Navigator.of(context).pop(_quantity)
                      : null,
            ),
          ],
        ),
      ),
    );
  }
}
