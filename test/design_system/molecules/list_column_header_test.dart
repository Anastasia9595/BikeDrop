// test/design_system/widgets/list_column_header_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bikedrop/design_system/tokens/app_colors.dart';
import 'package:bikedrop/design_system/molecules/list_column_header.dart';

void main() {
  testWidgets('renders uppercased label and a divider below', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: ListColumnHeader(label: 'Artikel')),
      ),
    );

    expect(find.text('ARTIKEL'), findsOneWidget);
    final divider = tester.widget<Divider>(find.byType(Divider));
    expect(divider.color, AppColors.divider);
  });
}
