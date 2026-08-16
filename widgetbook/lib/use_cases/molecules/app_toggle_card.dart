import 'package:bikedrop/design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart' as widgetbook;
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

@widgetbook.UseCase(name: 'Interactive', type: AppToggleCard)
Widget appToggleCardInteractive(BuildContext context) {
  final title = context.knobs.string(
    label: 'Titel',
    initialValue: 'Für Kunden sichtbar',
  );
  final description = context.knobs.string(
    label: 'Beschreibung',
    initialValue: 'Erscheint auf der Kunden-Website',
  );

  bool value = false;

  return Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: StatefulBuilder(
        builder:
            (context, setState) => AppToggleCard(
              title: title,
              description: description,
              value: value,
              onChanged: (v) => setState(() => value = v),
            ),
      ),
    ),
  );
}
