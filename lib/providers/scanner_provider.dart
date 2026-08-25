import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../interface/barcode_scanner_interface.dart';
import '../repository/fake_barcod_scanner_repository.dart';
import '../repository/mobile_scanner_adapter_repository.dart';

final scannerProvider = Provider<BarcodeScannerInterface>((ref) {
  const useFakeScanner = bool.fromEnvironment(
    'USE_FAKE_SCANNER',
    defaultValue: false,
  );
  final scanner = useFakeScanner
      ? FakeBarcodeScanner()
      : MobileScannerAdapter();
  return scanner;
});
