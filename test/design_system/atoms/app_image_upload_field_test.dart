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
}
