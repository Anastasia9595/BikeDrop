import 'package:bikedrop/design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:widgetbook/widgetbook.dart' as widgetbook;
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

@widgetbook.UseCase(name: 'Default', type: AppIconButton)
Widget appIconButtonDefault(BuildContext context) {
  final enabled = context.knobs.boolean(label: 'Aktiv', initialValue: true);

  return Center(
    child: AppIconButton(
      icon: context.knobs.object.dropdown<IconData>(
        label: 'Icon',
        options: const [Symbols.add, Symbols.remove, Symbols.delete],
        labelBuilder: (icon) => switch (icon) {
          Symbols.remove => 'remove',
          Symbols.delete => 'delete',
          _ => 'add',
        },
      ),
      tooltip: context.knobs.string(
        label: 'Tooltip',
        initialValue: 'Hinzufügen',
      ),
      onPressed: enabled ? () {} : null,
    ),
  );
}
