// test/design_system/atoms/app_icon_button_test.dart
import 'package:bikedrop/design_system/atoms/app_icon_button.dart';
import 'package:bikedrop/design_system/tokens/app_colors.dart';
import 'package:bikedrop/design_system/tokens/app_spacing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_symbols_icons/symbols.dart';

Widget _wrap(Widget child) =>
    MaterialApp(home: Scaffold(body: Center(child: child)));

void main() {
  testWidgets('renders the icon and calls onPressed', (tester) async {
    var pressed = 0;

    await tester.pumpWidget(
      _wrap(
        AppIconButton(
          icon: Symbols.add,
          tooltip: 'Hinzufügen',
          onPressed: () => pressed++,
        ),
      ),
    );

    expect(find.byIcon(Symbols.add), findsOneWidget);
    await tester.tap(find.byType(AppIconButton));
    expect(pressed, 1);
  });

  testWidgets('exposes the tooltip as its accessible label', (tester) async {
    await tester.pumpWidget(
      _wrap(
        AppIconButton(
          icon: Symbols.add,
          tooltip: 'Hinzufügen',
          onPressed: () {},
        ),
      ),
    );

    expect(find.byTooltip('Hinzufügen'), findsOneWidget);
  });

  testWidgets('is disabled and greyed out when onPressed is null', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        const AppIconButton(
          icon: Symbols.remove,
          tooltip: 'Entfernen',
          onPressed: null,
        ),
      ),
    );

    final button = tester.widget<IconButton>(find.byType(IconButton));
    expect(button.onPressed, isNull);

    // IconButton faerbt ueber das umgebende IconTheme, nicht ueber Icon.color.
    final iconTheme = IconTheme.of(tester.element(find.byIcon(Symbols.remove)));
    expect(iconTheme.color, AppColors.textQuaternaryLight);
  });

  testWidgets('keeps a minimum tap target', (tester) async {
    await tester.pumpWidget(
      _wrap(
        AppIconButton(
          icon: Symbols.add,
          tooltip: 'Hinzufügen',
          onPressed: () {},
        ),
      ),
    );

    final size = tester.getSize(find.byType(AppIconButton));
    expect(size.width, greaterThanOrEqualTo(AppSpacing.minTapTarget));
    expect(size.height, greaterThanOrEqualTo(AppSpacing.minTapTarget));
  });
}
