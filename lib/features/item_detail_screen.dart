import 'package:flutter/material.dart';

import '../design_system/design_system.dart';

class ItemDetailScreen extends StatefulWidget {
  const ItemDetailScreen({super.key});

  @override
  State<ItemDetailScreen> createState() => _ItemDetailScreenState();
}

class _ItemDetailScreenState extends State<ItemDetailScreen> {
  ItemStatus _status = ItemStatus.imShop;
  bool _visibleForCustomers = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {},
        ),
        title: const Text('Neuer Artikel', style: AppTypography.screenTitle),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.screenPaddingH,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AppImageUploadField(onTap: () {}),
            const SizedBox(height: AppSpacing.screenSpacingV),
            const AppTextField(label: 'Artikelnummer'),
            const AppTextField(label: 'Artikelname'),
            Row(
              children: [
                Expanded(
                  child: AppDropdownField<String>(
                    label: 'Kategorie',
                    items: const ['Kategorie 1', 'Kategorie 2', 'Kategorie 3'],
                    itemLabel: (item) => item,
                    onChanged: (String? value) {},
                  ),
                ),
                const SizedBox(width: AppSpacing.screenSpacingH),
                Expanded(
                  child: AppDropdownField<String>(
                    label: 'Lieferant',
                    items: const ['Lieferant 1', 'Lieferant 2', 'Lieferant 3'],
                    itemLabel: (item) => item,
                    onChanged: (String? value) {},
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: QuantityStepper(
                    label: 'Menge',
                    quantity: 1,
                    onChanged: (int value) {},
                    min: 0,
                    max: 100,
                  ),
                ),
                const SizedBox(width: AppSpacing.screenSpacingH),
                Expanded(
                  child: AppTextField(
                    label: 'Mindestbestand',
                    keyboardType: TextInputType.number,
                    placeholder: '0',
                  ),
                ),
              ],
            ),

            Row(
              children: [
                Expanded(
                  child: AppTextField(
                    label: 'Einkaufspreis',
                    keyboardType: TextInputType.number,
                    placeholder: '0.00 €',
                  ),
                ),
                const SizedBox(width: AppSpacing.screenSpacingH),
                Expanded(
                  child: AppTextField(
                    label: 'Verkaufspreis',
                    keyboardType: TextInputType.number,
                    placeholder: '0.00 €',
                  ),
                ),
              ],
            ),
            AppTextField(
              label: 'Lagerort',
              placeholder: 'z.B. Regal A, Fach 3',
            ),
            const SizedBox(height: AppSpacing.screenSpacingV),
            AppSegmentedControl<ItemStatus>(
              label: 'Status',
              options: ItemStatus.values,
              labelBuilder: (status) => status.label,
              value: _status,
              onChanged: (status) => setState(() => _status = status),
            ),
            const SizedBox(height: AppSpacing.screenSpacingV),
            AppToggleCard(
              title: 'Für Kunden sichtbar',
              description: 'Erscheint auf der Kunden-Website',
              value: _visibleForCustomers,
              onChanged:
                  (value) => setState(() => _visibleForCustomers = value),
            ),
          ],
        ),
      ),
    );
  }
}
