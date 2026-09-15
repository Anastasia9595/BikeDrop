# Warenkorb-Filter: Chips → exklusive Segmented-Control — Design

**Datum:** 2026-09-15
**Status:** Genehmigt

## Kontext & Ziel

Im Wareneingang-Warenkorb ([receiving_cart_sheet_content.dart](../../../lib/design_system/organisms/receiving_cart_sheet_content.dart))
stehen aktuell zwei `KpiFilterCard`-Chips ("Ergänzung nötig" / "Vollständige Artikel") über der
Liste, gebaut mit dem generischen `KpiFilterRow`. `groupFilter` ist `bool?`: `true`/`false` filtert
auf eine der beiden Gruppen, `null` zeigt beide Gruppen gruppiert untereinander. Erneutes Tippen auf
den aktiven Chip springt zurück auf `null`.

Das impliziert Mehrfachauswahl/"alle anzeigen", was hier nicht gewünscht ist — es soll immer genau
eine der beiden Ansichten sichtbar sein. Ziel: die Chips durch eine exklusive Segmented Control
ersetzen (Label + Zähler + Status-Punkt bleiben erhalten), Auswahl steuert direkt, welche der beiden
Listen angezeigt wird.

Das Projekt hat bereits ein passendes Design-System-Paar für Segmented Controls
(`AppSegment`-Atom + `AppSegmentedControl<T>`-Molecule, genutzt für den Status im Artikel-Formular),
aktuell aber nur mit reinem Text-Label. Dieses wird um einen optionalen Status-Punkt erweitert und im
Warenkorb wiederverwendet — statt Flutters rohem `SegmentedButton`/`ToggleButtons`, um konsistent mit
der bestehenden Design-System-Konvention zu bleiben.

## Erweiterung: `AppSegment` (Atom)

[app_segment.dart](../../../lib/design_system/atoms/app_segment.dart)

Neuer optionaler Parameter `final Color? dotColor;` (Default `null` → unverändertes Verhalten für
den bestehenden Aufrufer im Artikel-Formular).

Wenn gesetzt, wird vor dem Label ein 8px-Farbpunkt gerendert (gleiche Größe/Optik wie in
`KpiFilterCard`), in **voller Farbe unabhängig vom `selected`-Zustand** — analog dazu, wie der Punkt
in `KpiFilterCard` bisher schon in beiden Zuständen voll eingefärbt ist:

```dart
Row(
  mainAxisSize: MainAxisSize.min,
  mainAxisAlignment: MainAxisAlignment.center,
  children: [
    if (dotColor != null) ...[
      Container(
        width: 8,
        height: 8,
        decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
      ),
      const SizedBox(width: 8),
    ],
    Flexible(
      child: Text(
        label,
        overflow: TextOverflow.ellipsis,
        style: AppTypography.secondaryButtonLabel.copyWith(
          color: selected ? AppColors.white : AppColors.textSecondary,
        ),
      ),
    ),
  ],
)
```

Hintergrund/Text-Farbe bei Auswahl bleiben wie bisher einheitlich (`AppColors.textPrimary`-Pill,
weißer Text) — **kein** pro-Segment eingefärbter Hintergrund. Das hält das Atom generisch und
vermeidet eine Sonderbehandlung nur für den Warenkorb-Anwendungsfall.

## Erweiterung: `AppSegmentedControl<T>` (Molecule)

[app_segmented_control.dart](../../../lib/design_system/molecules/app_segmented_control.dart)

Neuer optionaler Parameter `final Color Function(T)? dotColorBuilder;`, durchgereicht an `AppSegment`:

```dart
AppSegment(
  label: labelBuilder(option),
  dotColor: dotColorBuilder?.call(option),
  selected: option == value,
  onTap: option == value ? null : () => onChanged(option),
),
```

Bestehender Aufrufer (`ItemDetailScreen`) übergibt `dotColorBuilder` nicht → unverändertes Verhalten.

`onTap: null` beim bereits ausgewählten Segment ist in `AppSegment` schon vorhanden und liefert genau
das geforderte Verhalten "kein Callback bei erneutem Tap auf aktives Segment" — es gibt also nie
einen Weg, in einen "kein Segment aktiv"-Zustand zu gelangen.

## Anpassung: `ReceivingCartSheetContent`

[receiving_cart_sheet_content.dart](../../../lib/design_system/organisms/receiving_cart_sheet_content.dart)

- `groupFilter` wird von `bool?` zu `bool` (non-nullable). Doc-Kommentar entsprechend anpassen
  (`true` = "Ergänzung nötig", `false` = "Vollständige Artikel", kein Freitext-`null`-Fall mehr).
- `visible`-Berechnung vereinfacht sich, der `null`-Zweig entfällt:
  ```dart
  final visible = !expanded
      ? _peekOrder(items).take(2).toList()
      : items.where((item) => item.scanStatus.needsCompletion == groupFilter).toList();
  ```
- Da im expandierten Zustand immer nur eine Gruppe sichtbar ist, entfallen `_groupedSlivers` und
  `_sectionSlivers` ersatzlos (die zweite Gruppe wäre nach dem Filtern ohnehin immer leer, ein
  zusätzlicher `ListSectionHeader` über der einzigen sichtbaren Gruppe wäre redundant zum Label der
  Segmented Control, das Gruppe + Zähler bereits zeigt, z.B. "Ergänzung nötig · 2"). Der
  `ListSectionHeader`-Import wird entfernt (das Widget bleibt als Design-System-Molecule bestehen,
  wird hier nur nicht mehr gebraucht).
- Neuer Empty State, wenn die gefilterte Liste leer ist (z.B. alle Artikel bereits vollständig, aber
  "Ergänzung nötig" ist ausgewählt): einfacher zentrierter Hinweistext, analog zum
  "keine Suchtreffer"-Muster aus `overview_screen.dart` (`Center` + `Text`, `AppTypography.body`,
  `AppColors.textSecondary`, kein Icon — das reichhaltigere Icon-Empty-State-Muster ist für
  "grundsätzlich keine Daten" reserviert und passt hier nicht, da der Warenkorb selbst nie leer ist).
  ```dart
  slivers: expanded && visible.isEmpty
      ? [
          SliverFillRemaining(
            hasScrollBody: false,
            child: Center(
              child: Text(
                'Keine Artikel in dieser Ansicht.',
                style: AppTypography.body.copyWith(color: AppColors.textSecondary),
              ),
            ),
          ),
        ]
      : [_itemSliver(visible)],
  ```
- `_buildExpandedHeader`: `KpiFilterRow` wird durch `AppSegmentedControl<bool>` ersetzt:
  ```dart
  AppSegmentedControl<bool>(
    options: const [true, false],
    labelBuilder: (needsCompletion) => needsCompletion
        ? 'Ergänzung nötig · ${(counts[ReceivingScanStatus.unknown] ?? 0) + (counts[ReceivingScanStatus.catalogMatch] ?? 0)}'
        : 'Vollständige Artikel · ${counts[ReceivingScanStatus.inStock] ?? 0}',
    dotColorBuilder: (needsCompletion) => needsCompletion
        ? AppColors.receivingStatusColors[ReceivingScanStatus.unknown]!
        : AppColors.receivingStatusColors[ReceivingScanStatus.inStock]!,
    value: groupFilter,
    onChanged: onFilterTap,
  ),
  ```
  `onFilterTap` bleibt `ValueChanged<bool>` — passt jetzt direkt ohne `as bool`-Cast (vorher nötig,
  weil `KpiFilterRow.onEntryTap` mit `Object` arbeitet).
- Import von `kpi_filter_row.dart` entfällt in dieser Datei, Import von `app_segmented_control.dart`
  (bzw. `../design_system.dart`, je nach Importkonvention der Datei) kommt hinzu.

## Anpassung: `ReceivingCartSheet`

[receiving_cart_sheet.dart](../../../lib/design_system/organisms/receiving_cart_sheet.dart)

- Doc-Kommentar über `_groupFilter` anpassen (kein `null`-"kein Filter"-Fall mehr).
- State-Feld umbenannt zu `_groupFilterOverride` (`bool?`, `null` = Nutzer hat noch nicht manuell
  gewählt → Default wird bei jedem Build aus dem Inhalt berechnet):
  ```dart
  bool? _groupFilterOverride;
  ```
- In `build()`, nach der Berechnung von `counts`:
  ```dart
  final needsCompletionCount =
      (counts[ReceivingScanStatus.unknown] ?? 0) +
      (counts[ReceivingScanStatus.catalogMatch] ?? 0);
  final groupFilter = _groupFilterOverride ?? (needsCompletionCount > 0);
  ```
  Standard: "Ergänzung nötig" (`true`), außer diese Gruppe ist leer → dann "Vollständige Artikel"
  (`false`). Sobald der Nutzer manuell tippt, ist die Wahl für die Lebensdauer des Sheets (bzw. bis
  der Warenkorb komplett leert und `ReceivingCartSheet` dadurch aus dem Baum verschwindet) fixiert.
- `onFilterTap` vereinfacht sich (kein Toggle-auf-`null` mehr):
  ```dart
  onFilterTap: (group) => setState(() => _groupFilterOverride = group),
  ```
- `groupFilter: _groupFilter` in der Weitergabe an `ReceivingCartSheetContent` wird zu
  `groupFilter: groupFilter` (die oben berechnete lokale Variable).

## Widgetbook

- [widgetbook/lib/use_cases/atoms/app_segment.dart](../../../widgetbook/lib/use_cases/atoms/app_segment.dart):
  neuer optionaler `dotColor`-Knob (`context.knobs.colorOrNull` bzw. ein Boolean-Knob "Mit
  Status-Punkt" + fixe Beispielfarbe), damit der neue Parameter isoliert sichtbar/testbar ist.
- [widgetbook/lib/use_cases/molecules/app_segmented_control.dart](../../../widgetbook/lib/use_cases/molecules/app_segmented_control.dart):
  vorhandene `ArticleStatus`-Story um einen `dotColorBuilder` ergänzen (z.B. über
  `AppColors.statusColors`), damit sichtbar ist, wie Punkte + Label + Auswahl zusammenspielen.
- `widgetbook/lib/use_cases/organisms/receiving_cart_sheet.dart` bleibt inhaltlich unverändert
  (seedet bereits gemischte Items, exerciert damit automatisch die neue Segmented Control mit).
- Nach den Änderungen `build_runner build` im Ordner `widgetbook/` laufen lassen, damit
  `main.directories.g.dart` die neuen Knobs aufnimmt (keine neue Use-Case-Datei nötig, nur
  Änderungen an bestehenden).

## Tests

**Neu/angepasst — `test/design_system/atoms/app_segment_test.dart`:**
- Mit gesetztem `dotColor` wird ein `Container` mit `BoxShape.circle` und der übergebenen Farbe
  gerendert; ohne `dotColor` (Default) erscheint kein Punkt (bestehendes Verhalten/bestehende Tests
  bleiben grün).
- Punkt hat unabhängig von `selected` immer die volle `dotColor` (kein Abblassen im
  nicht-ausgewählten Zustand).

**Neu/angepasst — `test/design_system/molecules/app_segmented_control_test.dart`:**
- Mit `dotColorBuilder` gesetzt wird pro Option die passende `dotColor` an `AppSegment`
  durchgereicht; ohne `dotColorBuilder` bleibt `dotColor` `null` (Regressionsschutz für den
  bestehenden `ItemDetailScreen`-Aufrufer).

**Angepasst — `test/design_system/organisms/receiving_cart_sheet_test.dart`:**
Bestehende Tests referenzieren `KpiFilterRow` und den Text `'Ergänzung nötig'` als Chip-Label; werden
umgestellt auf `AppSegmentedControl<bool>` bzw. `AppSegment` und das neue Label-Format:
- `find.byType(KpiFilterRow)` → `find.byType(AppSegmentedControl<bool>)` in allen betroffenen Tests
  (Zeilen 125, 151, 177, 199, 217, 226, 243, 248 laut aktuellem Stand).
- `'tapping a filter chip narrows the expanded list'`: Tap-Ziel wird
  `find.text('Ergänzung nötig · 1')` (Label inkl. Zähler) statt `find.text('Ergänzung nötig')`.
- **Neuer Test:** Tippen auf das bereits aktive Segment löst keinen Rebuild-Wechsel aus (Liste bleibt
  unverändert) — deckt "kein Callback bei Re-Tap" ab (kommt aus `AppSegment.onTap: null` beim
  ausgewählten Segment, ist aber auf Sheet-Ebene sinnvoll gegenzuprüfen).
- **Neuer Test:** Warenkorb mit ausschließlich vollständigen Artikeln (keine `unknown`/
  `catalogMatch`-Items) zeigt beim Öffnen direkt "Vollständige Artikel" als aktives Segment
  (Default-Auswahl je nach Inhalt).
- **Neuer Test:** Wechsel auf ein Segment mit 0 Treffern (z.B. alle Artikel sind vollständig, Nutzer
  tippt trotzdem — oder umgekehrt) zeigt den Empty-State-Text `'Keine Artikel in dieser Ansicht.'`
  statt einer leeren Liste.

## Out of Scope

- Persistenz der Segment-Auswahl über das Schließen/Wiederöffnen des Sheets hinaus (das Sheet
  verschwindet ohnehin ganz, sobald der Warenkorb leer ist — der State-Reset in diesem Moment ist
  gewolltes Verhalten, kein Edge Case, der extra behandelt werden muss).
- Ein generisches `EmptyState`-Design-System-Molecule (gäbe es Bedarf für mehr als diesen einen
  Anwendungsfall, siehe `overview_screen.dart` für das bisher einzige andere Vorkommen) — hier reicht
  der lokale, einfache Text analog zum bestehenden Muster.
- Pro-Segment eingefärbter Hintergrund/Tint bei Auswahl (wie bei `KpiFilterCard`) — bewusst nicht
  Teil der Atom-Erweiterung, um `AppSegment` generisch zu halten; nur der Status-Punkt trägt Farbe.
