import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bikedrop/design_system/app_colors.dart';
import 'package:bikedrop/design_system/app_spacing.dart';
import 'package:bikedrop/design_system/app_theme.dart';

void main() {
  test('AppTheme.light wires tokens into ThemeData', () {
    final theme = AppTheme.light();

    expect(theme.colorScheme.primary, AppColors.accent);
    expect(theme.colorScheme.error, AppColors.accent);
    expect(theme.colorScheme.surface, AppColors.white);
    expect(theme.scaffoldBackgroundColor, AppColors.surface);
    expect(theme.dividerTheme.color, AppColors.divider);
    expect(theme.dividerTheme.thickness, AppSpacing.dividerWeight);

    final inputBorder =
        theme.inputDecorationTheme.enabledBorder as OutlineInputBorder;
    expect(inputBorder.borderSide.color, AppColors.border);
    expect(inputBorder.borderSide.width, AppSpacing.fieldBorderWidth);
    expect(
      inputBorder.borderRadius,
      BorderRadius.circular(AppSpacing.buttonRadius),
    );

    expect(theme.snackBarTheme.backgroundColor, AppColors.snackbarBg);
  });
}
