# Status-Auswahl & Sichtbarkeits-Karte (Design-System-Atom + Molecule) — Design

**Datum:** 2026-08-15
**Status:** Genehmigt

## Kontext & Ziel

`docs/design/artikel_anlegen_formular.png` (neu hinzugefügter Screenshot) zeigt zwei Abschnitte
unterhalb des bestehenden Formulars in [item_detail_screen.dart](../../../lib/features/item_detail_screen.dart):

1. Eine **Status-Auswahl** ("Im Shop" / "Bestellt" / "Fehlt") als Segmented Control.
2. Eine **"Für Kunden sichtbar"-Karte** mit Titel, Beschreibungstext und einem Switch.

Der Screenshot selbst ist ein Dark-Mockup, das Projekt hat aber nur ein Light-Theme
(`AppTheme.light()`). Für die Sichtbarkeits-Karte existiert bereits eine exakte Light-Theme-Vorlage
in `docs/design/Article Detail Screen.png` und `docs/design/Create new Article Screen.png`
("Für Kunden sichtbar" / "Erscheint auf der Kunden-Website"-Karte mit hellgrauem
Hintergrund) — diese wird 1:1 übernommen. Für die Status-Auswahl gibt es keine Light-Theme-Vorlage;
das Interaktionsmuster aus dem Dark-Mockup wird auf die bestehenden Tokens übersetzt (siehe unten).

Ziel: zwei neue, wiederverwendbare Design-System-Bausteine (ein Atom, ein Molecule) sowie deren
Einbindung in `ItemDetailScreen`.

## Atom: `AppSegmentedControl<T>`

`lib/design_system/atoms/app_segmented_control.dart`

```dart
class AppSegmentedControl<T> extends StatelessWidget {
  const AppSegmentedControl({
    required this.options,
    required this.labelBuilder,
    required this.value,
    required this.onChanged,
    this.label,
    super.key,
  });

  final List<T> options;
  final String Function(T) labelBuilder;
  final T value;
  final ValueChanged<T> onChanged;
  final String? label;               // optionale Caps-Feldbezeichnung wie bei AppDropdownField
}
```

Generisch statt auf `ItemStatus` zugeschnitten, analog zu `AppDropdownField<T>`: dasselbe Atom
kann künftig für andere feste, kurze Optionslisten wiederverwendet werden, ohne dass Aufrufer
zwischen Enum-Werten und Strings hin- und zurückmappen müssen. Vollständig kontrolliert —
kein eigener State im Atom.

### Layout & Aufbau

1. Falls `label` gesetzt: `Text(label!.toUpperCase(), style: AppTypography.fieldLabel)` +
   `SizedBox(height: 6)` — identisch zur Label-Zeile von `AppTextField`/`AppDropdownField`.
2. `Container` mit Höhe `AppSpacing.fieldHeight`, `BorderRadius.circular(AppSpacing.buttonRadius)`,
   `Border.all(color: AppColors.border, width: AppSpacing.fieldBorderWidth)`,
   Hintergrund `AppColors.surface`.
3. `Row` aus `Expanded`-Segmenten für jede Option in `options`. Jedes Segment ist ein
   `InkWell` (`borderRadius` passend zur Pill) um `AnimatedContainer` mit 4 px Innenabstand zum
   äußeren Rahmen, sodass das ausgewählte Segment als abgerundete Pill innerhalb des Containers
   sitzt (kein hartes Kantenaneinanderstoßen).

### Zustände & Visuals

Ausschließlich bestehende Tokens (`design_system_lint`/`avoid_hardcoded_colors`):

| Element | Ausgewählt | Nicht ausgewählt |
|---|---|---|
| Pill-Hintergrund | `AppColors.textPrimary` | transparent |
| Text | `AppColors.white` | `AppColors.textSecondary` |
| Text-Style | `AppTypography.secondaryButtonLabel` | `AppTypography.secondaryButtonLabel` |

`onChanged(option)` wird bei Tap auf ein nicht ausgewähltes Segment aufgerufen; Tap auf das
bereits ausgewählte Segment ist ein No-op (kein erneuter Callback).

## Molecule: `AppToggleCard`

`lib/design_system/molecules/app_toggle_card.dart`

```dart
class AppToggleCard extends StatelessWidget {
  const AppToggleCard({
    required this.title,
    required this.description,
    required this.value,
    required this.onChanged,
    super.key,
  });

  final String title;
  final String description;
  final bool value;
  final ValueChanged<bool> onChanged;
}
```

Bildet die Karte aus `Article Detail Screen.png` / `Create new Article Screen.png` nach:

- `Container`: Hintergrund `AppColors.surface`, `BorderRadius.circular(AppSpacing.cardRadius)`,
  Padding `EdgeInsets.symmetric(horizontal: AppSpacing.screenPaddingH, vertical: AppSpacing.screenPaddingV)`.
- `Row`: links `Expanded` → `Column` (crossAxisAlignment: start):
  - `Text(title, style: AppTypography.secondaryButtonLabel.copyWith(color: AppColors.textPrimary))`
  - `SizedBox(height: 4)`
  - `Text(description, style: AppTypography.body.copyWith(color: AppColors.textSecondary, fontSize: 13))`
  - rechts: `Switch(value: value, onChanged: onChanged)` — nutzt das bereits vorhandene
    `SwitchThemeData` aus `app_theme.dart` (Accent-Track wenn an, Border-Track wenn aus, weißer
    Thumb). Kein eigenes Switch-Atom nötig, dafür existiert das Material-Widget bereits fertig
    geskinnt.

Composition aus Text + `Switch` → Molecule, nicht Atom.

## Begleitende Änderung: `ItemStatus`-Label-Extension

Die Zuordnung `ItemStatus` → deutscher Anzeigetext ist aktuell als inline-`switch` in
`lib/design_system/molecules/item_list_tile.dart:27` versteckt. Für die Status-Auswahl wird
dieselbe Zuordnung gebraucht. Analog zu `CategoryLabel` (`lib/design_system/tokens/app_colors.dart`)
wandert sie in eine Extension neben `enum ItemStatus`:

```dart
// lib/design_system/tokens/app_colors.dart, direkt unter enum ItemStatus
extension ItemStatusLabel on ItemStatus {
  String get label => switch (this) {
    ItemStatus.imShop => 'Im Shop',
    ItemStatus.bestellt => 'Bestellt',
    ItemStatus.fehlt => 'Fehlt',
  };
}
```

`item_list_tile.dart` wird auf `status.label` umgestellt, Verhalten und Texte bleiben unverändert.

## Export

Neue Einträge in `lib/design_system/design_system.dart`:
- `export 'atoms/app_segmented_control.dart';` bei den Atom-Exports.
- `export 'molecules/app_toggle_card.dart';` bei den Molecule-Exports.

## Einbindung in `ItemDetailScreen`

`item_detail_screen.dart` wird von `StatelessWidget` zu `StatefulWidget`, da die Seite aktuell
keinerlei Eingabewerte hält (auch die bestehenden Felder sind unkontrolliert). Neuer lokaler State:

```dart
ItemStatus _status = ItemStatus.imShop;
bool _visibleForCustomers = false;
```

Nach dem bestehenden `AppTextField(label: 'Lagerort', …)` werden ergänzt:

```dart
const SizedBox(height: AppSpacing.screenSpacingV),
AppSegmentedControl<ItemStatus>(
  label: 'Status',
  options: ItemStatus.values,
  labelBuilder: (s) => s.label,
  value: _status,
  onChanged: (s) => setState(() => _status = s),
),
const SizedBox(height: AppSpacing.screenSpacingV),
AppToggleCard(
  title: 'Für Kunden sichtbar',
  description: 'Erscheint auf der Kunden-Website',
  value: _visibleForCustomers,
  onChanged: (v) => setState(() => _visibleForCustomers = v),
),
```

Default `imShop`/`false` entspricht dem Screenshot (erstes Segment aktiv, Switch aus).

## Widgetbook

Neue Use-Case-Dateien, analog zu `app_dropdown_field.dart`:

- `widgetbook/lib/use_cases/atoms/app_segmented_control.dart`:
  `AppSegmentedControl<ItemStatus>` mit `label`-Knob (String) und Auswahl per `StatefulBuilder`.
- `widgetbook/lib/use_cases/molecules/app_toggle_card.dart`:
  `AppToggleCard` mit `title`/`description`-Knobs (String) und Wert per `StatefulBuilder`.

`main.directories.g.dart` wird per `build_runner build` im Ordner `widgetbook/` neu generiert.

## Testing

- `test/design_system/atoms/app_segmented_control_test.dart`:
  - Alle Options-Labels werden gerendert.
  - Tap auf ein nicht ausgewähltes Segment ruft `onChanged` mit dem passenden Wert auf.
  - Tap auf das bereits ausgewählte Segment ruft `onChanged` **nicht** auf.
  - Mit `label` gesetzt wird die Großbuchstaben-Beschriftung gerendert; ohne `label` nicht.
- `test/design_system/molecules/app_toggle_card_test.dart`:
  - Titel und Beschreibung werden gerendert.
  - `Switch` spiegelt `value` wider.
  - Tap auf den Switch ruft `onChanged` mit dem invertierten Wert auf.
- `test/design_system/molecules/item_list_tile_test.dart` muss nach dem `ItemStatusLabel`-Refactoring
  unverändert grün bleiben (kein neuer Test nötig, reine Umstellung auf die Extension).

## Out of Scope

- Persistenz/Speichern der Formularwerte (`Artikel anlegen`-Button ist noch nicht verdrahtet) —
  nicht Teil dieses Screenshots/dieser Aufgabe.
- Lokalisierung der neuen Texte über `l10n` — bleibt hardcodiert deutsch, konsistent mit dem
  restlichen Formular (siehe `2026-08-12-app-dropdown-field-design.md`).
- Deaktivierter/Fehler-Zustand für `AppSegmentedControl` — analog zu `AppDropdownField` bewusst
  weggelassen (YAGNI), kann später ergänzt werden.
