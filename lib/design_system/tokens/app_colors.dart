import 'package:flutter/material.dart';

enum Category { bremsen, reifen, eBike, zubehoer, pflege }

extension CategoryLabel on Category {
  String get label => switch (this) {
    Category.bremsen => 'Bremsen',
    Category.reifen => 'Reifen',
    Category.eBike => 'E-Bike',
    Category.zubehoer => 'Zubehör',
    Category.pflege => 'Pflege',
  };
}

enum ItemStatus { imShop, fehlt, bestellt }

extension ItemStatusLabel on ItemStatus {
  String get label => switch (this) {
    ItemStatus.imShop => 'Im Shop',
    ItemStatus.bestellt => 'Bestellt',
    ItemStatus.fehlt => 'Fehlt',
  };
}

class CategoryColorPair {
  const CategoryColorPair(this.background, this.text);

  final Color background;
  final Color text;
}

class AppColors {
  const AppColors._();

  static const Color accent = Color(0xFFEC3013);
  static const Color accentHover = Color(0xFFDD2B0F);
  static const Color accentPressed = Color(0xFFAE1800);
  static const Color accentTint = Color(0xFFFFF2EF);

  static const Color statusColorSuccess = Color(0xFF2D9B4A);
  static const Color statusColorWarning = Color(0xFFF2C94C);
  static const Color statusColorError = Color(0xFFEB5757);

  static const Color textPrimary = Color(0xFF201E1D);
  static const Color textSecondary = Color(0xFF605D5D);
  static const Color textTertiary = Color(0xFF7D7979);
  static const Color textQuaternary = Color(0xFF9B9797);
  static const Color textQuaternaryLight = Color(0xFFBAB6B6);

  static const Color border = Color(0xFFD7D3D3);
  static const Color divider = Color(0xFFEAE7E7);
  static const Color surface = Color(0xFFF8F4F4);
  static const Color surfaceDark = Color(0xFFEAE7E7);
  static const Color white = Color(0xFFFFFFFF);

  static const Color snackbarBg = Color(0xFF201E1D);
  static const Color snackbarAccent = Color(0xFFFF9783);

  static const Map<Category, CategoryColorPair> categoryColors = {
    Category.bremsen: CategoryColorPair(Color(0xFFFFE0D9), Color(0xFF7C1405)),
    Category.reifen: CategoryColorPair(Color(0xFFE2EEFC), Color(0xFF1A4A8A)),
    Category.eBike: CategoryColorPair(Color(0xFFE6F0E0), Color(0xFF33591F)),
    Category.zubehoer: CategoryColorPair(Color(0xFFF3E8FB), Color(0xFF5C2A8A)),
    Category.pflege: CategoryColorPair(Color(0xFFFDF1CF), Color(0xFF8A5A00)),
  };

  static const Map<ItemStatus, Color> statusColors = {
    ItemStatus.imShop: statusColorSuccess,
    ItemStatus.bestellt: statusColorWarning,
    ItemStatus.fehlt: statusColorError,
  };
}
