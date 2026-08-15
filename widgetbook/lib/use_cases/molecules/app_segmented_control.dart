import 'package:bikedrop/design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart' as widgetbook;
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

@widgetbook.UseCase(name: 'Interactive', type: AppSegmentedControl)
Widget appSegmentedControlInteractive(BuildContext context) {
  final label = context.knobs.string(label: 'Label', initialValue: 'Status');

  ItemStatus selected = ItemStatus.imShop;

  return Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: StatefulBuilder(
        builder:
            (context, setState) => AppSegmentedControl<ItemStatus>(
              label: label.isEmpty ? null : label,
              options: ItemStatus.values,
              labelBuilder: (status) => status.label,
              value: selected,
              onChanged: (status) => setState(() => selected = status),
            ),
      ),
    ),
  );
}
