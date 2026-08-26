import 'package:bikedrop/design_system/atoms/barcode_painter.dart';
import 'package:bikedrop/design_system/organisms/fake_camera_view.dart';
import 'package:bikedrop/design_system/organisms/scanner_frame.dart';
import 'package:bikedrop/models/demoscanoption.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

const _hit = DemoScanOption(
  label: 'Katalogtreffer simulieren',
  subtitle: 'EAN 4007249913555 · Shimano XT',
  ean: '4007249913555',
  icon: Icons.check_circle_outline,
);

const _miss = DemoScanOption(
  label: 'Unbekannten Artikel simulieren',
  subtitle: 'EAN 4260119901230 · nicht im Katalog',
  ean: '4260119901230',
  icon: Icons.help_outline,
);

Future<List<DemoScanOption>> _pump(
  WidgetTester tester, {
  String? activeEan,
  List<DemoScanOption> options = const [_hit, _miss],
}) async {
  final tapped = <DemoScanOption>[];

  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: FakeCameraView(
          demoOptions: options,
          activeEan: activeEan,
          onOptionTap: tapped.add,
          onTapWithoutBarcode: () => debugPrint('Keine EAN scannen'),
        ),
      ),
    ),
  );

  return tapped;
}

void main() {
  testWidgets('rendert den ScannerFrame', (tester) async {
    await _pump(tester);

    expect(find.byType(ScannerFrame), findsOneWidget);
  });

  testWidgets('zeigt im Idle-Zustand keinen Barcode', (tester) async {
    await _pump(tester);

    expect(find.byType(BarcodeWidget), findsNothing);
  });

  testWidgets('zeigt den Barcode der activeEan', (tester) async {
    await _pump(tester, activeEan: '4007249913555');

    final barcode = tester.widget<BarcodeWidget>(find.byType(BarcodeWidget));
    expect(barcode.ean, '4007249913555');
    expect(barcode.barColor, Colors.white);
  });

  testWidgets('blendet den Barcode ueber einen AnimatedSwitcher ein', (
    tester,
  ) async {
    await _pump(tester);

    final switcher = tester.widget<AnimatedSwitcher>(
      find.byType(AnimatedSwitcher),
    );
    expect(switcher.duration, const Duration(milliseconds: 300));
  });

  testWidgets('zeigt je eine Kachel pro Demo-Option', (tester) async {
    await _pump(tester);

    for (final option in [_hit, _miss]) {
      expect(find.text(option.label), findsOneWidget);
      expect(find.text(option.subtitle), findsOneWidget);
      expect(find.byIcon(option.icon), findsOneWidget);
    }
  });

  testWidgets('meldet einen Tap mit der angetippten Option nach aussen', (
    tester,
  ) async {
    final tapped = await _pump(tester);

    await tester.tap(find.text(_miss.label));
    await tester.pump();

    expect(tapped, [_miss]);
  });

  testWidgets('blockiert Taps, solange ein Scan laeuft', (tester) async {
    final tapped = await _pump(tester, activeEan: '4007249913555');

    await tester.tap(find.text(_hit.label), warnIfMissed: false);
    await tester.pump();

    expect(tapped, isEmpty);
  });

  testWidgets('kommt ohne Demo-Optionen aus', (tester) async {
    await _pump(tester, options: const []);

    expect(find.byType(ScannerFrame), findsOneWidget);
    expect(find.byType(InkWell), findsNothing);
  });
}
