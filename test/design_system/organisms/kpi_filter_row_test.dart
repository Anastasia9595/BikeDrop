// test/design_system/organisms/kpi_filter_row_test.dart
import 'package:bikedrop/design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

const _green = AppColors.statusColorSuccess;
const _greenTint = Color(0xFFEAF6ED);
const _yellow = AppColors.statusColorWarning;
const _yellowTint = Color(0xFFF5EDE0);
const _red = AppColors.statusColorError;
const _redTint = Color(0xFFFCEAEA);

const _entries = [
  KpiFilterEntry(key: 'inStock', label: 'Im Shop', color: _green, tint: _greenTint, count: 6),
  KpiFilterEntry(key: 'bestellt', label: 'Bestellt', color: _yellow, tint: _yellowTint, count: 2),
  KpiFilterEntry(key: 'fehlt', label: 'Fehlt', color: _red, tint: _redTint, count: 1),
];

Future<void> _pump(WidgetTester tester, Widget row, {double width = 390}) async {
  tester.view.physicalSize = Size(width, 640);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPaddingH),
          child: row,
        ),
      ),
    ),
  );
}

void main() {
  testWidgets('shows one card per entry with its count', (tester) async {
    await _pump(tester, const KpiFilterRow(entries: _entries));

    expect(find.byType(KpiFilterCard), findsNWidgets(3));
    expect(find.text('6'), findsOneWidget);
    expect(find.text('2'), findsOneWidget);
    expect(find.text('1'), findsOneWidget);
  });

  testWidgets('keeps the given entry order', (tester) async {
    await _pump(tester, const KpiFilterRow(entries: _entries));

    final labels = tester
        .widgetList<KpiFilterCard>(find.byType(KpiFilterCard))
        .map((card) => card.label)
        .toList();

    expect(labels, ['Im Shop', 'Bestellt', 'Fehlt']);
  });

  testWidgets('marks only the selected entry', (tester) async {
    await _pump(tester, const KpiFilterRow(entries: _entries, selectedKey: 'bestellt'));

    final selectedLabels = tester
        .widgetList<KpiFilterCard>(find.byType(KpiFilterCard))
        .where((card) => card.selected)
        .map((card) => card.label);

    expect(selectedLabels, ['Bestellt']);
  });

  testWidgets('reports the tapped key', (tester) async {
    final tapped = <Object>[];
    await _pump(tester, KpiFilterRow(entries: _entries, onEntryTap: tapped.add));

    await tester.tap(find.text('Fehlt'));
    await tester.tap(find.text('Im Shop'));

    expect(tapped, ['fehlt', 'inStock']);
  });

  testWidgets('is display-only without a callback', (tester) async {
    await _pump(tester, const KpiFilterRow(entries: _entries));

    for (final card in tester.widgetList<KpiFilterCard>(find.byType(KpiFilterCard))) {
      expect(card.onTap, isNull);
    }
  });

  testWidgets('does not overflow on a 320 dp screen', (tester) async {
    await _pump(tester, const KpiFilterRow(entries: _entries), width: 320);

    expect(tester.takeException(), isNull);
    expect(find.text('Bestellt'), findsOneWidget);
  });
}
