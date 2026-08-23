import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bikedrop/design_system/atoms/status_indicator.dart';

Widget _wrap(Widget child) =>
    MaterialApp(home: Scaffold(body: Center(child: child)));

void main() {
  testWidgets('renders a colored dot and the label when no icon is given', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        const StatusIndicator(color: Colors.red, label: 'Fehlt'),
      ),
    );

    expect(find.text('Fehlt'), findsOneWidget);
    final dot = tester.widget<Container>(
      find.byWidgetPredicate(
        (widget) =>
            widget is Container &&
            (widget.decoration as BoxDecoration?)?.shape == BoxShape.circle,
      ),
    );
    expect((dot.decoration as BoxDecoration).color, Colors.red);
  });

  testWidgets('renders the given icon in the marker color instead of a dot', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        const StatusIndicator(
          color: Colors.blue,
          label: 'Nicht online',
          icon: Icons.visibility_off_outlined,
        ),
      ),
    );

    final icon = tester.widget<Icon>(
      find.byIcon(Icons.visibility_off_outlined),
    );
    expect(icon.color, Colors.blue);
    expect(find.text('Nicht online'), findsOneWidget);
  });
}
