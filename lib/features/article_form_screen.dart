import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/article_image.dart';
import '../design_system/design_system.dart';
import '../models/article.dart';
import '../models/catalogarticle.dart';
import '../providers/article_repository_provider.dart';
import '../providers/image_picker_provider.dart';

class ArticleFormScreen extends ConsumerStatefulWidget {
  const ArticleFormScreen({this.article, this.catalogArticle, super.key});

  /// Wenn gesetzt, startet das Formular vorausgefüllt zum Bearbeiten
  /// dieses Artikels. Bei null wird ein neuer Artikel angelegt.
  final Article? article;

  /// Stammdaten aus dem Katalog zu einer gescannten EAN, die das Projekt noch
  /// nicht im Lager hat. Befüllt das Formular vor, es bleibt aber ein NEUER
  /// Artikel — anders als [article]. Wird ignoriert, wenn [article] gesetzt ist.
  final CatalogArticle? catalogArticle;

  @override
  ConsumerState<ArticleFormScreen> createState() => _ArticleFormScreenState();
}

class _ArticleFormScreenState extends ConsumerState<ArticleFormScreen> {
  late final TextEditingController _articleNumberController;
  late final TextEditingController _nameController;
  late final TextEditingController _minQuantityController;
  late final TextEditingController _maxQuantityController;
  late final TextEditingController _purchasePriceController;
  late final TextEditingController _sellingPriceController;
  late final TextEditingController _storageLocationController;

  late Category? _category;
  late String? _supplier;
  late int _quantity;
  late ArticleStatus _status;
  late bool _visibleForCustomers;

  /// Verweis auf das Artikelbild: entweder die gespeicherte URL oder,
  /// nach einer frischen Aufnahme, der lokale Pfad der Bilddatei.
  late String? _imageSource;

  @override
  void initState() {
    super.initState();
    final article = widget.article;
    // Nur relevant, solange kein Artikel bearbeitet wird.
    final catalog = article == null ? widget.catalogArticle : null;

    _articleNumberController = TextEditingController(
      text: article?.ean ?? catalog?.ean ?? '',
    );
    _nameController = TextEditingController(
      text: article?.name ?? catalog?.name ?? '',
    );
    _minQuantityController = TextEditingController(
      text: article != null ? '${article.minQuantity}' : '',
    );
    _maxQuantityController = TextEditingController(
      text: article?.maxQuantity != null ? '${article!.maxQuantity}' : '',
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

    _category = article?.category ?? catalog?.category;
    _supplier = article?.supplier ?? catalog?.supplier;
    _quantity = article?.quantity ?? 1;
    _status = article?.status ?? ArticleStatus.inStock;
    _visibleForCustomers = article?.isPublic ?? false;
    _imageSource = article?.imageUrl ?? catalog?.imageUrl;
  }

  /// Laesst den Nutzer die Quelle waehlen und uebernimmt das aufgenommene
  /// bzw. ausgewaehlte Bild ins Formular.
  Future<void> _pickImage() async {
    final source = await ImageSourceSheet.show(context);
    if (source == null || !mounted) return;

    try {
      final file = await ref.read(imagePickerServiceProvider).pickImage(source);
      // Abbruch in Kamera/Galerie liefert null — dann bleibt das
      // bisherige Bild stehen.
      if (file == null || !mounted) return;
      setState(() => _imageSource = file.path);
    } on Exception catch (error, stackTrace) {
      // Ohne Log ist die Snackbar nicht diagnostizierbar — z. B. eine
      // MissingPluginException, wenn die App nach dem Hinzufuegen des
      // Plugins nur hot-reloaded statt neu gebaut wurde.
      debugPrint('Bildauswahl fehlgeschlagen: $error\n$stackTrace');
      if (!mounted) return;
      AppSnackbar.show(context, 'Bild konnte nicht geladen werden');
    }
  }

  @override
  void dispose() {
    _articleNumberController.dispose();
    _nameController.dispose();
    _minQuantityController.dispose();
    _maxQuantityController.dispose();
    _purchasePriceController.dispose();
    _sellingPriceController.dispose();
    _storageLocationController.dispose();
    super.dispose();
  }

  int get _minQuantity => int.tryParse(_minQuantityController.text.trim()) ?? 0;

  /// Eingetragener Hoechstbestand, null wenn das Feld leer ist (= unbegrenzt).
  int? get _maxQuantity => int.tryParse(_maxQuantityController.text.trim());

  /// Verhindert, dass man sich eine Obergrenze setzt, die unter dem bereits
  /// eingelagerten Bestand liegt — sonst laesst sich die Menge danach nicht
  /// mehr erhoehen.
  String? get _maxQuantityError {
    if (_maxQuantityController.text.trim().isEmpty) return null;
    final max = _maxQuantity;
    if (max == null) return 'Bitte eine ganze Zahl eingeben';
    if (max < _minQuantity) {
      return 'Darf nicht unter dem Mindestbestand liegen';
    }
    if (max < _quantity) return 'Darf nicht unter der aktuellen Menge liegen';
    return null;
  }

  /// Ein Zahlenfeld zaehlt erst als ausgefuellt, wenn es auch lesbar ist —
  /// sonst wuerde beim Speichern still 0 landen.
  bool _hasNumber(TextEditingController controller) =>
      double.tryParse(controller.text.trim().replaceAll(',', '.')) != null;

  /// Pflicht sind nur die fachlich noetigen Felder. Hoechstbestand, Lieferant,
  /// Lagerort und Bild sind im Datenmodell nullable und bleiben freiwillig.
  bool get _canSave =>
      _articleNumberController.text.trim().isNotEmpty &&
      _nameController.text.trim().isNotEmpty &&
      _category != null &&
      _hasNumber(_minQuantityController) &&
      _hasNumber(_purchasePriceController) &&
      _hasNumber(_sellingPriceController) &&
      _maxQuantityError == null;

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
              minQuantity: _minQuantity,
              maxQuantity: _maxQuantity,
              purchasePrice:
                  double.tryParse(_purchasePriceController.text) ?? 0,
              sellingPrice: double.tryParse(_sellingPriceController.text) ?? 0,
              storageLocation: storageLocation.isEmpty ? null : storageLocation,
              status: _status,
              isPublic: _visibleForCustomers,
              imageUrl: _imageSource,
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

  /// Die bekannten Lieferanten, ergaenzt um den aktuell gesetzten.
  ///
  /// [getSuppliers] kennt nur Lieferanten, die schon an einem Lagerartikel
  /// haengen. Ein aus dem Katalog uebernommener Lieferant fehlt dort und wuerde
  /// im Dropdown sonst leer bleiben.
  List<String> _supplierOptions(List<String> known) {
    final supplier = _supplier;
    if (supplier == null || known.contains(supplier)) return known;
    return [supplier, ...known];
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.article != null;

    return Scaffold(
      appBar: AppBar(
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
          spacing: AppSpacing.fieldGap,
          children: [
            AppImageUploadField(
              onTap: _pickImage,
              image: articleImageProvider(_imageSource),
            ),
            AppTextField(
              label: 'Artikelnummer',
              controller: _articleNumberController,
              maxLines: 1,
              onChanged: (_) => setState(() {}),
            ),
            AppTextField(
              label: 'Artikelname',
              controller: _nameController,
              onChanged: (_) => setState(() {}),
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: AppSpacing.screenSpacingH,
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
                Expanded(
                  child: AppDropdownField<String>(
                    label: 'Lieferant',
                    items: _supplierOptions(
                      ref
                          .watch(getSuppliers)
                          .maybeWhen(
                            data: (data) => data.whereType<String>().toList(),
                            orElse: () => <String>[],
                          ),
                    ),
                    itemLabel: (item) => item,
                    value: _supplier,
                    onChanged: (String? value) =>
                        setState(() => _supplier = value),
                  ),
                ),
              ],
            ),
            QuantityStepper(
              label: 'Menge',
              quantity: _quantity,
              onChanged: (int value) => setState(() => _quantity = value),
              min: 0,
              // Nur eine gueltige Grenze begrenzen lassen — solange die
              // Eingabe fehlerhaft ist, bleibt der Stepper offen.
              max: _maxQuantityError == null ? _maxQuantity : null,
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: AppSpacing.screenSpacingH,
              children: [
                Expanded(
                  child: AppTextField(
                    label: 'Mindestbestand',
                    keyboardType: TextInputType.number,
                    placeholder: '0',
                    controller: _minQuantityController,
                    maxLines: 1,
                    onChanged: (_) => setState(() {}),
                  ),
                ),
                Expanded(
                  child: AppTextField(
                    label: 'Höchstbestand',
                    keyboardType: TextInputType.number,
                    placeholder: 'unbegrenzt',
                    controller: _maxQuantityController,
                    errorText: _maxQuantityError,
                    maxLines: 1,
                    onChanged: (_) => setState(() {}),
                  ),
                ),
              ],
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: AppSpacing.screenSpacingH,
              children: [
                Expanded(
                  child: AppTextField(
                    label: 'Einkaufspreis',
                    onChanged: (_) => setState(() {}),
                    keyboardType: TextInputType.number,
                    placeholder: '0.00 €',
                    controller: _purchasePriceController,
                    maxLines: 1,
                  ),
                ),
                Expanded(
                  child: AppTextField(
                    label: 'Verkaufspreis',
                    onChanged: (_) => setState(() {}),
                    keyboardType: TextInputType.number,
                    placeholder: '0.00 €',
                    controller: _sellingPriceController,
                    maxLines: 1,
                  ),
                ),
              ],
            ),
            AppTextField(
              label: 'Lagerort',
              placeholder: 'z.B. Regal A, Fach 3',
              controller: _storageLocationController,
            ),
            AppSegmentedControl<ArticleStatus>(
              label: 'Status',
              options: ArticleStatus.values,
              labelBuilder: (status) => status.label,
              value: _status,
              onChanged: (status) => setState(() => _status = status),
            ),
            AppToggleCard(
              title: 'Für Kunden sichtbar',
              description: 'Erscheint auf der Kunden-Website',
              value: _visibleForCustomers,
              onChanged: (value) =>
                  setState(() => _visibleForCustomers = value),
            ),
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
