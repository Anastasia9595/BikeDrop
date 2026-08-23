// test/design_system/atoms/app_image_upload_field_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bikedrop/design_system/atoms/app_image_upload_field.dart';

void main() {
  testWidgets('shows upload instructions', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: AppImageUploadField(onTap: () {})),
      ),
    );

    expect(find.text('Zum Hochladen klicken'), findsOneWidget);
    expect(find.text('JPG, PNG (max. 2 MB)'), findsOneWidget);
  });

  testWidgets('calls onTap exactly once when tapped', (tester) async {
    var tapCount = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AppImageUploadField(onTap: () => tapCount++),
        ),
      ),
    );

    await tester.tap(find.byType(AppImageUploadField));
    expect(tapCount, 1);
  });

  group('imageUrl', () {
    testWidgets('shows the image instead of the upload prompt when set', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppImageUploadField(
              onTap: () {},
              imageUrl: 'https://example.com/bike.png',
            ),
          ),
        ),
      );

      expect(find.byType(Image), findsOneWidget);
      expect(find.text('Zum Hochladen klicken'), findsNothing);
      expect(find.text('JPG, PNG (max. 2 MB)'), findsNothing);

      // The sandboxed test environment has no network access, so the
      // NetworkImage load fails; consume that expected error so it
      // doesn't fail the test — we only care about the widget structure.
      tester.takeException();
    });

    testWidgets('still calls onTap when an image is shown', (tester) async {
      var tapCount = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppImageUploadField(
              onTap: () => tapCount++,
              imageUrl: 'https://example.com/bike.png',
            ),
          ),
        ),
      );

      await tester.tap(find.byType(AppImageUploadField));
      expect(tapCount, 1);

      tester.takeException();
    });
  });
}
