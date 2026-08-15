// test/design_system/atoms/app_segmented_control_test.dart
import 'package:bikedrop/design_system/molecules/app_segmented_control.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

enum _Status { imShop, bestellt, fehlt }

Widget _wrap(Widget child) =>
    MaterialApp(home: Scaffold(body: Center(child: child)));

void main() {
  testWidgets('renders a label for every option', (tester) async {
    await tester.pumpWidget(
      _wrap(
        AppSegmentedControl<_Status>(
          options: _Status.values,
          labelBuilder: (s) => switch (s) {
            _Status.imShop => 'Im Shop',
            _Status.bestellt => 'Bestellt',
            _Status.fehlt => 'Fehlt',
          },
          value: _Status.imShop,
          onChanged: (_) {},
        ),
      ),
    );

    expect(find.text('Im Shop'), findsOneWidget);
    expect(find.text('Bestellt'), findsOneWidget);
    expect(find.text('Fehlt'), findsOneWidget);
  });

  testWidgets('calls onChanged with the tapped option', (tester) async {
    _Status? changed;

    await tester.pumpWidget(
      _wrap(
        AppSegmentedControl<_Status>(
          options: _Status.values,
          labelBuilder: (s) => switch (s) {
            _Status.imShop => 'Im Shop',
            _Status.bestellt => 'Bestellt',
            _Status.fehlt => 'Fehlt',
          },
          value: _Status.imShop,
          onChanged: (s) => changed = s,
        ),
      ),
    );
    await tester.tap(find.text('Bestellt'));

    expect(changed, _Status.bestellt);
  });

  testWidgets('does not call onChanged when tapping the selected option', (
    tester,
  ) async {
    var called = false;

    await tester.pumpWidget(
      _wrap(
        AppSegmentedControl<_Status>(
          options: _Status.values,
          labelBuilder: (s) => switch (s) {
            _Status.imShop => 'Im Shop',
            _Status.bestellt => 'Bestellt',
            _Status.fehlt => 'Fehlt',
          },
          value: _Status.imShop,
          onChanged: (_) => called = true,
        ),
      ),
    );
    await tester.tap(find.text('Im Shop'));

    expect(called, isFalse);
  });

  testWidgets('renders the label above the control when set', (tester) async {
    await tester.pumpWidget(
      _wrap(
        AppSegmentedControl<_Status>(
          label: 'Status',
          options: _Status.values,
          labelBuilder: (s) => s.name,
          value: _Status.imShop,
          onChanged: (_) {},
        ),
      ),
    );

    expect(find.text('STATUS'), findsOneWidget);
  });

  testWidgets('renders no label when not set', (tester) async {
    await tester.pumpWidget(
      _wrap(
        AppSegmentedControl<_Status>(
          options: _Status.values,
          labelBuilder: (s) => s.name,
          value: _Status.imShop,
          onChanged: (_) {},
        ),
      ),
    );

    expect(find.text('STATUS'), findsNothing);
  });
}
