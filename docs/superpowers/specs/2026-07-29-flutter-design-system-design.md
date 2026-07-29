# Flutter Design System (BikeDrop) — Design

**Datum:** 2026-07-29
**Status:** Genehmigt

## Kontext & Ziel

Die App hat aktuell nur Platzhalter-Theming (`ColorScheme.fromSeed(seedColor: Colors.deepPurple)`
in [main.dart](../../../lib/main.dart)) und ein rohes `login_screen.dart` ohne Styling. Grundlage
ist `docs/BikeDrop Design System.md`, ein bereits fertiges Design-Dokument (Farben, Typografie,
Abstände, Komponenten, Zustände, Prinzipien), das aus dem bestehenden App-Design extrahiert wurde.

Ziel: eine einzige Quelle der Wahrheit (`lib/design_system/`) für alle visuellen Werte, so dass
jeder neue Screen/Widget automatisch nur diese Werte verwendet — nie eigene Rohwerte (Hex-Farben,
Pixel-Zahlen, ad-hoc TextStyles). Durchgesetzt durch Struktur (ThemeData + fertige Komponenten)
UND automatisierte Lints (Farben, TextStyles).

Kein neuer fachlicher Umfang — dies ist reines UI-Fundament für die bereits geplante
Warenannahme-App (siehe `docs/superpowers/specs/2026-07-26-warenannahme-app-design.md` und
`docs/superpowers/plans/2026-07-28-warenannahme-app-struktur.md`).

## Struktur

```
lib/design_system/
  app_colors.dart         # Farbkonstanten + Kategorie-Farbpaare
  app_typography.dart     # TextStyle-Konstanten
  app_spacing.dart        # Abstände, Radien, Maße, Tap-Ziele
  app_theme.dart          # ThemeData aus den drei Dateien oben
  widgets/
    app_primary_button.dart
    app_secondary_button.dart
    app_text_field.dart
    category_badge.dart
    app_snackbar.dart
    delete_confirmation_dialog.dart
    list_column_header.dart
  design_system.dart      # Barrel-Export

packages/design_system_lint/  # eigenständiges Dart-Package für custom_lint-Regeln
```

## Tokens

**`AppColors`** (statische `Color`-Konstanten, 1:1 aus der Farbtabelle im Design-Doc):
`accent` (`#ec3013`), `accentHover` (`#dd2b0f`), `accentPressed` (`#ae1800`),
`accentTint` (`#fff2ef`), `textPrimary` (`#201e1d`), `textSecondary` (`#605d5d`),
`textTertiary` (`#7d7979`), `textQuaternary` (`#9b9797`), `textQuaternaryLight` (`#bab6b6`),
`border` (`#d7d3d3`), `divider` (`#eae7e7`), `surface` (`#f8f4f4`), `surfaceDark` (`#eae7e7`),
`white` (`#fff`), `snackbarBg` (`#201e1d`), `snackbarAccent` (`#ff9783`).

`categoryColors`: `Map<Category, (Color background, Color text)>` für Bremsen, Reifen, E-Bike,
Zubehör, Pflege (Werte exakt aus der Tabelle im Design-Doc). `Category` ist ein einfaches Enum,
das hier lebt, da es rein visuelles Mapping ist (keine Fachlogik).

**`AppTypography`** (statische `TextStyle`-Getter, `fontFamily: 'Archivo'`):
`screenTitle` (800/22–28, -.02em), `loginWordmark` (800/44, -.03em), `body` (400/14–16,
line-height 1.4–1.55), `fieldLabel` (600/13, .04em, `textSecondary`), `sectionKicker`
(800/11, .16em), `buttonLabel` (800/17), `listNumber` (800/18).
Wo das Design-Doc eine Spanne angibt (z. B. Screen-Titel 22–28px), wird ein konkreter
Default-Wert innerhalb der Spanne gewählt (Implementierungsdetail, kein Freifahrtschein für
beliebige Werte außerhalb der Spanne).

**`AppSpacing`** (statische `double`-Konstanten):
`screenPaddingH` (20–24 → konkreter Default), `cardRadius`, `buttonRadius`, `dialogRadius` (22),
`photoTileRadius`, `fieldHeight` (54–56 → Default), `fieldBorderWidth` (1.5), `primaryButtonHeight`
(60), `minTapTarget` (44), `switchTrackWidth`/`switchTrackHeight` (58×34), `switchThumbSize` (28),
`listRowPaddingV` (12), `listRowGap` (12), `snackbarBottomOffset` (136), `dividerWeight` (2).

## `AppTheme`

`AppTheme.light()` liefert ein `ThemeData`:

- `colorScheme`: `primary`/`error` = `AppColors.accent`, `surface` = `AppColors.white`,
  Hintergrund-Ton = `AppColors.surface`. Kein `ColorScheme.fromSeed` mehr.
- `textTheme`: aus `AppTypography` gemappt auf die passenden Material-Slots.
- `elevatedButtonTheme`/`outlinedButtonTheme`: Radius/Höhe/Textstil aus Tokens als Fallback-Styling
  für Standard-Buttons; die eigentlichen CTA-Buttons der App nutzen aber `AppPrimaryButton`/
  `AppSecondaryButton` (s. u.), da Schatten und space-between-Layout über Standard-Theming
  hinausgehen.
- `inputDecorationTheme`: Randfarbe/-stärke, Radius, Höhe, Fehlerfarbe aus Tokens.
- `switchTheme`: an = `accent`, aus = `border`, Track/Thumb-Maße aus `AppSpacing`.
- `dividerTheme`: Farbe `AppColors.divider`.
- `snackBarTheme`: Grundfarbe `AppColors.snackbarBg`, Radius aus Tokens. Bottom-Offset (136px) und
  Slide-up-Verhalten sind über Theme nicht steuerbar → das übernimmt `AppSnackbar.show(...)`.

`main.dart` wird auf `theme: AppTheme.light()` umgestellt.

### Font-Einbindung

`pubspec.yaml` bekommt einen `fonts:`-Eintrag für Familie `Archivo`:

```yaml
fonts:
  - family: Archivo
    fonts:
      - asset: assets/fonts/Archivo-Regular.ttf
        weight: 400
      - asset: assets/fonts/Archivo-Medium.ttf
        weight: 500
      - asset: assets/fonts/Archivo-SemiBold.ttf
        weight: 600
      - asset: assets/fonts/Archivo-Bold.ttf
        weight: 700
      - asset: assets/fonts/Archivo-ExtraBold.ttf
        weight: 800
```

Die `.ttf`-Dateien werden vom Nutzer selbst von Google Fonts geladen und unter `assets/fonts/`
abgelegt — sind nicht Teil dieser Implementierung. Ohne die Dateien läuft die App mit
Flutter-Fallback-Font, bricht aber nicht.

## Komponenten-Widgets

Nur für Fälle, die über Standard-Material-Theming hinausgehen:

- **`AppPrimaryButton`**: Label + optionales Icon (space-between-Layout), Signalrot, Schatten
  (`0 8–10px 18–22px rgba(236,48,19,.28–.32)`), Radius/Höhe aus `AppSpacing`. `onPressed: null` →
  visueller Disabled-State (45% Opacity, wie im Design-Doc als Konvention vermerkt, da kein
  expliziter Disabled-Stil definiert ist).
- **`AppSecondaryButton`**: weiß, 1.5px Rand (`textPrimary` oder `border`), Text 700/14.
- **`AppTextField`**: Caps-Label darüber, 1.5px Rand, Fehlerzustand (Rand+Text in Signalrot/
  `accentPressed`).
- **`CategoryBadge`**: nimmt `Category`, holt Farbpaar aus `AppColors.categoryColors`, rendert
  700/10 Caps, Radius 6, Padding 4×7.
- **`AppSnackbar.show(BuildContext, String message, {String? actionLabel, VoidCallback? onAction})`**:
  statische Helper-Funktion, zeigt dunklen Snackbar mit 136px-Bottom-Offset, Slide-up.
- **`DeleteConfirmationDialog.show(BuildContext) → Future<bool>`**: Overlay
  `rgba(32,30,29,.55)`, weiße Card radius 22, Abbrechen (outline) + Löschen (gefüllt rot)
  nebeneinander.
- **`ListColumnHeader`**: Caps-Text (700/11, `textTertiary`) + 2px Divider darunter.

Standard-`Switch` und normale Listenzeilen-Layouts brauchen kein eigenes Widget — sie laufen über
`switchTheme` bzw. werden mit `AppSpacing`-Konstanten direkt in Screens zusammengesetzt.

## Lint-Durchsetzung

Neues lokales Package `packages/design_system_lint/` (Dart-Package mit `custom_lint_builder`-
Dependency), per `path:`-Dependency in `bikedrop/pubspec.yaml` (dev_dependency) eingebunden und in
`analysis_options.yaml` über `custom_lint` aktiviert.

Zwei Regeln:

1. **`avoid_hardcoded_colors`**: meldet `Color(...)`-Konstruktor-Aufrufe und `Colors.*`-Zugriffe
   außerhalb von `lib/design_system/app_colors.dart`.
2. **`avoid_hardcoded_text_style`**: meldet `TextStyle(...)`-Konstruktor-Aufrufe außerhalb von
   `lib/design_system/app_typography.dart`.

**Bewusst nicht enthalten:** eine Spacing/Radius-Lint-Regel. Zahlen-Literale kommen im Code auch
für viele nicht-visuelle Zwecke vor (Listen-Indizes, `Duration`, `flex`, Icon-Größen), eine
generische "keine harten Zahlen"-Regel hätte eine hohe False-Positive-Rate und würde die
Lint-Ergebnisse unglaubwürdig machen. Kann bei Bedarf später gezielt nachgezogen werden (z. B. nur
für `EdgeInsets`/`BorderRadius.circular`-Aufrufe), sobald sich am echten Code zeigt, wie groß das
Rauschen wäre.

## CLAUDE.md

Neu angelegt mit einer kurzen Projektregel: UI-Code verwendet ausschließlich Werte aus
`lib/design_system/` (Farben, Typografie, Abstände, Komponenten) — keine Rohwerte/Hex-Codes/
Pixel-Zahlen direkt in Screens/Widgets. Ziel: automatisches Befolgen in künftigen Sessions, auch
ohne dass der Lint jede mögliche Verletzung abdeckt (Spacing bleibt z. B. ungelintet).

## Migration bestehender Dateien

- **`main.dart`**: `ColorScheme.fromSeed(seedColor: Colors.deepPurple)` entfernt, `theme:
  AppTheme.light()` gesetzt.
- **`login_screen.dart`**: bleibt fachlich Platzhalter (Login-Logik ist Teil eines separaten
  Plans), aber Text/Button werden auf `AppTypography`/`AppPrimaryButton` umgestellt, damit von
  Anfang an keine Rohwerte im Screen-Code landen.
- **`overview_screen.dart`, `capture_screen.dart`, `item_detail_screen.dart`,
  `item_list_tile.dart`**: aktuell leer/ungenutzt (siehe Architekturplan) — werden hier nicht
  angefasst, entstehen mit der eigentlichen Feature-Implementierung und nutzen das Design-System
  dann von Anfang an.

## Testing

- Kein automatisierter Widget-/Golden-Test-Umfang in diesem Design (reines Fundament, keine
  fachliche Logik). Der Lint-Package selbst bekommt minimale Unit-Tests für seine beiden Regeln
  (positiver/negativer Fall je Regel), wie bei `custom_lint`-Paketen üblich.

## Out of Scope

- Dark Mode / zweites Theme (Design-Doc definiert nur ein helles Theme).
- Spacing/Radius-Lint-Regel (s. o.).
- Bereitstellung der Archivo-`.ttf`-Dateien selbst.
- Fachliche Implementierung der Screens (Login-Logik, Formulare, Supabase-Anbindung) — eigener
  Plan/eigene Umsetzung, nutzt aber ab sofort dieses Design-System.
