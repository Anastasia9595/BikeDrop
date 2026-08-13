// test/design_system/atoms/app_dropdown_field_test.dart
import 'package:bikedrop/design_system/atoms/app_dropdown_field.dart';
import 'package:bikedrop/design_system/tokens/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _wrap(Widget child) =>
    MaterialApp(home: Scaffold(body: Center(child: child)));

void main() {
  testWidgets('shows the label uppercased above the field', (tester) async {
    await tester.pumpWidget(
      _wrap(
        AppDropdownField<Category>(
          label: 'Kategorie',
          items: Category.values,
          itemLabel: (category) => category.label,
          onChanged: (_) {},
        ),
      ),
    );

    expect(find.text('KATEGORIE'), findsOneWidget);
  });

  testWidgets('shows the label of the selected value', (tester) async {
    await tester.pumpWidget(
      _wrap(
        AppDropdownField<Category>(
          label: 'Kategorie',
          value: Category.bremsen,
          items: Category.values,
          itemLabel: (category) => category.label,
          onChanged: (_) {},
        ),
      ),
    );

    expect(find.text('Bremsen'), findsOneWidget);
  });

  testWidgets('calls onChanged with the picked value', (tester) async {
    Category? picked;

    await tester.pumpWidget(
      _wrap(
        AppDropdownField<Category>(
          label: 'Kategorie',
          value: Category.bremsen,
          items: Category.values,
          itemLabel: (category) => category.label,
          onChanged: (category) => picked = category,
        ),
      ),
    );

    await tester.tap(find.byType(DropdownButton<Category>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Reifen').last);
    await tester.pumpAndSettle();

    expect(picked, Category.reifen);
  });

  testWidgets('shows error text and accent border when errorText is set', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        AppDropdownField<Category>(
          label: 'Kategorie',
          items: Category.values,
          itemLabel: (category) => category.label,
          onChanged: (_) {},
          errorText: 'Pflichtfeld',
        ),
      ),
    );

    expect(find.text('Pflichtfeld'), findsOneWidget);

    final decorator = tester.widget<InputDecorator>(
      find.byType(InputDecorator),
    );
    final border =
        decorator.decoration.enabledBorder! as OutlineInputBorder;
    expect(border.borderSide.color, AppColors.accent);
  });

  testWidgets('uses the default border and no error text without errorText', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        AppDropdownField<Category>(
          label: 'Kategorie',
          items: Category.values,
          itemLabel: (category) => category.label,
          onChanged: (_) {},
        ),
      ),
    );

    expect(find.text('Pflichtfeld'), findsNothing);

    final decorator = tester.widget<InputDecorator>(
      find.byType(InputDecorator),
    );
    final border =
        decorator.decoration.enabledBorder! as OutlineInputBorder;
    expect(border.borderSide.color, AppColors.border);
  });

  testWidgets('renders long item labels without overflowing', (tester) async {
    await tester.pumpWidget(
      _wrap(
        SizedBox(
          width: 180,
          child: AppDropdownField<String>(
            label: 'Lieferant',
            value: 'Paul Lange & Co. OHG Stuttgart',
            items: const ['Paul Lange & Co. OHG Stuttgart'],
            itemLabel: (supplier) => supplier,
            onChanged: (_) {},
          ),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
  });
}
