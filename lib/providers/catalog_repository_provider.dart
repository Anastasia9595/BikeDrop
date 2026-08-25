import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../interface/catalog_interface.dart';
import '../models/catalogarticle.dart';
import '../repository/mockcatalog_repository.dart';

final catalogRepositoryProvider = Provider<CatalogRepository>((ref) {
  return MockCatalogRepository();
});

/// Stammdaten zu einer gescannten EAN, oder null wenn der Katalog sie nicht
/// kennt. Eine unbekannte EAN ist kein Fehler, sondern ein neuer Artikel.
final catalogArticleByEan = FutureProvider.family<CatalogArticle?, String>((
  ref,
  ean,
) async {
  final repository = ref.watch(catalogRepositoryProvider);
  return repository.lookupByEan(ean);
});
