import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bikedrop/design_system/organisms/quantity_edit_sheet.dart';

Future<int?> _open(
  WidgetTester tester, {
  int initialQuantity = 9,
  int min = 0,
  int? max,
}) async {
  int? result;

  await tester.pumpWidget(
    MaterialApp(
      home: Builder(
        builder:
            (context) => Scaffold(
              body: ElevatedButton(
                onPressed: () async {
                  result = await QuantityEditSheet.show(
                    context,
                    title: 'KMC Kette X11',
                    subtitle: 'Regal C3 · aktuell $initialQuantity Stk.',
                    initialQuantity: initialQuantity,
                    min: min,
                    max: max,
                  );
                },
                child: const Text('Trigger'),
              ),
            ),
      ),
    ),
  );

  await tester.tap(find.text('Trigger'));
  await tester.pumpAndSettle();

  return result;
}

void main() {
  testWidgets('shows title, subtitle and the initial quantity', (
    tester,
  ) async {
    await _open(tester, initialQuantity: 9);

    expect(find.text('KMC Kette X11'), findsOneWidget);
    expect(find.text('Regal C3 · aktuell 9 Stk.'), findsOneWidget);
    expect(find.text('9'), findsOneWidget);
  });

  testWidgets('increments via the stepper and updates the button label', (
    tester,
  ) async {
    await _open(tester, initialQuantity: 9);

    await tester.tap(find.byTooltip('Menge erhöhen'));
    await tester.pump();
    await tester.tap(find.byTooltip('Menge erhöhen'));
    await tester.pump();

    expect(find.text('11'), findsOneWidget);
    expect(find.text('Bestand auf 11 setzen'), findsOneWidget);
    expect(find.text('+2'), findsOneWidget);
  });

  testWidgets('shows a negative delta when decremented', (tester) async {
    await _open(tester, initialQuantity: 9);

    await tester.tap(find.byTooltip('Menge verringern'));
    await tester.pump();

    expect(find.text('-1'), findsOneWidget);
  });

  testWidgets('shows no delta when the quantity is unchanged', (
    tester,
  ) async {
    await _open(tester, initialQuantity: 9);

    expect(find.textContaining('+0'), findsNothing);
    expect(find.text('0'), findsNothing);
  });

  testWidgets('resolves the awaited Future with the confirmed quantity', (
    tester,
  ) async {
    int? result;

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder:
              (context) => Scaffold(
                body: ElevatedButton(
                  onPressed: () async {
                    result = await QuantityEditSheet.show(
                      context,
                      title: 'KMC Kette X11',
                      subtitle: 'aktuell 9 Stk.',
                      initialQuantity: 9,
                    );
                  },
                  child: const Text('Trigger'),
                ),
              ),
        ),
      ),
    );

    await tester.tap(find.text('Trigger'));
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Menge erhöhen'));
    await tester.pump();
    await tester.tap(find.text('Bestand auf 10 setzen'));
    await tester.pumpAndSettle();

    expect(result, 10);
  });

  testWidgets('disables the confirm button while the quantity is unchanged', (
    tester,
  ) async {
    await _open(tester, initialQuantity: 9);

    final button = tester.widget<ElevatedButton>(
      find.widgetWithText(ElevatedButton, 'Bestand auf 9 setzen'),
    );
    expect(button.onPressed, isNull);
  });

  testWidgets('enables the confirm button once the quantity changes', (
    tester,
  ) async {
    await _open(tester, initialQuantity: 9);

    await tester.tap(find.byTooltip('Menge erhöhen'));
    await tester.pump();

    final button = tester.widget<ElevatedButton>(
      find.widgetWithText(ElevatedButton, 'Bestand auf 10 setzen'),
    );
    expect(button.onPressed, isNotNull);
  });

  testWidgets('respects min so the decrement button disables at the floor', (
    tester,
  ) async {
    await _open(tester, initialQuantity: 0, min: 0);

    final decrementButton = tester.widget<IconButton>(
      find.ancestor(
        of: find.byTooltip('Menge verringern'),
        matching: find.byType(IconButton),
      ),
    );
    expect(decrementButton.onPressed, isNull);
  });
}
