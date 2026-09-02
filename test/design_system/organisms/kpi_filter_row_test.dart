// test/design_system/organisms/kpi_filter_row_test.dart
import 'package:bikedrop/design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

const _counts = {
  ArticleStatus.inStock: 6,
  ArticleStatus.bestellt: 2,
  ArticleStatus.fehlt: 1,
};

Future<void> _pump(
  WidgetTester tester,
  Widget row, {
  double width = 390,
}) async {
  tester.view.physicalSize = Size(width, 640);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.screenPaddingH,
          ),
          child: row,
        ),
      ),
    ),
  );
}

void main() {
  testWidgets('shows one card per status with its count', (tester) async {
    await _pump(tester, const KpiFilterRow(counts: _counts));

    expect(find.byType(KpiFilterCard), findsNWidgets(3));

    int valueOf(ArticleStatus status) => tester
        .widget<KpiFilterCard>(
          find.byWidgetPredicate(
            (w) => w is KpiFilterCard && w.status == status,
          ),
        )
        .value;
    expect(valueOf(ArticleStatus.inStock), 6);
    expect(valueOf(ArticleStatus.bestellt), 2);
    expect(valueOf(ArticleStatus.fehlt), 1);
  });

  testWidgets('runs from green over yellow to red', (tester) async {
    await _pump(tester, const KpiFilterRow(counts: _counts));

    final order = tester
        .widgetList<KpiFilterCard>(find.byType(KpiFilterCard))
        .map((card) => card.status)
        .toList();

    expect(order, [
      ArticleStatus.inStock,
      ArticleStatus.bestellt,
      ArticleStatus.fehlt,
    ]);
  });

  testWidgets('falls back to 0 for a status without a count', (tester) async {
    await _pump(
      tester,
      const KpiFilterRow(counts: {ArticleStatus.inStock: 6}),
    );

    final fehlt = tester.widget<KpiFilterCard>(
      find.byWidgetPredicate(
        (w) => w is KpiFilterCard && w.status == ArticleStatus.fehlt,
      ),
    );
    expect(fehlt.value, 0);
  });

  testWidgets('marks only the selected status', (tester) async {
    await _pump(
      tester,
      const KpiFilterRow(counts: _counts, selected: ArticleStatus.bestellt),
    );

    final selected = tester
        .widgetList<KpiFilterCard>(find.byType(KpiFilterCard))
        .where((card) => card.selected)
        .map((card) => card.status);

    expect(selected, [ArticleStatus.bestellt]);
  });

  testWidgets('reports the tapped status', (tester) async {
    final tapped = <ArticleStatus>[];
    await _pump(
      tester,
      KpiFilterRow(counts: _counts, onStatusTap: tapped.add),
    );

    await tester.tap(find.text('Fehlt'));
    await tester.tap(find.text('Im Shop'));

    expect(tapped, [ArticleStatus.fehlt, ArticleStatus.inStock]);
  });

  testWidgets('is display-only without a callback', (tester) async {
    await _pump(tester, const KpiFilterRow(counts: _counts));

    for (final card in tester.widgetList<KpiFilterCard>(
      find.byType(KpiFilterCard),
    )) {
      expect(card.onTap, isNull);
    }
  });

  testWidgets('does not overflow on a 320 dp screen', (tester) async {
    await _pump(tester, const KpiFilterRow(counts: _counts), width: 320);

    expect(tester.takeException(), isNull);
    expect(find.text('Bestellt'), findsOneWidget);
  });
}
