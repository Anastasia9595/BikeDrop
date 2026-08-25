import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../interface/catalog_interface.dart';
import '../models/catalogarticle.dart';
import '../repository/mockcatalog_repository.dart';

final catalogRepositoryProvider = Provider<CatalogRepository>((ref) {
  return MockCatalogRepository();
});

final lookupByEanProvider = FutureProvider.family<CatalogArticle?, String>((
  ref,
  ean,
) async {
  final repository = ref.watch(catalogRepositoryProvider);
  return repository.lookupByEan(ean);
});
