import 'package:bikedrop/design_system/molecules/demo_option_tile.dart';
import 'package:bikedrop/models/demoscanoption.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

const _option = DemoScanOption(
  label: 'Katalogartikel simulieren',
  subtitle: 'EAN 4007249913555 · Shimano XT',
  ean: '4007249913555',
  icon: Icons.qr_code,
);

Future<int> _pump(WidgetTester tester, {required bool enabled}) async {
  var taps = 0;

  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: DemoOptionTile(
          option: _option,
          enabled: enabled,
          onTap: () => taps++,
        ),
      ),
    ),
  );

  return taps;
}

void main() {
  testWidgets('zeigt Icon, Label und Untertitel der Option', (tester) async {
    await _pump(tester, enabled: true);

    expect(find.byIcon(_option.icon), findsOneWidget);
    expect(find.text(_option.label), findsOneWidget);
    expect(find.text(_option.subtitle), findsOneWidget);
  });

  testWidgets('hebt das Label gegenueber dem Untertitel hervor',
      (tester) async {
    await _pump(tester, enabled: true);

    final label = tester.widget<Text>(find.text(_option.label));
    final subtitle = tester.widget<Text>(find.text(_option.subtitle));

    expect(label.style!.fontWeight, FontWeight.w700);
    expect(subtitle.style!.fontSize, lessThan(label.style!.fontSize!));
  });

  testWidgets('meldet einen Tap, wenn aktiviert', (tester) async {
    var taps = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: DemoOptionTile(
            option: _option,
            enabled: true,
            onTap: () => taps++,
          ),
        ),
      ),
    );

    await tester.tap(find.text(_option.label));
    await tester.pump();

    expect(taps, 1);
  });

  testWidgets('ignoriert Taps, wenn deaktiviert', (tester) async {
    var taps = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: DemoOptionTile(
            option: _option,
            enabled: false,
            onTap: () => taps++,
          ),
        ),
      ),
    );

    await tester.tap(find.text(_option.label), warnIfMissed: false);
    await tester.pump();

    expect(taps, 0);
  });

  testWidgets('dimmt die Kachel im deaktivierten Zustand', (tester) async {
    await _pump(tester, enabled: false);
    final disabled = tester.widget<Opacity>(find.byType(Opacity).first).opacity;

    await _pump(tester, enabled: true);
    final active = tester.widget<Opacity>(find.byType(Opacity).first).opacity;

    expect(disabled, lessThan(active));
  });
}
