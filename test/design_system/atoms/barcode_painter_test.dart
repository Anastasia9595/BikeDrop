import 'dart:ui' as ui;

import 'package:bikedrop/design_system/atoms/barcode_painter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Zeichnet nicht wirklich, sondern merkt sich nur, was gezeichnet wurde.
class _RecordingCanvas implements Canvas {
  final List<Rect> rects = <Rect>[];
  final List<Paint> paints = <Paint>[];
  int paragraphCount = 0;

  @override
  void drawRect(Rect rect, Paint paint) {
    rects.add(rect);
    paints.add(paint);
  }

  @override
  void drawParagraph(ui.Paragraph paragraph, Offset offset) {
    paragraphCount++;
  }

  @override
  void noSuchMethod(Invocation invocation) {}
}

const _validEan = '4007249913555';
const _invalidEan = '4007249913554'; // falsche Pruefziffer

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('BarcodePainter', () {
    test('zeichnet Balken fuer eine gueltige EAN', () {
      final canvas = _RecordingCanvas();

      BarcodePainter(ean: _validEan).paint(canvas, const Size(200, 80));

      expect(canvas.rects, isNotEmpty);
      expect(
        canvas.paints.every((p) => p.color.toARGB32() == Colors.black.toARGB32()),
        isTrue,
        reason: 'Balken sollen in barColor gezeichnet werden',
      );
    });

    test('faerbt die Balken in der uebergebenen barColor', () {
      final canvas = _RecordingCanvas();

      BarcodePainter(
        ean: _validEan,
        barColor: const Color(0xFF123456),
      ).paint(canvas, const Size(200, 80));

      expect(canvas.paints, isNotEmpty);
      expect(
        canvas.paints.every(
          (p) => p.color.toARGB32() == const Color(0xFF123456).toARGB32(),
        ),
        isTrue,
      );
    });

    test('ignoriert fuehrende und abschliessende Leerzeichen in der EAN', () {
      final withSpaces = _RecordingCanvas();
      final without = _RecordingCanvas();

      BarcodePainter(ean: '  $_validEan  ').paint(withSpaces, const Size(200, 80));
      BarcodePainter(ean: _validEan).paint(without, const Size(200, 80));

      expect(withSpaces.rects.length, without.rects.length);
    });

    test('zeichnet einen Platzhalter statt zu werfen, wenn die EAN ungueltig ist',
        () {
      final canvas = _RecordingCanvas();

      expect(
        () => BarcodePainter(ean: _invalidEan).paint(canvas, const Size(200, 80)),
        returnsNormally,
      );
      expect(canvas.rects, hasLength(1), reason: 'nur der Platzhalter-Rahmen');
      expect(canvas.paints.single.style, PaintingStyle.stroke);
    });

    test('zeichnet einen Platzhalter bei leerer EAN', () {
      final canvas = _RecordingCanvas();

      expect(
        () => BarcodePainter(ean: '').paint(canvas, const Size(200, 80)),
        returnsNormally,
      );
      expect(canvas.rects, hasLength(1));
      expect(canvas.paints.single.style, PaintingStyle.stroke);
    });

    test('zeichnet die EAN als Text, wenn drawText true ist', () {
      final canvas = _RecordingCanvas();

      BarcodePainter(ean: _validEan, drawText: true)
          .paint(canvas, const Size(200, 80));

      expect(canvas.paragraphCount, greaterThan(0));
    });

    test('zeichnet keinen Text, wenn drawText false ist', () {
      final canvas = _RecordingCanvas();

      BarcodePainter(ean: _validEan, drawText: false)
          .paint(canvas, const Size(200, 80));

      expect(canvas.paragraphCount, 0);
    });

    test('shouldRepaint ist false bei identischer Konfiguration', () {
      expect(
        BarcodePainter(ean: _validEan)
            .shouldRepaint(BarcodePainter(ean: _validEan)),
        isFalse,
      );
    });

    test('shouldRepaint ist true, wenn sich die ean aendert', () {
      expect(
        BarcodePainter(ean: _validEan)
            .shouldRepaint(BarcodePainter(ean: '4260119901230')),
        isTrue,
      );
    });

    test('shouldRepaint ist true, wenn sich die barColor aendert', () {
      expect(
        BarcodePainter(ean: _validEan, barColor: Colors.black)
            .shouldRepaint(BarcodePainter(ean: _validEan, barColor: Colors.red)),
        isTrue,
      );
    });

    test('shouldRepaint ist true, wenn sich drawText aendert', () {
      expect(
        BarcodePainter(ean: _validEan, drawText: true)
            .shouldRepaint(BarcodePainter(ean: _validEan, drawText: false)),
        isTrue,
      );
    });
  });

  group('BarcodeWidget', () {
    testWidgets('rendert einen CustomPaint mit dem BarcodePainter',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: BarcodeWidget(ean: _validEan))),
      );

      final painter = tester
          .widgetList<CustomPaint>(find.byType(CustomPaint))
          .map((w) => w.painter)
          .whereType<BarcodePainter>()
          .single;

      expect(painter.ean, _validEan);
    });

    testWidgets('belegt die uebergebene Size', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: BarcodeWidget(ean: _validEan, size: Size(240, 96)),
            ),
          ),
        ),
      );

      expect(tester.getSize(find.byType(BarcodeWidget)), const Size(240, 96));
    });

    testWidgets('stuerzt bei ungueltiger EAN nicht ab', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: BarcodeWidget(ean: _invalidEan))),
      );

      expect(tester.takeException(), isNull);
    });
  });
}
