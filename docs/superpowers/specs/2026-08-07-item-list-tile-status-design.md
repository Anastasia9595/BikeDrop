# ItemListTile — Status als festes Enum mit Farbe — Design

**Datum:** 2026-08-07
**Status:** Genehmigt

## Kontext & Ziel

`ItemListTile` (siehe `docs/superpowers/specs/2026-08-06-item-list-tile-design.md`) wurde
zwischenzeitlich (noch uncommitted) so geändert, dass statt `timestampLabel` ein `statusLabel`
(freier `String`) neben dem Kategorie-Badge angezeigt wird, begleitet von einem farbigen Punkt.
Die Farbe des Punkts ist aktuell fest auf `AppColors.statusColorSuccess` verdrahtet, unabhängig
vom tatsächlichen Text.

Ziel dieses Changes: `statusLabel` durch ein typsicheres Enum mit genau drei festen Werten
ersetzen — **Im Shop**, **Fehlt**, **Bestellt** — und die Punktfarbe abhängig vom Wert setzen.

## Öffentliche API

`ItemListTile` erhält statt `statusLabel: String` den Parameter `status: ItemStatus`:

```dart
class ItemListTile extends StatelessWidget {
  const ItemListTile({
    required this.title,
    required this.quantity,
    required this.category,
    this.image,
    this.onTap,
    required this.status,
    super.key,
  });

  final String title;
  final int quantity;
  final Category category;
  final ImageProvider? image;
  final VoidCallback? onTap;
  final ItemStatus status;
}
```

Neues Enum in `lib/design_system/tokens/app_colors.dart` (gleiche Datei wie `Category`, gleiches
Muster):

```dart
enum ItemStatus { imShop, fehlt, bestellt }
```

## Farbzuordnung

Neue `static const Map<ItemStatus, Color> statusColors` in `AppColors`, analog zu
`categoryColors`, unter Wiederverwendung der bereits vorhandenen Ampel-Tokens:

| ItemStatus  | Farbe                          |
|-------------|---------------------------------|
| `imShop`    | `AppColors.statusColorSuccess` (grün) |
| `bestellt`  | `AppColors.statusColorWarning` (gelb) |
| `fehlt`     | `AppColors.statusColorError` (rot)    |

## Label-Ableitung

In `ItemListTile` ein privater Getter, analog zu `CategoryBadge._label`:

```dart
String get _statusLabel => switch (status) {
  ItemStatus.imShop => 'Im Shop',
  ItemStatus.fehlt => 'Fehlt',
  ItemStatus.bestellt => 'Bestellt',
};
```

Der farbige Punkt (`Container`, 8×8, `BoxShape.circle`) verwendet
`AppColors.statusColors[status]!` als `color` statt des fest verdrahteten
`statusColorSuccess`. Der Text daneben verwendet `_statusLabel` statt des bisherigen
`statusLabel`-Parameters; Textfarbe/-stil bleiben unverändert (`AppTypography.body`,
Größe 12, `AppColors.textSecondary`).

## Widgetbook

`widgetbook/lib/use_cases/molecules/item_list_tile.dart`: der bisherige
`context.knobs.string(label: 'Status', ...)`-Knob wird durch einen Dropdown-Knob ersetzt,
gleiches Muster wie der bestehende `Category`-Dropdown:

```dart
status: context.knobs.object.dropdown<ItemStatus>(
  label: 'Status',
  options: ItemStatus.values,
  labelBuilder: (status) => status.name,
),
```

## Testing

`test/design_system/molecules/item_list_tile_test.dart` referenziert aktuell noch den bereits
entfernten `timestampLabel`-Parameter (Stand vor dieser Änderung nicht kompilierbar) — wird im
Zuge dieser Änderung auf `status: ItemStatus.xxx` umgestellt. Zusätzlich neuer Test:

- Für jeden `ItemStatus`-Wert wird der erwartete Label-Text gerendert (`'Im Shop'`, `'Fehlt'`,
  `'Bestellt'`).
- Für jeden `ItemStatus`-Wert hat der farbige Punkt (`Container` mit `BoxShape.circle`) die
  laut `AppColors.statusColors` erwartete Farbe.

## Out of Scope

- Verwendung von `ItemListTile` in `overview_screen.dart` oder einer echten Listenansicht —
  weiterhin nicht Teil dieses Changes (siehe Out-of-Scope im ursprünglichen Design).
- Lokalisierung der Label-Texte (i18n) — Texte bleiben hartcodiertes Deutsch, wie der Rest der
  Komponente.
