import 'package:barcode/barcode.dart';
import 'package:flutter/material.dart';

/// Zeichnet einen EAN-13-Barcode zur Laufzeit auf die Canvas — ohne Bild-Asset
/// und ohne Netzwerk-Request.
///
/// Ist die EAN keine gueltige EAN-13 (falsche Laenge, keine Ziffern, falsche
/// Pruefziffer), wird statt eines Barcodes ein Platzhalter gezeichnet. Der
/// Painter wirft nie — er ist rein visuell und validiert fachlich nichts.
class BarcodePainter extends CustomPainter {
  BarcodePainter({
    required this.ean,
    this.barColor = Colors.black,
    this.drawText = true,
  });

  final String ean;
  final Color barColor;
  final bool drawText;

  @override
  void paint(Canvas canvas, Size size) {
    final elements = _makeElements(size);

    if (elements == null) {
      _paintPlaceholder(canvas, size);
      return;
    }

    final barPaint = Paint()..color = barColor;

    for (final element in elements) {
      if (element is BarcodeBar) {
        // Weisse Balken sind die Luecken — der Hintergrund liegt schon dort.
        if (!element.black) continue;
        canvas.drawRect(
          Rect.fromLTWH(
            element.left,
            element.top,
            element.width,
            element.height,
          ),
          barPaint,
        );
      } else if (element is BarcodeText) {
        _paintText(canvas, element);
      }
    }
  }

  /// Erzeugt die Zeichenoperationen, oder null wenn die EAN ungueltig ist.
  ///
  /// `make()` liefert ein lazy [Iterable] — die Validierung schlaegt erst beim
  /// Iterieren zu, deshalb wird hier bereits innerhalb des try zur Liste
  /// materialisiert.
  List<BarcodeElement>? _makeElements(Size size) {
    try {
      return Barcode.ean13()
          .make(
            ean.trim(),
            width: size.width,
            height: size.height,
            drawText: drawText,
            fontHeight: drawText ? size.height * 0.2 : null,
          )
          .toList();
    } on BarcodeException {
      return null;
    }
  }

  void _paintText(Canvas canvas, BarcodeText element) {
    final painter = TextPainter(
      text: TextSpan(
        text: element.text,
        style: TextStyle(color: barColor, fontSize: element.height),
      ),
      textDirection: TextDirection.ltr,
      textAlign: switch (element.align) {
        BarcodeTextAlign.left => TextAlign.left,
        BarcodeTextAlign.center => TextAlign.center,
        BarcodeTextAlign.right => TextAlign.right,
      },
    )..layout(minWidth: element.width, maxWidth: element.width);

    painter.paint(canvas, Offset(element.left, element.top));
  }

  void _paintPlaceholder(Canvas canvas, Size size) {
    canvas.drawRect(
      Offset.zero & size,
      Paint()
        ..color = Colors.grey
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );

    final painter = TextPainter(
      text: TextSpan(
        text: 'Ungültige EAN',
        style: TextStyle(color: Colors.grey, fontSize: size.height * 0.2),
      ),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    )..layout(minWidth: size.width, maxWidth: size.width);

    painter.paint(
      canvas,
      Offset(0, (size.height - painter.height) / 2),
    );
  }

  @override
  bool shouldRepaint(BarcodePainter oldDelegate) {
    return oldDelegate.ean != ean ||
        oldDelegate.barColor != barColor ||
        oldDelegate.drawText != drawText;
  }
}

/// Duenner Wrapper um [BarcodePainter], damit Aufrufer nicht selbst mit
/// [CustomPaint] hantieren muessen.
class BarcodeWidget extends StatelessWidget {
  const BarcodeWidget({
    required this.ean,
    this.barColor = Colors.black,
    this.drawText = true,
    this.size = const Size(200, 80),
    super.key,
  });

  final String ean;
  final Color barColor;
  final bool drawText;
  final Size size;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: size,
      painter: BarcodePainter(
        ean: ean,
        barColor: barColor,
        drawText: drawText,
      ),
    );
  }
}
