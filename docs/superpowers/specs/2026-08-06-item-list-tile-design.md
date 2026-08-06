# ItemListTile (Design-System-Molekül) — Design

**Datum:** 2026-08-06
**Status:** Genehmigt

## Kontext & Ziel

`lib/design_system/molecules/item_list_tile.dart` existiert bereits als leere Platzhalter-Datei
(siehe `docs/superpowers/specs/2026-07-29-flutter-design-system-design.md`, Abschnitt "Migration
bestehender Dateien") und wird hier erstmals mit Inhalt gefüllt. Ziel ist eine wiederverwendbare
Karte für eine einzelne Bestandsposition (Artikel-Zeile), wie sie später in der
Bestandsübersicht/Liste verwendet wird — reines Presentational-Widget, keine Datenanbindung.

Die Tokens `AppSpacing.photoTileRadius`, `AppSpacing.listRowPaddingV` und `AppSpacing.listRowGap`
sind laut Design-System-Spec bereits für genau diesen Zweck reserviert, bisher aber ungenutzt.
`AppTypography.listNumber` ist ebenfalls schon vorhanden und passt namentlich zur Mengenanzeige.

Referenz-Screenshot: weiße Karte mit Rahmen, links quadratisches Bild-Platzhalter-Icon, mittig
Titel (2-zeilig) + Kategorie-Badge + relativer Zeitstempel, rechts Menge + Augen-Icon.

## Öffentliche API

```dart
class ItemListTile extends StatelessWidget {
  const ItemListTile({
    required this.title,
    required this.quantity,
    required this.category,
    required this.timestampLabel,
    this.image,
    this.onTap,
    super.key,
  });

  final String title;
  final int quantity;
  final Category category;      // bestehendes Enum aus app_colors.dart
  final String timestampLabel;  // fertig formatiert, z. B. "vor 4 Min"
  final ImageProvider? image;   // null → Platzhalter-Icon
  final VoidCallback? onTap;    // null → Karte nicht tippbar
}
```

Keine Zeitlogik/Formatierung im Widget: `timestampLabel` kommt bereits fertig formatiert vom
Aufrufer (Screen/ViewModel), damit das Molekül reine Presentational-Komponente ohne
Lokalisierungs-/Zeitzonen-Logik bleibt.

Kein eigener Parameter für das Augen-Icon: es ist laut Klärung immer sichtbar und fester
Bestandteil der Karte (kein Status-Flag in v1, YAGNI — kann bei Bedarf später als optionaler
Parameter ergänzt werden).

## Layout & Aufbau

Äußere Struktur: `Container` mit weißem Hintergrund, `AppColors.border`-Rahmen (1px),
`BorderRadius.circular(AppSpacing.cardRadius)`, Innenabstand
`EdgeInsets.symmetric(horizontal: AppSpacing.screenPaddingH, vertical: AppSpacing.listRowPaddingV)`.
Ist `onTap` gesetzt, wird die Karte über `InkWell` (gleicher `borderRadius`) tippbar gemacht;
ansonsten reines `Container`-Layout ohne Tap-Feedback.

Innen ein `Row`-Layout mit drei Abschnitten, getrennt durch `SizedBox(width: AppSpacing.listRowGap)`:

1. **Thumbnail** (fix, quadratisch): `ClipRRect` mit `BorderRadius.circular(AppSpacing.photoTileRadius)`
   um einen `Container` mit `AppColors.surface`-Hintergrund. Ist `image` gesetzt, wird
   `Image(image: image, fit: BoxFit.cover)` gerendert, sonst ein zentriertes Platzhalter-Icon
   (`Symbols.image`, Farbe `AppColors.textQuaternaryLight`).
2. **Mitte** (`Expanded`): `Column`, linksbündig.
   - Titel: `Text(title, maxLines: 2, overflow: TextOverflow.ellipsis)`, Style
     `AppTypography.body.copyWith(fontWeight: FontWeight.w700, fontSize: 15, color: AppColors.textPrimary)`.
   - Darunter (kleiner vertikaler Abstand): `Row` mit vorhandenem `CategoryBadge(category: category)`,
     Abstand, dann `Text(timestampLabel, style: AppTypography.body.copyWith(fontSize: 12, color: AppColors.textTertiary))`.
3. **Rechts** (fix): `Column`, rechtsbündig.
   - Menge: `Text('$quantity', style: AppTypography.listNumber.copyWith(color: AppColors.textPrimary))`.
   - Darunter: `Icon(Symbols.visibility, size: AppSpacing.iconButtonSize, color: AppColors.accent)`,
     immer sichtbar.

Es werden ausschließlich bestehende Design-System-Tokens/Widgets verwendet
(`AppColors`, `AppSpacing`, `AppTypography`, `CategoryBadge`) — keine neuen globalen Typo-Tokens,
Titel/Zeitstempel-Größen werden lokal per `copyWith` von `AppTypography.body` abgeleitet
(gleiches Muster wie bereits in `overview_screen.dart`).

## Widgetbook

Neue Use-Case-Datei `widgetbook/lib/use_cases/molecules/item_list_tile.dart`, analog zu
`list_column_header.dart`: `@widgetbook.UseCase(name: 'Default', type: ItemListTile)`, Knobs für
`title`, `quantity`, `category` (Dropdown über `Category`-Werte) und `timestampLabel`. Kein Knob
für `image` (Bild-Picker im Widgetbook nicht sinnvoll) — Use-Case zeigt den Icon-Platzhalter-Fall.
`main.directories.g.dart` wird per `build_runner build` in `widgetbook/` neu generiert, kein
manueller Eingriff nötig.

## Export

Neuer Export-Eintrag in `lib/design_system/design_system.dart`:
`export 'molecules/item_list_tile.dart';`.

## Testing

Ein Widget-Test unter `test/design_system/molecules/item_list_tile_test.dart`, analog zum
Muster in `test/design_system/atoms/app_primary_button_test.dart`:

- Titel, Menge und Zeitstempel werden gerendert.
- Ohne `image` wird das Platzhalter-Icon angezeigt.
- `onTap` wird bei Tap auf die Karte aufgerufen, wenn gesetzt.
- Ohne `onTap` ist kein `InkWell`/Tap-Verhalten vorhanden.

## Out of Scope

- Datenmodell für Bestandspositionen (gibt es aktuell nicht im Projekt) — Aufrufer übergeben
  vorerst einzelne Primitive.
- Relative-Zeit-Formatierung ("vor 4 Min") — Aufgabe des Aufrufers, nicht dieses Widgets.
- Status-Flag/Sichtbarkeitssteuerung für das Augen-Icon — laut Klärung in v1 immer sichtbar.
- Einbindung in `overview_screen.dart` oder eine echte Listenansicht — folgt in einem separaten
  Schritt, sobald die Bestandsliste selbst gebaut wird.
