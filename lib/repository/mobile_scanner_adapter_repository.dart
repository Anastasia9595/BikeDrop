import 'package:mobile_scanner/mobile_scanner.dart';
import '../interface/barcode_scanner_interface.dart';
import 'dart:async';

class MobileScannerAdapter implements BarcodeScannerInterface {
  final _controller = MobileScannerController();
  final _out = StreamController<String>.broadcast();
  StreamSubscription<BarcodeCapture>? _sub;

  Future<void> stop() async {
    await _sub?.cancel();
    await _controller.stop();
  }

  @override
  Stream<String> get scans => _out.stream;

  @override
  Future<String> get scan => _out.stream.first;

  @override
  Future<void> startScan() async {
    await _controller.start();
    _sub = _controller.barcodes.listen((capture) {
      for (final barcode in capture.barcodes) {
        if (barcode.rawValue != null) {
          _out.add(barcode.rawValue!);
        }
      }
    });
  }

  @override
  Future<void> stopScan() async {
    await _sub?.cancel();
    await _controller.stop();
  }
}
