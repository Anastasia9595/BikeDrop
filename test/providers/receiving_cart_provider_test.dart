import 'dart:math';

import 'package:bikedrop/enums/article_status.dart';
import 'package:bikedrop/enums/category.dart';
import 'package:bikedrop/interface/article_interface.dart';
import 'package:bikedrop/interface/catalog_interface.dart';
import 'package:bikedrop/models/article.dart';
import 'package:bikedrop/models/catalogarticle.dart';
import 'package:bikedrop/providers/article_repository_provider.dart';
import 'package:bikedrop/providers/catalog_repository_provider.dart';
import 'package:bikedrop/providers/receiving_cart_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// Waehlt immer den ersten Eintrag — macht Zufallsauswahl im Test
/// deterministisch, ohne `Random` selbst nachbauen zu muessen.
class _FirstRandom implements Random {
  @override
  int nextInt(int max) => 0;
  @override
  double nextDouble() => 0;
  @override
  bool nextBool() => false;
}

class _FakeCatalogRepository implements CatalogRepository {
  _FakeCatalogRepository(this.articles);
  final List<CatalogArticle> articles;

  @override
  Future<CatalogArticle?> lookupByEan(String ean) async =>
      articles.where((a) => a.ean == ean).firstOrNull;

  @override
  Future<List<CatalogArticle>> getCatalogArticles() async => articles;
}

class _FakeArticleRepository implements ArticleRepository {
  _FakeArticleRepository(this.articles);
  final List<Article> articles;

  @override
  Future<List<Article>> getArticles() async => articles;
  @override
  Future<Article?> getArticleByEan(String ean) => throw UnimplementedError();
  @override
  Future<Article?> getArticleById(String id) => throw UnimplementedError();
  @override
  Future<List<Article>> searchArticlesByName(String query) => throw UnimplementedError();
  @override
  Future<Article> createArticle(Article article) => throw UnimplementedError();
  @override
  Future<Article> updateArticle(Article article) => throw UnimplementedError();
  @override
  Future<Article> changeQuantity(String id, int newQuantity) => throw UnimplementedError();
  @override
  Future<void> deleteArticle(String id) => throw UnimplementedError();
  @override
  Future<List<String>> getSuppliers() => throw UnimplementedError();
}

const _catalogArticle = CatalogArticle(
  name: 'Abus Bordo 6000 Faltschloss 90cm',
  category: Category.zubehoer,
  ean: '4029876501233',
);

Article _ownArticle({String? ean, int packSize = 1}) {
  final now = DateTime(2026, 1, 1);
  return Article(
    ean: ean,
    name: 'KMC Kette X11',
    category: Category.antrieb,
    quantity: 5,
    minQuantity: 0,
    packSize: packSize,
    purchasePrice: 1,
    sellingPrice: 2,
    status: ArticleStatus.inStock,
    createdAt: now,
    updatedAt: now,
  );
}

ProviderContainer _container({
  List<CatalogArticle> catalog = const [_catalogArticle],
  List<Article> ownArticles = const [],
}) {
  final container = ProviderContainer(
    overrides: [
      catalogRepositoryProvider.overrideWithValue(_FakeCatalogRepository(catalog)),
      articleRepositoryProvider.overrideWithValue(_FakeArticleRepository(ownArticles)),
      receivingCartRandomProvider.overrideWithValue(_FirstRandom()),
    ],
  );
  return container;
}

void main() {
  test('starts empty', () {
    final container = _container();
    addTearDown(container.dispose);

    expect(container.read(receivingCartProvider), isEmpty);
  });

  test('addFromCatalog adds a new line for the picked catalog article', () async {
    final container = _container();
    addTearDown(container.dispose);

    await container.read(receivingCartProvider.notifier).addFromCatalog();

    final cart = container.read(receivingCartProvider);
    expect(cart, hasLength(1));
    expect(cart.single.catalogData?.ean, '4029876501233');
    expect(cart.single.quantity, 1);
    expect(cart.single.resolvedArticle, isNull);
  });

  test('addFromCatalog merges into the existing line on a repeat pick', () async {
    final container = _container();
    addTearDown(container.dispose);
    final notifier = container.read(receivingCartProvider.notifier);

    await notifier.addFromCatalog();
    await notifier.addFromCatalog();

    final cart = container.read(receivingCartProvider);
    expect(cart, hasLength(1));
    expect(cart.single.quantity, 2);
  });

  test('addFromCatalog does nothing when the catalog is empty', () async {
    final container = _container(catalog: const []);
    addTearDown(container.dispose);

    await container.read(receivingCartProvider.notifier).addFromCatalog();

    expect(container.read(receivingCartProvider), isEmpty);
  });

  test('addFromOwnArticles adds a new line with quantity = packSize', () async {
    final container = _container(
      ownArticles: [_ownArticle(ean: '4711234567899', packSize: 3)],
    );
    addTearDown(container.dispose);

    await container.read(receivingCartProvider.notifier).addFromOwnArticles();

    final cart = container.read(receivingCartProvider);
    expect(cart, hasLength(1));
    expect(cart.single.resolvedArticle?.ean, '4711234567899');
    expect(cart.single.quantity, 3);
    expect(cart.single.catalogData, isNull);
  });

  test('addFromOwnArticles merges by adding packSize on a repeat pick', () async {
    final container = _container(
      ownArticles: [_ownArticle(ean: '4711234567899', packSize: 2)],
    );
    addTearDown(container.dispose);
    final notifier = container.read(receivingCartProvider.notifier);

    await notifier.addFromOwnArticles();
    await notifier.addFromOwnArticles();

    final cart = container.read(receivingCartProvider);
    expect(cart, hasLength(1));
    expect(cart.single.quantity, 4);
  });

  test('addFromOwnArticles ignores articles without an ean', () async {
    final container = _container(ownArticles: [_ownArticle(ean: null)]);
    addTearDown(container.dispose);

    await container.read(receivingCartProvider.notifier).addFromOwnArticles();

    expect(container.read(receivingCartProvider), isEmpty);
  });

  test('addUnknown always appends a new line, never merges', () async {
    final container = _container();
    addTearDown(container.dispose);
    final notifier = container.read(receivingCartProvider.notifier);

    notifier.addUnknown('978020137962');
    notifier.addUnknown('978020137962');

    final cart = container.read(receivingCartProvider);
    expect(cart, hasLength(2));
    expect(cart.every((item) => item.quantity == 1), isTrue);
    expect(cart.every((item) => item.resolvedArticle == null && item.catalogData == null), isTrue);
  });

  test('updateQuantity changes only the targeted line', () async {
    final container = _container();
    addTearDown(container.dispose);
    final notifier = container.read(receivingCartProvider.notifier);

    notifier.addUnknown('111');
    notifier.addUnknown('222');
    final target = container.read(receivingCartProvider)[0];

    notifier.updateQuantity(target, 9);

    final cart = container.read(receivingCartProvider);
    expect(cart[0].quantity, 9);
    expect(cart[1].quantity, 1);
  });

  test('resolveUnknown replaces exactly the targeted line, even with a shared ean', () async {
    final container = _container(
      ownArticles: [_ownArticle(ean: '978020137962', packSize: 1)],
    );
    addTearDown(container.dispose);
    final notifier = container.read(receivingCartProvider.notifier);

    notifier.addUnknown('978020137962');
    notifier.addUnknown('978020137962');
    final firstUnknown = container.read(receivingCartProvider)[0];
    final resolved = _ownArticle(ean: '978020137962');

    notifier.resolveUnknown(firstUnknown, resolved);

    final cart = container.read(receivingCartProvider);
    expect(cart[0].resolvedArticle, resolved);
    expect(cart[1].resolvedArticle, isNull);
  });
}
