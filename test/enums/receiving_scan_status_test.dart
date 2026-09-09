import 'package:bikedrop/enums/receiving_scan_status.dart';
import 'package:bikedrop/models/article.dart';
import 'package:bikedrop/models/catalogarticle.dart';
import 'package:bikedrop/models/receivingcartitem.dart';
import 'package:bikedrop/enums/article_status.dart';
import 'package:bikedrop/enums/category.dart';
import 'package:flutter_test/flutter_test.dart';

Article _article() {
  final now = DateTime(2026, 1, 1);
  return Article(
    ean: '4711234567899',
    name: 'KMC Kette X11',
    category: Category.antrieb,
    quantity: 1,
    minQuantity: 0,
    purchasePrice: 1,
    sellingPrice: 2,
    status: ArticleStatus.inStock,
    createdAt: now,
    updatedAt: now,
  );
}

const _catalogArticle = CatalogArticle(
  name: 'Abus Bordo 6000 Faltschloss 90cm',
  category: Category.zubehoer,
  ean: '4029876501233',
);

void main() {
  test('labels match the German copy', () {
    expect(ReceivingScanStatus.inStock.label, 'Im Bestand');
    expect(ReceivingScanStatus.catalogMatch.label, 'Katalogtreffer');
    expect(ReceivingScanStatus.unknown.label, 'Unbekannt');
  });

  test('a resolved own article is inStock', () {
    final item = ReceivingCartItem(
      ean: '4711234567899',
      quantity: 1,
      resolvedArticle: _article(),
    );
    expect(item.scanStatus, ReceivingScanStatus.inStock);
  });

  test('a catalog-only match is catalogMatch', () {
    final item = ReceivingCartItem(
      ean: '4029876501233',
      quantity: 1,
      catalogData: _catalogArticle,
    );
    expect(item.scanStatus, ReceivingScanStatus.catalogMatch);
  });

  test('neither resolved nor catalog data is unknown', () {
    final item = ReceivingCartItem(ean: '978020137962', quantity: 1);
    expect(item.scanStatus, ReceivingScanStatus.unknown);
  });

  test('a resolved article wins even if catalog data is also set', () {
    final item = ReceivingCartItem(
      ean: '4711234567899',
      quantity: 1,
      resolvedArticle: _article(),
      catalogData: _catalogArticle,
    );
    expect(item.scanStatus, ReceivingScanStatus.inStock);
  });
}
