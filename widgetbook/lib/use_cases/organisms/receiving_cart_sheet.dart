import 'package:bikedrop/design_system/design_system.dart';
import 'package:bikedrop/models/receivingcartitem.dart';
import 'package:bikedrop/providers/receiving_cart_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

class _SeededCartNotifier extends ReceivingCartNotifier {
  _SeededCartNotifier(this._seed);
  final List<ReceivingCartItem> _seed;

  @override
  List<ReceivingCartItem> build() => _seed;
}

@widgetbook.UseCase(name: 'Mit Positionen', type: ReceivingCartSheet)
Widget receivingCartSheetWithItems(BuildContext context) {
  return ProviderScope(
    overrides: [
      receivingCartProvider.overrideWith(
        () => _SeededCartNotifier(const [
          ReceivingCartItem(ean: '4055123456780', quantity: 2),
          ReceivingCartItem(ean: '4711234567899', quantity: 10),
          ReceivingCartItem(ean: '978020137962', quantity: 1),
        ]),
      ),
    ],
    child: const Scaffold(body: ReceivingCartSheet()),
  );
}
