import 'package:bikedrop/design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart' as widgetbook;
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

@widgetbook.UseCase(name: 'Interactive', type: AppPrimaryButton)
Widget appPrimaryButtonInteractive(BuildContext context) {
  final isDisabled = context.knobs.boolean(label: 'Disabled', initialValue: false);
  final hasIcon = context.knobs.boolean(label: 'With icon', initialValue: false);

  return Center(
    child: AppPrimaryButton(
      label: context.knobs.string(label: 'Label', initialValue: 'Speichern'),
      icon: hasIcon ? Icons.check : null,
      onPressed: isDisabled ? null : () {},
    ),
  );
}
