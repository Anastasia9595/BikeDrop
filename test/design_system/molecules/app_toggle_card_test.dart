// test/design_system/molecules/app_toggle_card_test.dart
import 'package:bikedrop/design_system/molecules/app_toggle_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _wrap(Widget child) =>
    MaterialApp(home: Scaffold(body: Center(child: child)));

void main() {
  testWidgets('renders title and description', (tester) async {
    await tester.pumpWidget(
      _wrap(
        AppToggleCard(
          title: 'Für Kunden sichtbar',
          description: 'Erscheint auf der Kunden-Website',
          value: false,
          onChanged: (_) {},
        ),
      ),
    );

    expect(find.text('Für Kunden sichtbar'), findsOneWidget);
    expect(find.text('Erscheint auf der Kunden-Website'), findsOneWidget);
  });

  testWidgets('reflects value on the switch', (tester) async {
    await tester.pumpWidget(
      _wrap(
        AppToggleCard(
          title: 'Für Kunden sichtbar',
          description: 'Erscheint auf der Kunden-Website',
          value: true,
          onChanged: (_) {},
        ),
      ),
    );

    final switchWidget = tester.widget<Switch>(find.byType(Switch));
    expect(switchWidget.value, isTrue);
  });

  testWidgets('calls onChanged with the inverted value when tapped', (
    tester,
  ) async {
    bool? changed;

    await tester.pumpWidget(
      _wrap(
        AppToggleCard(
          title: 'Für Kunden sichtbar',
          description: 'Erscheint auf der Kunden-Website',
          value: false,
          onChanged: (v) => changed = v,
        ),
      ),
    );
    await tester.tap(find.byType(Switch));

    expect(changed, isTrue);
  });
}
