import 'package:bikedrop/design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

import 'main.directories.g.dart';

void main() {
  runApp(const WidgetbookApp());
}

@widgetbook.App()
class WidgetbookApp extends StatelessWidget {
  const WidgetbookApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Widgetbook.material(
      directories: directories,
      addons: [
        ViewportAddon(
          [IosViewports.iPhone13, AndroidViewports.samsungGalaxyA50],
        ),
        TextScaleAddon(min: 1, max: 2),
        ThemeAddon<ThemeData>(
          themes: [
            WidgetbookTheme(name: 'BikeDrop', data: AppTheme.light()),
          ],
          themeBuilder: (context, theme, child) => Theme(
            data: theme,
            child: child,
          ),
        ),
      ],
    );
  }
}
