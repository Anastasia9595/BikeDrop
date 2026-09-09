import 'package:bikedrop/design_system/design_system.dart';
import 'package:bikedrop/enums/article_status.dart';
import 'package:bikedrop/enums/category.dart';
import 'package:bikedrop/models/article.dart';
import 'package:bikedrop/models/catalogarticle.dart';
import 'package:bikedrop/models/receivingcartitem.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Article _article() {
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

const _catalogArticle = CatalogArticle(
  name: 'Abus Bordo 6000 Faltschloss 90cm',
  category: Category.zubehoer,
  ean: '4029876501233',
);

Widget _wrap(ReceivingCartItem item, {ValueChanged<int>? onQuantityChanged, VoidCallback? onAnlegenTap}) {
  return MaterialApp(
    home: Scaffold(
      body: ReceivingCartItemTile(
        item: item,
        onQuantityChanged: onQuantityChanged ?? (_) {},
        onAnlegenTap: onAnlegenTap ?? () {},
      ),
    ),
  );
}

void main() {
  testWidgets('shows the resolved article name and its EAN', (tester) async {
    await tester.pumpWidget(
      _wrap(ReceivingCartItem(ean: '4711234567899', quantity: 3, resolvedArticle: _article())),
    );

    expect(find.text('KMC Kette X11'), findsOneWidget);
    expect(find.text('EAN 4711234567899'), findsOneWidget);
  });

  testWidgets('shows the catalog article name when only the catalog matched', (tester) async {
    await tester.pumpWidget(
      _wrap(ReceivingCartItem(ean: '4029876501233', quantity: 1, catalogData: _catalogArticle)),
    );

    expect(find.text('Abus Bordo 6000 Faltschloss 90cm'), findsOneWidget);
  });

  testWidgets('falls back to a generic name for an unknown item', (tester) async {
    await tester.pumpWidget(_wrap(const ReceivingCartItem(ean: '978020137962', quantity: 1)));

    expect(find.text('Unbekannter Artikel'), findsOneWidget);
  });

  testWidgets('shows a QuantityStepper and no Anlegen-button for a known item', (tester) async {
    await tester.pumpWidget(
      _wrap(ReceivingCartItem(ean: '4711234567899', quantity: 3, resolvedArticle: _article())),
    );

    expect(find.byType(QuantityStepper), findsOneWidget);
    expect(find.text('Anlegen'), findsNothing);
  });

  testWidgets('reports quantity changes from the stepper', (tester) async {
    var reported = -1;
    await tester.pumpWidget(
      _wrap(
        ReceivingCartItem(ean: '4711234567899', quantity: 3, resolvedArticle: _article()),
        onQuantityChanged: (q) => reported = q,
      ),
    );

    await tester.tap(find.byTooltip('Menge erhöhen'));
    expect(reported, 4);
  });

  testWidgets('shows an Anlegen-button and no stepper for an unknown item', (tester) async {
    await tester.pumpWidget(_wrap(const ReceivingCartItem(ean: '978020137962', quantity: 1)));

    expect(find.text('Anlegen'), findsOneWidget);
    expect(find.byType(QuantityStepper), findsNothing);
  });

  testWidgets('reports a tap on Anlegen', (tester) async {
    var tapped = false;
    await tester.pumpWidget(
      _wrap(const ReceivingCartItem(ean: '978020137962', quantity: 1), onAnlegenTap: () => tapped = true),
    );

    await tester.tap(find.text('Anlegen'));
    expect(tapped, isTrue);
  });
}
