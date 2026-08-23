import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bikedrop/design_system/atoms/quantity_display.dart';

Widget _wrap(Widget child) =>
    MaterialApp(home: Scaffold(body: Center(child: child)));

void main() {
  testWidgets('renders the quantity and the "Stk." unit label', (
    tester,
  ) async {
    await tester.pumpWidget(_wrap(const QuantityDisplay(quantity: 14)));

    expect(find.text('14'), findsOneWidget);
    expect(find.text('Stk.'), findsOneWidget);
  });

  testWidgets('calls onTap when the field is tapped', (tester) async {
    var tapped = false;

    await tester.pumpWidget(
      _wrap(QuantityDisplay(quantity: 14, onTap: () => tapped = true)),
    );
    await tester.tap(find.text('14'));

    expect(tapped, isTrue);
  });

  testWidgets('shows a down chevron as the "opens a picker" affordance', (
    tester,
  ) async {
    await tester.pumpWidget(_wrap(const QuantityDisplay(quantity: 14)));

    expect(find.byIcon(Icons.keyboard_arrow_down), findsOneWidget);
  });
}
