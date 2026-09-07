import 'package:bikedrop/design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart' as widgetbook;
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

@widgetbook.UseCase(name: 'Default', type: KpiFilterRow)
Widget kpiFilterRowDefault(BuildContext context) {
  return Padding(
    padding: const EdgeInsets.all(AppSpacing.screenPaddingH),
    child: KpiFilterRow(
      counts: {
        ArticleStatus.inStock: context.knobs.int.input(
          label: 'Im Shop',
          initialValue: 432,
        ),
        ArticleStatus.bestellt: context.knobs.int.input(
          label: 'Bestellt',
          initialValue: 12,
        ),
        ArticleStatus.fehlt: context.knobs.int.input(
          label: 'Fehlt',
          initialValue: 7,
        ),
      },
      selected: context.knobs.object.dropdown<ArticleStatus?>(
        label: 'Aktiver Filter',
        options: [null, ...ArticleStatus.values],
        labelBuilder: (status) => status?.label ?? 'Kein Filter',
      ),
      onStatusTap: (_) {},
    ),
  );
}
