import 'package:bikedrop/design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart' as widgetbook;
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

@widgetbook.UseCase(name: 'Interactive', type: AppTextField)
Widget appTextFieldInteractive(BuildContext context) {
  final errorText = context.knobs.string(label: 'Fehlertext', initialValue: '');
  final obscureText = context.knobs.boolean(label: 'Obscured', initialValue: false);

  return Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: AppTextField(
        label: context.knobs.string(label: 'Label', initialValue: 'Name'),
        errorText: errorText.isEmpty ? null : errorText,
        obscureText: obscureText,
      ),
    ),
  );
}
