enum ArticleStatus { inStock, fehlt, bestellt }

extension ArticleStatusLabel on ArticleStatus {
  String get label => switch (this) {
    ArticleStatus.inStock => 'Im Shop',
    ArticleStatus.bestellt => 'Bestellt',
    ArticleStatus.fehlt => 'Fehlt',
  };
}
