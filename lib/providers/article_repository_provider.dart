import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../interface/article_interface.dart';
import '../models/article.dart';
import '../repository/mockarticle_repository.dart';

final articleRepositoryProvider = Provider<ArticleRepository>((ref) {
  return MockArticleRepository();
});

/// Aktueller Suchtext der Such-Leiste auf dem Bestand-Screen.
final searchQueryProvider = StateProvider<String>((ref) => '');

/// Vom Bestand-Screen verwendeter TextEditingController, damit der Screen
/// selbst als ConsumerWidget ohne eigenen State auskommt. Wird automatisch
/// disposed, sobald niemand mehr auf ihn watcht (z. B. beim Verlassen
/// des Screens).
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
