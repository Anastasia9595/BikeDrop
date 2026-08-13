import 'package:bikedrop/design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart' as widgetbook;
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

@widgetbook.UseCase(name: 'Default', type: QuantityStepper)
Widget quantityStepperDefault(BuildContext context) {
  final min = context.knobs.int.input(label: 'Min', initialValue: 0);
  final max = context.knobs.intOrNull.input(label: 'Max', initialValue: null);

  var quantity = context.knobs.int.input(label: 'Startmenge', initialValue: 12);

  return Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: SizedBox(
        width: 220,
        child: StatefulBuilder(
          builder: (context, setState) => QuantityStepper(
            quantity: quantity,
            min: min,
            max: max,
            onChanged: (value) => setState(() => quantity = value),
          ),
        ),
      ),
    ),
  );
}
