import 'package:bikedrop/design_system/design_system.dart';
import 'package:bikedrop/interface/article_interface.dart';
import 'package:bikedrop/models/article.dart';
import 'package:bikedrop/models/receivingcartitem.dart';
import 'package:bikedrop/providers/article_repository_provider.dart';
import 'package:bikedrop/providers/receiving_cart_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _SeededCartNotifier extends ReceivingCartNotifier {
  _SeededCartNotifier(this._seed);
  final List<ReceivingCartItem> _seed;

  @override
  List<ReceivingCartItem> build() => _seed;
}

class _FakeArticleRepository implements ArticleRepository {
  _FakeArticleRepository({this.byEan = const {}});
  final Map<String, Article> byEan;

  @override
  Future<Article?> getArticleByEan(String ean) async => byEan[ean];
  @override
  Future<List<Article>> getArticles() async => byEan.values.toList();
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
  Future<List<String>> getSuppliers() async => [];
}

Article _article({required String ean, required String name}) {
  final now = DateTime(2026, 1, 1);
  return Article(
    ean: ean,
    name: name,
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

Future<ProviderContainer> _pump(
  WidgetTester tester, {
  required List<ReceivingCartItem> seed,
  Map<String, Article> articlesByEan = const {},
}) async {
  // Realistische Telefonhoehe statt der 600dp-Testvorgabe: bei der ist die
  // Peek-Box (minChildSize-Anteil davon) zu knapp, um zuverlaessig 2 Zeilen
  // zu zeigen — die ListView ist lazy und baut sonst nur, was ins (sehr
  // kleine) Viewport passt.
  tester.view.physicalSize = const Size(393, 852);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  late final ProviderContainer container;
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        receivingCartProvider.overrideWith(() => _SeededCartNotifier(seed)),
        articleRepositoryProvider.overrideWithValue(_FakeArticleRepository(byEan: articlesByEan)),
      ],
      child: Builder(
        builder: (context) {
          container = ProviderScope.containerOf(context);
          return const MaterialApp(
            home: Scaffold(body: ReceivingCartSheet()),
          );
        },
      ),
    ),
  );
  await tester.pumpAndSettle();
  return container;
}

/// Ein Item mit `resolvedArticle` — zaehlt als `ReceivingScanStatus.inStock`,
/// im Unterschied zu einem bloss aus `ean`/`quantity` gebauten Item, das
/// sonst als `unknown` gelten wuerde.
ReceivingCartItem _known({required String ean, required int quantity}) {
  return ReceivingCartItem(
    ean: ean,
    quantity: quantity,
    resolvedArticle: _article(ean: ean, name: 'Artikel $ean'),
  );
}

void main() {
  testWidgets('shows nothing when the cart is empty', (tester) async {
    await _pump(tester, seed: const []);

    expect(find.byType(DraggableScrollableSheet), findsNothing);
  });

  testWidgets('peek state shows at most 2 rows and no filters or CTA', (tester) async {
    await _pump(
      tester,
      seed: [
        _known(ean: '1', quantity: 1),
        _known(ean: '2', quantity: 1),
        _known(ean: '3', quantity: 1),
      ],
    );

    expect(tester.takeException(), isNull);
    expect(find.byType(DraggableScrollableSheet), findsOneWidget);
    expect(find.byType(ReceivingCartItemTile), findsNWidgets(2));
    expect(find.byType(KpiFilterRow), findsNothing);
    expect(find.textContaining('Wareneingang abschließen'), findsNothing);
  });

  testWidgets('peek state with a single row does not throw a layout error', (tester) async {
    await _pump(tester, seed: [_known(ean: '1', quantity: 1)]);

    expect(tester.takeException(), isNull);
    expect(find.byType(ReceivingCartItemTile), findsOneWidget);
  });

  testWidgets('tapping the expand icon reveals the header, filters, full list and CTA', (
    tester,
  ) async {
    await _pump(
      tester,
      seed: [
        _known(ean: '1', quantity: 2),
        _known(ean: '2', quantity: 1),
        _known(ean: '3', quantity: 1),
      ],
    );

    await tester.tap(find.byTooltip('Warenkorb ganz anzeigen'));
    await tester.pumpAndSettle();

    expect(find.byType(KpiFilterRow), findsOneWidget);
    expect(find.byType(ReceivingCartItemTile), findsNWidgets(3));
    expect(find.text('Wareneingang abschließen (3 Artikel)'), findsOneWidget);
    expect(find.textContaining('3 Positionen'), findsOneWidget);
    expect(find.textContaining('4 Stk'), findsOneWidget);
  });

  testWidgets('dragging the handle all the way up also reveals the full view without overflowing', (
    tester,
  ) async {
    await _pump(
      tester,
      seed: [
        _known(ean: '1', quantity: 2),
        _known(ean: '2', quantity: 1),
        _known(ean: '3', quantity: 1),
      ],
    );

    await tester.dragFrom(
      tester.getCenter(find.byKey(const ValueKey('receiving-cart-drag-handle'))),
      const Offset(0, -700),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.byType(KpiFilterRow), findsOneWidget);
    expect(find.byType(ReceivingCartItemTile), findsNWidgets(3));
  });

  testWidgets('dragging a list item does not resize the sheet, only scrolls the list', (
    tester,
  ) async {
    await _pump(
      tester,
      seed: [
        _known(ean: '1', quantity: 1),
        _known(ean: '2', quantity: 1),
      ],
    );

    await tester.dragFrom(
      tester.getCenter(find.byType(ReceivingCartItemTile).first),
      const Offset(0, -700),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.byType(KpiFilterRow), findsNothing);
    expect(find.textContaining('Wareneingang abschließen'), findsNothing);
  });

  testWidgets('dragging the handle down from the expanded view collapses back to peek', (
    tester,
  ) async {
    await _pump(
      tester,
      seed: [
        _known(ean: '1', quantity: 2),
        _known(ean: '2', quantity: 1),
        _known(ean: '3', quantity: 1),
      ],
    );

    await tester.tap(find.byTooltip('Warenkorb ganz anzeigen'));
    await tester.pumpAndSettle();
    expect(find.byType(KpiFilterRow), findsOneWidget);

    await tester.dragFrom(
      tester.getCenter(find.byKey(const ValueKey('receiving-cart-drag-handle'))),
      const Offset(0, 700),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.byType(KpiFilterRow), findsNothing);
  });

  testWidgets('tapping the collapse icon in the expanded view returns to the peek state', (
    tester,
  ) async {
    await _pump(
      tester,
      seed: [
        _known(ean: '1', quantity: 2),
        _known(ean: '2', quantity: 1),
        _known(ean: '3', quantity: 1),
      ],
    );

    await tester.tap(find.byTooltip('Warenkorb ganz anzeigen'));
    await tester.pumpAndSettle();
    expect(find.byType(KpiFilterRow), findsOneWidget);

    await tester.tap(find.byTooltip('Warenkorb einklappen'));
    await tester.pumpAndSettle();

    expect(find.byType(KpiFilterRow), findsNothing);
    expect(find.byType(ReceivingCartItemTile), findsNWidgets(2));
  });

  testWidgets('tapping a filter chip narrows the expanded list', (tester) async {
    await _pump(
      tester,
      seed: [
        _known(ean: '1', quantity: 1),
        const ReceivingCartItem(ean: '978020137962', quantity: 1),
      ],
    );

    await tester.tap(find.byTooltip('Warenkorb ganz anzeigen'));
    await tester.pumpAndSettle();
    expect(find.byType(ReceivingCartItemTile), findsNWidgets(2));

    await tester.tap(find.text('Unbekannt'));
    await tester.pumpAndSettle();

    expect(find.byType(ReceivingCartItemTile), findsNWidgets(1));
    expect(find.text('Unbekannter Artikel'), findsOneWidget);
  });

  testWidgets('the quantity stepper updates the cart provider', (tester) async {
    final container = await _pump(tester, seed: [_known(ean: '1', quantity: 1)]);

    await tester.tap(find.byTooltip('Warenkorb ganz anzeigen'));
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Menge erhöhen'));
    await tester.pumpAndSettle();

    expect(container.read(receivingCartProvider).single.quantity, 2);
  });

  testWidgets('Anlegen pushes ArticleFormScreen and resolves the row afterwards', (tester) async {
    final container = await _pump(
      tester,
      seed: const [ReceivingCartItem(ean: '978020137962', quantity: 1)],
      articlesByEan: {'978020137962': _article(ean: '978020137962', name: 'Neuer Artikel')},
    );

    await tester.tap(find.byTooltip('Warenkorb ganz anzeigen'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Anlegen'));
    await tester.pumpAndSettle();
    expect(find.text('Neuer Artikel'), findsOneWidget);

    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();

    expect(container.read(receivingCartProvider).single.resolvedArticle?.name, 'Neuer Artikel');
  });

  testWidgets('Anlegen prefills EAN and the suggested name in the form', (tester) async {
    await _pump(
      tester,
      seed: const [
        ReceivingCartItem(
          ean: '4090123456781',
          quantity: 1,
          suggestedName: 'Rücklicht Pulse X1',
        ),
      ],
    );

    await tester.tap(find.text('Anlegen'));
    await tester.pumpAndSettle();

    expect(find.text('4090123456781'), findsOneWidget);
    expect(find.text('Rücklicht Pulse X1'), findsOneWidget);
  });

  testWidgets('Wareneingang abschließen is disabled while an unresolved unknown item remains', (
    tester,
  ) async {
    await _pump(
      tester,
      seed: [
        _known(ean: '1', quantity: 1),
        const ReceivingCartItem(ean: '978020137962', quantity: 1),
      ],
    );

    await tester.tap(find.byTooltip('Warenkorb ganz anzeigen'));
    await tester.pumpAndSettle();

    final button = tester.widget<AppPrimaryButton>(find.byType(AppPrimaryButton));
    expect(button.onPressed, isNull);
  });

  testWidgets('Wareneingang abschließen is enabled once no unknown item remains', (tester) async {
    await _pump(tester, seed: [_known(ean: '1', quantity: 1)]);

    await tester.tap(find.byTooltip('Warenkorb ganz anzeigen'));
    await tester.pumpAndSettle();

    final button = tester.widget<AppPrimaryButton>(find.byType(AppPrimaryButton));
    expect(button.onPressed, isNotNull);
  });

  testWidgets(
    'Wareneingang abschließen becomes enabled after the last unknown item is resolved',
    (tester) async {
      await _pump(
        tester,
        seed: const [ReceivingCartItem(ean: '978020137962', quantity: 1)],
        articlesByEan: {'978020137962': _article(ean: '978020137962', name: 'Neuer Artikel')},
      );

      await tester.tap(find.byTooltip('Warenkorb ganz anzeigen'));
      await tester.pumpAndSettle();
      expect(
        tester.widget<AppPrimaryButton>(find.byType(AppPrimaryButton)).onPressed,
        isNull,
      );

      await tester.tap(find.text('Anlegen'));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();

      expect(
        tester.widget<AppPrimaryButton>(find.byType(AppPrimaryButton)).onPressed,
        isNotNull,
      );
    },
  );
}
