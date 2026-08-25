import 'package:bikedrop/design_system/design_system.dart';
import 'package:bikedrop/models/demoscanoption.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:widgetbook/widgetbook.dart' as widgetbook;
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

const _demoOptions = [
  DemoScanOption(
    label: 'Katalogtreffer simulieren',
    subtitle: 'EAN 4007249913555 · Shimano XT',
    ean: '4007249913555',
    icon: Symbols.check_circle,
  ),
  DemoScanOption(
    label: 'Bekannten Artikel simulieren',
    subtitle: 'EAN 4055123456780 · Shimano Deore Bremsscheibe',
    ean: '4055123456780',
    icon: Symbols.inventory_2,
  ),
  DemoScanOption(
    label: 'Unbekannten Artikel simulieren',
    subtitle: 'EAN 4260119901230 · nicht im Katalog',
    ean: '4260119901230',
    icon: Symbols.help,
  ),
];

/// [FakeCameraView] ist zustandslos — hier uebernimmt der Knob die Rolle des
/// Parents und setzt activeEan.
@widgetbook.UseCase(name: 'Default', type: FakeCameraView)
Widget fakeCameraViewDefault(BuildContext context) {
  final scanning = context.knobs.boolean(
    label: 'Scan laeuft',
    initialValue: false,
  );
  final activeEan = context.knobs.string(
    label: 'Aktive EAN',
    initialValue: '4007249913555',
  );

  return SingleChildScrollView(
    child: FakeCameraView(
      demoOptions: _demoOptions,
      activeEan: scanning ? activeEan : null,
      onOptionTap: (option) => debugPrint('Tap: ${option.ean}'),
    ),
  );
}
