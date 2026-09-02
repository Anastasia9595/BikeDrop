import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../interface/article_interface.dart';
import '../enums/article_status.dart';
import '../models/article.dart';
import '../repository/mockarticle_repository.dart';

final articleRepositoryProvider = Provider<ArticleRepository>((ref) {
  return MockArticleRepository();
});

final searchQueryProvider = StateProvider<String>((ref) => '');

/// Aktiver Status-Filter der Bestandsliste, gesetzt ueber die KpiFilterCards.
/// `null` heisst: kein Status-Filter, alle Artikel sind sichtbar.
final statusFilterProvider = StateProvider<ArticleStatus?>((ref) => null);

final searchControllerProvider = Provider.autoDispose<TextEditingController>((
  ref,
) {
  final controller = TextEditingController();
  ref.onDispose(controller.dispose);
  return controller;
});

final articleListProvider = FutureProvider<List<Article>>((ref) {
  final repository = ref.watch(articleRepositoryProvider);
  return repository.getArticles();
});

final filterArticleByName = FutureProvider.family<List<Article>, String>((
  ref,
  name,
) async {
  final repository = ref.watch(articleRepositoryProvider);
  return repository.searchArticlesByName(name);
});

final filterArticleByEan = FutureProvider.family<Article?, String>((
  ref,
  ean,
) async {
  final repository = ref.watch(articleRepositoryProvider);
  return repository.getArticleByEan(ean);
});

final getSuppliers = FutureProvider<List<String?>>((ref) async {
  final repository = ref.watch(articleRepositoryProvider);
  return repository.getSuppliers();
});
