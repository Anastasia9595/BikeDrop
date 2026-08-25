import 'package:flutter_test/flutter_test.dart';
import 'package:bikedrop/enums/category.dart';
import 'package:bikedrop/repository/mockcatalog_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('liefert den Katalogartikel zu einer bekannten EAN', () async {
    final repository = MockCatalogRepository();

    final article = await repository.lookupByEan('4260119901230');

    expect(article, isNotNull);
    expect(article!.ean, '4260119901230');
    expect(article.name, 'Schwalbe Marathon Plus 28x1.75');
    expect(article.category, Category.reifen);
    expect(article.supplier, 'Schwalbe');
  });

  test('liefert null zu einer unbekannten EAN', () async {
    final repository = MockCatalogRepository();

    expect(await repository.lookupByEan('0000000000000'), isNull);
  });

  test('liefert null zu einer leeren EAN', () async {
    final repository = MockCatalogRepository();

    expect(await repository.lookupByEan(''), isNull);
  });

  test('liefert imageUrl null fuer einen Katalogartikel ohne Bild', () async {
    final repository = MockCatalogRepository();

    final article = await repository.lookupByEan('4051234509872');

    expect(article, isNotNull);
    expect(article!.name, 'Muc-Off Bike Cleaner 1L');
    expect(article.imageUrl, isNull);
  });

  test('findet auch EANs, die bereits als Artikel im Lager existieren', () async {
    final repository = MockCatalogRepository();

    final article = await repository.lookupByEan('4055123456780');

    expect(article, isNotNull);
    expect(article!.name, 'Shimano Deore Bremsscheibe 180mm');
    expect(article.category, Category.bremsen);
  });

  test('liefert bei wiederholtem Lookup dieselbe Instanz aus dem Cache', () async {
    final repository = MockCatalogRepository();

    final first = await repository.lookupByEan('4711234567899');
    final second = await repository.lookupByEan('4711234567899');

    expect(identical(first, second), isTrue);
  });
}
