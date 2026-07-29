import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTypography {
  const AppTypography._();

  static const String fontFamily = 'Archivo';

  static const TextStyle screenTitle = TextStyle(
    fontFamily: fontFamily,
    fontWeight: FontWeight.w800,
    fontSize: 24,
    letterSpacing: -0.48,
  );

  static const TextStyle loginWordmark = TextStyle(
    fontFamily: fontFamily,
    fontWeight: FontWeight.w800,
    fontSize: 44,
    letterSpacing: -1.32,
  );

  static const TextStyle body = TextStyle(
    fontFamily: fontFamily,
    fontWeight: FontWeight.w400,
    fontSize: 15,
    height: 1.5,
  );

  static const TextStyle fieldLabel = TextStyle(
    fontFamily: fontFamily,
    fontWeight: FontWeight.w600,
    fontSize: 13,
    letterSpacing: 0.52,
    color: AppColors.textSecondary,
  );

  static const TextStyle sectionKicker = TextStyle(
    fontFamily: fontFamily,
    fontWeight: FontWeight.w800,
    fontSize: 11,
    letterSpacing: 1.76,
  );

  static const TextStyle buttonLabel = TextStyle(
    fontFamily: fontFamily,
    fontWeight: FontWeight.w800,
    fontSize: 17,
  );

  static const TextStyle listNumber = TextStyle(
    fontFamily: fontFamily,
    fontWeight: FontWeight.w800,
    fontSize: 18,
  );

  static const TextStyle secondaryButtonLabel = TextStyle(
    fontFamily: fontFamily,
    fontWeight: FontWeight.w700,
    fontSize: 14,
  );

  static const TextStyle categoryBadgeLabel = TextStyle(
    fontFamily: fontFamily,
    fontWeight: FontWeight.w700,
    fontSize: 10,
    letterSpacing: 0.4,
  );

  static const TextStyle columnHeaderLabel = TextStyle(
    fontFamily: fontFamily,
    fontWeight: FontWeight.w700,
    fontSize: 11,
  );
}
