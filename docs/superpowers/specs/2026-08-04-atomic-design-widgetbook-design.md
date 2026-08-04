# Atomic Design Restrukturierung & Widgetbook — Design

**Datum:** 2026-08-04
**Status:** Genehmigt

## Kontext & Ziel

`lib/design_system/` (siehe `docs/superpowers/specs/2026-07-29-flutter-design-system-design.md`)
enthält bereits Tokens (Colors, Spacing, Typography, Theme) und 7 Widgets in einem flachen
`widgets/`-Ordner. Ziel dieses Umbaus: die Widgets nach Atomic-Design-Kategorien (Atoms/
Molecules/Organisms) gliedern und eine eigenständige Widgetbook-App aufsetzen, damit jedes
Widget isoliert von Navigation, echten Daten und Riverpod-Providern entwickelt/betrachtet werden
kann.

Der Rest von `lib/` (`models/`, `providers/`, `repository/`, `core/`) ist laut
`docs/superpowers/plans/2026-07-28-warenannahme-app-struktur.md` noch nicht implementiert (leere
Platzhalterdateien) und bleibt unangetastet — diese Schichten sind bewusst nicht Teil des
Atomic-Design-Umbaus. Aktuell koppelt kein einziges Widget an Riverpod oder echte Daten; die
Isolation ist für den Bestand bereits gegeben, das Ziel dieses Umbaus ist, das für zukünftige
Widgets strukturell zu erzwingen und Widgetbook als Entwicklungswerkzeug verfügbar zu machen.

Kein neuer fachlicher Umfang — reine Struktur-Maßnahme.

## Teil 1: lib/ und test/ Zielstruktur

```
lib/
  design_system/
    design_system.dart          # Barrel, Exportpfade aktualisiert
    tokens/
      app_colors.dart
      app_spacing.dart
      app_typography.dart
      app_theme.dart
    atoms/
      app_primary_button.dart
      app_secondary_button.dart
      app_text_field.dart
      category_badge.dart
    molecules/
      list_column_header.dart
      app_snackbar.dart
      item_list_tile.dart       # aktuell leer (0 Byte); verschoben aus lib/widgets/, da diese
                                 # Komponente laut Architekturplan (Thumbnail+Name+Badge+Icon)
                                 # eine Molecule wird und lib/widgets/ in der Zielstruktur entfällt
    organisms/
      delete_confirmation_dialog.dart
  features/                     # umbenannt von screens/
    login_screen.dart
    overview_screen.dart        # leer
    capture_screen.dart         # leer
    item_detail_screen.dart     # leer
  core/                         # unverändert
  models/                       # unverändert
  providers/                    # unverändert
  repository/                   # unverändert

test/
  design_system/
    tokens/       app_colors_test.dart, app_spacing_test.dart, app_theme_test.dart, app_typography_test.dart
    atoms/         app_primary_button_test.dart, app_secondary_button_test.dart, app_text_field_test.dart, category_badge_test.dart
    molecules/     list_column_header_test.dart, app_snackbar_test.dart
    organisms/     delete_confirmation_dialog_test.dart
  features/        capture_screen_test.dart (leer)
  repository/      supabase_repository_test.dart (leer, unverändert)
  widget_test.dart # unverändert — Default-Counter-Test, nicht Teil dieses Umbaus
```

`lib/widgets/` wird komplett aufgelöst. Betroffene Imports (`main.dart`, `login_screen.dart`,
alle Widget-Dateien untereinander, alle Test-Dateien) werden auf die neuen Pfade angepasst. Der
Barrel-Export `design_system.dart` bleibt bestehen und exportiert aus den neuen Unterordnern, so
dass externe Konsumenten (`login_screen.dart`) unverändert `package:bikedrop/design_system/design_system.dart`
importieren können.

### Klassifizierung

| Widget | Kategorie | Begründung |
|---|---|---|
| `AppPrimaryButton` | Atom | kleinster interaktiver Baustein, keine Komposition anderer DS-Widgets |
| `AppSecondaryButton` | Atom | dito |
| `AppTextField` | Atom | atomares Eingabeelement (Label+Input+Fehlertext gilt als eine Einheit) |
| `CategoryBadge` | Atom | einzelnes Label-Element |
| `ListColumnHeader` | Molecule | Komposition aus Text + Divider |
| `AppSnackbar` | Molecule | Komposition aus Text + optionaler Action, kein eigenständiges Widget im Tree (statische `show()`-Methode) |
| `DeleteConfirmationDialog` | Organism | komponiert `AppSecondaryButton` + `AppPrimaryButton` + Text zu einem kompletten UI-Block |
| `ItemListTile` (künftig) | Molecule | noch leer; vorgesehen als Thumbnail+Name+Badge+Sichtbarkeits-Icon |

## Teil 2: Widgetbook-App

Eigenständige Flutter-App im Repo-Root, Geschwisterverzeichnis von `lib/`:

```
widgetbook/
  pubspec.yaml            # name: bikedrop_widgetbook; path-Dependency auf ../ (bikedrop)
  build.yaml               # Codegen-Konfiguration für widgetbook_generator
  lib/
    main.dart              # Widgetbook.material(directories: directories, addons: [...])
    use_cases/
      atoms/
        app_primary_button.dart
        app_secondary_button.dart
        app_text_field.dart
        category_badge.dart
      molecules/
        list_column_header.dart
        app_snackbar.dart
      organisms/
        delete_confirmation_dialog.dart
    main.directories.g.dart  # generiert via build_runner
```

**Dependencies:**
- Runtime: `widgetbook`, `widgetbook_annotation`
- Dev: `widgetbook_generator`, `build_runner`
- `bikedrop` als `path: ../` Dependency (Zugriff auf `design_system/`; zieht transitiv
  `flutter_riverpod`/`supabase_flutter` mit, was hier unschädlich ist, da Widgetbook diese nicht
  nutzt)

**Addons in `main.dart`:** `DeviceFrameAddon`, `TextScaleAddon`, `ThemeAddon` (mit `AppTheme.light()`).
Alle Use-Cases werden mit dem App-Theme umschlossen, damit Widgets in Widgetbook exakt wie in der
App aussehen.

`packages/` bleibt reserviert für reine Dart-Tooling-Pakete (aktuell `design_system_lint`);
`widgetbook/` ist bewusst kein Unterordner davon, da es eine vollständige Flutter-App ist.

### Use-Cases pro Widget

| Widget | Varianten | Knobs |
|---|---|---|
| `AppPrimaryButton` | Default, Disabled (`onPressed: null`), mit Icon | Label (`context.knobs.string`), Icon-Toggle (`context.knobs.boolean`) |
| `AppSecondaryButton` | Default, Disabled | Label (`context.knobs.string`) |
| `AppTextField` | Default, Error-State (`errorText` gesetzt), Obscured (Passwort) | Label, Fehlertext (`context.knobs.string`) |
| `CategoryBadge` | je eine Variante pro `Category`-Enum-Wert (5) | Category-Auswahl (`context.knobs.list`) |
| `ListColumnHeader` | Default | Label (`context.knobs.string`) |
| `AppSnackbar` | Default, mit Action-Button | Use-Case zeigt `AppPrimaryButton`, der beim Tap `AppSnackbar.show(...)` auslöst; Message/ActionLabel via Knobs |
| `DeleteConfirmationDialog` | Default | Use-Case zeigt Trigger-Button, der den Dialog öffnet; Titel/Message via Knobs |

## Teil 3: Verifikation

- Hauptprojekt: `flutter analyze` + `flutter test` — bestehende Tests müssen nach dem Umbau
  weiterhin grün sein (nur Importpfade ändern sich, keine Logikänderung).
- `widgetbook/`: `dart run build_runner build --delete-conflicting-outputs`, danach
  `flutter analyze`, danach `flutter run -d chrome` (oder anderes Device) zur visuellen Prüfung
  aller Use-Cases.

## Out of Scope

- `models/`, `providers/`, `repository/`, `core/` — unverändert, da laut Architekturplan bewusst
  eigene Schichten außerhalb des UI-Baukastens.
- `test/widget_test.dart` — Default-Counter-Test, unabhängig vom Umbau.
- Dark-Theme/`ThemeAddon`-Varianten über `AppTheme.light()` hinaus — aktuell existiert kein
  Dark-Theme im Design System.
- Extraktion von `design_system/` in ein eigenes Package (`packages/design_system/`) — bewusst
  nicht gemacht, da explizit gewünscht ist, dass `design_system/` Teil von `lib/` bleibt.
