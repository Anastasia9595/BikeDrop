// test/features/item_detail_screen_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bikedrop/features/item_detail_screen.dart';

void main() {
  testWidgets('does not overflow on a common phone-sized viewport', (
    tester,
  ) async {
    addTearDown(() => tester.view.resetPhysicalSize());
    tester.view.physicalSize = const Size(390, 700);
    tester.view.devicePixelRatio = 1.0;

    await tester.pumpWidget(const MaterialApp(home: ItemDetailScreen()));

    expect(tester.takeException(), isNull);
  });
}
