import 'package:bikedrop/design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart' as widgetbook;
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

@widgetbook.UseCase(name: 'Default', type: AppSecondaryButton)
Widget appSecondaryButtonDefault(BuildContext context) {
  return Center(
    child: AppSecondaryButton(
      label: context.knobs.string(label: 'Label', initialValue: 'Abbrechen'),
      onPressed: () {},
    ),
  );
}

@widgetbook.UseCase(name: 'Disabled', type: AppSecondaryButton)
Widget appSecondaryButtonDisabled(BuildContext context) {
  return Center(
    child: AppSecondaryButton(
      label: context.knobs.string(label: 'Label', initialValue: 'Abbrechen'),
      onPressed: null,
    ),
  );
}
