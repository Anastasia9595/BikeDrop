import 'package:bikedrop/design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart' as widgetbook;
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

@widgetbook.UseCase(name: 'Interactive', type: AppDropdownField)
Widget appDropdownFieldInteractive(BuildContext context) {
  final label = context.knobs.string(label: 'Label', initialValue: 'Kategorie');
  final errorText = context.knobs.string(label: 'Fehlertext', initialValue: '');

  Category? selected = Category.bremsen;

  return Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: StatefulBuilder(
        builder: (context, setState) => AppDropdownField<Category>(
          label: label,
          value: selected,
          items: Category.values,
          itemLabel: (category) => category.label,
          errorText: errorText.isEmpty ? null : errorText,
          onChanged: (category) => setState(() => selected = category),
        ),
      ),
    ),
  );
}
