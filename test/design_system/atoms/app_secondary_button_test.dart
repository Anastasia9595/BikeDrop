import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bikedrop/design_system/atoms/app_secondary_button.dart';

void main() {
  testWidgets('renders label and calls onPressed when tapped', (tester) async {
    var tapped = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AppSecondaryButton(label: 'Abbrechen', onPressed: () => tapped = true),
        ),
      ),
    );

    expect(find.text('Abbrechen'), findsOneWidget);
    await tester.tap(find.byType(AppSecondaryButton));
    expect(tapped, isTrue);
  });
}
