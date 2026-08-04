import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bikedrop/design_system/atoms/app_primary_button.dart';

void main() {
  testWidgets('renders label and calls onPressed when tapped', (tester) async {
    var tapped = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AppPrimaryButton(
            label: 'Speichern',
            onPressed: () => tapped = true,
          ),
        ),
      ),
    );

    expect(find.text('Speichern'), findsOneWidget);
    await tester.tap(find.byType(AppPrimaryButton));
    expect(tapped, isTrue);
  });

  testWidgets('does not call onPressed when disabled', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AppPrimaryButton(label: 'Speichern', onPressed: null),
        ),
      ),
    );

    final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
    expect(button.onPressed, isNull);
  });

  testWidgets('shows icon when provided', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AppPrimaryButton(label: 'Speichern', icon: Icons.check, onPressed: () {}),
        ),
      ),
    );

    expect(find.byIcon(Icons.check), findsOneWidget);
  });
}
