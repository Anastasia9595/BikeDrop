# AppDropdownField (Design-System-Atom) — Design

**Datum:** 2026-08-12
**Status:** Genehmigt

## Kontext & Ziel

`lib/design_system/atoms/app_dropdown_field.dart` existiert bereits als leerer Platzhalter mit der
Klasse `DropDownField` (leerer `build`, kompiliert nicht sinnvoll) und wird hier erstmals mit
Inhalt gefüllt.

Der Design-Screenshot `docs/design/Create new Article Screen.png` ("Ware erfassen") zeigt zwei
Auswahlfelder nebeneinander — **KATEGORIE** ("Bremsen") und **LIEFERANT** ("Paul Lange") —, die
optisch identisch zu den Textfeldern darüber sind: Caps-Label über dem Feld, gerundeter Rahmen,
56 px Höhe, rechts ein Chevron nach unten. Ziel ist ein wiederverwendbares, rein präsentatives
Atom, das dieses Muster abbildet und sowohl mit Enums (`Category`) als auch mit beliebigen
anderen Typen (Lieferant) funktioniert.

## Öffentliche API

```dart
class AppDropdownField<T> extends StatelessWidget {
  const AppDropdownField({
    required this.label,
    required this.items,
    required this.itemLabel,
    required this.onChanged,
    this.value,
    this.errorText,
    super.key,
  });

  final String label;                 // 'Kategorie' → wird als KATEGORIE gerendert
  final List<T> items;
  final String Function(T) itemLabel; // T → Anzeigetext
  final ValueChanged<T?> onChanged;
  final T? value;                     // null → leeres Feld
  final String? errorText;            // null/leer → kein Fehlerzustand
}
```

Generisch statt String-only, damit dasselbe Atom `Category` (Enum) und Lieferant (String oder
späteres Modell) bedienen kann, ohne dass Aufrufer zwischen Enum und String hin- und
zurückmappen müssen.

Die Klasse heißt `AppDropdownField` (nicht `DropDownField` wie im Platzhalter), passend zum
Dateinamen und zu den übrigen Atomen (`AppTextField`, `AppPrimaryButton`, …). Der Platzhalter
wird von niemandem importiert, die Umbenennung bricht also nichts.

Vollständig kontrolliert: Der Aufrufer besitzt `value`, das Atom hält keinen eigenen State.

Beispiel-Aufruf:

```dart
AppDropdownField<Category>(
  label: 'Kategorie',
  value: _category,
  items: Category.values,
  itemLabel: (c) => c.label,
  onChanged: (c) => setState(() => _category = c),
)
```

## Layout & Aufbau

Struktur analog zu `AppTextField` (`lib/design_system/atoms/app_text_field.dart`), damit beide
Feldtypen nebeneinander exakt auf einer Linie liegen:

1. `Text(label.toUpperCase(), style: AppTypography.fieldLabel)`
2. `SizedBox(height: 6)`
3. `SizedBox(height: AppSpacing.fieldHeight)` um
   `InputDecorator` → `DropdownButtonHideUnderline` → `DropdownButton<T>`
4. Bei Fehler: `SizedBox(height: 4)` + Fehlertext

Die `InputDecoration` im `InputDecorator` ist identisch zu der in `AppTextField`:
`contentPadding: EdgeInsets.symmetric(horizontal: AppSpacing.screenPaddingH)`, `border` und
`enabledBorder` als `OutlineInputBorder` mit `BorderRadius.circular(AppSpacing.buttonRadius)` und
`BorderSide(color: borderColor, width: AppSpacing.fieldBorderWidth)`.

**Warum `InputDecorator` und nicht `DropdownButtonFormField`:** `InputDecorator` erlaubt es, exakt
dieselbe `InputDecoration` wie `AppTextField` zu verwenden (pixelgleiche Rahmen), während
`DropdownButton` rein vom Elternteil gesteuert bleibt. `DropdownButtonFormField` würde internen
`FormField`-State einführen; zusätzlich ist dessen `value`-Parameter seit Flutter 3.35 zugunsten
von `initialValue` deprecated (Projekt läuft auf Flutter 3.44), was für ein kontrolliertes Atom
das falsche Modell ist.

## Zustände & Visuals

Ausschließlich bestehende Tokens — `design_system_lint` (`avoid_hardcoded_colors`) verbietet
hartkodierte Farben.

| Element | Wert |
|---|---|
| Rahmen normal | `AppColors.border` |
| Rahmen Fehler | `AppColors.accent` |
| Ausgewählter Text | `AppTypography.body` + `AppColors.textPrimary` |
| Chevron | `Symbols.keyboard_arrow_down`, `AppColors.textSecondary` |
| Menü-Hintergrund | `AppColors.white`, `BorderRadius.circular(AppSpacing.buttonRadius)` |
| Fehlertext | `AppTypography.body.copyWith(color: AppColors.accentPressed, fontSize: 12)` |

Das Icon kommt aus `material_symbols_icons` (`Symbols.*`), wie bereits in `item_list_tile.dart`
und `overview_screen.dart` verwendet — nicht aus `Icons.*`.

`isExpanded: true`, damit lange Lieferantennamen mit Ellipse abgeschnitten werden statt
überzulaufen.

Fehlerzustand wird wie in `AppTextField` über `errorText != null && errorText!.isNotEmpty`
bestimmt.

Ist `value` null, zeigt das Feld einen leeren Kasten — kein Hint/Platzhalter, kein
Disabled-Zustand (bewusst weggelassen, YAGNI; kann später als optionaler Parameter ergänzt
werden).

## Begleitende Änderung: `Category.label`

`CategoryBadge` versteckt die Zuordnung `Category` → deutscher Anzeigetext aktuell in einem
privaten Getter `_label` (`lib/design_system/atoms/category_badge.dart:10`). Damit das Dropdown
dieselben Bezeichnungen verwenden kann, ohne den `switch` zu duplizieren, wandert die Zuordnung
in eine Extension neben das Enum:

```dart
// lib/design_system/tokens/app_colors.dart, direkt unter enum Category
extension CategoryLabel on Category {
  String get label => switch (this) { ... };
}
```

`CategoryBadge._label` entfällt und wird durch `category.label` ersetzt. Verhalten und Texte
bleiben unverändert.

## Export

Neuer Eintrag in `lib/design_system/design_system.dart`:
`export 'atoms/app_dropdown_field.dart';` — eingeordnet bei den übrigen Atom-Exports.

## Widgetbook

Neue Use-Case-Datei `widgetbook/lib/use_cases/atoms/app_dropdown_field.dart`, analog zu
`app_text_field.dart`: `@widgetbook.UseCase(name: 'Interactive', type: AppDropdownField)` mit
einer `AppDropdownField<Category>`-Instanz, Knobs für `label` (String) und `errorText` (String,
leer → null). Die Auswahl selbst wird über einen lokalen `StatefulBuilder` gehalten, damit der
Use-Case tatsächlich bedienbar ist. `main.directories.g.dart` wird per `build_runner build` im
Ordner `widgetbook/` neu generiert.

## Testing

Widget-Test unter `test/design_system/atoms/app_dropdown_field_test.dart`, nach dem Muster von
`test/design_system/atoms/app_text_field_test.dart`:

- Label wird in Großbuchstaben gerendert.
- Der zu `value` gehörende `itemLabel`-Text wird angezeigt.
- Tap auf das Feld öffnet das Menü; Tap auf einen Eintrag ruft `onChanged` mit dem passenden
  Wert auf.
- Mit `errorText` wird der Fehlertext gerendert und der Rahmen verwendet `AppColors.accent`.
- Ohne `errorText` wird kein Fehlertext gerendert.

Für `Category.label` wird kein neuer Test geschrieben: `test/design_system/atoms/category_badge_test.dart`
prüft die Texte bereits und muss nach dem Refactoring unverändert grün bleiben.

## Out of Scope

- Hint/Placeholder-Text und Disabled-Zustand — bewusst nicht in v1.
- Einbindung in den "Ware erfassen"-Screen (`capture_screen.dart`) — folgt separat, sobald das
  Formular gebaut wird.
- Lieferanten-Datenmodell — existiert im Projekt noch nicht; das generische Atom ist dafür
  bereits vorbereitet.
- Lokalisierung der Kategorie-Labels über `l10n` — die Texte sind heute hartkodiert deutsch
  (wie in `CategoryBadge`), das bleibt hier unverändert.
