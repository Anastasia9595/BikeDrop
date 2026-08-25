import '../models/catalogarticle.dart';

abstract class CatalogRepository {
  Future<CatalogArticle?> lookupByEan(String ean);
}
