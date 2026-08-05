import 'package:bikedrop/design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart' as widgetbook;
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

@widgetbook.UseCase(name: 'Interactive', type: AppSecondaryButton)
Widget appSecondaryButtonInteractive(BuildContext context) {
  final isDisabled = context.knobs.boolean(label: 'Disabled', initialValue: false);

  return Center(
    child: AppSecondaryButton(
      label: context.knobs.string(label: 'Label', initialValue: 'Abbrechen'),
      onPressed: isDisabled ? null : () {},
    ),
  );
}
