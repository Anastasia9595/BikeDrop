# Design: AppImageUploadField

## Kontext

Im Artikel-Erfassungsformular (`lib/features/item_detail_screen.dart`) soll oberhalb des ersten Feldes (`Artikelnummer`) ein klickbarer Platzhalter-Container für einen späteren Bild-Upload eingebaut werden. In diesem Schritt bekommt der Container noch keine Funktion (kein Bild-Picker, kein State) — nur die visuelle Komponente inkl. Klick-Hook für spätere Anbindung.

## Komponente: `AppImageUploadField`

Neues Atom in `lib/design_system/atoms/app_image_upload_field.dart` (analog zu `AppTextField`, da es sich wie ein Formularfeld verhält).

**Props:**
- `onTap: VoidCallback` (required) — Klick-Hook, aktuell ohne Logik von außen belegt (`onTap: () {}`), analog zu den bestehenden leeren `onChanged: (value) {}` Platzhaltern in `item_detail_screen.dart`.

Kein State, keine weiteren Parameter — Text und Icon sind fix, da es aktuell nur einen Anwendungsfall gibt (YAGNI).

**Aufbau:**
- Klickbarer Container über die volle Breite, feste Höhe (neuer Token `AppSpacing.imageUploadFieldHeight = 160.0`)
- Gestrichelter Rand über das vorhandene `dotted_border`-Package, gleiche Machart wie im Empty-State in `overview_screen.dart`:
  - `RoundedRectDottedBorderOptions`
  - `color: AppColors.border`
  - `dashPattern: [10, 5]`
  - `strokeWidth: 2`
  - `radius: Radius.circular(AppSpacing.cardRadius)`
- Klickbarkeit über `InkWell` (mit `borderRadius` passend zum `cardRadius`), `onTap` wird durchgereicht
- Zentrierter Inhalt (Column, `mainAxisAlignment: center`):
  - Kreisförmiges Icon-Badge: `Container` mit `shape: BoxShape.circle`, Hintergrund `AppColors.surfaceDark`, darin `Icon(Symbols.image)` in `AppColors.textSecondary`
  - Bold-Text „Zum Hochladen klicken" — `AppTypography.secondaryButtonLabel`, Farbe `AppColors.textPrimary`
  - Sekundärtext „JPG, PNG (max. 2 MB)" — `AppTypography.body`, Farbe `AppColors.textSecondary`, kleinere Schriftgröße analog zur `description` in `AppToggleCard` (fontSize 13)

**Export:** Eintrag in `lib/design_system/design_system.dart` unter den Atom-Exports.

## Einbindung in `item_detail_screen.dart`

Als erstes Element in der `Column` (vor `AppTextField(label: 'Artikelnummer')`):

```dart
AppImageUploadField(onTap: () {}),
const SizedBox(height: AppSpacing.screenSpacingV),
```

## Tests

`test/design_system/atoms/app_image_upload_field_test.dart`, analog zu den bestehenden Atom-Tests:
- Rendert Icon, Titel- und Subtiteltext
- Tap auf den Container löst `onTap` genau einmal aus

## Widgetbook

`widgetbook/lib/use_cases/atoms/app_image_upload_field.dart` — einfacher Use-Case, der die Komponente zentriert mit etwas Padding zeigt (kein Knob nötig, da keine konfigurierbaren Props außer `onTap`).

## Out of Scope

- Bildauswahl-Logik (Image Picker, Berechtigungen, Dateivalidierung)
- Anzeige eines ausgewählten Bildes / Vorschau
- Fehlerzustände (z. B. Datei zu groß, falsches Format)

Diese Punkte werden in einem späteren Schritt umgesetzt, sobald die eigentliche Upload-Funktion angebunden wird.
