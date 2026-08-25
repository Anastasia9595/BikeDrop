import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../design_system/organisms/fake_camera_view.dart';
import '../design_system/organisms/scanner_frame.dart';
import '../interface/barcode_scanner_interface.dart';
import '../models/demoscanoption.dart';
import '../providers/scanner_provider.dart';
import '../repository/fake_barcod_scanner_repository.dart';

/// Generischer Scanner-Container.
///
/// Kennt weder Artikel noch Wareneingang: Was mit einer erkannten EAN
/// passiert, liefert der Aufrufer ueber [onEanScanned] — inklusive Navigation.
class ScannerScreen extends ConsumerStatefulWidget {
  const ScannerScreen({
    required this.title,
    required this.demoOptions,
    required this.onEanScanned,
    super.key,
  });

  final String title;
  final List<DemoScanOption> demoOptions;
  final Future<void> Function(BuildContext context, WidgetRef ref, String ean)
  onEanScanned;

  @override
  ConsumerState<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends ConsumerState<ScannerScreen> {
  /// In initState gemerkt: in dispose() ist `ref` bereits entsorgt und
  /// ref.read wuerde dort werfen.
  late final BarcodeScannerInterface _scanner;

  /// Ob die simulierte Kamera-Ansicht gezeigt wird — steuert zugleich, ob der
  /// Scanner ueberhaupt gestartet werden darf.
  late final bool _isFake;

  StreamSubscription<String>? _sub;

  /// null = idle, sonst die EAN, deren Scan gerade simuliert wird.
  String? _activeEan;

  @override
  void initState() {
    super.initState();
    _scanner = ref.read(scannerProvider);
    _isFake = _scanner is FakeBarcodeScanner;
    _sub = _scanner.scans.listen(_handleScannedEan);

    // Nur starten, wenn auch eine Ansicht dazu existiert: mobile_scanner
    // verlangt ein gebautes MobileScanner-Widget, sonst wirft der Controller
    // controllerNotAttached. Das Kamera-Widget kommt in Phase 6.
    if (_isFake) {
      _scanner.startScan();
    }
  }

  /// Der einzige Ort, an dem [ScannerScreen.onEanScanned] aufgerufen wird —
  /// echte und simulierte Scans laufen beide durch denselben Stream.
  Future<void> _handleScannedEan(String ean) async {
    await widget.onEanScanned(context, ref, ean);
  }

  Future<void> _simulate(DemoScanOption option) async {
    setState(() => _activeEan = option.ean);

    // Fade einblenden lassen und kurz "scannen".
    await Future<void>.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;

    (_scanner as FakeBarcodeScanner).simulateScan(option.ean);
    setState(() => _activeEan = null);
  }

  @override
  void dispose() {
    _sub?.cancel();
    if (_isFake) {
      _scanner.stopScan();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: _isFake
          ? FakeCameraView(
              demoOptions: widget.demoOptions,
              activeEan: _activeEan,
              onOptionTap: _simulate,
            )
          : const ScannerFrame(
              content: Center(child: Text('Kamera folgt in Phase 6')),
            ),
    );
  }
}
