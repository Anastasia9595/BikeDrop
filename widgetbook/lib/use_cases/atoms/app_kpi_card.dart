import 'package:bikedrop/design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart' as widgetbook;
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

@widgetbook.UseCase(name: 'Default', type: KpiFilterCard)
Widget kpiFilterCardDefault(BuildContext context) {
  final status = context.knobs.object.dropdown<ArticleStatus>(
    label: 'Status (nur zur Vorschau)',
    options: ArticleStatus.values,
    labelBuilder: (status) => status.label,
  );

  return Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: SizedBox(
        // Etwa so breit wie eine von drei Kacheln auf einem 390-dp-Geraet.
        width: 111,
        child: KpiFilterCard(
          value: context.knobs.int.input(label: 'Wert', initialValue: 432),
          label: status.label,
          color: AppColors.statusColors[status]!,
          tint: AppColors.statusColorTints[status]!,
          selected: context.knobs.boolean(label: 'Als Filter aktiv'),
          onTap: () {},
        ),
      ),
    ),
  );
}
