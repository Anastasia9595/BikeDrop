import 'package:bikedrop/design_system/organisms/scanner_frame.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

const _contentKey = Key('scanner-frame-content');

Future<void> _pump(
  WidgetTester tester, {
  Widget? content,
  double? height,
}) {
  return tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: ScannerFrame(
          content: content ??
              Container(key: _contentKey, color: Colors.black),
          height: height ?? 240,
        ),
      ),
    ),
  );
}

void main() {
  testWidgets('rendert das uebergebene content-Widget', (tester) async {
    await _pump(tester);

    expect(find.byKey(_contentKey), findsOneWidget);
  });

  testWidgets('ist standardmaessig 240 hoch', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ScannerFrame(content: Container(key: _contentKey)),
        ),
      ),
    );

    expect(tester.getSize(find.byType(ScannerFrame)).height, 240);
  });

  testWidgets('uebernimmt eine abweichende height', (tester) async {
    await _pump(tester, height: 320);

    expect(tester.getSize(find.byType(ScannerFrame)).height, 320);
  });

  testWidgets('laesst den content die volle Flaeche fuellen', (tester) async {
    await _pump(tester, height: 300);

    final frameSize = tester.getSize(find.byType(ScannerFrame));
    expect(tester.getSize(find.byKey(_contentKey)), frameSize);
  });

  testWidgets('legt einen gestrichelten Viewfinder von 240x190 darueber',
      (tester) async {
    await _pump(tester);

    expect(tester.getSize(find.byType(DottedBorder)), const Size(240, 190));
  });

  testWidgets('zentriert den Viewfinder im Rahmen', (tester) async {
    await _pump(tester);

    expect(
      tester.getCenter(find.byType(DottedBorder)),
      tester.getCenter(find.byType(ScannerFrame)),
    );
  });

  testWidgets('zeichnet den Rahmen nach den Design-Vorgaben', (tester) async {
    await _pump(tester);

    final options = tester
        .widget<DottedBorder>(find.byType(DottedBorder))
        .options as RoundedRectDottedBorderOptions;

    // BorderType wird vom Package nicht exportiert, daher ueber den Namen.
    expect(options.borderType?.name, 'RRect');
    expect(options.radius, const Radius.circular(10));
    expect(options.dashPattern, const [5, 4]);
    expect(options.color, Colors.white54);
    expect(options.strokeWidth, 2);
  });

  testWidgets('funktioniert mit beliebigem content', (tester) async {
    await _pump(tester, content: const Text('beliebiger Inhalt'));

    expect(find.text('beliebiger Inhalt'), findsOneWidget);
    expect(find.byType(DottedBorder), findsOneWidget);
  });
}
