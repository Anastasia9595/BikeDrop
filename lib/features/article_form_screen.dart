import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../design_system/design_system.dart';
import '../models/article.dart';
import '../providers/article_repository_provider.dart';

class ArticleFormScreen extends ConsumerStatefulWidget {
  const ArticleFormScreen({this.article, super.key});

  /// Wenn gesetzt, startet das Formular vorausgefüllt zum Bearbeiten
  /// dieses Artikels. Bei null wird ein neuer Artikel angelegt.
  final Article? article;

  @override
  ConsumerState<ArticleFormScreen> createState() => _ArticleFormScreenState();
}

class _ArticleFormScreenState extends ConsumerState<ArticleFormScreen> {
  late final TextEditingController _articleNumberController;
  late final TextEditingController _nameController;
  late final TextEditingController _minQuantityController;
  late final TextEditingController _purchasePriceController;
  late final TextEditingController _sellingPriceController;
  late final TextEditingController _storageLocationController;

  late Category? _category;
  late String? _supplier;
  late int _quantity;
  late ArticleStatus _status;
  late bool _visibleForCustomers;

  @override
  void initState() {
    super.initState();
    final article = widget.article;

    _articleNumberController = TextEditingController(text: article?.ean ?? '');
    _nameController = TextEditingController(text: article?.name ?? '');
    _minQuantityController = TextEditingController(
      text: article != null ? '${article.minQuantity}' : '',
    );
    _purchasePriceController = TextEditingController(
      text: article != null ? '${article.purchasePrice}' : '',
    );
    _sellingPriceController = TextEditingController(
      text: article != null ? '${article.sellingPrice}' : '',
    );
    _storageLocationController = TextEditingController(
      text: article?.storageLocation ?? '',
    );

    _category = article?.category;
    _supplier = article?.supplier;
    _quantity = article?.quantity ?? 1;
    _status = article?.status ?? ArticleStatus.inStock;
    _visibleForCustomers = article?.isPublic ?? false;
  }

  @override
  void dispose() {
    _articleNumberController.dispose();
    _nameController.dispose();
    _minQuantityController.dispose();
    _purchasePriceController.dispose();
    _sellingPriceController.dispose();
    _storageLocationController.dispose();
    super.dispose();
  }

  bool get _canSave =>
      _nameController.text.trim().isNotEmpty && _category != null;

  Future<void> _save() async {
    final category = _category;
    if (category == null) return;

    final now = DateTime.now();
    final ean = _articleNumberController.text.trim();
    final storageLocation = _storageLocationController.text.trim();
    final existing = widget.article;

    final article =
        (existing ??
                Article(
                  name: '',
                  category: category,
                  quantity: 0,
                  minQuantity: 0,
                  purchasePrice: 0,
                  sellingPrice: 0,
                  status: ArticleStatus.inStock,
                  createdAt: now,
                  updatedAt: now,
                ))
            .copyWith(
              ean: ean.isEmpty ? null : ean,
              name: _nameController.text.trim(),
              category: category,
              supplier: _supplier,
              quantity: _quantity,
              minQuantity: int.tryParse(_minQuantityController.text) ?? 0,
              purchasePrice:
                  double.tryParse(_purchasePriceController.text) ?? 0,
              sellingPrice: double.tryParse(_sellingPriceController.text) ?? 0,
              storageLocation: storageLocation.isEmpty ? null : storageLocation,
              status: _status,
              isPublic: _visibleForCustomers,
              updatedAt: now,
            );

    final repository = ref.read(articleRepositoryProvider);
    if (existing != null) {
      await repository.updateArticle(article);
    } else {
      await repository.createArticle(article);
    }

    ref.invalidate(filterArticleByName(ref.read(searchQueryProvider)));

    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.article != null;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          isEditing ? 'Artikel bearbeiten' : 'Neuer Artikel',
          style: AppTypography.screenTitle,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.screenPaddingH,
          vertical: AppSpacing.screenSpacingV,
        ),
        child: Column(
          children: [
            AppImageUploadField(
              onTap: () {},
              imageUrl: widget.article?.imageUrl,
            ),
            const SizedBox(height: AppSpacing.screenSpacingV),
            AppTextField(
              label: 'Artikelnummer',
              controller: _articleNumberController,
            ),
            AppTextField(
              label: 'Artikelname',
              controller: _nameController,
              onChanged: (_) => setState(() {}),
            ),
            Row(
              children: [
                Expanded(
                  child: AppDropdownField<Category>(
                    label: 'Kategorie',
                    items: Category.values,
                    itemLabel: (item) => item.label,
                    value: _category,
                    onChanged: (Category? value) =>
                        setState(() => _category = value),
                  ),
                ),
                const SizedBox(width: AppSpacing.screenSpacingH),
                Expanded(
                  child: AppDropdownField<String>(
                    label: 'Lieferant',
                    items: ref
                        .read(getSuppliers)
                        .maybeWhen(
                          data: (data) => data.whereType<String>().toList(),
                          orElse: () => [],
                        ),
                    itemLabel: (item) => item,
                    value: _supplier,
                    onChanged: (String? value) =>
                        setState(() => _supplier = value),
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: QuantityStepper(
                    label: 'Menge',
                    quantity: _quantity,
                    onChanged: (int value) => setState(() => _quantity = value),
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
                    controller: _minQuantityController,
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
                    controller: _purchasePriceController,
                  ),
                ),
                const SizedBox(width: AppSpacing.screenSpacingH),
                Expanded(
                  child: AppTextField(
                    label: 'Verkaufspreis',
                    keyboardType: TextInputType.number,
                    placeholder: '0.00 €',
                    controller: _sellingPriceController,
                  ),
                ),
              ],
            ),
            AppTextField(
              label: 'Lagerort',
              placeholder: 'z.B. Regal A, Fach 3',
              controller: _storageLocationController,
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
              onChanged: (value) =>
                  setState(() => _visibleForCustomers = value),
            ),
            const SizedBox(height: AppSpacing.screenSpacingV),
            AppPrimaryButton(
              label: isEditing ? 'Änderungen speichern' : 'Artikel speichern',
              onPressed: _canSave ? _save : null,
            ),
          ],
        ),
      ),
    );
  }
}
