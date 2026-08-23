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

  group('editable', () {
    testWidgets('shows a plain Text instead of a TextField by default', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(QuantityStepper(label: 'Menge', quantity: 12, onChanged: (_) {})),
      );

      expect(find.byType(TextField), findsNothing);
    });

    testWidgets('shows an editable TextField when editable is true', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(
          QuantityStepper(
            label: 'Menge',
            quantity: 12,
            editable: true,
            onChanged: (_) {},
          ),
        ),
      );

      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('only accepts digits while typing', (tester) async {
      await tester.pumpWidget(
        _wrap(
          QuantityStepper(
            label: 'Menge',
            quantity: 12,
            editable: true,
            onChanged: (_) {},
          ),
        ),
      );

      await tester.enterText(find.byType(TextField), 'a9b9c');

      final field = tester.widget<TextField>(find.byType(TextField));
      expect(field.controller!.text, '99');
    });

    testWidgets('calls onChanged with the parsed value on submit', (
      tester,
    ) async {
      int? changed;

      await tester.pumpWidget(
        _wrap(
          QuantityStepper(
            label: 'Menge',
            quantity: 12,
            editable: true,
            onChanged: (value) => changed = value,
          ),
        ),
      );

      await tester.enterText(find.byType(TextField), '42');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump();

      expect(changed, 42);
    });

    testWidgets('clamps submitted values to min/max', (tester) async {
      int? changed;

      await tester.pumpWidget(
        _wrap(
          QuantityStepper(
            label: 'Menge',
            quantity: 5,
            min: 0,
            max: 10,
            editable: true,
            onChanged: (value) => changed = value,
          ),
        ),
      );

      await tester.enterText(find.byType(TextField), '999');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump();

      expect(changed, 10);
    });

    testWidgets('reverts to the current quantity when input is empty', (
      tester,
    ) async {
      int? changed;

      await tester.pumpWidget(
        _wrap(
          QuantityStepper(
            label: 'Menge',
            quantity: 12,
            editable: true,
            onChanged: (value) => changed = value,
          ),
        ),
      );

      await tester.enterText(find.byType(TextField), '');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump();

      expect(changed, isNull);
      final field = tester.widget<TextField>(find.byType(TextField));
      expect(field.controller!.text, '12');
    });
  });

  group('showBorder / showLabel', () {
    testWidgets('shows the border and label by default', (tester) async {
      await tester.pumpWidget(
        _wrap(QuantityStepper(label: 'Menge', quantity: 12, onChanged: (_) {})),
      );

      expect(find.text('MENGE'), findsOneWidget);
      final container = tester.widget<Container>(
        find.byWidgetPredicate(
          (widget) =>
              widget is Container &&
              (widget.decoration as BoxDecoration?)?.border != null,
        ),
      );
      expect((container.decoration as BoxDecoration).border, isNotNull);
    });

    testWidgets('hides the border when showBorder is false', (tester) async {
      await tester.pumpWidget(
        _wrap(
          QuantityStepper(
            label: 'Menge',
            quantity: 12,
            showBorder: false,
            onChanged: (_) {},
          ),
        ),
      );

      expect(
        find.byWidgetPredicate(
          (widget) =>
              widget is Container &&
              (widget.decoration as BoxDecoration?)?.border != null,
        ),
        findsNothing,
      );
    });

    testWidgets('hides the label when showLabel is false', (tester) async {
      await tester.pumpWidget(
        _wrap(
          QuantityStepper(
            label: 'Menge',
            quantity: 12,
            showLabel: false,
            onChanged: (_) {},
          ),
        ),
      );

      expect(find.text('MENGE'), findsNothing);
    });
  });
}
