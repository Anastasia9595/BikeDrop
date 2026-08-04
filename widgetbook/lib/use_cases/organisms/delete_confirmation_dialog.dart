import 'package:bikedrop/design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart' as widgetbook;
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

@widgetbook.UseCase(name: 'Default', type: DeleteConfirmationDialog)
Widget deleteConfirmationDialogDefault(BuildContext context) {
  final title = context.knobs.string(label: 'Titel', initialValue: 'Löschen?');
  final message = context.knobs.string(
    label: 'Nachricht',
    initialValue: 'Artikel wirklich löschen?',
  );

  return Center(
    child: AppPrimaryButton(
      label: 'Dialog öffnen',
      onPressed: () => DeleteConfirmationDialog.show(
        context,
        title: title,
        message: message,
      ),
    ),
  );
}
