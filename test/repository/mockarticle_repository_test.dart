import 'package:bikedrop/repository/mockarticle_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('liefert den Artikel zu einer bekannten EAN', () async {
    final repository = MockArticleRepository();

    final article = await repository.getArticleByEan('4055123456780');

    expect(article, isNotNull);
    expect(article!.name, 'Shimano Deore Bremsscheibe 180mm');
  });

  test('liefert null zu einer unbekannten EAN, statt zu werfen', () async {
    final repository = MockArticleRepository();

    expect(await repository.getArticleByEan('4007249913555'), isNull);
  });

  test('liefert null zu einer leeren EAN', () async {
    final repository = MockArticleRepository();

    expect(await repository.getArticleByEan(''), isNull);
  });

  test('verwechselt Artikel ohne EAN nicht mit einer leeren Suche', () async {
    final repository = MockArticleRepository();

    // In seed_articles.json haben zwei Artikel ean: null.
    expect(await repository.getArticleByEan('null'), isNull);
  });
}
