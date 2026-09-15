import 'package:bikedrop/design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart' as widgetbook;
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

@widgetbook.UseCase(name: 'Default', type: AppSegment)
Widget appSegmentDefault(BuildContext context) {
  final selected = context.knobs.boolean(
    label: 'Ausgewählt',
    initialValue: false,
  );

  return Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: SizedBox(
        width: 140,
        height: AppSpacing.fieldHeight,
        child: AppSegment(
          label: context.knobs.string(label: 'Label', initialValue: 'Bestellt'),
          selected: selected,
          onTap: () {},
        ),
      ),
    ),
  );
}
