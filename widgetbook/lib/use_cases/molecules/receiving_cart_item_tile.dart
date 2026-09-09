import 'package:bikedrop/design_system/design_system.dart';
import 'package:bikedrop/models/article.dart';
import 'package:bikedrop/models/catalogarticle.dart';
import 'package:bikedrop/models/receivingcartitem.dart';
import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart' as widgetbook;
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

Article _demoArticle() {
  final now = DateTime(2026, 1, 1);
  return Article(
    ean: '4711234567899',
    name: 'KMC Kette X11',
    category: Category.antrieb,
    quantity: 5,
    minQuantity: 0,
    purchasePrice: 1,
    sellingPrice: 2,
    status: ArticleStatus.inStock,
    createdAt: now,
    updatedAt: now,
  );
}

const _demoCatalogArticle = CatalogArticle(
  name: 'Abus Bordo 6000 Faltschloss 90cm',
  category: Category.zubehoer,
  ean: '4029876501233',
);

@widgetbook.UseCase(name: 'Interactive', type: ReceivingCartItemTile)
Widget receivingCartItemTileInteractive(BuildContext context) {
  final scenario = context.knobs.object.dropdown<String>(
    label: 'Szenario',
    options: const ['Im Bestand', 'Katalogtreffer', 'Unbekannt'],
  );
  final quantity = context.knobs.int.input(label: 'Menge', initialValue: 2);

  final item = switch (scenario) {
    'Im Bestand' => ReceivingCartItem(
      ean: '4711234567899',
      quantity: quantity,
      resolvedArticle: _demoArticle(),
    ),
    'Katalogtreffer' => ReceivingCartItem(
      ean: '4029876501233',
      quantity: quantity,
      catalogData: _demoCatalogArticle,
    ),
    _ => ReceivingCartItem(ean: '978020137962', quantity: quantity),
  };

  return Center(
    child: ReceivingCartItemTile(
      item: item,
      onQuantityChanged: (_) {},
      onAnlegenTap: () {},
    ),
  );
}
