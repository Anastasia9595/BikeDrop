# Wareneingang: Warenkorb-Bottom-Sheet im Scanner

## Ziel

Im Wareneingang-Scanner-Screen (`ScannerScreen` mit `layout: DemoOptionsLayout.grid`) soll nach dem Tippen auf einen der drei Demo-Szenario-Buttons (Katalogartikel / Eigener Artikel / Unbekannt) ein Bottom Sheet mit der Liste der bisher "gescannten" Artikel erscheinen — analog zu einem Warenkorb. Jeder Tap zieht per Zufall einen Artikel aus dem passenden Datentopf (Katalog-JSON, eigene Artikel-JSON, oder einen unbekannten Platzhalter) und fügt ihn der Liste hinzu bzw. erhöht die Menge eines bereits vorhandenen Eintrags.

Referenz für Layout/Optik: vom Nutzer bereitgestellter Screenshot (Dark-Theme-Vorlage aus einer anderen App) — hier im Light-Theme des bestehenden Design-Systems umzusetzen.

## Scope

**Nur UI/Interaktion in diesem Schritt.** "Wareneingang abschließen" schließt den Scanner-Screen, schreibt aber noch nichts in `ArticleRepository`. Eine echte Bestandsübernahme ist ein späterer Schritt.

## Datenmodell & Status

- `ReceivingCartItem` (bereits vorhanden in `lib/models/receivingcartitem.dart`, bisher ungenutzt) wird unverändert als Zeilenmodell verwendet: `resolvedArticle` gesetzt → Artikel ist im eigenen Bestand; nur `catalogData` gesetzt → Katalogtreffer; beide `null` → unbekannt.
- Neues Enum `ReceivingScanStatus { inStock, catalogMatch, unknown }` in `lib/enums/receiving_scan_status.dart`, Label-Extension analog zu `ArticleStatus` ("Im Bestand", "Katalogtreffer", "Unbekannt"). Wird per Extension-Getter aus einem `ReceivingCartItem` abgeleitet (`resolvedArticle != null` → `inStock`, sonst `catalogData != null` → `catalogMatch`, sonst `unknown`), nicht zusätzlich gespeichert.
- `CatalogRepository` (Interface `lib/interface/catalog_interface.dart`, Implementierung `MockCatalogRepository`) bekommt eine neue Methode `Future<List<CatalogArticle>> getCatalogArticles()`, analog zu `ArticleRepository.getArticles()`, um daraus zufällig wählen zu können.

## State-Management

Neuer Provider `lib/providers/receiving_cart_provider.dart`:

```dart
final receivingCartProvider =
    NotifierProvider.autoDispose<ReceivingCartNotifier, List<ReceivingCartItem>>(
        ReceivingCartNotifier.new);
```

`ReceivingCartNotifier` (State = `List<ReceivingCartItem>`, startet leer):

- `addFromCatalog()`: lädt `getCatalogArticles()`, wählt per `Random` zufällig einen Eintrag. Existiert bereits eine Zeile mit gleicher `catalogData.ean` → deren Menge wird um 1 erhöht. Sonst neue Zeile mit Menge 1.
- `addFromOwnArticles()`: lädt `getArticles()`, filtert auf `ean != null` (nur scannbare Artikel), wählt zufällig einen. Existiert bereits eine Zeile mit gleicher `resolvedArticle.id` → Menge wird um `article.packSize` erhöht. Sonst neue Zeile mit Menge `article.packSize`.
- `addUnknown(String ean)`: fügt **immer** eine neue Zeile an (`ReceivingCartItem(ean: ean, quantity: 1)`), kein Merge — unbekannte Zeilen haben keine Identität, über die man sinnvoll zusammenführen könnte, auch wenn mehrere Zeilen zufällig dieselbe (feste Demo-)EAN tragen.
- `updateQuantity(ReceivingCartItem item, int quantity)`: für den `+`/`-`-Stepper einer Zeile im Sheet.
- `resolveUnknown(ReceivingCartItem item, Article resolvedArticle)`: ersetzt genau diese eine Zeile (Identifikation über Objekt-Referenz mit `identical()`, nicht über `ean` — wichtig, weil mehrere "Unbekannt"-Zeilen dieselbe Demo-EAN teilen können) durch eine Kopie mit gesetztem `resolvedArticle`.

`autoDispose` sorgt dafür, dass der Warenkorb bei jedem neuen Aufruf von "Wareneingang" leer startet, sobald der vorherige Scanner-Screen keine Zuhörer mehr hat (Screen geschlossen) — kein zusätzlicher Reset-Code nötig.

Zufälligkeit über ein injizierbares `Random` (Default `Random()`, im Test ein seed-fester `Random(seed)`), damit die Merge-/Zufallslogik deterministisch testbar ist.

## Komponenten

### Angepasst (generalisiert)

- **`KpiFilterCard`** (`lib/design_system/atoms/kpi_filter_card.dart`): Parameter `status: ArticleStatus` wird durch generische Parameter ersetzt: `label: String`, `color: Color`, `tint: Color`, dazu weiterhin `value: int`, `selected`, `onTap`. Visuelles Verhalten (Rahmen/Hintergrund/Textfarbe je nach `selected`) bleibt exakt gleich.
- **`KpiFilterRow`** (`lib/design_system/organisms/kpi_filter_row.dart`): wird generisch über eine neue kleine Wertklasse `KpiFilterEntry` (`key` als `Object`, `label`, `color`, `tint`, `count`) statt fest an `ArticleStatus`/`AppColors.statusColors` gebunden. Parameter: `entries: List<KpiFilterEntry>`, `selectedKey: Object?`, `onEntryTap: ValueChanged<Object>?`.
- **`OverviewScreen`**: baut seine 3 Einträge für `KpiFilterRow` weiterhin aus `ArticleStatus` + `AppColors.statusColors`/`statusColorTints` selbst zusammen (kleine lokale Anpassung, keine Verhaltensänderung).
- **`ScannerScreen`** (`lib/features/scanner_screen.dart`): neuer optionaler Parameter `overlay` (`Widget?`, Default `null`). Im `build()` wird der bisherige `body` in einen `Stack` gepackt: bestehender Inhalt (`FakeCameraView`/`ScannerFrame`) plus, falls gesetzt, `overlay` am Stack-Ende. `ScannerScreen` bleibt dadurch weiterhin generisch und kennt den Warenkorb nicht namentlich.

### Wiederverwendet, unverändert

- `QuantityStepper` (`showBorder: true, showLabel: false`) für den `- N +`-Steller pro Zeile.
- `AppPrimaryButton` für "Wareneingang abschließen (N Artikel)".
- Bestehende `AppSpacing`/`AppColors`/`AppTypography`-Tokens, u.a. dieselben Statusfarben, die schon die Demo-Buttons verwenden (`AppColors.statusColorSuccess`, `AppColors.infoBlue`, `AppColors.statusColorWarning`), für visuelle Konsistenz zwischen Szenario-Button und Zeilen-Icon.

### Neu

- **Molekül `ReceivingCartItemTile`** (`lib/design_system/molecules/receiving_cart_item_tile.dart`): farbiger Icon-Kreis (Check/Katalog-Icon/Fragezeichen je `ReceivingScanStatus`) + Artikelname + EAN als Untertitel + rechts entweder `QuantityStepper` (Status `inStock`/`catalogMatch`) oder ein kompakter "+ Anlegen"-Button (Status `unknown`). `ItemListTile` passt hier nicht: es hat Kategorie-Badge, Thumbnail und `QuantityDisplay` fest verdrahtet und kennt weder EAN-Untertitel noch den Icon-Kreis.
- **Organismus `ReceivingCartSheet`** (`lib/design_system/organisms/receiving_cart_sheet.dart`): `ConsumerWidget`, beobachtet `receivingCartProvider`. Liste leer → `SizedBox.shrink()` (Sheet unsichtbar bis zum ersten Scan). Sonst `DraggableScrollableSheet` (`minChildSize: 0.18`, `initialChildSize: 0.18`, `maxChildSize: 0.85`, `snap: true`) mit: Drag-Handle, Kopfzeile ("5 Positionen · 23 Stk · 1 offen", aus der Liste berechnet), `KpiFilterRow` mit den 3 `ReceivingScanStatus`-Einträgen, gefiltertem `ListView` aus `ReceivingCartItemTile`, unten fixiertem `AppPrimaryButton`.
- **Enum `ReceivingScanStatus`** (siehe Datenmodell-Abschnitt).

### Widgetbook

Neue Use-Cases unter `widgetbook/lib/use_cases/molecules/receiving_cart_item_tile.dart` und `widgetbook/lib/use_cases/organisms/receiving_cart_sheet.dart`, nach dem bestehenden Muster (Knobs für Status/Menge, `Builder`+`Scaffold` für den Sheet-Trigger).

## Verdrahtung in `overview_screen.dart`

- Im "Wareneingang"-Aufruf: `ScannerScreen(..., overlay: const ReceivingCartSheet())`.
- `onEanScanned` verzweigt anhand der (weiterhin festen Demo-)EAN auf die passende Notifier-Methode:
  - `4029876501233` (Katalogartikel) → `receivingCartProvider.notifier.addFromCatalog()`
  - `4711234567899` (Eigener Artikel) → `.addFromOwnArticles()`
  - `978020137962` (Unbekannt) → `.addUnknown(ean)`
- "+ Anlegen" in `ReceivingCartItemTile` (nur bei `unknown`): `Navigator.push(ArticleFormScreen(scannedEan: item.ean))`, nach Rückkehr `getArticleByEan(item.ean)` erneut abfragen; bei Treffer `resolveUnknown(item, article)`. Keine Änderung an `ArticleFormScreen` nötig — `scannedEan` und das Speichern über `createArticle` existieren bereits.
- "Wareneingang abschließen": `Navigator.of(context).pop()`, keine Repository-Schreibvorgänge (siehe Scope).

## Interaktion/Ablauf

1. Erster Tap auf einen der drei Szenario-Buttons löst den bestehenden 900ms-Fake-Scan aus, danach die passende Notifier-Methode. Das Sheet erscheint erstmals im Peek-Zustand (ca. 1–2 Zeilen sichtbar). Die bestehende `enabled = activeEan == null`-Sperre der Buttons (nur während der 900ms-Scan-Animation selbst) bleibt unverändert — sie hat mit der Sheet-Sichtbarkeit nichts zu tun, danach sind die Buttons automatisch wieder für weitere Scans nutzbar.
2. Weitere Taps fügen weitere Zeilen hinzu bzw. erhöhen Mengen bei zufälligem Duplikat; die vom Nutzer gewählte Sheet-Höhe bleibt dabei erhalten (kein automatisches Auf-/Zuklappen bei jedem Scan).
3. Hochziehen zeigt die volle Liste inkl. Kopfzeile und Filter-Chips, wie im Referenz-Screenshot, aber im Light-Theme (weißer Sheet-Hintergrund, bestehende `AppColors`-Tokens statt der dunklen Vorlage).
4. Tap auf einen Filter-Chip filtert die Liste auf den jeweiligen `ReceivingScanStatus`; erneuter Tap hebt den Filter wieder auf (gleiches Verhalten wie `KpiFilterRow` in der Übersicht).
5. "+ Anlegen" bei einer Unbekannt-Zeile öffnet das Formular; nach dem Speichern wechselt genau diese Zeile zu "Im Bestand", sofern die EAN danach auflösbar ist.
6. "Wareneingang abschließen" schließt den Scanner-Screen und kehrt zur Übersicht zurück.

## Out of Scope

- Echte Bestandsübernahme beim Abschließen (Mengen erhöhen, neue Artikel anlegen) — folgt in einem späteren Schritt.
- Änderungen an `ArticleFormScreen` selbst (Rückgabewert o.ä.) — der bestehende `scannedEan`/`getArticleByEan`-Mechanismus reicht für den "+ Anlegen"-Flow.
- Echtes Barcode-Scanning/Kamera — unverändert Teil eines späteren Schritts (siehe bestehender `ScannerFrame`-Platzhalter).

## Tests

- `test/enums/receiving_scan_status_test.dart`: Label-Mapping.
- `test/providers/receiving_cart_provider_test.dart`: Merge-Logik (Katalog/eigene Artikel), immer-neue-Zeile bei Unbekannt, `updateQuantity`, `resolveUnknown` — mit Fake-Repositories und seed-festem `Random` für deterministische Zufallsauswahl.
- `test/design_system/atoms/kpi_filter_card_test.dart`, `test/design_system/organisms/kpi_filter_row_test.dart`: Anpassung an die generalisierte API (falls diese Tests bereits existieren).
- `test/design_system/molecules/receiving_cart_item_tile_test.dart`: Icon/Status je `ReceivingScanStatus`, Stepper- vs. Anlegen-Button-Darstellung.
- `test/design_system/organisms/receiving_cart_sheet_test.dart`: Peek-/Voll-Zustand, Filter-Interaktion, Kopfzeilen-Berechnung — Muster wie `quantity_edit_sheet_test.dart`.
- `test/features/scanner_screen_test.dart`: neuer `overlay`-Parameter wird über dem bestehenden Inhalt gerendert und bleibt interaktiv.
- `test/features/overview_screen_test.dart`: neue `onEanScanned`-Zweige für den Wareneingang-Flow, "+ Anlegen"-Re-Resolve.
