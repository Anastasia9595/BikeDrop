// test/design_system/organisms/image_source_sheet_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bikedrop/design_system/design_system.dart';

/// Haelt das noch offene Ergebnis-Future des Sheets fest — als nackter
/// Rueckgabewert wuerde es beim Awaiten des Oeffnens mitgeflattened und
/// der Test wuerde auf das Schliessen warten.
class _OpenSheet {
  _OpenSheet(this.result);

  final Future<ImageSourceOption?> result;
}

Future<_OpenSheet> _openSheet(WidgetTester tester) async {
  late Future<ImageSourceOption?> result;

  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: Builder(
          builder: (context) => ElevatedButton(
            onPressed: () => result = ImageSourceSheet.show(context),
            child: const Text('open'),
          ),
        ),
      ),
    ),
  );

  await tester.tap(find.text('open'));
  await tester.pumpAndSettle();

  return _OpenSheet(result);
}

void main() {
  testWidgets('offers camera and gallery', (tester) async {
    await _openSheet(tester);

    expect(find.text('Bild hinzufügen'), findsOneWidget);
    expect(find.text('Foto aufnehmen'), findsOneWidget);
    expect(find.text('Aus Galerie wählen'), findsOneWidget);
  });

  testWidgets('returns camera when the camera entry is tapped', (tester) async {
    final sheet = await _openSheet(tester);

    await tester.tap(find.text('Foto aufnehmen'));
    await tester.pumpAndSettle();

    expect(await sheet.result, ImageSourceOption.camera);
  });

  testWidgets('returns gallery when the gallery entry is tapped', (
    tester,
  ) async {
    final sheet = await _openSheet(tester);

    await tester.tap(find.text('Aus Galerie wählen'));
    await tester.pumpAndSettle();

    expect(await sheet.result, ImageSourceOption.gallery);
  });

  testWidgets('returns null when dismissed', (tester) async {
    final sheet = await _openSheet(tester);

    await tester.tapAt(const Offset(10, 10));
    await tester.pumpAndSettle();

    expect(await sheet.result, isNull);
  });
}
