import 'package:bikedrop_widgetbook/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('WidgetbookApp builds without throwing', (tester) async {
    await tester.pumpWidget(const WidgetbookApp());
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
  });
}
