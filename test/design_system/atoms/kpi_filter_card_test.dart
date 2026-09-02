// test/design_system/atoms/kpi_filter_card_test.dart
import 'package:bikedrop/design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _wrap(Widget child) =>
    MaterialApp(home: Scaffold(body: Center(child: child)));

Material _card(WidgetTester tester) => tester.widget<Material>(
  find.ancestor(of: find.byType(InkWell), matching: find.byType(Material)).first,
);

/// Drei Kacheln nebeneinander, so wie sie auf dem Overview-Screen stehen.
Future<void> _pumpRow(
  WidgetTester tester,
  double screenWidth, {
  double textScale = 1.0,
}) async {
  tester.view.physicalSize = Size(screenWidth, 640);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(
    MediaQuery(
      data: MediaQueryData(textScaler: TextScaler.linear(textScale)),
      child: MaterialApp(
        home: Scaffold(
          body: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.screenPaddingH,
            ),
            child: const KpiFilterRow(
              counts: {
                ArticleStatus.inStock: 432,
                ArticleStatus.bestellt: 12,
                ArticleStatus.fehlt: 7,
              },
            ),
          ),
        ),
      ),
    ),
  );
}

void main() {
  testWidgets('shows the value and the status label', (tester) async {
    await tester.pumpWidget(
      _wrap(const KpiFilterCard(value: 432, status: ArticleStatus.inStock)),
    );

    expect(find.text('432'), findsOneWidget);
    expect(find.text('Im Shop'), findsOneWidget);
  });

  testWidgets('paints the card in the status color', (tester) async {
    await tester.pumpWidget(
      _wrap(const KpiFilterCard(value: 7, status: ArticleStatus.fehlt)),
    );

    expect(
      _card(tester).color,
      AppColors.statusColors[ArticleStatus.fehlt],
    );
  });

  testWidgets('uses white foreground on green and red', (tester) async {
    for (final status in [ArticleStatus.inStock, ArticleStatus.fehlt]) {
      await tester.pumpWidget(_wrap(KpiFilterCard(value: 1, status: status)));

      final value = tester.widget<Text>(find.text('1'));
      final label = tester.widget<Text>(find.text(status.label));
      expect(value.style!.color, AppColors.white, reason: '$status');
      expect(label.style!.color, AppColors.white, reason: '$status');
    }
  });

  testWidgets('uses dark ink on the yellow "bestellt" card', (tester) async {
    await tester.pumpWidget(
      _wrap(const KpiFilterCard(value: 12, status: ArticleStatus.bestellt)),
    );

    final value = tester.widget<Text>(find.text('12'));
    final icon = tester.widget<Icon>(find.byType(Icon));
    expect(value.style!.color, AppColors.textPrimary);
    expect(icon.color, AppColors.textPrimary);
  });

  testWidgets('reports taps', (tester) async {
    var taps = 0;
    await tester.pumpWidget(
      _wrap(
        KpiFilterCard(
          value: 5,
          status: ArticleStatus.bestellt,
          onTap: () => taps++,
        ),
      ),
    );

    await tester.tap(find.byType(KpiFilterCard));
    expect(taps, 1);
  });

  testWidgets('is not tappable without a callback', (tester) async {
    await tester.pumpWidget(
      _wrap(const KpiFilterCard(value: 5, status: ArticleStatus.bestellt)),
    );

    expect(tester.widget<InkWell>(find.byType(InkWell)).onTap, isNull);
  });

  testWidgets('three cards fit side by side on a 320 dp screen', (
    tester,
  ) async {
    await _pumpRow(tester, 320);

    expect(tester.takeException(), isNull);
    expect(find.text('Bestellt'), findsOneWidget);
  });

  testWidgets('three cards fit at a 1.5x text scale', (tester) async {
    await _pumpRow(tester, 320, textScale: 1.5);

    expect(tester.takeException(), isNull);
  });

  testWidgets('all three cards make the same icon decision', (tester) async {
    for (final width in [320.0, 360.0, 390.0, 430.0]) {
      await _pumpRow(tester, width);
      expect(
        find.byType(Icon).evaluate().length,
        anyOf(0, 3),
        reason: 'bei ${width}dp',
      );
    }
  });

  // Bewusst sehr breit: die Testschrift ist deutlich breiter als die echte,
  // eine Grenze nahe an realen Geraetebreiten waere hier nicht aussagekraeftig.
  testWidgets('keeps the icon when the card is wide enough', (tester) async {
    await _pumpRow(tester, 800);

    expect(find.byType(Icon), findsNWidgets(3));
  });
}
