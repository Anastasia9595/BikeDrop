import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../interface/barcode_scanner_interface.dart';
import '../repository/fake_barcod_scanner_repository.dart';
import '../repository/mobile_scanner_adapter_repository.dart';

final scannerProvider = Provider<BarcodeScannerInterface>((ref) {
  // Default true, solange es kein Kamera-Widget gibt (Phase 6): Der echte
  // Adapter kann bis dahin nichts anzeigen. Fuer einen Geraetetest mit
  // --dart-define=USE_FAKE_SCANNER=false umschalten.
  const useFakeScanner = bool.fromEnvironment(
    'USE_FAKE_SCANNER',
    defaultValue: true,
  );
  final scanner = useFakeScanner
      ? FakeBarcodeScanner()
      : MobileScannerAdapter();
  return scanner;
});
