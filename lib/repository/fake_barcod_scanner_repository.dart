import '../interface/barcode_scanner_interface.dart';
import 'dart:async';

class FakeBarcodeScanner implements BarcodeScannerInterface {
  final _controller = StreamController<String>.broadcast();

  @override
  Future<String> get scan => _controller.stream.first;

  @override
  Future<void> startScan() async {}

  @override
  Future<void> stopScan() async {}

  void simulateScan(String ean) => _controller.add(ean);

  void dispose() => _controller.close();
}
