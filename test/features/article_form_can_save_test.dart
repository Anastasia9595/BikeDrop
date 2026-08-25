import 'package:bikedrop/design_system/design_system.dart';
import 'package:bikedrop/features/article_form_screen.dart';
import 'package:bikedrop/models/catalogarticle.dart';
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

Future<void> _pump(WidgetTester tester, {CatalogArticle? catalog}) {
  return tester.pumpWidget(
    ProviderScope(
      child: MaterialApp(home: ArticleFormScreen(catalogArticle: catalog)),
    ),
  );
}

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
}
