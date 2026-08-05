import 'package:bikedrop/design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart' as widgetbook;
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

@widgetbook.UseCase(name: 'Interactive', type: AppSnackbar)
Widget appSnackbarInteractive(BuildContext context) {
  final message = context.knobs.string(
    label: 'Nachricht',
    initialValue: 'Keine Verbindung',
  );
  final withAction = context.knobs.boolean(label: 'With action', initialValue: false);
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
        actionLabel: withAction ? actionLabel : null,
        onAction: withAction ? () {} : null,
      ),
    ),
  );
}
