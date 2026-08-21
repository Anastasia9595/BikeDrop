import '../models/article.dart';

abstract class ArticleRepository {
  /// Gibt alle Artikel zurück (S1 – Lagerliste)
  Future<List<Article>> getArticles();

  /// Sucht einen Artikel per interner ID (z.B. S7 – Detail)
  Future<Article?> getArticleById(String id);

  /// Sucht einen Artikel per EAN (Scan in S3/S5)
  Future<Article?> getArticleByEan(String ean);

  /// Suche über den Namen, ohne Barcode (S4)
  Future<List<Article>> searchArticlesByName(String query);

  /// Legt einen neuen Artikel an (S6)
  Future<Article> createArticle(Article article);

  /// Aktualisiert einen bestehenden Artikel, außer reine Mengenänderung (S7)
  Future<Article> updateArticle(Article article);

  /// Ändert ausschließlich die Menge (S2 – Mengen-Sheet)
  Future<Article> changeQuantity(String id, int newQuantity);

  /// Löscht einen Artikel unwiderruflich (S7)
  Future<void> deleteArticle(String id);
}
