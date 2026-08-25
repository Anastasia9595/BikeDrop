import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bikedrop/interface/catalog_interface.dart';
import 'package:bikedrop/providers/catalog_repository_provider.dart';
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
}
