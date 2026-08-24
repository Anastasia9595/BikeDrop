import 'package:bikedrop/models/article.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
import '../interface/article_interface.dart';

class MockArticleRepository implements ArticleRepository {
  List<Article>? _articles;

  Future<List<Article>> _ensureLoaded() async {
    if (_articles == null) {
      final jsonString = await rootBundle.loadString(
        'assets/data/seed_articles.json',
      );
      final List<dynamic> jsonList = jsonDecode(jsonString);
      _articles = jsonList
          .map((e) => Article.fromJson(e as Map<String, dynamic>))
          .toList();
      return _articles!;
    }

    return _articles!;
  }

  @override
  Future<Article> changeQuantity(String id, int newQuantity) async {
    final articles = await _ensureLoaded();
    final index = articles.indexWhere((a) => a.id == id);
    if (index == -1) {
      throw Exception('Artikel mit ID $id nicht gefunden');
    }
    final updated = articles[index].copyWith(
      quantity: newQuantity,
      updatedAt: DateTime.now(),
    );
    articles[index] = updated;
    return updated;
  }

  @override
  Future<Article> createArticle(Article article) async {
    final articles = await _ensureLoaded();
    final newArticle = article.copyWith(
      id: 'art_${DateTime.now().millisecondsSinceEpoch}',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    articles.add(newArticle);
    return newArticle;
  }

  @override
  Future<void> deleteArticle(String id) async {
    final articles = await _ensureLoaded();
    final index = articles.indexWhere((a) => a.id == id);
    if (index == -1) {
      throw Exception('Artikel mit ID $id nicht gefunden');
    }
    articles.removeAt(index);
  }

  @override
  Future<Article?> getArticleByEan(String ean) async {
    final articles = await _ensureLoaded();
    return articles.firstWhere(
      (article) => article.ean == ean,
      orElse: () => throw Exception('Article not found'),
    );
  }

  @override
  Future<Article?> getArticleById(String id) async {
    final articles = await _ensureLoaded();
    return articles.firstWhere(
      (article) => article.id == id,
      orElse: () => throw Exception('Article not found'),
    );
  }

  @override
  Future<List<Article>> getArticles() async {
    final articles = await _ensureLoaded();
    return List.unmodifiable(articles);
  }

  @override
  Future<List<Article>> searchArticlesByName(String query) async {
    final articles = await _ensureLoaded();
    return articles
        .where(
          (article) => article.name.toLowerCase().contains(query.toLowerCase()),
        )
        .toList();
  }

  @override
  Future<Article> updateArticle(Article article) async {
    final articles = await _ensureLoaded();
    final index = articles.indexWhere((a) => a.id == article.id);
    if (index == -1) {
      throw Exception('Artikel mit ID ${article.id} nicht gefunden');
    }
    final updated = article.copyWith(updatedAt: DateTime.now());
    articles[index] = updated;
    return updated;
  }

  @override
  Future<List<String>> getSuppliers() async {
    final articles = await _ensureLoaded();
    final suppliers =
        articles.map((a) => a.supplier).whereType<String>().toSet().toList()
          ..sort();
    return suppliers;
  }
}
