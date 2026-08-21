import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bikedrop/design_system/tokens/app_colors.dart';
import 'package:bikedrop/enums/category.dart';

void main() {
  test('core palette matches design doc hex values', () {
    expect(AppColors.accent, const Color(0xFFEC3013));
    expect(AppColors.accentHover, const Color(0xFFDD2B0F));
    expect(AppColors.accentPressed, const Color(0xFFAE1800));
    expect(AppColors.accentTint, const Color(0xFFFFF2EF));
    expect(AppColors.textPrimary, const Color(0xFF201E1D));
    expect(AppColors.textSecondary, const Color(0xFF605D5D));
    expect(AppColors.textTertiary, const Color(0xFF7D7979));
    expect(AppColors.textQuaternary, const Color(0xFF9B9797));
    expect(AppColors.textQuaternaryLight, const Color(0xFFBAB6B6));
    expect(AppColors.border, const Color(0xFFD7D3D3));
    expect(AppColors.divider, const Color(0xFFEAE7E7));
    expect(AppColors.surface, const Color(0xFFF8F4F4));
    expect(AppColors.surfaceDark, const Color(0xFFEAE7E7));
    expect(AppColors.white, const Color(0xFFFFFFFF));
    expect(AppColors.snackbarBg, const Color(0xFF201E1D));
    expect(AppColors.snackbarAccent, const Color(0xFFFF9783));
  });

  test('category color pairs match design doc table', () {
    expect(AppColors.categoryColors[Category.bremsen]!.background, const Color(0xFFFFE0D9));
    expect(AppColors.categoryColors[Category.bremsen]!.text, const Color(0xFF7C1405));
    expect(AppColors.categoryColors[Category.reifen]!.background, const Color(0xFFE2EEFC));
    expect(AppColors.categoryColors[Category.reifen]!.text, const Color(0xFF1A4A8A));
    expect(AppColors.categoryColors[Category.eBike]!.background, const Color(0xFFE6F0E0));
    expect(AppColors.categoryColors[Category.eBike]!.text, const Color(0xFF33591F));
    expect(AppColors.categoryColors[Category.zubehoer]!.background, const Color(0xFFF3E8FB));
    expect(AppColors.categoryColors[Category.zubehoer]!.text, const Color(0xFF5C2A8A));
    expect(AppColors.categoryColors[Category.pflege]!.background, const Color(0xFFFDF1CF));
    expect(AppColors.categoryColors[Category.pflege]!.text, const Color(0xFF8A5A00));
  });
}
