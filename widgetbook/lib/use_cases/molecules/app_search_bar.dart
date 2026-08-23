import 'package:bikedrop/design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart' as widgetbook;
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

@widgetbook.UseCase(name: 'Interactive', type: AppSearchBar)
Widget appSearchBarInteractive(BuildContext context) {
  final controller = TextEditingController();

  return Padding(
    padding: const EdgeInsets.all(24),
    child: AppSearchBar(
      controller: controller,
      placeholder: context.knobs.string(
        label: 'Placeholder',
        initialValue: 'Suchen...',
      ),
      onChanged: (value) {},
    ),
  );
}
