import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/article.dart';
import '../models/receivingcartitem.dart';
import 'article_repository_provider.dart';
import 'catalog_repository_provider.dart';

/// Injektionspunkt fuer den Zufall — im Produktivbetrieb ein echter
/// [Random], in Tests durch einen deterministischen Stellvertreter ersetzbar.
final receivingCartRandomProvider = Provider<Random>((ref) => Random());

/// Haelt den Wareneingangs-Warenkorb fuer die Dauer eines Scanner-Screen-
/// Aufrufs. `autoDispose`, damit jeder neue Aufruf von "Wareneingang" leer
/// beginnt, sobald niemand mehr zuhoert (Screen geschlossen).
class ReceivingCartNotifier extends AutoDisposeNotifier<List<ReceivingCartItem>> {
  late final Random _random;

  @override
  List<ReceivingCartItem> build() {
    _random = ref.read(receivingCartRandomProvider);
    return [];
  }

  /// Zieht zufaellig einen Katalogartikel. Existiert bereits eine Zeile mit
  /// derselben Katalog-EAN, wird deren Menge erhoeht statt einer neuen Zeile.
  Future<void> addFromCatalog() async {
    final catalogArticles = await ref.read(catalogRepositoryProvider).getCatalogArticles();
    if (catalogArticles.isEmpty) return;

    final picked = catalogArticles[_random.nextInt(catalogArticles.length)];
    final index = state.indexWhere((item) => item.catalogData?.ean == picked.ean);
    if (index == -1) {
      state = [...state, ReceivingCartItem(ean: picked.ean, quantity: 1, catalogData: picked)];
    } else {
      _incrementAt(index, 1);
    }
  }

  /// Zieht zufaellig einen eigenen Artikel mit EAN (nur scannbare Artikel
  /// kommen infrage). Existiert bereits eine Zeile mit demselben Artikel,
  /// wird deren Menge um [Article.packSize] erhoeht statt einer neuen Zeile.
  Future<void> addFromOwnArticles() async {
    final articles = (await ref.read(articleRepositoryProvider).getArticles())
        .where((a) => a.ean != null)
        .toList();
    if (articles.isEmpty) return;

    final picked = articles[_random.nextInt(articles.length)];
    final index = state.indexWhere((item) => item.resolvedArticle?.id == picked.id);
    if (index == -1) {
      state = [
        ...state,
        ReceivingCartItem(ean: picked.ean!, quantity: picked.packSize, resolvedArticle: picked),
      ];
    } else {
      _incrementAt(index, picked.packSize);
    }
  }

  /// Fuegt immer eine neue Zeile an — unbekannte Zeilen haben keine
  /// Identitaet, ueber die man sinnvoll zusammenfuehren koennte, auch wenn
  /// mehrere Zeilen zufaellig dieselbe (Demo-)EAN tragen.
  void addUnknown(String ean) {
    state = [...state, ReceivingCartItem(ean: ean, quantity: 1)];
  }

  void updateQuantity(ReceivingCartItem item, int quantity) {
    state = [
      for (final current in state)
        identical(current, item) ? current.copyWith(quantity: quantity) : current,
    ];
  }

  /// Ersetzt genau diese eine Zeile (per Objekt-Referenz identifiziert,
  /// nicht per EAN — mehrere "Unbekannt"-Zeilen koennen dieselbe EAN
  /// tragen) mit einem aufgeloesten Artikel.
  void resolveUnknown(ReceivingCartItem item, Article resolvedArticle) {
    state = [
      for (final current in state)
        identical(current, item)
            ? current.copyWith(
                ean: resolvedArticle.ean ?? current.ean,
                resolvedArticle: resolvedArticle,
              )
            : current,
    ];
  }

  void _incrementAt(int index, int amount) {
    final existing = state[index];
    state = [
      for (var i = 0; i < state.length; i++)
        if (i == index) existing.copyWith(quantity: existing.quantity + amount) else state[i],
    ];
  }
}

final receivingCartProvider =
    NotifierProvider.autoDispose<ReceivingCartNotifier, List<ReceivingCartItem>>(
  ReceivingCartNotifier.new,
);
