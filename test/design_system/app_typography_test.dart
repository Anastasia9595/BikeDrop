// test/design_system/app_typography_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bikedrop/design_system/app_colors.dart';
import 'package:bikedrop/design_system/app_typography.dart';

void main() {
  test('text styles match design doc weights/sizes/spacing', () {
    expect(AppTypography.screenTitle.fontFamily, 'Archivo');
    expect(AppTypography.screenTitle.fontWeight, FontWeight.w800);
    expect(AppTypography.screenTitle.fontSize, 24);
    expect(AppTypography.screenTitle.letterSpacing, closeTo(-0.48, 0.001));

    expect(AppTypography.loginWordmark.fontWeight, FontWeight.w800);
    expect(AppTypography.loginWordmark.fontSize, 44);
    expect(AppTypography.loginWordmark.letterSpacing, closeTo(-1.32, 0.001));

    expect(AppTypography.body.fontWeight, FontWeight.w400);
    expect(AppTypography.body.fontSize, 15);
    expect(AppTypography.body.height, 1.5);

    expect(AppTypography.fieldLabel.fontWeight, FontWeight.w600);
    expect(AppTypography.fieldLabel.fontSize, 13);
    expect(AppTypography.fieldLabel.letterSpacing, closeTo(0.52, 0.001));
    expect(AppTypography.fieldLabel.color, AppColors.textSecondary);

    expect(AppTypography.sectionKicker.fontWeight, FontWeight.w800);
    expect(AppTypography.sectionKicker.fontSize, 11);
    expect(AppTypography.sectionKicker.letterSpacing, closeTo(1.76, 0.001));

    expect(AppTypography.buttonLabel.fontWeight, FontWeight.w800);
    expect(AppTypography.buttonLabel.fontSize, 17);

    expect(AppTypography.listNumber.fontWeight, FontWeight.w800);
    expect(AppTypography.listNumber.fontSize, 18);

    expect(AppTypography.secondaryButtonLabel.fontWeight, FontWeight.w700);
    expect(AppTypography.secondaryButtonLabel.fontSize, 14);

    expect(AppTypography.categoryBadgeLabel.fontWeight, FontWeight.w700);
    expect(AppTypography.categoryBadgeLabel.fontSize, 10);
    expect(AppTypography.categoryBadgeLabel.letterSpacing, closeTo(0.4, 0.001));
  });
}
