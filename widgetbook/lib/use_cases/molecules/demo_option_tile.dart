import 'package:bikedrop/design_system/design_system.dart';
import 'package:bikedrop/models/demoscanoption.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:widgetbook/widgetbook.dart' as widgetbook;
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

@widgetbook.UseCase(name: 'Default', type: DemoOptionTile)
Widget demoOptionTileDefault(BuildContext context) {
  final enabled = context.knobs.boolean(
    label: 'Aktiv',
    initialValue: true,
  );
  final label = context.knobs.string(
    label: 'Label',
    initialValue: 'Katalogartikel simulieren',
  );
  final subtitle = context.knobs.string(
    label: 'Untertitel',
    initialValue: 'EAN 4007249913555 · Shimano XT',
  );

  return Center(
    child: DemoOptionTile(
      option: DemoScanOption(
        label: label,
        subtitle: subtitle,
        ean: '4007249913555',
        icon: Symbols.qr_code,
      ),
      enabled: enabled,
      onTap: () => debugPrint('Tap'),
    ),
  );
}
