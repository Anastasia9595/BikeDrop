// test/features/overview_screen_test.dart
import 'package:bikedrop/design_system/design_system.dart';
import 'package:bikedrop/features/overview_screen.dart';
import 'package:bikedrop/interface/article_interface.dart';
import 'package:bikedrop/models/article.dart';
import 'package:bikedrop/providers/article_repository_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

Article _article({required String name, required ArticleStatus status}) {
  final now = DateTime(2026, 1, 1);
  return Article(
    name: name,
    category: Category.bremsen,
    quantity: 1,
    minQuantity: 0,
    purchasePrice: 1,
    sellingPrice: 2,
    status: status,
    createdAt: now,
    updatedAt: now,
  );
}

/// Zwei "Im Shop", eins "Bestellt", keins "Fehlt" — so ist jede der drei
/// Kacheln mit einer anderen Zahl belegt.
final _articles = [
  _article(name: 'Bremsscheibe', status: ArticleStatus.inStock),
  _article(name: 'Kette', status: ArticleStatus.inStock),
  _article(name: 'Schlauch', status: ArticleStatus.bestellt),
];

class _FakeArticleRepository implements ArticleRepository {
  _FakeArticleRepository({this.articles = const []});

  final List<Article> articles;

  @override
  Future<List<Article>> getArticles() async => articles;

  @override
  Future<List<Article>> searchArticlesByName(String query) async => query.isEmpty
      ? articles
      : articles
            .where((a) => a.name.toLowerCase().contains(query.toLowerCase()))
            .toList();

  @override
  Future<Article> changeQuantity(String id, int newQuantity) =>
      throw UnimplementedError();

  @override
  Future<Article> createArticle(Article article) => throw UnimplementedError();

  @override
  Future<void> deleteArticle(String id) => throw UnimplementedError();

  @override
  Future<Article?> getArticleByEan(String ean) => throw UnimplementedError();

  @override
  Future<Article?> getArticleById(String id) => throw UnimplementedError();

  @override
  Future<List<String>> getSuppliers() async => [];

  @override
  Future<Article> updateArticle(Article article) => throw UnimplementedError();
}

Widget _wrap(List<Article> articles) {
  return ProviderScope(
    overrides: [
      articleRepositoryProvider.overrideWithValue(
        _FakeArticleRepository(articles: articles),
      ),
    ],
    child: const MaterialApp(home: OverviewScreen()),
  );
}

Future<void> _pump(WidgetTester tester, {required Size size}) async {
  addTearDown(() => tester.view.resetPhysicalSize());
  addTearDown(() => tester.view.resetDevicePixelRatio());
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;

  await tester.pumpWidget(_wrap(_articles));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('shows one card per status with the matching count', (
    tester,
  ) async {
    await _pump(tester, size: const Size(390, 780));

    expect(find.byType(KpiFilterCard), findsNWidgets(3));
    expect(find.text('Im Shop'), findsOneWidget);
    expect(find.text('Bestellt'), findsOneWidget);
    expect(find.text('Fehlt'), findsOneWidget);

    KpiFilterCard card(ArticleStatus status) => tester.widget<KpiFilterCard>(
      find.byWidgetPredicate(
        (w) => w is KpiFilterCard && w.status == status,
      ),
    );
    expect(card(ArticleStatus.inStock).value, 2);
    expect(card(ArticleStatus.bestellt).value, 1);
    expect(card(ArticleStatus.fehlt).value, 0);
  });

  testWidgets('does not overflow on a common phone-sized viewport', (
    tester,
  ) async {
    await _pump(tester, size: const Size(390, 780));

    expect(tester.takeException(), isNull);
  });

  testWidgets('does not overflow on a narrow viewport', (tester) async {
    await _pump(tester, size: const Size(320, 568));

    expect(tester.takeException(), isNull);
  });

  testWidgets('does not overflow with a large text scale', (tester) async {
    addTearDown(() => tester.view.resetPhysicalSize());
    addTearDown(() => tester.view.resetDevicePixelRatio());
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1.0;

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          articleRepositoryProvider.overrideWithValue(
            _FakeArticleRepository(articles: _articles),
          ),
        ],
        child: const MaterialApp(
          home: MediaQuery(
            data: MediaQueryData(textScaler: TextScaler.linear(1.5)),
            child: OverviewScreen(),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
  });

  testWidgets('tapping a card filters the list down to that status', (
    tester,
  ) async {
    await _pump(tester, size: const Size(390, 780));

    expect(find.text('Bremsscheibe'), findsOneWidget);
    expect(find.text('Schlauch'), findsOneWidget);

    await tester.tap(find.text('Bestellt'));
    await tester.pumpAndSettle();

    expect(find.text('Schlauch'), findsOneWidget);
    expect(find.text('Bremsscheibe'), findsNothing);
  });

  testWidgets('keeps every article of the selected status in the list', (
    tester,
  ) async {
    await _pump(tester, size: const Size(390, 780));

    await tester.tap(find.text('Im Shop'));
    await tester.pumpAndSettle();

    expect(find.byType(ItemListTile), findsNWidgets(2));
    expect(find.text('Bremsscheibe'), findsOneWidget);
    expect(find.text('Kette'), findsOneWidget);
    expect(find.text('Schlauch'), findsNothing);
  });

  testWidgets('keeps the counts of the unfiltered result while filtering', (
    tester,
  ) async {
    await _pump(tester, size: const Size(390, 780));
    await tester.tap(find.text('Bestellt'));
    await tester.pumpAndSettle();

    final inStock = tester.widget<KpiFilterCard>(
      find.byWidgetPredicate(
        (w) => w is KpiFilterCard && w.status == ArticleStatus.inStock,
      ),
    );
    expect(inStock.value, 2);
    expect(inStock.selected, isFalse);
  });

  testWidgets('tapping the active card again clears the filter', (
    tester,
  ) async {
    await _pump(tester, size: const Size(390, 780));

    await tester.tap(find.text('Bestellt'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Bestellt'));
    await tester.pumpAndSettle();

    expect(find.text('Bremsscheibe'), findsOneWidget);
    expect(find.text('Schlauch'), findsOneWidget);
  });

  testWidgets('explains an empty result caused by the status filter', (
    tester,
  ) async {
    await _pump(tester, size: const Size(390, 780));

    await tester.tap(find.text('Fehlt'));
    await tester.pumpAndSettle();

    expect(find.text('Keine Artikel mit Status „Fehlt“.'), findsOneWidget);
  });

  testWidgets('hides the cards when there is no stock at all', (tester) async {
    addTearDown(() => tester.view.resetPhysicalSize());
    tester.view.physicalSize = const Size(390, 780);
    tester.view.devicePixelRatio = 1.0;

    await tester.pumpWidget(_wrap(const []));
    await tester.pumpAndSettle();

    expect(find.byType(KpiFilterCard), findsNothing);
    expect(find.text('Noch kein Bestand erfasst'), findsOneWidget);
  });
}
