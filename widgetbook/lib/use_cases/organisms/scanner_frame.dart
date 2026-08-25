import 'package:bikedrop/design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart' as widgetbook;
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

@widgetbook.UseCase(name: 'Default', type: ScannerFrame)
Widget scannerFrameDefault(BuildContext context) {
  final height = context.knobs.double.slider(
    label: 'Hoehe',
    initialValue: 240,
    min: 160,
    max: 400,
  );

  return Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: ScannerFrame(
        height: height,
        content: Container(color: Colors.black),
      ),
    ),
  );
}

/// Zeigt, dass der Rahmen beliebigen content umschliesst — hier den
/// Fake-Barcode, spaeter die echte Kamera-Preview.
@widgetbook.UseCase(name: 'Mit Barcode', type: ScannerFrame)
Widget scannerFrameWithBarcode(BuildContext context) {
  final ean = context.knobs.string(
    label: 'EAN',
    initialValue: '4007249913555',
  );

  return Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: ScannerFrame(
        content: ColoredBox(
          color: Colors.black,
          child: Center(
            child: BarcodeWidget(ean: ean, barColor: Colors.white),
          ),
        ),
      ),
    ),
  );
}
