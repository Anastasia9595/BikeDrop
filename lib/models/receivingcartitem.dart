import 'article.dart';
import 'catalogarticle.dart';

/// Immutable model of a single position in the receiving cart (Wareneingang):
/// ein gescannter Barcode zusammen mit der Menge, die eingebucht werden soll.
///
/// [resolvedArticle] und [catalogData] beschreiben, was zu der [ean] bereits
/// bekannt ist: ein Artikel aus dem eigenen Bestand, Stammdaten aus dem
/// Katalog, oder — wenn beide null sind — ein noch unbekannter Barcode, der
/// beim Einbuchen manuell angelegt werden muss.
class ReceivingCartItem {
  const ReceivingCartItem({
    required this.ean,
    required this.quantity,
    this.resolvedArticle,
    this.catalogData,
  });

  /// Gescannter Barcode. Schluessel der Position und immer vorhanden.
  final String ean;

  /// Menge, die fuer diese [ean] eingebucht werden soll.
  final int quantity;

  /// Artikel aus dem eigenen Bestand, falls die [ean] dort gefunden wurde.
  /// Null, wenn der Artikel noch nicht im Bestand existiert.
  final Article? resolvedArticle;

  /// Stammdaten aus dem Katalog, falls die [ean] dort gefunden wurde.
  /// Null, wenn der Barcode im Katalog unbekannt ist.
  final CatalogArticle? catalogData;

  ReceivingCartItem copyWith({
    String? ean,
    int? quantity,
    Object? resolvedArticle = _unset,
    Object? catalogData = _unset,
  }) {
    return ReceivingCartItem(
      ean: ean ?? this.ean,
      quantity: quantity ?? this.quantity,
      resolvedArticle: identical(resolvedArticle, _unset)
          ? this.resolvedArticle
          : resolvedArticle as Article?,
      catalogData: identical(catalogData, _unset)
          ? this.catalogData
          : catalogData as CatalogArticle?,
    );
  }

  factory ReceivingCartItem.fromJson(Map<String, dynamic> json) {
    final resolvedArticle = json['resolvedArticle'] as Map<String, dynamic>?;
    final catalogData = json['catalogData'] as Map<String, dynamic>?;
    return ReceivingCartItem(
      ean: json['ean'] as String,
      quantity: json['quantity'] as int,
      resolvedArticle: resolvedArticle == null
          ? null
          : Article.fromJson(resolvedArticle),
      catalogData: catalogData == null
          ? null
          : CatalogArticle.fromJson(catalogData),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ean': ean,
      'quantity': quantity,
      'resolvedArticle': resolvedArticle?.toJson(),
      'catalogData': catalogData?.toJson(),
    };
  }
}

/// Sentinel used by [ReceivingCartItem.copyWith] to distinguish
/// "leave unchanged" from "explicitly set to null" for nullable fields.
const Object _unset = Object();
