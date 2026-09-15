import 'package:bikedrop/enums/article_status.dart';
import 'package:bikedrop/enums/category.dart';
import 'package:bikedrop/interface/article_interface.dart';
import 'package:bikedrop/models/article.dart';
import 'package:bikedrop/providers/article_form_provider.dart';
import 'package:bikedrop/providers/article_repository_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeArticleRepository implements ArticleRepository {
  Article? created;
  Article? updated;
  Object? errorOnCreate;

  @override
  Future<Article> createArticle(Article article) async {
    if (errorOnCreate != null) throw errorOnCreate!;
    created = article;
    return article;
  }

  @override
  Future<Article> updateArticle(Article article) async {
    updated = article;
    return article;
  }

  @override
  Future<Article> changeQuantity(String id, int newQuantity) => throw UnimplementedError();
  @override
  Future<void> deleteArticle(String id) => throw UnimplementedError();
  @override
  Future<Article?> getArticleByEan(String ean) => throw UnimplementedError();
  @override
  Future<Article?> getArticleById(String id) => throw UnimplementedError();
  @override
  Future<List<Article>> getArticles() async => [];
  @override
  Future<List<String>> getSuppliers() async => [];
  @override
  Future<List<Article>> searchArticlesByName(String query) async => [];
}

Article _existing() {
  final now = DateTime(2026, 1, 1);
  return Article(
    ean: '111',
    name: 'Alt',
    category: Category.antrieb,
    quantity: 1,
    minQuantity: 0,
    purchasePrice: 1,
    sellingPrice: 2,
    status: ArticleStatus.inStock,
    createdAt: now,
    updatedAt: now,
  );
}

ArticleFormSaveRequest _request({
  Article? existing,
  String rawEan = '978020137962',
  String name = 'Neuer Artikel',
  int quantity = 3,
  String storageLocation = '',
}) {
  return ArticleFormSaveRequest(
    existing: existing,
    rawEan: rawEan,
    name: name,
    category: Category.zubehoer,
    supplier: null,
    quantity: quantity,
    minQuantity: 0,
    maxQuantity: null,
    purchasePriceText: '9.99',
    sellingPriceText: '19.99',
    storageLocation: storageLocation,
    status: ArticleStatus.inStock,
    isPublic: false,
    imageUrl: null,
  );
}

void main() {
  test('creates a new article when existing is null', () async {
    final repository = _FakeArticleRepository();
    final container = ProviderContainer(
      overrides: [articleRepositoryProvider.overrideWithValue(repository)],
    );
    addTearDown(container.dispose);

    await container.read(articleFormProvider.notifier).save(_request());

    expect(repository.created?.name, 'Neuer Artikel');
    expect(repository.created?.quantity, 3);
    expect(repository.updated, isNull);
    expect(container.read(articleFormProvider).value, repository.created);
  });

  test('updates the existing article instead of creating one', () async {
    final repository = _FakeArticleRepository();
    final container = ProviderContainer(
      overrides: [articleRepositoryProvider.overrideWithValue(repository)],
    );
    addTearDown(container.dispose);
    final existing = _existing();

    await container
        .read(articleFormProvider.notifier)
        .save(_request(existing: existing, name: 'Neu benannt'));

    expect(repository.updated?.id, existing.id);
    expect(repository.updated?.name, 'Neu benannt');
    expect(repository.created, isNull);
  });

  test('clears ean and storageLocation when left empty', () async {
    final repository = _FakeArticleRepository();
    final container = ProviderContainer(
      overrides: [articleRepositoryProvider.overrideWithValue(repository)],
    );
    addTearDown(container.dispose);

    await container
        .read(articleFormProvider.notifier)
        .save(_request(rawEan: '', storageLocation: ''));

    expect(repository.created?.ean, isNull);
    expect(repository.created?.storageLocation, isNull);
  });

  test('normalizes a typed UPC-A to 13 digits like a scan', () async {
    final repository = _FakeArticleRepository();
    final container = ProviderContainer(
      overrides: [articleRepositoryProvider.overrideWithValue(repository)],
    );
    addTearDown(container.dispose);

    await container
        .read(articleFormProvider.notifier)
        .save(_request(rawEan: '978020137962'));

    expect(repository.created?.ean, '0978020137962');
  });

  test('surfaces a repository failure as AsyncError instead of throwing', () async {
    final repository = _FakeArticleRepository()
      ..errorOnCreate = Exception('boom');
    final container = ProviderContainer(
      overrides: [articleRepositoryProvider.overrideWithValue(repository)],
    );
    addTearDown(container.dispose);

    await container.read(articleFormProvider.notifier).save(_request());

    expect(container.read(articleFormProvider).hasError, isTrue);
  });
}
