import 'package:bikedrop/design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart' as widgetbook;
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

@widgetbook.UseCase(name: 'Default', type: BarcodeWidget)
Widget barcodeWidgetDefault(BuildContext context) {
  final ean = context.knobs.string(
    label: 'EAN',
    initialValue: '4007249913555',
  );
  final barColor = context.knobs.color(
    label: 'Balkenfarbe',
    initialValue: Colors.black,
  );
  final drawText = context.knobs.boolean(
    label: 'EAN als Text anzeigen',
    initialValue: true,
  );
  final width = context.knobs.double.slider(
    label: 'Breite',
    initialValue: 200,
    min: 80,
    max: 400,
  );
  final height = context.knobs.double.slider(
    label: 'Hoehe',
    initialValue: 80,
    min: 40,
    max: 200,
  );

  return Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: BarcodeWidget(
        ean: ean,
        barColor: barColor,
        drawText: drawText,
        size: Size(width, height),
      ),
    ),
  );
}

/// Zeigt den Platzhalter, den der Painter statt einer Exception zeichnet:
/// Die Pruefziffer dieser EAN ist falsch (muesste 5 statt 4 sein).
@widgetbook.UseCase(name: 'Ungültige EAN', type: BarcodeWidget)
Widget barcodeWidgetInvalid(BuildContext context) {
  final ean = context.knobs.string(
    label: 'EAN',
    initialValue: '4007249913554',
  );

  return Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: BarcodeWidget(ean: ean),
    ),
  );
}
