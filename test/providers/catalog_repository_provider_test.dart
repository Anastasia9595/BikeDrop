import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bikedrop/interface/catalog_interface.dart';
import 'package:bikedrop/providers/catalog_repository_provider.dart';
import 'package:bikedrop/models/catalogarticle.dart';
import 'package:bikedrop/repository/mockcatalog_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('stellt ein CatalogRepository bereit', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final repository = container.read(catalogRepositoryProvider);

    expect(repository, isA<CatalogRepository>());
    expect(repository, isA<MockCatalogRepository>());
  });

  test('liefert dieselbe Repository-Instanz bei mehrfachem Lesen', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final first = container.read(catalogRepositoryProvider);
    final second = container.read(catalogRepositoryProvider);

    expect(identical(first, second), isTrue);
  });

  test('catalogArticleByEan liefert den Katalogartikel zur EAN', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final article = await container.read(
      catalogArticleByEan('4029876501233').future,
    );

    expect(article, isNotNull);
    expect(article!.name, 'Abus Bordo 6000 Faltschloss 90cm');
    expect(article.supplier, 'Abus');
  });

  test('catalogArticleByEan liefert null zu einer unbekannten EAN', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final CatalogArticle? article = await container.read(
      catalogArticleByEan('0000000000000').future,
    );

    expect(article, isNull);
  });
}
