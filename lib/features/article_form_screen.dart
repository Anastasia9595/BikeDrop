import 'package:flutter/material.dart';

import '../design_system/design_system.dart';

class ArticleFormScreen extends StatefulWidget {
  const ArticleFormScreen({super.key});

  @override
  State<ArticleFormScreen> createState() => _ArticleFormScreenState();
}

class _ArticleFormScreenState extends State<ArticleFormScreen> {
  ArticleStatus _status = ArticleStatus.inStock;
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.screenPaddingH,
          vertical: AppSpacing.screenSpacingV,
        ),
        child: Column(
          children: [
            AppImageUploadField(onTap: () {}),
            const SizedBox(height: AppSpacing.screenSpacingV),
            const AppTextField(label: 'Artikelnummer'),
            const AppTextField(label: 'Artikelname'),
            Row(
              children: [
                Expanded(
                  child: AppDropdownField<Category>(
                    label: 'Kategorie',
                    items: Category.values,
                    itemLabel: (item) => item.label,
                    onChanged: (Category? value) {},
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
            AppSegmentedControl<ArticleStatus>(
              label: 'Status',
              options: ArticleStatus.values,
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
            const SizedBox(height: AppSpacing.screenSpacingV),
            AppPrimaryButton(label: 'Artikel speichern', onPressed: () {}),
          ],
        ),
      ),
    );
  }
}
