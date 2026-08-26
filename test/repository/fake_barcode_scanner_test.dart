import 'package:bikedrop/interface/barcode_scanner_interface.dart';
import 'package:bikedrop/repository/fake_barcod_scanner_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('simulateScan schreibt in den scans-Stream', () async {
    final scanner = FakeBarcodeScanner();
    addTearDown(scanner.dispose);

    final received = <String>[];
    scanner.scans.listen(received.add);

    scanner.simulateScan('4007249913555');
    scanner.simulateScan('4260119901230');
    await Future<void>.delayed(Duration.zero);

    expect(received, ['4007249913555', '4260119901230']);
  });

  test('scans ist Teil des Interfaces', () {
    final BarcodeScannerInterface scanner = FakeBarcodeScanner();
    addTearDown((scanner as FakeBarcodeScanner).dispose);

    expect(scanner.scans, isA<Stream<String>>());
  });

  test('scans ist ein Broadcast-Stream mit mehreren Zuhoerern', () async {
    final scanner = FakeBarcodeScanner();
    addTearDown(scanner.dispose);

    final a = <String>[];
    final b = <String>[];
    scanner.scans.listen(a.add);
    scanner.scans.listen(b.add);

    scanner.simulateScan('4007249913555');
    await Future<void>.delayed(Duration.zero);

    expect(a, ['4007249913555']);
    expect(b, ['4007249913555']);
  });
}
