// test/features/item_detail_screen_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bikedrop/design_system/design_system.dart';
import 'package:bikedrop/features/article_form_screen.dart';
import 'package:bikedrop/interface/article_interface.dart';
import 'package:bikedrop/models/article.dart';
import 'package:bikedrop/providers/article_repository_provider.dart';

Article _buildArticle({
  String? ean,
  required String name,
  required Category category,
  String? supplier,
  required int quantity,
  required int minQuantity,
  int? maxQuantity,
  required double purchasePrice,
  required double sellingPrice,
  String? storageLocation,
  required ArticleStatus status,
  bool isPublic = false,
}) {
  final now = DateTime(2026, 1, 1);
  return Article(
    ean: ean,
    name: name,
    category: category,
    supplier: supplier,
    quantity: quantity,
    minQuantity: minQuantity,
    maxQuantity: maxQuantity,
    purchasePrice: purchasePrice,
    sellingPrice: sellingPrice,
    storageLocation: storageLocation,
    status: status,
    isPublic: isPublic,
    createdAt: now,
    updatedAt: now,
  );
}

class _FakeArticleRepository implements ArticleRepository {
  Article? created;
  Article? updated;

  @override
  Future<Article> createArticle(Article article) async {
    created = article;
    return article;
  }

  @override
  Future<Article> updateArticle(Article article) async {
    updated = article;
    return article;
  }

  @override
  Future<Article> changeQuantity(String id, int newQuantity) =>
      throw UnimplementedError();

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

Widget _wrap(Widget child, {ArticleRepository? repository}) {
  return ProviderScope(
    overrides: [
      if (repository != null)
        articleRepositoryProvider.overrideWithValue(repository),
    ],
    child: MaterialApp(home: child),
  );
}

void main() {
  testWidgets('does not overflow on a common phone-sized viewport', (
    tester,
  ) async {
    addTearDown(() => tester.view.resetPhysicalSize());
    tester.view.physicalSize = const Size(390, 700);
    tester.view.devicePixelRatio = 1.0;

    await tester.pumpWidget(_wrap(const ArticleFormScreen()));

    expect(tester.takeException(), isNull);
  });

  testWidgets('pads the scrollable content on all sides with screen spacing', (
    tester,
  ) async {
    await tester.pumpWidget(_wrap(const ArticleFormScreen()));

    final scrollView = tester.widget<SingleChildScrollView>(
      find.byType(SingleChildScrollView),
    );

    expect(
      scrollView.padding,
      const EdgeInsets.symmetric(
        horizontal: AppSpacing.screenPaddingH,
        vertical: AppSpacing.screenSpacingV,
      ),
    );
  });

  group('vorausgefülltes Bearbeiten', () {
    final article = _buildArticle(
      ean: '4055123456789',
      name: 'Shimano Deore Bremsscheibe 180mm',
      category: Category.bremsen,
      supplier: 'Shimano',
      quantity: 14,
      minQuantity: 5,
      purchasePrice: 18.5,
      sellingPrice: 34.9,
      storageLocation: 'Regal C3',
      status: ArticleStatus.fehlt,
      isPublic: true,
    );

    testWidgets('shows "Artikel bearbeiten" as the title', (tester) async {
      await tester.pumpWidget(_wrap(ArticleFormScreen(article: article)));

      expect(find.text('Artikel bearbeiten'), findsOneWidget);
      expect(find.text('Neuer Artikel'), findsNothing);
    });

    testWidgets('pre-fills the text fields from the article', (tester) async {
      await tester.pumpWidget(_wrap(ArticleFormScreen(article: article)));

      expect(find.text('4055123456789'), findsOneWidget);
      expect(find.text('Shimano Deore Bremsscheibe 180mm'), findsOneWidget);
      expect(find.text('5'), findsOneWidget);
      expect(find.text('18.5'), findsOneWidget);
      expect(find.text('34.9'), findsOneWidget);
      expect(find.text('Regal C3'), findsOneWidget);
    });

    testWidgets('pre-selects category, supplier, quantity and status', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap(ArticleFormScreen(article: article)));

      expect(find.text('Bremsen'), findsOneWidget);
      expect(find.text('Shimano'), findsOneWidget);
      expect(find.text('14'), findsOneWidget);
      expect(find.text('Fehlt'), findsOneWidget);
    });

    testWidgets('pre-fills a supplier not in the default dropdown list', (
      tester,
    ) async {
      final withCustomSupplier = _buildArticle(
        name: 'Nabendynamo',
        category: Category.laufraeder,
        supplier: 'Custom Supplier GmbH',
        quantity: 1,
        minQuantity: 1,
        purchasePrice: 10,
        sellingPrice: 20,
        status: ArticleStatus.inStock,
      );

      await tester.pumpWidget(
        _wrap(ArticleFormScreen(article: withCustomSupplier)),
      );

      expect(find.text('Custom Supplier GmbH'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('shows "Änderungen speichern" as the button label', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap(ArticleFormScreen(article: article)));

      expect(find.text('Änderungen speichern'), findsOneWidget);
      expect(find.text('Artikel speichern'), findsNothing);
    });
  });

  group('Speichern über das Repository', () {
    testWidgets(
      'calls updateArticle with the edited values and pops the screen',
      (tester) async {
        final article = _buildArticle(
          name: 'Alter Name',
          category: Category.bremsen,
          quantity: 5,
          minQuantity: 1,
          purchasePrice: 1,
          sellingPrice: 2,
          status: ArticleStatus.inStock,
        );
        final repository = _FakeArticleRepository();

        await tester.pumpWidget(
          _wrap(
            Navigator(
              onGenerateRoute: (settings) => MaterialPageRoute(
                builder: (_) => ArticleFormScreen(article: article),
              ),
            ),
            repository: repository,
          ),
        );

        await tester.enterText(find.text('Alter Name'), 'Neuer Name');
        await tester.tap(find.text('Änderungen speichern'));
        await tester.pumpAndSettle();

        expect(repository.updated?.name, 'Neuer Name');
        expect(repository.updated?.id, article.id);
        expect(find.byType(ArticleFormScreen), findsNothing);
      },
    );

    testWidgets('calls createArticle when there is no existing article', (
      tester,
    ) async {
      final repository = _FakeArticleRepository();

      await tester.pumpWidget(
        _wrap(const ArticleFormScreen(), repository: repository),
      );

      // TextField #1 is "Artikelname" (index 0 is "Artikelnummer").
      await tester.enterText(find.byType(TextField).at(1), 'Testartikel');
      await tester.tap(find.byType(DropdownButton<Category>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Bremsen').last);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Artikel speichern'));
      await tester.pumpAndSettle();

      expect(repository.created?.name, 'Testartikel');
      expect(repository.created?.category, Category.bremsen);
    });

    testWidgets('disables the save button when the name is empty', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap(const ArticleFormScreen()));

      final button = tester.widget<ElevatedButton>(
        find.widgetWithText(ElevatedButton, 'Artikel speichern'),
      );
      expect(button.onPressed, isNull);
    });
  });

  group('Höchstbestand', () {
    Finder maxField() => find.byWidgetPredicate(
      (widget) => widget is AppTextField && widget.label == 'Höchstbestand',
    );

    Finder maxInput() =>
        find.descendant(of: maxField(), matching: find.byType(TextField));

    ElevatedButton saveButton(WidgetTester tester) => tester.widget(
      find.widgetWithText(ElevatedButton, 'Änderungen speichern'),
    );

    Article articleWith({int quantity = 10, int? maxQuantity}) => _buildArticle(
      name: 'Speiche',
      category: Category.laufraeder,
      quantity: quantity,
      minQuantity: 5,
      maxQuantity: maxQuantity,
      purchasePrice: 0.45,
      sellingPrice: 0.95,
      status: ArticleStatus.inStock,
    );

    testWidgets('leaves the stepper unbounded when the article has no limit', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap(ArticleFormScreen(article: articleWith())));

      expect(
        tester.widget<QuantityStepper>(find.byType(QuantityStepper)).max,
        isNull,
      );
      expect(find.text('unbegrenzt'), findsOneWidget);
    });

    testWidgets('passes the article limit to the stepper', (tester) async {
      await tester.pumpWidget(
        _wrap(ArticleFormScreen(article: articleWith(maxQuantity: 500))),
      );

      expect(
        tester.widget<QuantityStepper>(find.byType(QuantityStepper)).max,
        500,
      );
      expect(find.text('500'), findsOneWidget);
    });

    testWidgets('blocks saving a limit below the current quantity', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(ArticleFormScreen(article: articleWith(quantity: 128))),
      );

      await tester.enterText(maxInput(), '100');
      await tester.pump();

      expect(
        find.text('Darf nicht unter der aktuellen Menge liegen'),
        findsOneWidget,
      );
      expect(saveButton(tester).onPressed, isNull);
    });

    testWidgets('blocks saving a limit below the minimum stock', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(ArticleFormScreen(article: articleWith(quantity: 1))),
      );

      await tester.enterText(maxInput(), '3');
      await tester.pump();

      expect(
        find.text('Darf nicht unter dem Mindestbestand liegen'),
        findsOneWidget,
      );
      expect(saveButton(tester).onPressed, isNull);
    });

    testWidgets('keeps the stepper open while the entered limit is invalid', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(ArticleFormScreen(article: articleWith(quantity: 128))),
      );

      await tester.enterText(maxInput(), '100');
      await tester.pump();

      expect(
        tester.widget<QuantityStepper>(find.byType(QuantityStepper)).max,
        isNull,
      );
    });

    testWidgets('saves the entered limit', (tester) async {
      final repository = _FakeArticleRepository();

      await tester.pumpWidget(
        _wrap(
          Navigator(
            onGenerateRoute: (settings) => MaterialPageRoute(
              builder: (_) => ArticleFormScreen(article: articleWith()),
            ),
          ),
          repository: repository,
        ),
      );

      await tester.enterText(maxInput(), '250');
      await tester.pump();
      await tester.tap(find.text('Änderungen speichern'));
      await tester.pumpAndSettle();

      expect(repository.updated?.maxQuantity, 250);
    });

    testWidgets('clears the limit when the field is emptied', (tester) async {
      final repository = _FakeArticleRepository();

      await tester.pumpWidget(
        _wrap(
          Navigator(
            onGenerateRoute: (settings) => MaterialPageRoute(
              builder: (_) =>
                  ArticleFormScreen(article: articleWith(maxQuantity: 500)),
            ),
          ),
          repository: repository,
        ),
      );

      await tester.enterText(maxInput(), '');
      await tester.pump();
      await tester.tap(find.text('Änderungen speichern'));
      await tester.pumpAndSettle();

      expect(repository.updated?.maxQuantity, isNull);
    });
  });
}
