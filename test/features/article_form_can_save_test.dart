import 'package:bikedrop/design_system/design_system.dart';
import 'package:bikedrop/features/article_form_screen.dart';
import 'package:bikedrop/interface/article_interface.dart';
import 'package:bikedrop/models/article.dart';
import 'package:bikedrop/models/catalogarticle.dart';
import 'package:bikedrop/providers/article_repository_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// Liefert EAN, Name und Kategorie vor — so bleiben nur die Zahlenfelder offen.
const _catalog = CatalogArticle(
  ean: '4029876501233',
  name: 'Abus Bordo 6000 Faltschloss 90cm',
  category: Category.zubehoer,
  supplier: 'Abus',
);

/// Merkt sich nur, was gespeichert wurde — mehr braucht dieser Test nicht.
class _FakeArticleRepository implements ArticleRepository {
  Article? created;

  @override
  Future<Article> createArticle(Article article) async {
    created = article;
    return article;
  }

  @override
  Future<List<String>> getSuppliers() async => [];

  @override
  Future<Article> updateArticle(Article article) => throw UnimplementedError();

  @override
  Future<Article> changeQuantity(String id, int q) => throw UnimplementedError();

  @override
  Future<void> deleteArticle(String id) => throw UnimplementedError();

  @override
  Future<Article?> getArticleByEan(String ean) => throw UnimplementedError();

  @override
  Future<Article?> getArticleById(String id) => throw UnimplementedError();

  @override
  Future<List<Article>> getArticles() async => [];

  @override
  Future<List<Article>> searchArticlesByName(String q) async => [];
}

Future<void> _pump(
  WidgetTester tester, {
  CatalogArticle? catalog,
  _FakeArticleRepository? repository,
}) {
  return tester.pumpWidget(
    ProviderScope(
      overrides: [
        if (repository != null)
          articleRepositoryProvider.overrideWithValue(repository),
      ],
      child: MaterialApp(home: ArticleFormScreen(catalogArticle: catalog)),
    ),
  );
}

/// Der Fehlertext, den AppTextField unter dem Feld rendert — null, wenn keiner.
String? _errorOf(WidgetTester tester, String label) => tester
    .widget<AppTextField>(find.widgetWithText(AppTextField, label.toUpperCase()))
    .errorText;

bool _saveEnabled(WidgetTester tester) {
  final button = tester.widget<AppPrimaryButton>(
    find.byType(AppPrimaryButton),
  );
  return button.onPressed != null;
}

Future<void> _fill(WidgetTester tester, String label, String value) async {
  await tester.enterText(
    find.descendant(
      // AppTextField rendert das Label in Grossbuchstaben.
      of: find.widgetWithText(AppTextField, label.toUpperCase()),
      matching: find.byType(TextField),
    ),
    value,
  );
  await tester.pump();
}

Future<void> _fillNumbers(WidgetTester tester) async {
  await _fill(tester, 'Mindestbestand', '2');
  await _fill(tester, 'Einkaufspreis', '49.90');
  await _fill(tester, 'Verkaufspreis', '89.90');
}

void main() {
  testWidgets('Speichern ist bei leerem Formular deaktiviert', (tester) async {
    await _pump(tester);

    expect(_saveEnabled(tester), isFalse);
  });

  testWidgets('Speichern bleibt deaktiviert, solange die Zahlenfelder fehlen',
      (tester) async {
    await _pump(tester, catalog: _catalog);

    expect(_saveEnabled(tester), isFalse);
  });

  testWidgets('Speichern wird aktiv, sobald alle Pflichtfelder gefuellt sind',
      (tester) async {
    await _pump(tester, catalog: _catalog);
    await _fillNumbers(tester);

    expect(_saveEnabled(tester), isTrue);
  });

  testWidgets('Speichern bleibt deaktiviert ohne Artikelnummer',
      (tester) async {
    await _pump(tester, catalog: _catalog);
    await _fillNumbers(tester);
    await _fill(tester, 'Artikelnummer', '');

    expect(_saveEnabled(tester), isFalse);
  });

  testWidgets('Speichern bleibt deaktiviert ohne Artikelname', (tester) async {
    await _pump(tester, catalog: _catalog);
    await _fillNumbers(tester);
    await _fill(tester, 'Artikelname', '   ');

    expect(_saveEnabled(tester), isFalse);
  });

  testWidgets('Speichern bleibt deaktiviert bei unlesbarem Preis',
      (tester) async {
    await _pump(tester, catalog: _catalog);
    await _fillNumbers(tester);
    await _fill(tester, 'Verkaufspreis', 'abc');

    expect(_saveEnabled(tester), isFalse);
  });

  testWidgets('Hoechstbestand und Lagerort bleiben freiwillig',
      (tester) async {
    await _pump(tester, catalog: _catalog);
    await _fillNumbers(tester);

    expect(_saveEnabled(tester), isTrue,
        reason: 'Hoechstbestand und Lagerort sind leer und duerfen es sein');
  });

  testWidgets('zeigt keinen Fehler, solange die Artikelnummer leer ist',
      (tester) async {
    await _pump(tester);

    expect(_errorOf(tester, 'Artikelnummer'), isNull);
  });

  testWidgets('markiert eine Artikelnummer mit falscher Pruefziffer',
      (tester) async {
    await _pump(tester, catalog: _catalog);
    await _fill(tester, 'Artikelnummer', '4029876501234');

    expect(_errorOf(tester, 'Artikelnummer'), isNotNull);
  });

  testWidgets('markiert eine zu kurze Artikelnummer', (tester) async {
    await _pump(tester, catalog: _catalog);
    await _fill(tester, 'Artikelnummer', '40298765012');

    expect(_errorOf(tester, 'Artikelnummer'), isNotNull);
  });

  testWidgets('sperrt das Speichern bei ungueltiger Artikelnummer',
      (tester) async {
    await _pump(tester, catalog: _catalog);
    await _fillNumbers(tester);
    await _fill(tester, 'Artikelnummer', '4029876501234');

    expect(_saveEnabled(tester), isFalse);
  });

  testWidgets('akzeptiert eine gueltige EAN-8 ohne Fehler', (tester) async {
    await _pump(tester, catalog: _catalog);
    await _fillNumbers(tester);
    await _fill(tester, 'Artikelnummer', '96385074');

    expect(_errorOf(tester, 'Artikelnummer'), isNull);
    expect(_saveEnabled(tester), isTrue);
  });

  testWidgets('speichert einen getippten UPC-A wie einen Scan 13-stellig',
      (tester) async {
    final repository = _FakeArticleRepository();
    await _pump(tester, catalog: _catalog, repository: repository);
    await _fillNumbers(tester);
    await _fill(tester, 'Artikelnummer', '978020137962');

    // Der Speichern-Button liegt unterhalb des Test-Viewports.
    await tester.ensureVisible(find.byType(AppPrimaryButton));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(AppPrimaryButton));
    await tester.pumpAndSettle();

    expect(repository.created?.ean, '0978020137962');
  });
}
