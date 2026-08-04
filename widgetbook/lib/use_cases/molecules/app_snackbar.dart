import 'package:bikedrop/design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart' as widgetbook;
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

@widgetbook.UseCase(name: 'Default', type: AppSnackbar)
Widget appSnackbarDefault(BuildContext context) {
  final message = context.knobs.string(
    label: 'Nachricht',
    initialValue: 'Keine Verbindung',
  );

  return Center(
    child: AppPrimaryButton(
      label: 'Snackbar zeigen',
      onPressed: () => AppSnackbar.show(context, message),
    ),
  );
}

@widgetbook.UseCase(name: 'With action', type: AppSnackbar)
Widget appSnackbarWithAction(BuildContext context) {
  final message = context.knobs.string(
    label: 'Nachricht',
    initialValue: 'Keine Verbindung',
  );
  final actionLabel = context.knobs.string(
    label: 'Aktion-Label',
    initialValue: 'Erneut versuchen',
  );

  return Center(
    child: AppPrimaryButton(
      label: 'Snackbar zeigen',
      onPressed: () => AppSnackbar.show(
        context,
        message,
        actionLabel: actionLabel,
        onAction: () {},
      ),
    ),
  );
}
