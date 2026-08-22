import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../interface/article_interface.dart';
import '../models/article.dart';
import '../repository/mockarticle_repository.dart';

final articleRepositoryProvider = Provider<ArticleRepository>((ref) {
  return MockArticleRepository();
});

final articleListProvider = FutureProvider<List<Article>>((ref) {
  final repository = ref.watch(articleRepositoryProvider);
  return repository.getArticles();
});
