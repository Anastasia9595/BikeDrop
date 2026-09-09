import 'package:flutter/material.dart';

import '../../enums/category.dart';
import '../../enums/article_status.dart';
import '../../enums/receiving_scan_status.dart';

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

  /// Akzentfarbe fuer den "Katalogartikel"-Button im Wareneingang-Grid — kein
  /// Status, deshalb kein statusColor*, sondern ein eigener Info-Ton.
  static const Color infoBlue = Color(0xFF3B82F6);

  /// Amper-Gelb fuer die Ampel-Optik (Gruen/Gelb/Rot). Da die Farbe im
  /// KpiFilterCard nur noch als Punkt neben dunklem Text erscheint (kein
  /// weisser Text mehr direkt auf der Flaeche), ist ein kraeftiges,
  /// erkennbares Gelb statt eines gedeckten Braun-Tons moeglich.
  static const Color statusColorWarning = Color(0xFFF2A900);
  static const Color statusColorError = Color(0xFFEB5757);

  static const Color textPrimary = Color(0xFF201E1D);
  static const Color textSecondary = Color(0xFF605D5D);
  static const Color textTertiary = Color(0xFF7D7979);
  static const Color textQuaternary = Color(0xFF9B9797);
  static const Color textQuaternaryLight = Color(0xFFBAB6B6);
  static const Color textError = Color(0xFFEB5757);

  static const Color border = Color(0xFFD7D3D3);
  static const Color divider = Color(0xFFEAE7E7);

  /// Trennlinie zwischen Zeilen in der flachen Artikelliste.
  static const Color listDivider = Color(0xFFE5E5E5);
  static const Color surface = Color(0xFFF8F4F4);
  static const Color surfaceDark = Color(0xFFEAE7E7);
  static const Color white = Color(0xFFFFFFFF);

  static const Color snackbarBg = Color(0xFF201E1D);
  static const Color snackbarAccent = Color(0xFFFF9783);

  static const Map<Category, CategoryColorPair> categoryColors = {
    Category.bremsen: CategoryColorPair(Color(0xFFFFE0D9), Color(0xFF7C1405)),
    Category.antrieb: CategoryColorPair(Color(0xFFFDE8D2), Color(0xFF8A4A00)),
    Category.reifen: CategoryColorPair(Color(0xFFE2EEFC), Color(0xFF1A4A8A)),
    Category.eBike: CategoryColorPair(Color(0xFFE6F0E0), Color(0xFF33591F)),
    Category.laufraeder: CategoryColorPair(
      Color(0xFFE2F5F2),
      Color(0xFF0F6B5C),
    ),
    Category.zubehoer: CategoryColorPair(Color(0xFFF3E8FB), Color(0xFF5C2A8A)),
    Category.pflege: CategoryColorPair(Color(0xFFFDF1CF), Color(0xFF8A5A00)),
  };

  static const Map<ArticleStatus, Color> statusColors = {
    ArticleStatus.inStock: statusColorSuccess,
    ArticleStatus.bestellt: statusColorWarning,
    ArticleStatus.fehlt: statusColorError,
  };

  /// Zarter Hintergrundton je Status fuer den ausgewaehlten Zustand des
  /// KpiFilterCard-Chips — die Statusfarbe selbst waere als Flaeche zu
  /// kraeftig, hier soll nur ein Hauch Farbe hinter Punkt, Label und Rahmen
  /// liegen.
  static const Map<ArticleStatus, Color> statusColorTints = {
    ArticleStatus.inStock: Color(0xFFEAF6ED),
    ArticleStatus.bestellt: Color(0xFFF5EDE0),
    ArticleStatus.fehlt: Color(0xFFFCEAEA),
  };

  /// Vordergrundfarbe *auf* der gesaettigten Statusfarbe — z. B. in der
  /// KpiFilterCard. Alle drei Statusfarben sind inzwischen dunkel genug
  /// fuer Weiss (>= 4.5:1).
  static const Map<ArticleStatus, Color> statusOnColors = {
    ArticleStatus.inStock: white,
    ArticleStatus.bestellt: white,
    ArticleStatus.fehlt: white,
  };

  /// Punktfarbe je [ReceivingScanStatus] im Wareneingangs-Warenkorb —
  /// dieselben Töne wie die Demo-Szenario-Buttons im Scanner-Grid, damit
  /// Button und Zeilen-Icon optisch zusammengehören.
  static const Map<ReceivingScanStatus, Color> receivingStatusColors = {
    ReceivingScanStatus.inStock: statusColorSuccess,
    ReceivingScanStatus.catalogMatch: infoBlue,
    ReceivingScanStatus.unknown: statusColorWarning,
  };

  static const Map<ReceivingScanStatus, Color> receivingStatusTints = {
    ReceivingScanStatus.inStock: Color(0xFFEAF6ED),
    ReceivingScanStatus.catalogMatch: Color(0xFFE2EEFC),
    ReceivingScanStatus.unknown: Color(0xFFF5EDE0),
  };
}
