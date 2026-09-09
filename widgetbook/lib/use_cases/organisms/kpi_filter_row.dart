import 'package:bikedrop/design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart' as widgetbook;
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

KpiFilterEntry _entry(ArticleStatus status, int count) => KpiFilterEntry(
  key: status,
  label: status.label,
  color: AppColors.statusColors[status]!,
  tint: AppColors.statusColorTints[status]!,
  count: count,
);

@widgetbook.UseCase(name: 'Default', type: KpiFilterRow)
Widget kpiFilterRowDefault(BuildContext context) {
  final entries = [
    _entry(ArticleStatus.inStock, context.knobs.int.input(label: 'Im Shop', initialValue: 432)),
    _entry(ArticleStatus.bestellt, context.knobs.int.input(label: 'Bestellt', initialValue: 12)),
    _entry(ArticleStatus.fehlt, context.knobs.int.input(label: 'Fehlt', initialValue: 7)),
  ];
  final selected = context.knobs.object.dropdown<ArticleStatus?>(
    label: 'Aktiver Filter',
    options: [null, ...ArticleStatus.values],
    labelBuilder: (status) => status?.label ?? 'Kein Filter',
  );

  return Padding(
    padding: const EdgeInsets.all(AppSpacing.screenPaddingH),
    child: KpiFilterRow(
      entries: entries,
      selectedKey: selected,
      onEntryTap: (_) {},
    ),
  );
}
