import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:bikedrop/design_system/molecules/item_list_tile.dart';
import 'package:bikedrop/design_system/tokens/app_colors.dart';

// 1x1 transparent PNG, so `Image`/`MemoryImage` can decode it synchronously
// in widget tests without needing real asset/network loading.
final _onePixelPng = base64Decode(
  'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNk+A8AAQUBAScY'
  '42YAAAAASUVORK5CYII=',
);

void main() {
  testWidgets('renders title, quantity and timestamp', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: ItemListTile(
            title: 'Shimano XT Scheibe 203',
            quantity: 12,
            category: Category.bremsen,
            timestampLabel: 'vor 4 Min',
          ),
        ),
      ),
    );

    expect(find.text('Shimano XT Scheibe 203'), findsOneWidget);
    expect(find.text('12'), findsOneWidget);
    expect(find.text('vor 4 Min'), findsOneWidget);
  });

  testWidgets('shows placeholder icon when no image is provided', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: ItemListTile(
            title: 'Kettenöl',
            quantity: 3,
            category: Category.pflege,
            timestampLabel: 'vor 1 Std',
          ),
        ),
      ),
    );

    expect(find.byIcon(Symbols.image), findsOneWidget);
    expect(find.byType(Image), findsNothing);
  });

  testWidgets('shows the image instead of the placeholder when provided', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ItemListTile(
            title: 'Kettenöl',
            quantity: 3,
            category: Category.pflege,
            timestampLabel: 'vor 1 Std',
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
            timestampLabel: 'vor 2 Min',
            onTap: () => tapped = true,
          ),
        ),
      ),
    );

    await tester.tap(find.byType(ItemListTile));
    expect(tapped, isTrue);
  });

  testWidgets('has no InkWell when onTap is not provided', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: ItemListTile(
            title: 'Bremsbelag',
            quantity: 8,
            category: Category.bremsen,
            timestampLabel: 'vor 2 Min',
          ),
        ),
      ),
    );

    expect(find.byType(InkWell), findsNothing);
  });
}
