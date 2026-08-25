abstract class BarcodeScannerInterface {
  /// Alle erkannten Barcodes als fortlaufender Broadcast-Stream.
  ///
  /// Im Gegensatz zu [scan] endet er nicht nach dem ersten Treffer — ein
  /// Screen kann also fuer die Dauer seiner Lebenszeit zuhoeren.
  Stream<String> get scans;

  /// Der naechste erkannte Barcode.
  Future<String> get scan;

  Future<void> startScan();
  Future<void> stopScan();
}
