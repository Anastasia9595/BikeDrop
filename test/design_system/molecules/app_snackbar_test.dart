// test/design_system/widgets/app_snackbar_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bikedrop/design_system/tokens/app_colors.dart';
import 'package:bikedrop/design_system/molecules/app_snackbar.dart';

void main() {
  testWidgets('shows message and triggers action callback', (tester) async {
    var actionTapped = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: ElevatedButton(
                onPressed: () => AppSnackbar.show(
                  context,
                  'Keine Verbindung',
                  actionLabel: 'Erneut versuchen',
                  onAction: () => actionTapped = true,
                ),
                child: const Text('Trigger'),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Trigger'));
    await tester.pumpAndSettle();

    expect(find.text('Keine Verbindung'), findsOneWidget);
    final snackBar = tester.widget<SnackBar>(find.byType(SnackBar));
    expect(snackBar.backgroundColor, AppColors.snackbarBg);

    await tester.tap(find.text('Erneut versuchen'));
    await tester.pumpAndSettle();
    expect(actionTapped, isTrue);
  });
}
