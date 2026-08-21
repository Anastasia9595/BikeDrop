import 'package:uuid/uuid.dart';

import '../enums/article_status.dart';
import '../enums/category.dart';

const _uuid = Uuid();

/// Immutable model of a single inventory article.
class Article {
  Article({
    String? id,
    this.ean,
    required this.name,
    required this.category,
    this.supplier,
    required this.quantity,
    required this.minQuantity,
    this.unit = 'Stk',
    this.packSize = 1,
    required this.purchasePrice,
    required this.sellingPrice,
    this.storageLocation,
    required this.status,
    this.isPublic = false,
    this.imageUrl,
    required this.createdAt,
    required this.updatedAt,
    this.updatedBy,
  }) : id = id ?? _uuid.v4();

  /// Unique identifier. Auto-generated as a UUID v4 when not supplied,
  /// e.g. when creating a new article that has not been persisted yet.
  final String id;

  /// Barcode (EAN). Null for articles without a scannable barcode.
  final String? ean;

  final String name;
  final Category category;
  final String? supplier;
  final int quantity;
  final int minQuantity;
  final String unit;

  /// Quantity added per scan, e.g. 10 when scanning a full box (Karton)
  /// instead of a single unit. Defaults to 1 for individually scanned articles.
  final int packSize;

  final double purchasePrice;
  final double sellingPrice;
  final String? storageLocation;
  final ArticleStatus status;

  /// Whether the article is visible in the customer-facing shop.
  /// Defaults to false so new articles stay internal until explicitly published.
  final bool isPublic;

  final String? imageUrl;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? updatedBy;

  Article copyWith({
    String? id,
    Object? ean = _unset,
    String? name,
    Category? category,
    Object? supplier = _unset,
    int? quantity,
    int? minQuantity,
    String? unit,
    int? packSize,
    double? purchasePrice,
    double? sellingPrice,
    Object? storageLocation = _unset,
    ArticleStatus? status,
    bool? isPublic,
    Object? imageUrl = _unset,
    DateTime? createdAt,
    DateTime? updatedAt,
    Object? updatedBy = _unset,
  }) {
    return Article(
      id: id ?? this.id,
      ean: identical(ean, _unset) ? this.ean : ean as String?,
      name: name ?? this.name,
      category: category ?? this.category,
      supplier: identical(supplier, _unset) ? this.supplier : supplier as String?,
      quantity: quantity ?? this.quantity,
      minQuantity: minQuantity ?? this.minQuantity,
      unit: unit ?? this.unit,
      packSize: packSize ?? this.packSize,
      purchasePrice: purchasePrice ?? this.purchasePrice,
      sellingPrice: sellingPrice ?? this.sellingPrice,
      storageLocation: identical(storageLocation, _unset) ? this.storageLocation : storageLocation as String?,
      status: status ?? this.status,
      isPublic: isPublic ?? this.isPublic,
      imageUrl: identical(imageUrl, _unset) ? this.imageUrl : imageUrl as String?,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      updatedBy: identical(updatedBy, _unset) ? this.updatedBy : updatedBy as String?,
    );
  }

  factory Article.fromJson(Map<String, dynamic> json) {
    return Article(
      id: json['id'] as String,
      ean: json['ean'] as String?,
      name: json['name'] as String,
      category: Category.values.byName(json['category'] as String),
      supplier: json['supplier'] as String?,
      quantity: json['quantity'] as int,
      minQuantity: json['minQuantity'] as int,
      unit: json['unit'] as String? ?? 'Stk',
      packSize: json['packSize'] as int? ?? 1,
      purchasePrice: (json['purchasePrice'] as num).toDouble(),
      sellingPrice: (json['sellingPrice'] as num).toDouble(),
      storageLocation: json['storageLocation'] as String?,
      status: ArticleStatus.values.byName(json['status'] as String),
      isPublic: json['isPublic'] as bool? ?? false,
      imageUrl: json['imageUrl'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      updatedBy: json['updatedBy'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'ean': ean,
      'name': name,
      'category': category.name,
      'supplier': supplier,
      'quantity': quantity,
      'minQuantity': minQuantity,
      'unit': unit,
      'packSize': packSize,
      'purchasePrice': purchasePrice,
      'sellingPrice': sellingPrice,
      'storageLocation': storageLocation,
      'status': status.name,
      'isPublic': isPublic,
      'imageUrl': imageUrl,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'updatedBy': updatedBy,
    };
  }
}

/// Sentinel used by [Article.copyWith] to distinguish "leave unchanged"
/// from "explicitly set to null" for nullable fields.
const Object _unset = Object();
