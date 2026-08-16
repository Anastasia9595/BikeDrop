// test/design_system/molecules/quantity_stepper_test.dart
import 'package:bikedrop/design_system/molecules/quantity_stepper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _wrap(Widget child) =>
    MaterialApp(home: Scaffold(body: Center(child: child)));

final _decrement = find.byTooltip('Menge verringern');
final _increment = find.byTooltip('Menge erhöhen');

void main() {
  testWidgets('shows the current quantity', (tester) async {
    await tester.pumpWidget(
      _wrap(QuantityStepper(label: 'Menge', quantity: 12, onChanged: (_) {})),
    );

    expect(find.text('12'), findsOneWidget);
  });

  testWidgets('keeps the label on a single line instead of wrapping', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        QuantityStepper(label: 'Mindestbestand', quantity: 1, onChanged: (_) {}),
      ),
    );

    final label = tester.widget<Text>(find.text('MINDESTBESTAND'));
    expect(label.maxLines, 1);
    expect(label.overflow, TextOverflow.ellipsis);
  });

  testWidgets('increments by one', (tester) async {
    int? changed;

    await tester.pumpWidget(
      _wrap(
        QuantityStepper(
          label: 'Menge',
          quantity: 12,
          onChanged: (value) => changed = value,
        ),
      ),
    );
    await tester.tap(_increment);

    expect(changed, 13);
  });

  testWidgets('decrements by one', (tester) async {
    int? changed;

    await tester.pumpWidget(
      _wrap(
        QuantityStepper(
          label: 'Menge',
          quantity: 12,
          onChanged: (value) => changed = value,
        ),
      ),
    );
    await tester.tap(_decrement);

    expect(changed, 11);
  });

  testWidgets('does not decrement below min', (tester) async {
    int? changed;

    await tester.pumpWidget(
      _wrap(
        QuantityStepper(
          label: 'Menge',
          quantity: 0,
          onChanged: (value) => changed = value,
        ),
      ),
    );
    await tester.tap(_decrement);

    expect(changed, isNull);
  });

  testWidgets('does not increment above max', (tester) async {
    int? changed;

    await tester.pumpWidget(
      _wrap(
        QuantityStepper(
          label: 'Menge',
          quantity: 5,
          max: 5,
          onChanged: (value) => changed = value,
        ),
      ),
    );
    await tester.tap(_increment);

    expect(changed, isNull);
  });

  testWidgets('increments without an upper bound when max is null', (
    tester,
  ) async {
    int? changed;

    await tester.pumpWidget(
      _wrap(
        QuantityStepper(
          label: 'Menge',
          quantity: 9999,
          onChanged: (value) => changed = value,
        ),
      ),
    );
    await tester.tap(_increment);

    expect(changed, 10000);
  });

  testWidgets('respects a custom min', (tester) async {
    int? changed;

    await tester.pumpWidget(
      _wrap(
        QuantityStepper(
          label: 'Menge',
          quantity: 1,
          min: 1,
          onChanged: (value) => changed = value,
        ),
      ),
    );
    await tester.tap(_decrement);

    expect(changed, isNull);
  });
}
