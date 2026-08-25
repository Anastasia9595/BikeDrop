import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';

/// Fester Viewfinder-Rahmen fuer den Scanner-Screen.
///
/// Rendert [content] ueber die volle Flaeche und legt einen gestrichelten
/// Sucher-Rahmen darueber. Was der Inhalt ist — ein simulierter Barcode oder
/// spaeter eine echte Kamera-Preview — weiss dieses Widget bewusst nicht.
class ScannerFrame extends StatelessWidget {
  const ScannerFrame({required this.content, this.height = 240, super.key});

  final Widget content;
  final double height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: Stack(
        fit: StackFit.expand,
        children: [
          content,
          Center(
            child: DottedBorder(
              options: const RoundedRectDottedBorderOptions(
                padding: EdgeInsets.zero,
                radius: Radius.circular(10),
                color: Colors.white54,
                dashPattern: [5, 4],
                strokeWidth: 2,
              ),
              child: SizedBox(width: 240, height: 190),
            ),
          ),
        ],
      ),
    );
  }
}
