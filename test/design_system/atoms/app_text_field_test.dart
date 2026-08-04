// test/design_system/atoms/app_text_field_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bikedrop/design_system/atoms/app_text_field.dart';

void main() {
  testWidgets('shows label above the field and forwards input', (tester) async {
    String? changed;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AppTextField(
            label: 'Name',
            onChanged: (value) => changed = value,
          ),
        ),
      ),
    );

    expect(find.text('NAME'), findsOneWidget);
    await tester.enterText(find.byType(TextField), 'Kettenöl');
    expect(changed, 'Kettenöl');
  });

  testWidgets('shows error text when provided', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AppTextField(label: 'Name', errorText: 'Pflichtfeld'),
        ),
      ),
    );

    expect(find.text('Pflichtfeld'), findsOneWidget);
  });
}
