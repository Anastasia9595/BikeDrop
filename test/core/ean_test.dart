import 'package:bikedrop/core/ean.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('normalizeScannedEan', () {
    test('nimmt eine gueltige EAN-13 unveraendert an', () {
      expect(normalizeScannedEan('4029876501233'), '4029876501233');
    });

    test('nimmt eine gueltige EAN-8 unveraendert an', () {
      expect(normalizeScannedEan('96385074'), '96385074');
    });

    test('macht aus einem gueltigen UPC-A eine 13-stellige EAN', () {
      // Die fuehrende Null laesst die Pruefziffer unveraendert gueltig.
      expect(normalizeScannedEan('978020137962'), '0978020137962');
    });

    test('lehnt eine EAN-13 mit falscher Pruefziffer ab', () {
      expect(normalizeScannedEan('4029876501234'), isNull);
    });

    test('lehnt eine EAN-8 mit falscher Pruefziffer ab', () {
      expect(normalizeScannedEan('96385075'), isNull);
    });

    test('lehnt ein UPC-A mit falscher Pruefziffer ab', () {
      expect(normalizeScannedEan('978020137963'), isNull);
    });

    test('lehnt Nicht-Ziffern ab', () {
      expect(normalizeScannedEan('402987650123X'), isNull);
    });

    test('lehnt eine Laenge ab, die kein EAN-8, UPC-A oder EAN-13 ist', () {
      expect(normalizeScannedEan('4029876501'), isNull);
    });

    test('lehnt einen leeren Barcode ab', () {
      expect(normalizeScannedEan(''), isNull);
    });

    test('ignoriert umschliessende Leerzeichen', () {
      expect(normalizeScannedEan('  4029876501233  '), '4029876501233');
    });
  });
}
