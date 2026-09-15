import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/ean.dart';
import '../enums/article_status.dart';
import '../enums/category.dart';
import '../models/article.dart';
import 'article_repository_provider.dart';

/// Alle Rohwerte, die [ArticleFormNotifier.save] aus dem Formular braucht.
/// Reine Daten — keine Validierung, die passiert vorher im Screen ueber
/// `_canSave` (Button-Freischaltung, lebt bewusst weiter im Widget, da sie
/// bei jedem Tastendruck synchron neu berechnet wird).
class ArticleFormSaveRequest {
  const ArticleFormSaveRequest({
    required this.existing,
    required this.rawEan,
    required this.name,
    required this.category,
    required this.supplier,
    required this.quantity,
    required this.minQuantity,
    required this.maxQuantity,
    required this.purchasePriceText,
    required this.sellingPriceText,
    required this.storageLocation,
    required this.status,
    required this.isPublic,
    required this.imageUrl,
  });

  /// Gesetzt = Update eines bestehenden Artikels, null = Neuanlage.
  final Article? existing;
  final String rawEan;
  final String name;
  final Category category;
  final String? supplier;
  final int quantity;
  final int minQuantity;
  final int? maxQuantity;
  final String purchasePriceText;
  final String sellingPriceText;
  final String storageLocation;
  final ArticleStatus status;
  final bool isPublic;
  final String? imageUrl;
}

/// Haelt Lade-/Fehler-/Erfolgs-Zustand des Artikel-Formulars. `null` (in
/// [AsyncData]) heisst "noch nicht gespeichert" — der Screen reagiert per
/// `ref.listen` auf den Wechsel zu einem nicht-null Artikel (Erfolg) bzw.
/// auf [AsyncError] (Fehler), statt selbst zu warten/try-catchen.
class ArticleFormNotifier extends AutoDisposeAsyncNotifier<Article?> {
  @override
  FutureOr<Article?> build() => null;

  Future<void> save(ArticleFormSaveRequest request) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final now = DateTime.now();
      // Damit ein getippter UPC-A genauso 13-stellig im Bestand landet wie
      // derselbe Code ueber den Scanner.
      final ean = normalizeScannedEan(request.rawEan) ?? request.rawEan;
      final existing = request.existing;

      final article =
          (existing ??
                  Article(
                    name: '',
                    category: request.category,
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
                name: request.name,
                category: request.category,
                supplier: request.supplier,
                quantity: request.quantity,
                minQuantity: request.minQuantity,
                maxQuantity: request.maxQuantity,
                purchasePrice: double.tryParse(request.purchasePriceText) ?? 0,
                sellingPrice: double.tryParse(request.sellingPriceText) ?? 0,
                storageLocation: request.storageLocation.isEmpty
                    ? null
                    : request.storageLocation,
                status: request.status,
                isPublic: request.isPublic,
                imageUrl: request.imageUrl,
                updatedAt: now,
              );

      final repository = ref.read(articleRepositoryProvider);
      final saved = existing != null
          ? await repository.updateArticle(article)
          : await repository.createArticle(article);

      ref.invalidate(filterArticleByName(ref.read(searchQueryProvider)));
      return saved;
    });
  }
}

final articleFormProvider =
    AutoDisposeAsyncNotifierProvider<ArticleFormNotifier, Article?>(
      ArticleFormNotifier.new,
    );
