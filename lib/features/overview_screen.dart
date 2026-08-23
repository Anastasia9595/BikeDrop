import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:bikedrop/design_system/design_system.dart';
import 'package:bikedrop/features/article_form_screen.dart';
import 'package:bikedrop/models/article.dart';
import 'package:bikedrop/providers/article_repository_provider.dart';

Future<void> _editQuantity(
  BuildContext context,
  WidgetRef ref,
  Article article,
) async {
  final location = article.storageLocation;
  final subtitle =
      location != null
          ? '$location · aktuell ${article.quantity} Stk.'
          : 'aktuell ${article.quantity} Stk.';

  final newQuantity = await QuantityEditSheet.show(
    context,
    title: article.name,
    subtitle: subtitle,
    initialQuantity: article.quantity,
  );

  if (newQuantity == null || newQuantity == article.quantity) return;

  await ref
      .read(articleRepositoryProvider)
      .changeQuantity(article.id, newQuantity);
  ref.invalidate(filterArticleByName(ref.read(searchQueryProvider)));
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
              Expanded(
                child: articlesAsync.when(
                  data: (articles) {
                    if (articles.isEmpty && searchQuery.isNotEmpty) {
                      return Center(
                        child: Text(
                          'Keine Artikel gefunden für „$searchQuery“.',
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
                              onTap: () => _openArticleForm(context, article),
                              onQuantityTap:
                                  () => _editQuantity(context, ref, article),
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
