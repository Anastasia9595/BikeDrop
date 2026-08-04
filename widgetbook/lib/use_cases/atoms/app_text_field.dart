import 'package:bikedrop/design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart' as widgetbook;
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

@widgetbook.UseCase(name: 'Default', type: AppTextField)
Widget appTextFieldDefault(BuildContext context) {
  return Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: AppTextField(
        label: context.knobs.string(label: 'Label', initialValue: 'Name'),
      ),
    ),
  );
}

@widgetbook.UseCase(name: 'Error', type: AppTextField)
Widget appTextFieldError(BuildContext context) {
  return Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: AppTextField(
        label: context.knobs.string(label: 'Label', initialValue: 'Name'),
        errorText: context.knobs.string(
          label: 'Fehlertext',
          initialValue: 'Pflichtfeld',
        ),
      ),
    ),
  );
}

@widgetbook.UseCase(name: 'Obscured', type: AppTextField)
Widget appTextFieldObscured(BuildContext context) {
  return Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: AppTextField(
        label: context.knobs.string(label: 'Label', initialValue: 'Passwort'),
        obscureText: true,
      ),
    ),
  );
}
