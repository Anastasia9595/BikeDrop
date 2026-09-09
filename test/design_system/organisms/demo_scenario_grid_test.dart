import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bikedrop/design_system/atoms/demo_scenario_button.dart';
import 'package:bikedrop/design_system/organisms/demo_scenario_grid.dart';
import 'package:bikedrop/models/demoscanoption.dart';

const _katalog = DemoScanOption(
  label: 'Katalogartikel',
  subtitle: 'EAN 4029876501233',
  ean: '4029876501233',
  icon: Icons.grid_view,
  color: Colors.blue,
);
const _eigen = DemoScanOption(
  label: 'Eigener Artikel',
  subtitle: 'EAN 4711234567899',
  ean: '4711234567899',
  icon: Icons.check_circle,
  color: Colors.green,
);
const _unbekannt = DemoScanOption(
  label: 'Unbekannt',
  subtitle: 'EAN 978020137962',
  ean: '978020137962',
  icon: Icons.question_mark,
  color: Colors.orange,
);
const _ungueltig = DemoScanOption(
  label: 'Ungültiger Barcode',
  subtitle: 'EAN 4029876501234',
  ean: '4029876501234',
  icon: Icons.warning,
  color: Colors.red,
);

const _options = [_katalog, _eigen, _unbekannt, _ungueltig];

Future<List<DemoScanOption>> _pump(
  WidgetTester tester, {
  String? activeEan,
}) async {
  final tapped = <DemoScanOption>[];

  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: DemoScenarioGrid(
          options: _options,
          activeEan: activeEan,
          onOptionTap: tapped.add,
        ),
      ),
    ),
  );

  return tapped;
}

void main() {
  testWidgets('zeigt die Kicker-Ueberschrift', (tester) async {
    await _pump(tester);

    expect(find.text('DEMO-SZENARIEN'), findsOneWidget);
  });

  testWidgets('zeigt einen Button pro Option', (tester) async {
    await _pump(tester);

    expect(find.byType(DemoScenarioButton), findsNWidgets(4));
    for (final option in _options) {
      expect(find.text(option.label), findsOneWidget);
    }
  });

  testWidgets('ordnet die Buttons in einem 2-Spalten-Grid an', (tester) async {
    await _pump(tester);

    final positions = [
      for (final option in _options)
        tester.getTopLeft(find.text(option.label)),
    ];

    // Erste Reihe: gleiche Hoehe, unterschiedliche X-Position.
    expect(positions[0].dy, positions[1].dy);
    expect(positions[0].dx, lessThan(positions[1].dx));

    // Zweite Reihe: gleiche Hoehe wie zueinander, aber unterhalb der ersten.
    expect(positions[2].dy, positions[3].dy);
    expect(positions[2].dy, greaterThan(positions[0].dy));
  });

  testWidgets('meldet einen Tap mit der angetippten Option nach aussen', (
    tester,
  ) async {
    final tapped = await _pump(tester);

    await tester.tap(find.text(_unbekannt.label));

    expect(tapped, [_unbekannt]);
  });

  testWidgets('blockiert Taps, solange ein Scan laeuft', (tester) async {
    final tapped = await _pump(tester, activeEan: _katalog.ean);

    await tester.tap(find.text(_katalog.label), warnIfMissed: false);

    expect(tapped, isEmpty);
  });
}
