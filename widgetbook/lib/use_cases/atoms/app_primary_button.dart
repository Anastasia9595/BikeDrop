import 'package:bikedrop/design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart' as widgetbook;
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

@widgetbook.UseCase(name: 'Default', type: AppPrimaryButton)
Widget appPrimaryButtonDefault(BuildContext context) {
  return Center(
    child: AppPrimaryButton(
      label: context.knobs.string(label: 'Label', initialValue: 'Speichern'),
      onPressed: () {},
    ),
  );
}

@widgetbook.UseCase(name: 'With icon', type: AppPrimaryButton)
Widget appPrimaryButtonWithIcon(BuildContext context) {
  return Center(
    child: AppPrimaryButton(
      label: context.knobs.string(label: 'Label', initialValue: 'Speichern'),
      icon: Icons.check,
      onPressed: () {},
    ),
  );
}

@widgetbook.UseCase(name: 'Disabled', type: AppPrimaryButton)
Widget appPrimaryButtonDisabled(BuildContext context) {
  return Center(
    child: AppPrimaryButton(
      label: context.knobs.string(label: 'Label', initialValue: 'Speichern'),
      onPressed: null,
    ),
  );
}
