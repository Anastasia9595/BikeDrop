import 'dart:async';

import 'package:bikedrop/design_system/organisms/fake_camera_view.dart';
import 'package:bikedrop/design_system/organisms/scanner_frame.dart';
import 'package:bikedrop/features/scanner_screen.dart';
import 'package:bikedrop/interface/barcode_scanner_interface.dart';
import 'package:bikedrop/models/demoscanoption.dart';
import 'package:bikedrop/providers/scanner_provider.dart';
import 'package:bikedrop/repository/fake_barcod_scanner_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

const _option = DemoScanOption(
  label: 'Katalogtreffer simulieren',
  subtitle: 'EAN 4007249913555 · Shimano XT',
  ean: '4007249913555',
  icon: Icons.check_circle_outline,
);

/// Echter Scanner-Stellvertreter: implementiert das Interface, ist aber
/// bewusst KEIN FakeBarcodeScanner — deckt den Kamera-Zweig in build() ab.
class _RealScannerStub implements BarcodeScannerInterface {
  final _controller = StreamController<String>.broadcast();
  bool started = false;
  bool stopped = false;

  @override
  Stream<String> get scans => _controller.stream;

  @override
  Future<String> get scan => _controller.stream.first;

  @override
  Future<void> startScan() async => started = true;

  @override
  Future<void> stopScan() async => stopped = true;
}

/// Ist ein echter [FakeBarcodeScanner] (der `is`-Check in ScannerScreen greift),
/// merkt sich aber Start und Stopp.
class _TrackingFakeScanner extends FakeBarcodeScanner {
  bool started = false;
  bool stopped = false;

  @override
  Future<void> startScan() async => started = true;

  @override
  Future<void> stopScan() async => stopped = true;
}

Future<List<String>> _pump(
  WidgetTester tester, {
  BarcodeScannerInterface? scanner,
  List<DemoScanOption> options = const [_option],
  Future<void> Function(BuildContext, WidgetRef, String)? onEanScanned,
}) async {
  final scanned = <String>[];

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        scannerProvider.overrideWithValue(scanner ?? FakeBarcodeScanner()),
      ],
      child: MaterialApp(
        home: ScannerScreen(
          title: 'Test',
          demoOptions: options,
          onEanScanned: onEanScanned ??
              (context, ref, ean) async => scanned.add(ean),
        ),
      ),
    ),
  );

  return scanned;
}

void main() {
  testWidgets('zeigt den uebergebenen Titel', (tester) async {
    await _pump(tester);

    expect(find.widgetWithText(AppBar, 'Test'), findsOneWidget);
  });

  testWidgets('zeigt beim Fake-Scanner die Demo-Ansicht', (tester) async {
    await _pump(tester);

    expect(find.byType(FakeCameraView), findsOneWidget);
  });

  testWidgets('zeigt beim echten Scanner den Kamera-Platzhalter',
      (tester) async {
    await _pump(tester, scanner: _RealScannerStub());

    expect(find.byType(FakeCameraView), findsNothing);
    expect(find.byType(ScannerFrame), findsOneWidget);
    expect(find.text('Kamera folgt in Phase 6'), findsOneWidget);
  });

  testWidgets('startet den Fake-Scanner beim Aufbau', (tester) async {
    final scanner = _TrackingFakeScanner();
    addTearDown(scanner.dispose);
    await _pump(tester, scanner: scanner);

    expect(scanner.started, isTrue);
  });

  testWidgets('startet den echten Scanner NICHT, solange keine Kamera-Ansicht '
      'gerendert wird', (tester) async {
    // Sonst wirft mobile_scanner: der Controller ist an kein
    // MobileScanner-Widget gebunden (controllerNotAttached).
    final scanner = _RealScannerStub();
    await _pump(tester, scanner: scanner);

    expect(scanner.started, isFalse);
  });

  testWidgets('stoppt den Fake-Scanner beim Verlassen', (tester) async {
    final scanner = _TrackingFakeScanner();
    addTearDown(scanner.dispose);
    await _pump(tester, scanner: scanner);

    await tester.pumpWidget(const SizedBox());

    expect(scanner.stopped, isTrue);
  });

  testWidgets('stoppt den echten Scanner nicht, da er nie gestartet wurde',
      (tester) async {
    final scanner = _RealScannerStub();
    await _pump(tester, scanner: scanner);

    await tester.pumpWidget(const SizedBox());

    expect(scanner.stopped, isFalse);
  });

  testWidgets('meldet einen echten Scan aus dem Stream nach aussen',
      (tester) async {
    final scanner = _RealScannerStub();
    final scanned = await _pump(tester, scanner: scanner);

    scanner._controller.add('4260119901230');
    await tester.pump();

    expect(scanned, ['4260119901230']);
  });

  testWidgets('ruft onEanScanned nach einem simulierten Scan genau einmal auf',
      (tester) async {
    final scanned = await _pump(tester);

    await tester.tap(find.text(_option.label));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 900));
    await tester.pump();

    expect(scanned, [_option.ean]);
  });

  testWidgets('zeigt waehrend der Simulation den Barcode und danach nicht mehr',
      (tester) async {
    await _pump(tester);

    expect(
      tester.widget<FakeCameraView>(find.byType(FakeCameraView)).activeEan,
      isNull,
    );

    await tester.tap(find.text(_option.label));
    await tester.pump();

    expect(
      tester.widget<FakeCameraView>(find.byType(FakeCameraView)).activeEan,
      _option.ean,
    );

    await tester.pump(const Duration(milliseconds: 900));
    await tester.pump();

    expect(
      tester.widget<FakeCameraView>(find.byType(FakeCameraView)).activeEan,
      isNull,
    );
  });

  testWidgets('ueberlebt das Verlassen waehrend einer laufenden Simulation',
      (tester) async {
    await _pump(tester);

    await tester.tap(find.text(_option.label));
    await tester.pump();

    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(milliseconds: 900));

    expect(tester.takeException(), isNull);
  });
}
