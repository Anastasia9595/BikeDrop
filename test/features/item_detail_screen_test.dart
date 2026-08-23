// test/features/item_detail_screen_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bikedrop/design_system/design_system.dart';
import 'package:bikedrop/features/article_form_screen.dart';

void main() {
  testWidgets('does not overflow on a common phone-sized viewport', (
    tester,
  ) async {
    addTearDown(() => tester.view.resetPhysicalSize());
    tester.view.physicalSize = const Size(390, 700);
    tester.view.devicePixelRatio = 1.0;

    await tester.pumpWidget(const MaterialApp(home: ArticleFormScreen()));

    expect(tester.takeException(), isNull);
  });

  testWidgets('pads the scrollable content on all sides with screen spacing', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: ArticleFormScreen()));

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
}
