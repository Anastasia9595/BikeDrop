import 'dart:async';

import 'package:bikedrop/design_system/organisms/fake_camera_view.dart';
import 'package:bikedrop/design_system/organisms/scanner_frame.dart';
import 'package:bikedrop/features/scanner_screen.dart';
import 'package:bikedrop/interface/barcode_scanner_interface.dart';
import 'package:bikedrop/models/demo_options_layout.dart';
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
  DemoOptionsLayout layout = DemoOptionsLayout.list,
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
          layout: layout,
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

  testWidgets('reicht das layout an die FakeCameraView weiter', (
    tester,
  ) async {
    await _pump(tester, layout: DemoOptionsLayout.grid);

    expect(
      tester.widget<FakeCameraView>(find.byType(FakeCameraView)).layout,
      DemoOptionsLayout.grid,
    );
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

  testWidgets('meldet einen ungueltigen Barcode und ruft onEanScanned nicht auf',
      (tester) async {
    final scanner = _RealScannerStub();
    final scanned = await _pump(tester, scanner: scanner);

    // Gleiche EAN wie oben, nur mit falscher Pruefziffer.
    scanner._controller.add('4029876501234');
    await tester.pump();

    expect(scanned, isEmpty);
    expect(
      find.text('Ungültiger Barcode – bitte erneut scannen'),
      findsOneWidget,
    );
  });

  testWidgets('reicht ein UPC-A normalisiert auf 13 Stellen weiter',
      (tester) async {
    final scanner = _RealScannerStub();
    final scanned = await _pump(tester, scanner: scanner);

    scanner._controller.add('978020137962');
    await tester.pump();

    expect(scanned, ['0978020137962']);
  });

  testWidgets('does not render anything extra without an overlay', (tester) async {
    await _pump(tester);

    expect(find.byKey(const ValueKey('scanner-overlay-probe')), findsNothing);
  });

  testWidgets('renders the given overlay on top of the content', (tester) async {
    final scanned = <String>[];
    await tester.pumpWidget(
      ProviderScope(
        overrides: [scannerProvider.overrideWithValue(FakeBarcodeScanner())],
        child: MaterialApp(
          home: ScannerScreen(
            title: 'Test',
            demoOptions: const [_option],
            onEanScanned: (context, ref, ean) async => scanned.add(ean),
            overlay: const Align(
              alignment: Alignment.bottomCenter,
              child: SizedBox(key: ValueKey('scanner-overlay-probe'), height: 40),
            ),
          ),
        ),
      ),
    );

    expect(find.byKey(const ValueKey('scanner-overlay-probe')), findsOneWidget);
    expect(find.byType(FakeCameraView), findsOneWidget);
  });

  testWidgets('the overlay reaches the true bottom of the screen, not just the '
      'bottom of a short content', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [scannerProvider.overrideWithValue(FakeBarcodeScanner())],
        child: MaterialApp(
          home: ScannerScreen(
            title: 'Test',
            demoOptions: const [_option],
            onEanScanned: (context, ref, ean) async {},
            overlay: const Align(
              alignment: Alignment.bottomCenter,
              child: SizedBox(key: ValueKey('scanner-overlay-bottom-probe'), height: 1),
            ),
          ),
        ),
      ),
    );

    final scaffoldBottom = tester.getBottomLeft(find.byType(Scaffold)).dy;
    final overlayProbeBottom = tester
        .getBottomLeft(find.byKey(const ValueKey('scanner-overlay-bottom-probe')))
        .dy;

    // FakeCameraView (der Inhalt) ist deutlich kuerzer als der Bildschirm —
    // das Overlay muss trotzdem bis zum echten unteren Bildschirmrand
    // reichen, nicht nur bis zum Ende des kurzen Inhalts dahinter.
    expect(overlayProbeBottom, closeTo(scaffoldBottom, 1));
  });

  testWidgets('an empty overlay does not block taps on the demo buttons behind it', (
    tester,
  ) async {
    final scanned = await _pump(tester, layout: DemoOptionsLayout.grid);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [scannerProvider.overrideWithValue(FakeBarcodeScanner())],
        child: MaterialApp(
          home: ScannerScreen(
            title: 'Test',
            demoOptions: const [_option],
            layout: DemoOptionsLayout.grid,
            onEanScanned: (context, ref, ean) async => scanned.add(ean),
            overlay: const SizedBox.shrink(),
          ),
        ),
      ),
    );

    await tester.tap(find.text(_option.label));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 900));
    await tester.pump();

    expect(scanned, [_option.ean]);
  });
}
