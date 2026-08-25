import 'package:bikedrop/design_system/design_system.dart';
import 'package:bikedrop/features/article_form_screen.dart';
import 'package:bikedrop/models/catalogarticle.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// Ohne imageUrl: ein echtes NetworkImage laesst flutter_test scheitern,
/// die Bilduebernahme prueft der letzte Test separat.
const _catalogArticle = CatalogArticle(
  ean: '4029876501233',
  name: 'Abus Bordo 6000 Faltschloss 90cm',
  category: Category.zubehoer,
  supplier: 'Abus',
);

Future<void> _pump(WidgetTester tester, {CatalogArticle? catalogArticle}) {
  return tester.pumpWidget(
    ProviderScope(
      child: MaterialApp(
        home: ArticleFormScreen(catalogArticle: catalogArticle),
      ),
    ),
  );
}

void main() {
  testWidgets('uebernimmt Name und EAN aus dem Katalogartikel',
      (tester) async {
    await _pump(tester, catalogArticle: _catalogArticle);

    expect(find.text(_catalogArticle.name), findsWidgets);
    expect(find.text(_catalogArticle.ean), findsWidgets);
  });

  testWidgets('bleibt ein neuer Artikel, kein Bearbeiten-Modus',
      (tester) async {
    await _pump(tester, catalogArticle: _catalogArticle);

    expect(find.text('Neuer Artikel'), findsOneWidget);
    expect(find.text('Artikel bearbeiten'), findsNothing);
  });

  testWidgets('startet leer, wenn kein Katalogartikel uebergeben wird',
      (tester) async {
    await _pump(tester);

    expect(find.text(_catalogArticle.name), findsNothing);
    expect(find.text('Neuer Artikel'), findsOneWidget);
  });

  testWidgets('uebernimmt Kategorie und Lieferant aus dem Katalogartikel',
      (tester) async {
    await _pump(tester, catalogArticle: _catalogArticle);

    expect(find.text(Category.zubehoer.label), findsWidgets);
    expect(find.text('Abus'), findsWidgets);
  });

  testWidgets('uebernimmt das Katalogbild', (tester) async {
    await _pump(
      tester,
      catalogArticle: const CatalogArticle(
        ean: '4029876501233',
        name: 'Abus Bordo 6000 Faltschloss 90cm',
        category: Category.zubehoer,
        imageUrl: 'https://example.com/abus.png',
      ),
    );

    final image = tester
        .widgetList<Image>(find.byType(Image))
        .map((w) => w.image)
        .whereType<NetworkImage>()
        .toList();

    expect(image.map((i) => i.url), contains('https://example.com/abus.png'));

    // Der Ladeversuch scheitert im Test mangels Netzwerk — das ist erwartet.
    tester.takeException();
  });
}
