import 'package:bikedrop/design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart' as widgetbook;
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

@widgetbook.UseCase(name: 'Default', type: CategoryBadge)
Widget categoryBadgeDefault(BuildContext context) {
  final category = context.knobs.object.dropdown<Category>(
    label: 'Kategorie',
    options: Category.values,
    labelBuilder: (category) => category.name,
  );

  return Center(child: CategoryBadge(category: category));
}
