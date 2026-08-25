import '../enums/category.dart';

/// Immutable model of a catalog article — the supplier-side master data of an
/// article, without any inventory-specific fields such as quantity or price.
class CatalogArticle {
  const CatalogArticle({
    required this.name,
    required this.category,
    required this.ean,
    this.supplier,
    this.imageUrl,
  });

  final String name;
  final Category category;

  /// Supplier of the article. Null when no supplier is known.
  final String? supplier;

  /// Image of the article. Can be a remote URL or a local file path.
  final String? imageUrl;

  /// Barcode (EAN). Serves as the unique key of a catalog article and is
  /// therefore always present.
  final String ean;

  CatalogArticle copyWith({
    String? name,
    Category? category,
    Object? supplier = _unset,
    Object? imageUrl = _unset,
    String? ean,
  }) {
    return CatalogArticle(
      name: name ?? this.name,
      category: category ?? this.category,
      supplier: identical(supplier, _unset)
          ? this.supplier
          : supplier as String?,
      imageUrl: identical(imageUrl, _unset)
          ? this.imageUrl
          : imageUrl as String?,
      ean: ean ?? this.ean,
    );
  }

  factory CatalogArticle.fromJson(Map<String, dynamic> json) {
    return CatalogArticle(
      name: json['name'] as String,
      category: Category.values.byName(json['category'] as String),
      supplier: json['supplier'] as String?,
      imageUrl: json['imageUrl'] as String?,
      ean: json['ean'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'category': category.name,
      'supplier': supplier,
      'imageUrl': imageUrl,
      'ean': ean,
    };
  }
}

/// Sentinel used by [CatalogArticle.copyWith] to distinguish "leave unchanged"
/// from "explicitly set to null" for nullable fields.
const Object _unset = Object();
