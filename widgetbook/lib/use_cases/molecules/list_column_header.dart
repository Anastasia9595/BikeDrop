import 'package:bikedrop/design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart' as widgetbook;
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

@widgetbook.UseCase(name: 'Default', type: ListColumnHeader)
Widget listColumnHeaderDefault(BuildContext context) {
  return Padding(
    padding: const EdgeInsets.all(24),
    child: ListColumnHeader(
      label: context.knobs.string(label: 'Label', initialValue: 'Artikel'),
    ),
  );
}
