import 'package:bikedrop/design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart' as widgetbook;
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

@widgetbook.UseCase(name: 'Default', type: ItemListTile)
Widget itemListTileDefault(BuildContext context) {
  final category = context.knobs.object.dropdown<Category>(
    label: 'Kategorie',
    options: Category.values,
    labelBuilder: (category) => category.name,
  );

  return Padding(
    padding: const EdgeInsets.all(24),
    child: ItemListTile(
      title: context.knobs.string(
        label: 'Titel',
        initialValue: 'Shimano XT Scheibe 203',
      ),
      quantity: context.knobs.int.input(label: 'Menge', initialValue: 12),
      category: category,
      status: context.knobs.object.dropdown<ItemStatus>(
        label: 'Status',
        options: ItemStatus.values,
        labelBuilder: (status) => status.name,
      ),
      onTap:
          context.knobs.boolean(label: 'Tippbar', initialValue: true)
              ? () {}
              : null,
    ),
  );
}
