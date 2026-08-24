// test/features/article_form_image_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';
import 'package:bikedrop/design_system/design_system.dart';
import 'package:bikedrop/features/article_form_screen.dart';
import 'package:bikedrop/interface/image_picker_interface.dart';
import 'package:bikedrop/providers/image_picker_provider.dart';

class _FakeImagePicker implements ImagePickerService {
  _FakeImagePicker({this.result, this.error});

  final XFile? result;
  final Object? error;

  ImageSourceOption? requestedSource;

  @override
  Future<XFile?> pickImage(ImageSourceOption source) async {
    requestedSource = source;
    final error = this.error;
    if (error != null) throw error;
    return result;
  }
}

Widget _wrap(ImagePickerService picker) {
  return ProviderScope(
    overrides: [imagePickerServiceProvider.overrideWithValue(picker)],
    child: const MaterialApp(home: ArticleFormScreen()),
  );
}

Future<void> _tapUploadField(WidgetTester tester) async {
  await tester.tap(find.byType(AppImageUploadField));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('opens the source sheet when the upload field is tapped', (
    tester,
  ) async {
    await tester.pumpWidget(_wrap(_FakeImagePicker()));

    await _tapUploadField(tester);

    expect(find.text('Foto aufnehmen'), findsOneWidget);
    expect(find.text('Aus Galerie wählen'), findsOneWidget);
  });

  testWidgets('opens the camera when "Foto aufnehmen" is chosen', (
    tester,
  ) async {
    final picker = _FakeImagePicker();
    await tester.pumpWidget(_wrap(picker));

    await _tapUploadField(tester);
    await tester.tap(find.text('Foto aufnehmen'));
    await tester.pumpAndSettle();

    expect(picker.requestedSource, ImageSourceOption.camera);
  });

  testWidgets('opens the gallery when "Aus Galerie wählen" is chosen', (
    tester,
  ) async {
    final picker = _FakeImagePicker();
    await tester.pumpWidget(_wrap(picker));

    await _tapUploadField(tester);
    await tester.tap(find.text('Aus Galerie wählen'));
    await tester.pumpAndSettle();

    expect(picker.requestedSource, ImageSourceOption.gallery);
  });

  testWidgets('shows the picked photo instead of the upload prompt', (
    tester,
  ) async {
    final picker = _FakeImagePicker(result: XFile('/tmp/bike.jpg'));
    await tester.pumpWidget(_wrap(picker));

    await _tapUploadField(tester);
    await tester.tap(find.text('Foto aufnehmen'));
    await tester.pumpAndSettle();

    final field = tester.widget<AppImageUploadField>(
      find.byType(AppImageUploadField),
    );
    expect(field.image, isNotNull);
    expect(find.text('Zum Hochladen klicken'), findsNothing);

    // Die Datei existiert im Test nicht — der erwartete Ladefehler darf
    // den Test nicht kippen.
    tester.takeException();
  });

  testWidgets('keeps the upload prompt when the user cancels', (tester) async {
    final picker = _FakeImagePicker();
    await tester.pumpWidget(_wrap(picker));

    await _tapUploadField(tester);
    await tester.tap(find.text('Foto aufnehmen'));
    await tester.pumpAndSettle();

    expect(find.text('Zum Hochladen klicken'), findsOneWidget);
  });

  testWidgets('shows a snackbar when picking fails', (tester) async {
    final picker = _FakeImagePicker(error: Exception('no camera'));
    await tester.pumpWidget(_wrap(picker));

    await _tapUploadField(tester);
    await tester.tap(find.text('Foto aufnehmen'));
    await tester.pumpAndSettle();

    expect(find.text('Bild konnte nicht geladen werden'), findsOneWidget);
  });
}
