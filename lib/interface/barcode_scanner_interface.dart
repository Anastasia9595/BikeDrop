abstract class BarcodeScannerInterface {
  Future<String> get scan;
  Future<void> startScan();
  Future<void> stopScan();
}
