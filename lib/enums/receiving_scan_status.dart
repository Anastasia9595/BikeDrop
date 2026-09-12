import '../models/receivingcartitem.dart';

/// Auflösungsstatus einer gescannten Position im Wareneingangs-Warenkorb.
/// Anders als [ArticleStatus] (Bestandsstatus eines Artikels) beschreibt
/// dies, WOHER die Zeile ihre Daten hat, nicht ihren Lagerbestand.
enum ReceivingScanStatus { inStock, catalogMatch, unknown }

extension ReceivingScanStatusLabel on ReceivingScanStatus {
  String get label => switch (this) {
    ReceivingScanStatus.inStock => 'Im Bestand',
    ReceivingScanStatus.catalogMatch => 'Katalogtreffer',
    ReceivingScanStatus.unknown => 'Unbekannt',
  };

  bool get needsCompletion => this != ReceivingScanStatus.inStock;
}

/// Leitet den Scan-Status aus den vorhandenen Daten ab, statt ihn separat
/// zu speichern — [ReceivingCartItem.resolvedArticle]/[catalogData] bleiben
/// die einzige Quelle der Wahrheit.
extension ReceivingCartItemScanStatus on ReceivingCartItem {
  ReceivingScanStatus get scanStatus {
    if (resolvedArticle != null) return ReceivingScanStatus.inStock;
    if (catalogData != null) return ReceivingScanStatus.catalogMatch;
    return ReceivingScanStatus.unknown;
  }
}
