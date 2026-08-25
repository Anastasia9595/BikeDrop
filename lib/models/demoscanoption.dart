import 'package:flutter/widgets.dart';

/// Eine vorgegebene Auswahl im Demo-Scanner: Tippt man sie an, wird die
/// hinterlegte [ean] an [FakeBarcodeScanner.simulateScan] weitergereicht,
/// als haette die Kamera diesen Barcode erkannt.
class DemoScanOption {
  const DemoScanOption({
    required this.label,
    required this.subtitle,
    required this.ean,
    required this.icon,
  });
  final String label;
  final String subtitle;
  final String ean;
  final IconData icon;
}
