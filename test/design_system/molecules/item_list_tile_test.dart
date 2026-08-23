import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:bikedrop/design_system/molecules/item_list_tile.dart';
import 'package:bikedrop/design_system/tokens/app_colors.dart';
import 'package:bikedrop/enums/category.dart';
import 'package:bikedrop/enums/article_status.dart';

// 1x1 transparent PNG, so `Image`/`MemoryImage` can decode it synchronously
// in widget tests without needing real asset/network loading.
final _onePixelPng = base64Decode(
  'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNk+A8AAQUBAScY'
  '42YAAAAASUVORK5CYII=',
);

Finder _statusDotFinder() => find.byWidgetPredicate(
  (widget) =>
      widget is Container &&
      (widget.decoration as BoxDecoration?)?.shape == BoxShape.circle,
);

void main() {
  testWidgets('renders title and quantity', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: ItemListTile(
            title: 'Shimano XT Scheibe 203',
            quantity: 12,
            category: Category.bremsen,
            status: ArticleStatus.inStock,
          ),
        ),
      ),
    );

    expect(find.text('Shimano XT Scheibe 203'), findsOneWidget);
    expect(find.text('12'), findsOneWidget);
  });

  group('Bestand-Status', () {
    testWidgets(
      'renders no stock status for inStock (Normalfall, Menge reicht)',
      (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: ItemListTile(
                title: 'Kettenöl',
                quantity: 3,
                category: Category.pflege,
                status: ArticleStatus.inStock,
              ),
            ),
          ),
        );

        expect(find.text('Im Shop'), findsNothing);
        expect(_statusDotFinder(), findsNothing);
      },
    );

    testWidgets('renders red dot + "Fehlt" for fehlt', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ItemListTile(
              title: 'Kettenöl',
              quantity: 3,
              category: Category.pflege,
              status: ArticleStatus.fehlt,
            ),
          ),
        ),
      );

      expect(find.text('Fehlt'), findsOneWidget);
      final dot = tester.widget<Container>(_statusDotFinder());
      expect(
        (dot.decoration as BoxDecoration).color,
        AppColors.statusColors[ArticleStatus.fehlt],
      );
    });

    testWidgets('renders amber dot + "Bestellt +n" for bestellt', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ItemListTile(
              title: 'Kettenöl',
              quantity: 3,
              category: Category.pflege,
              status: ArticleStatus.bestellt,
              reorderedQuantity: 10,
            ),
          ),
        ),
      );

      expect(find.text('Bestellt +10'), findsOneWidget);
      final dot = tester.widget<Container>(_statusDotFinder());
      expect(
        (dot.decoration as BoxDecoration).color,
        AppColors.statusColors[ArticleStatus.bestellt],
      );
    });
  });

  group('Sichtbarkeits-Status', () {
    testWidgets('renders nothing when isPublic is true (Normalfall)', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ItemListTile(
              title: 'Kettenöl',
              quantity: 3,
              category: Category.pflege,
              status: ArticleStatus.inStock,
              isPublic: true,
            ),
          ),
        ),
      );

      expect(find.text('Nicht online'), findsNothing);
      expect(find.byIcon(Icons.visibility_off_outlined), findsNothing);
    });

    testWidgets('renders icon + "Nicht online" when isPublic is false', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ItemListTile(
              title: 'Kettenöl',
              quantity: 3,
              category: Category.pflege,
              status: ArticleStatus.inStock,
              isPublic: false,
            ),
          ),
        ),
      );

      expect(find.text('Nicht online'), findsOneWidget);
      expect(find.byIcon(Icons.visibility_off_outlined), findsOneWidget);
    });
  });

  testWidgets(
    'does not overflow with three badges on a narrow screen',
    (tester) async {
      tester.view.physicalSize = const Size(360, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ItemListTile(
              title: 'Bosch PowerTube 625Wh',
              quantity: 2,
              category: Category.eBike,
              status: ArticleStatus.bestellt,
              reorderedQuantity: 5,
              isPublic: false,
            ),
          ),
        ),
      );

      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'meta row keeps the same tile height with and without any status',
    (tester) async {
      Future<Size> pumpAndMeasure(ItemListTile tile) async {
        await tester.pumpWidget(
          MaterialApp(home: Scaffold(body: tile)),
        );
        return tester.getSize(find.byType(ItemListTile));
      }

      final withoutStatus = await pumpAndMeasure(
        const ItemListTile(
          title: 'Kettenöl',
          quantity: 3,
          category: Category.pflege,
          status: ArticleStatus.inStock,
          isPublic: true,
        ),
      );

      final withBothStatuses = await pumpAndMeasure(
        const ItemListTile(
          title: 'Kettenöl',
          quantity: 3,
          category: Category.pflege,
          status: ArticleStatus.bestellt,
          reorderedQuantity: 5,
          isPublic: false,
        ),
      );

      expect(withBothStatuses.height, withoutStatus.height);
    },
  );

  testWidgets('shows placeholder icon when no image is provided', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: ItemListTile(
            title: 'Kettenöl',
            quantity: 3,
            category: Category.pflege,
            status: ArticleStatus.fehlt,
          ),
        ),
      ),
    );

    expect(find.byIcon(Symbols.image), findsOneWidget);
    expect(find.byType(Image), findsNothing);
  });

  testWidgets('shows the image instead of the placeholder when provided', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ItemListTile(
            title: 'Kettenöl',
            quantity: 3,
            category: Category.pflege,
            status: ArticleStatus.fehlt,
            image: MemoryImage(_onePixelPng),
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.byType(Image), findsOneWidget);
    expect(find.byIcon(Symbols.image), findsNothing);
  });

  testWidgets('calls onTap when tapped', (tester) async {
    var tapped = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ItemListTile(
            title: 'Bremsbelag',
            quantity: 8,
            category: Category.bremsen,
            status: ArticleStatus.bestellt,
            reorderedQuantity: 5,
            onTap: () => tapped = true,
          ),
        ),
      ),
    );

    await tester.tap(find.byType(ItemListTile));
    expect(tapped, isTrue);
  });

  testWidgets('does not wrap the row in a tappable Material when onTap is not provided', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: ItemListTile(
            title: 'Bremsbelag',
            quantity: 8,
            category: Category.bremsen,
            status: ArticleStatus.bestellt,
            reorderedQuantity: 5,
          ),
        ),
      ),
    );

    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is Material && widget.type == MaterialType.transparency,
      ),
      findsNothing,
    );
  });

  group('Mengenanzeige', () {
    testWidgets('calls onQuantityTap when the quantity field is tapped', (
      tester,
    ) async {
      var quantityTapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ItemListTile(
              title: 'Bremsbelag',
              quantity: 8,
              category: Category.bremsen,
              status: ArticleStatus.bestellt,
              reorderedQuantity: 5,
              onQuantityTap: () => quantityTapped = true,
            ),
          ),
        ),
      );

      await tester.tap(find.text('8'));
      expect(quantityTapped, isTrue);
    });

    testWidgets(
      'does not trigger the row onTap when the quantity field is tapped',
      (tester) async {
        var rowTapped = false;
        var quantityTapped = false;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ItemListTile(
                title: 'Bremsbelag',
                quantity: 8,
                category: Category.bremsen,
                status: ArticleStatus.bestellt,
                reorderedQuantity: 5,
                onTap: () => rowTapped = true,
                onQuantityTap: () => quantityTapped = true,
              ),
            ),
          ),
        );

        await tester.tap(find.text('8'));

        expect(quantityTapped, isTrue);
        expect(rowTapped, isFalse);
      },
    );
  });
}
