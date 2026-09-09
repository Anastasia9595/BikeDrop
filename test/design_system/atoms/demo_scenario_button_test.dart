import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bikedrop/design_system/atoms/demo_scenario_button.dart';
import 'package:bikedrop/design_system/tokens/app_colors.dart';
import 'package:bikedrop/models/demoscanoption.dart';

const _option = DemoScanOption(
  label: 'Katalogartikel',
  subtitle: 'EAN 4029876501233',
  ean: '4029876501233',
  icon: Icons.grid_view,
  color: Colors.blue,
);

Future<void> _pump(
  WidgetTester tester, {
  bool enabled = true,
  VoidCallback? onTap,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: DemoScenarioButton(
          option: _option,
          enabled: enabled,
          onTap: onTap ?? () {},
        ),
      ),
    ),
  );
}

void main() {
  testWidgets('zeigt Label und Icon der Option', (tester) async {
    await _pump(tester);

    expect(find.text(_option.label), findsOneWidget);
    expect(find.byIcon(_option.icon), findsOneWidget);
  });

  testWidgets('faerbt das Icon in der Akzentfarbe der Option', (tester) async {
    await _pump(tester);

    final icon = tester.widget<Icon>(find.byIcon(_option.icon));
    expect(icon.color, Colors.blue);
  });

  testWidgets('faellt ohne Akzentfarbe auf Grau zurueck', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: DemoScenarioButton(
            option: const DemoScanOption(
              label: 'Katalogartikel',
              subtitle: 'EAN 4029876501233',
              ean: '4029876501233',
              icon: Icons.grid_view,
            ),
            enabled: true,
            onTap: () {},
          ),
        ),
      ),
    );

    final icon = tester.widget<Icon>(find.byIcon(Icons.grid_view));
    expect(icon.color, AppColors.textSecondary);
  });

  testWidgets('meldet einen Tap, wenn aktiv', (tester) async {
    var tapped = false;
    await _pump(tester, onTap: () => tapped = true);

    await tester.tap(find.byType(DemoScenarioButton));

    expect(tapped, isTrue);
  });

  testWidgets('reagiert nicht auf Taps, wenn deaktiviert', (tester) async {
    var tapped = false;
    await _pump(tester, enabled: false, onTap: () => tapped = true);

    await tester.tap(find.byType(DemoScenarioButton), warnIfMissed: false);

    expect(tapped, isFalse);
  });

  testWidgets('ist gedimmt, wenn deaktiviert', (tester) async {
    await _pump(tester, enabled: false);

    final opacity = tester.widget<Opacity>(find.byType(Opacity));
    expect(opacity.opacity, lessThan(1));
  });
}
