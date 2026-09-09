// test/design_system/atoms/kpi_filter_card_test.dart
import 'package:bikedrop/design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

const _green = AppColors.statusColorSuccess;
const _greenTint = Color(0xFFEAF6ED);

Widget _wrap(Widget child) =>
    MaterialApp(home: Scaffold(body: Center(child: child)));

Material _material(WidgetTester tester) => tester.widget<Material>(
  find.ancestor(of: find.byType(InkWell), matching: find.byType(Material)).first,
);

Container _dot(WidgetTester tester) => tester
    .widgetList<Container>(find.byType(Container))
    .firstWhere(
      (c) =>
          c.decoration is BoxDecoration &&
          (c.decoration! as BoxDecoration).shape == BoxShape.circle,
    );

void main() {
  testWidgets('shows the value and the label', (tester) async {
    await tester.pumpWidget(
      _wrap(const KpiFilterCard(value: 432, label: 'Im Bestand', color: _green, tint: _greenTint)),
    );

    expect(find.text('432'), findsOneWidget);
    expect(find.text('Im Bestand'), findsOneWidget);
  });

  testWidgets('paints the dot in the given color', (tester) async {
    await tester.pumpWidget(
      _wrap(const KpiFilterCard(value: 7, label: 'X', color: _green, tint: _greenTint)),
    );

    expect((_dot(tester).decoration! as BoxDecoration).color, _green);
  });

  testWidgets('is white with dark text when not selected', (tester) async {
    await tester.pumpWidget(
      _wrap(const KpiFilterCard(value: 1, label: 'X', color: _green, tint: _greenTint)),
    );

    expect(_material(tester).color, AppColors.white);
    expect(tester.widget<Text>(find.text('1')).style!.color, AppColors.textPrimary);
  });

  testWidgets('uses the tint background and the given color as text when selected', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        const KpiFilterCard(value: 1, label: 'X', color: _green, tint: _greenTint, selected: true),
      ),
    );

    expect(_material(tester).color, _greenTint);
    expect(tester.widget<Text>(find.text('1')).style!.color, _green);
  });

  testWidgets('reports taps', (tester) async {
    var taps = 0;
    await tester.pumpWidget(
      _wrap(
        KpiFilterCard(value: 5, label: 'X', color: _green, tint: _greenTint, onTap: () => taps++),
      ),
    );

    await tester.tap(find.byType(KpiFilterCard));
    expect(taps, 1);
  });

  testWidgets('is not tappable without a callback', (tester) async {
    await tester.pumpWidget(
      _wrap(const KpiFilterCard(value: 5, label: 'X', color: _green, tint: _greenTint)),
    );

    expect(tester.widget<InkWell>(find.byType(InkWell)).onTap, isNull);
  });
}
