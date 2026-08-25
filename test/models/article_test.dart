// test/models/article_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:bikedrop/enums/article_status.dart';
import 'package:bikedrop/enums/category.dart';
import 'package:bikedrop/models/article.dart';

Map<String, dynamic> _json({int? maxQuantity}) {
  return {
    'id': 'art_001',
    'ean': '4055123456780',
    'name': 'Shimano Deore Bremsscheibe 180mm',
    'category': 'bremsen',
    'supplier': 'Shimano',
    'quantity': 14,
    'minQuantity': 5,
    if (maxQuantity != null) 'maxQuantity': maxQuantity,
    'unit': 'Stk',
    'packSize': 1,
    'purchasePrice': 18.50,
    'sellingPrice': 34.90,
    'storageLocation': 'Regal C3',
    'status': 'inStock',
    'isPublic': true,
    'imageUrl': null,
    'createdAt': '2026-06-03T09:12:00.000Z',
    'updatedAt': '2026-08-18T14:03:00.000Z',
    'updatedBy': 'Anastasia',
  };
}

Article _article({int? maxQuantity}) {
  final now = DateTime(2026, 1, 1);
  return Article(
    name: 'Speiche',
    category: Category.laufraeder,
    quantity: 128,
    minQuantity: 20,
    maxQuantity: maxQuantity,
    purchasePrice: 0.45,
    sellingPrice: 0.95,
    status: ArticleStatus.inStock,
    createdAt: now,
    updatedAt: now,
  );
}

void main() {
  group('maxQuantity', () {
    test('is null when the JSON has no maxQuantity — unbegrenzt', () {
      expect(Article.fromJson(_json()).maxQuantity, isNull);
    });

    test('is read from the JSON when present', () {
      expect(Article.fromJson(_json(maxQuantity: 500)).maxQuantity, 500);
    });

    test('survives a toJson/fromJson round trip', () {
      final article = _article(maxQuantity: 500);

      expect(Article.fromJson(article.toJson()).maxQuantity, 500);
      expect(Article.fromJson(_article().toJson()).maxQuantity, isNull);
    });

    test('copyWith keeps the value when the field is not passed', () {
      expect(_article(maxQuantity: 500).copyWith(quantity: 1).maxQuantity, 500);
    });

    test('copyWith can clear the limit by passing null explicitly', () {
      expect(
        _article(maxQuantity: 500).copyWith(maxQuantity: null).maxQuantity,
        isNull,
      );
    });

    test('copyWith can set a limit on an article without one', () {
      expect(_article().copyWith(maxQuantity: 300).maxQuantity, 300);
    });
  });
}
