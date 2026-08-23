import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:bikedrop/design_system/design_system.dart';
import 'package:bikedrop/providers/article_repository_provider.dart';

class OverviewScreen extends ConsumerStatefulWidget {
  const OverviewScreen({super.key});

  @override
  ConsumerState<OverviewScreen> createState() => _OverviewScreenState();
}

class _OverviewScreenState extends ConsumerState<OverviewScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final articlesAsync = ref.watch(filterArticleByName(_searchQuery));

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
                  controller: _searchController,
                  placeholder: 'Artikel suchen...',
                  onChanged: (value) {
                    setState(() => _searchQuery = value);
                  },
                  onClear: () {
                    setState(() => _searchQuery = '');
                  },
                ),
              ),
              Expanded(
                child: articlesAsync.when(
                  data: (articles) {
                    if (articles.isEmpty && _searchQuery.isNotEmpty) {
                      return Center(
                        child: Text(
                          'Keine Artikel gefunden für „$_searchQuery“.',
                          textAlign: TextAlign.center,
                          style: AppTypography.body.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      );
                    }

                    return articles.isNotEmpty
                        ? ListView.separated(
                          itemCount: articles.length,
                          separatorBuilder:
                              (context, index) => Padding(
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
                            final article = articles[index];
                            return ItemListTile(
                              title: article.name,
                              quantity: article.quantity,
                              category: article.category,
                              status: article.status,
                              reorderedQuantity: article.reorderedQuantity,
                              isPublic: article.isPublic,
                              image:
                                  article.imageUrl != null
                                      ? NetworkImage(article.imageUrl!)
                                      : null,
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
                  loading:
                      () => const Center(child: CircularProgressIndicator()),
                  error:
                      (error, stackTrace) => Center(
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
                        // Handle get started action
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
