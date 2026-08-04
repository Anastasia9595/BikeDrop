// test/design_system/atoms/category_badge_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bikedrop/design_system/tokens/app_colors.dart';
import 'package:bikedrop/design_system/atoms/category_badge.dart';

void main() {
  testWidgets('renders category label in the matching colors', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: CategoryBadge(category: Category.reifen)),
      ),
    );

    expect(find.text('REIFEN'), findsOneWidget);

    final container = tester.widget<Container>(find.byType(Container));
    final decoration = container.decoration as BoxDecoration;
    expect(decoration.color, AppColors.categoryColors[Category.reifen]!.background);

    final text = tester.widget<Text>(find.text('REIFEN'));
    expect(text.style!.color, AppColors.categoryColors[Category.reifen]!.text);
  });
}
