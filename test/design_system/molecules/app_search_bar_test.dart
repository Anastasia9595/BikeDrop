import 'package:bikedrop/design_system/molecules/app_search_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_symbols_icons/symbols.dart';

Widget _wrap(Widget child) =>
    MaterialApp(home: Scaffold(body: Center(child: child)));

void main() {
  testWidgets('shows the placeholder text', (tester) async {
    final controller = TextEditingController();
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      _wrap(
        AppSearchBar(
          controller: controller,
          placeholder: 'Artikel suchen...',
        ),
      ),
    );

    expect(find.text('Artikel suchen...'), findsOneWidget);
  });

  testWidgets('calls onChanged as the user types', (tester) async {
    final controller = TextEditingController();
    addTearDown(controller.dispose);
    String? changed;

    await tester.pumpWidget(
      _wrap(AppSearchBar(controller: controller, onChanged: (v) => changed = v)),
    );
    await tester.enterText(find.byType(TextField), 'Kette');

    expect(changed, 'Kette');
  });

  testWidgets('hides the clear button when empty', (tester) async {
    final controller = TextEditingController();
    addTearDown(controller.dispose);

    await tester.pumpWidget(_wrap(AppSearchBar(controller: controller)));

    expect(find.byIcon(Symbols.close), findsNothing);
  });

  testWidgets('shows the clear button once text is entered', (tester) async {
    final controller = TextEditingController();
    addTearDown(controller.dispose);

    await tester.pumpWidget(_wrap(AppSearchBar(controller: controller)));
    await tester.enterText(find.byType(TextField), 'Kette');
    await tester.pump();

    expect(find.byIcon(Symbols.close), findsOneWidget);
  });

  testWidgets('reacts to external controller changes without onChanged', (
    tester,
  ) async {
    final controller = TextEditingController();
    addTearDown(controller.dispose);

    await tester.pumpWidget(_wrap(AppSearchBar(controller: controller)));
    controller.text = 'Von außen gesetzt';
    await tester.pump();

    expect(find.text('Von außen gesetzt'), findsOneWidget);
    expect(find.byIcon(Symbols.close), findsOneWidget);
  });

  testWidgets('clears the text and calls onChanged/onClear when tapped', (
    tester,
  ) async {
    final controller = TextEditingController();
    addTearDown(controller.dispose);
    String? changed;
    var cleared = false;

    await tester.pumpWidget(
      _wrap(
        AppSearchBar(
          controller: controller,
          onChanged: (v) => changed = v,
          onClear: () => cleared = true,
        ),
      ),
    );
    await tester.enterText(find.byType(TextField), 'Kette');
    await tester.pump();

    await tester.tap(find.byIcon(Symbols.close));
    await tester.pump();

    expect(find.text('Kette'), findsNothing);
    expect(changed, '');
    expect(cleared, isTrue);
    expect(find.byIcon(Symbols.close), findsNothing);
  });
}
