import '../models/catalogarticle.dart';

abstract class CatalogRepository {
  Future<CatalogArticle?> lookupByEan(String ean);

  /// Alle Katalogartikel — genutzt, um im Wareneingangs-Demo-Flow zufaellig
  /// einen Katalogtreffer zu simulieren.
  Future<List<CatalogArticle>> getCatalogArticles();
}
