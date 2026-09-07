import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:bikedrop/core/article_image.dart';
import 'package:bikedrop/design_system/design_system.dart';
import 'package:bikedrop/features/article_form_screen.dart';
import 'package:bikedrop/models/article.dart';
import 'package:bikedrop/providers/article_repository_provider.dart';
import 'package:bikedrop/providers/catalog_repository_provider.dart';

import '../models/demoscanoption.dart';
import 'scanner_screen.dart';

Future<void> _editQuantity(
  BuildContext context,
  WidgetRef ref,
  Article article,
) async {
  final location = article.storageLocation;
  final subtitle = location != null
      ? '$location · aktuell ${article.quantity} Stk.'
      : 'aktuell ${article.quantity} Stk.';

  final newQuantity = await QuantityEditSheet.show(
    context,
    title: article.name,
    subtitle: subtitle,
    initialQuantity: article.quantity,
    max: article.maxQuantity,
  );

  if (newQuantity == null || newQuantity == article.quantity) return;

  await ref
      .read(articleRepositoryProvider)
      .changeQuantity(article.id, newQuantity);
  ref.invalidate(filterArticleByName(ref.read(searchQueryProvider)));
}

/// Zaehlt die Artikel je Status. Gezaehlt wird immer das Suchergebnis, nicht
/// die schon status-gefilterte Liste — sonst waeren zwei der drei Zahlen 0,
/// sobald ein Filter aktiv ist.
Map<ArticleStatus, int> _countByStatus(List<Article> articles) {
  return {
    for (final status in ArticleStatus.values)
      status: articles.where((a) => a.status == status).length,
  };
}

/// Text fuer die leere Liste — je nachdem, ob Suche, Status-Filter oder
/// beides zusammen nichts gefunden haben.
String _noResultsMessage(String searchQuery, ArticleStatus? status) {
  if (status != null && searchQuery.isNotEmpty) {
    return 'Keine Artikel mit Status „${status.label}“ für „$searchQuery“.';
  }
  if (status != null) {
    return 'Keine Artikel mit Status „${status.label}“.';
  }
  return 'Keine Artikel gefunden für „$searchQuery“.';
}

void _openArticleForm(BuildContext context, Article article) {
  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (context) => ArticleFormScreen(article: article),
    ),
  );
}

class OverviewScreen extends ConsumerWidget {
  const OverviewScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchQuery = ref.watch(searchQueryProvider);
    final searchController = ref.watch(searchControllerProvider);
    final statusFilter = ref.watch(statusFilterProvider);
    final articlesAsync = ref.watch(filterArticleByName(searchQuery));

    return Scaffold(
      appBar: AppBar(title: Text('Bestand', style: AppTypography.screenTitle)),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.screenPaddingH,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.only(
                  top: AppSpacing.screenSpacingV,
                  bottom: AppSpacing.screenSpacingV,
                ),
                child: AppSearchBar(
                  controller: searchController,
                  placeholder: 'Artikel suchen...',
                  onChanged: (value) {
                    ref.read(searchQueryProvider.notifier).state = value;
                  },
                  onClear: () {
                    ref.read(searchQueryProvider.notifier).state = '';
                  },
                ),
              ),
              // Die Kacheln zaehlen immer das Suchergebnis, nicht die schon
              // status-gefilterte Liste — sonst waeren zwei der drei Zahlen
              // 0, sobald ein Filter aktiv ist.
              if (articlesAsync.valueOrNull?.isNotEmpty ?? false) ...[
                KpiFilterRow(
                  counts: _countByStatus(articlesAsync.requireValue),
                  selected: statusFilter,
                  onStatusTap: (status) =>
                      ref.read(statusFilterProvider.notifier).state =
                          statusFilter == status ? null : status,
                ),
                const SizedBox(height: AppSpacing.screenSpacingV),
              ],
              Expanded(
                child: articlesAsync.when(
                  data: (articles) {
                    final visible = statusFilter == null
                        ? articles
                        : articles
                              .where((a) => a.status == statusFilter)
                              .toList();

                    if (visible.isEmpty &&
                        (searchQuery.isNotEmpty || statusFilter != null)) {
                      return Center(
                        child: Text(
                          _noResultsMessage(searchQuery, statusFilter),
                          textAlign: TextAlign.center,
                          style: AppTypography.body.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      );
                    }

                    return visible.isNotEmpty
                        ? ListView.separated(
                            itemCount: visible.length,
                            separatorBuilder: (context, index) => Padding(
                              padding: EdgeInsets.only(
                                left:
                                    AppSpacing.screenPaddingH +
                                    AppSpacing.listThumbnailSize +
                                    AppSpacing.listRowGap,
                              ),
                              child: const Divider(
                                height: 1,
                                thickness: 1,
                                color: AppColors.listDivider,
                              ),
                            ),
                            itemBuilder: (context, index) {
                              final article = visible[index];
                              return ItemListTile(
                                title: article.name,
                                quantity: article.quantity,
                                category: article.category,
                                status: article.status,
                                reorderedQuantity: article.reorderedQuantity,
                                isPublic: article.isPublic,
                                onTap: () => _openArticleForm(context, article),
                                onQuantityTap: () =>
                                    _editQuantity(context, ref, article),
                                image: articleImageProvider(article.imageUrl),
                              );
                            },
                          )
                        : Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,

                              children: [
                                DottedBorder(
                                  options: RoundedRectDottedBorderOptions(
                                    radius: const Radius.circular(12),
                                    color: AppColors.border,
                                    dashPattern: [10, 5],
                                    strokeWidth: 2,
                                    padding: EdgeInsets.all(16),
                                  ),
                                  child: Icon(
                                    Symbols.package_2,
                                    size: AppSpacing.iconSizeLarge,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                const SizedBox(height: 24),
                                Text(
                                  'Noch kein Bestand erfasst',
                                  style: AppTypography.heading.copyWith(
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  'Fügen Sie jetzt Ihren ersten Artikel hinzu, um den Überblick zu behalten.',
                                  textAlign: TextAlign.center,
                                  style: AppTypography.body.copyWith(
                                    color: AppColors.textSecondary,
                                    fontSize: 17,
                                  ),
                                ),
                              ],
                            ),
                          );
                  },
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (error, stackTrace) => Center(
                    child: Text(
                      'Fehler beim Laden der Artikel: $error',
                      style: AppTypography.body.copyWith(
                        color: AppColors.textError,
                      ),
                    ),
                  ),
                ),
              ),
              Row(
                children: [
                  Expanded(
                    child: AppPrimaryButton(
                      label: 'Wareneingang',
                      onPressed: () {
                        // Handle get started action
                      },
                    ),
                  ),
                  const SizedBox(width: AppSpacing.screenSpacingH),
                  Expanded(
                    child: AppSecondaryButton(
                      label: 'Artikel anlegen',
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => ScannerScreen(
                              title: 'Artikel anlegen',
                              demoOptions: [
                                DemoScanOption(
                                  ean: '4029876501233',
                                  label: 'Katalogartikel simulieren',
                                  subtitle:
                                      'EAN 4029876501233 · Abus Bordo 6000 Faltschloss 90cm',
                                  icon: Symbols.qr_code,
                                ),
                                DemoScanOption(
                                  ean: '4711234567899',
                                  label: 'Eigenen Artikel simulieren',
                                  subtitle:
                                      'EAN 4711234567899 · Eigenes Produkt · KMC Kette X11',
                                  icon: Symbols.qr_code,
                                ),
                                DemoScanOption(
                                  ean: '978020137962',
                                  label: 'Unbekannten Artikel simulieren',
                                  subtitle:
                                      'EAN 978020137962 · Unbekanntes Produkt',
                                  icon: Symbols.question_mark_rounded,
                                ),
                                DemoScanOption(
                                  ean: '4029876501234',
                                  label: 'Ungültigen Barcode simulieren',
                                  subtitle:
                                      'EAN 4029876501234 · falsche Prüfziffer',
                                  icon: Symbols.error_rounded,
                                ),
                              ],
                              onEanScanned:
                                  (
                                    BuildContext context,
                                    WidgetRef ref,
                                    String ean,
                                  ) async {
                                    // Erst das Lager: kennt es die EAN, wird
                                    // der bestehende Artikel bearbeitet.
                                    final article = await ref.read(
                                      filterArticleByEan(ean).future,
                                    );
                                    // Sonst der Katalog: dessen Stammdaten
                                    // befuellen einen NEUEN Artikel vor.
                                    final catalogArticle = article != null
                                        ? null
                                        : await ref.read(
                                            catalogArticleByEan(ean).future,
                                          );

                                    if (!context.mounted) return;

                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (context) => ArticleFormScreen(
                                          article: article,
                                          catalogArticle: catalogArticle,
                                          // Kennt keiner von beiden die EAN,
                                          // bleibt sie als einzige Vorgabe.
                                          scannedEan: ean,
                                        ),
                                      ),
                                    );
                                  },
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
