import 'package:bikedrop/design_system/design_system.dart';
import 'package:bikedrop/models/demoscanoption.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:widgetbook/widgetbook.dart' as widgetbook;
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

enum _Accent { blau, gruen, orange, rot }

extension on _Accent {
  Color get color => switch (this) {
    _Accent.blau => AppColors.infoBlue,
    _Accent.gruen => AppColors.statusColorSuccess,
    _Accent.orange => AppColors.statusColorWarning,
    _Accent.rot => AppColors.statusColorError,
  };
}

@widgetbook.UseCase(name: 'Interactive', type: DemoScenarioButton)
Widget demoScenarioButtonInteractive(BuildContext context) {
  final enabled = context.knobs.boolean(label: 'Aktiv', initialValue: true);
  final label = context.knobs.string(
    label: 'Label',
    initialValue: 'Katalogartikel',
  );
  final accent = context.knobs.object.dropdown<_Accent>(
    label: 'Akzentfarbe',
    options: _Accent.values,
    labelBuilder: (accent) => accent.name,
  );

  return Center(
    child: DemoScenarioButton(
      option: DemoScanOption(
        label: label,
        subtitle: 'EAN 4029876501233',
        ean: '4029876501233',
        icon: Symbols.grid_view,
        color: accent.color,
      ),
      enabled: enabled,
      onTap: () => debugPrint('Tap'),
    ),
  );
}
