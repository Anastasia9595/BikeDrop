import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_spacing.dart';
import 'app_typography.dart';

class AppTheme {
  const AppTheme._();

  static ThemeData light() {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.accent,
      brightness: Brightness.light,
    ).copyWith(
      primary: AppColors.accent,
      error: AppColors.accent,
      surface: AppColors.white,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.surface,
      fontFamily: AppTypography.fontFamily,
      textTheme: const TextTheme(
        titleLarge: AppTypography.screenTitle,
        displayLarge: AppTypography.loginWordmark,
        bodyMedium: AppTypography.body,
        labelSmall: AppTypography.fieldLabel,
        labelLarge: AppTypography.buttonLabel,
      ),
      dividerTheme: DividerThemeData(
        color: AppColors.divider,
        thickness: AppSpacing.dividerWeight,
        space: AppSpacing.dividerWeight,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accent,
          foregroundColor: AppColors.white,
          minimumSize: Size.fromHeight(AppSpacing.primaryButtonHeight),
          textStyle: AppTypography.buttonLabel,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.buttonRadius),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.textPrimary,
          side: BorderSide(
            color: AppColors.border,
            width: AppSpacing.fieldBorderWidth,
          ),
          minimumSize: Size.fromHeight(AppSpacing.primaryButtonHeight),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.buttonRadius),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: false,
        contentPadding: EdgeInsets.symmetric(
          horizontal: AppSpacing.screenPaddingH,
          vertical: (AppSpacing.fieldHeight - AppTypography.body.fontSize!) / 2,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.buttonRadius),
          borderSide: BorderSide(
            color: AppColors.border,
            width: AppSpacing.fieldBorderWidth,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.buttonRadius),
          borderSide: BorderSide(
            color: AppColors.accent,
            width: AppSpacing.fieldBorderWidth,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.buttonRadius),
          borderSide: BorderSide(
            color: AppColors.accent,
            width: AppSpacing.fieldBorderWidth,
          ),
        ),
        labelStyle: AppTypography.fieldLabel,
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (states) =>
              states.contains(WidgetState.selected)
                  ? AppColors.white
                  : AppColors.white,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (states) =>
              states.contains(WidgetState.selected)
                  ? AppColors.accent
                  : AppColors.border,
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.snackbarBg,
        contentTextStyle: AppTypography.body.copyWith(color: AppColors.white),
        actionTextColor: AppColors.snackbarAccent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
