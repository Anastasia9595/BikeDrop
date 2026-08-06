import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:bikedrop/design_system/design_system.dart';

class OverviewScreen extends StatelessWidget {
  const OverviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Bestand', style: AppTypography.screenTitle)),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.screenPaddingH,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,

                    children: [
                      DottedBorder(
                        options: RoundedRectDottedBorderOptions(
                          radius: const Radius.circular(12),
                          color: AppColors.border,
                          dashPattern: [10, 5],
                          strokeWidth: 2,
                          padding: EdgeInsets.all(16),
                        ),
                        child: Icon(
                          Symbols.package_2,
                          size: AppSpacing.iconButtonSize,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Noch kein Bestand erfasst',
                        style: AppTypography.heading.copyWith(
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Fügen Sie jetzt Ihren ersten Artikel hinzu, um den Überblick zu behalten.',
                        textAlign: TextAlign.center,
                        style: AppTypography.body.copyWith(
                          color: AppColors.textSecondary,
                          fontSize: 17,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              AppPrimaryButton(
                label: 'Get Started',
                icon: Symbols.add,
                onPressed: () {
                  // Handle get started action
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
