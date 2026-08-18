# Graph Report - bikedrop  (2026-08-18)

## Corpus Check
- 222 files · ~106,870 words
- Verdict: corpus is large enough that graph structure adds value.

## Summary
- 944 nodes · 1359 edges · 88 communities (77 shown, 11 thin omitted)
- Extraction: 93% EXTRACTED · 7% INFERRED · 0% AMBIGUOUS · INFERRED: 95 edges (avg confidence: 0.82)
- Token cost: 0 input · 0 output

## Community Hubs (Navigation)
- Widgetbook Windows Runner
- BikeDrop Windows Runner
- Design System Docs & Plans
- Item Detail Screen Specs
- App Localizations (l10n)
- iOS/macOS App Delegates
- AppColors Token
- Design System Atoms/Molecules
- AppSpacing Token
- Linux Runner
- Overview Screen & Item List Tile
- AppTypography Token
- Create Article Screen Widgets
- Warenannahme App Structure Plan
- BikeDrop README & Architecture Decisions
- AppDropdownField & AppSegmentedControl
- Widgetbook Dropdown/Badge Use Cases
- Design System Barrel Exports
- design_system_lint Analyzer Plugin
- Widget Tests (Image Upload/Secondary Button/Delete Dialog)
- Widgetbook Use-Case Barrel
- Item Detail & Capture Screen State
- Login Screen & Auth
- AppTextField Atom
- main.dart Entry Point
- Widgetbook Windows Runner Utils
- BikeDrop Windows Runner Utils
- QuantityStepper Molecule
- CategoryBadge/ItemListTile Tests
- AppIconButton Tests
- Web App Manifest
- Widgetbook Web App Manifest
- ListColumnHeader/Tokens Tests
- AppPrimaryButton/AppTextField Tests
- AppSegment Tests
- Offline/Validation Error Screen
- AppToggleCard Molecule
- Widgetbook Icon Button Use Case
- AppIconButton Atom
- Login Screen & AppSegment Widgetbook
- Widgetbook App Entry Point
- QuantityStepper Tests
- Git Workflow Docs
- AppDropdownField Tests
- AppSegmentedControl Tests
- AppToggleCard Tests
- Widgetbook Image Upload/Secondary Button Use Cases
- Widgetbook AppSnackbar Use Case
- Widgetbook AppToggleCard Use Case
- Widgetbook QuantityStepper Use Case
- Delete Article Screen & Dialog
- AppSnackbar Tests
- design_system_lint Good-Colors Fixture
- Widgetbook AppPrimaryButton Use Case
- Widgetbook AppTextField Use Case
- Widgetbook AppSegmentedControl Use Case
- Widgetbook Delete Dialog Use Case
- Android MainActivity
- Linux CMake Build
- design_system_lint Package Config
- BikeDrop Pubspec & Widgetbook Config
- Widgetbook Android MainActivity
- Widgetbook Windows CMake Build
- BikeDrop Windows CMake Build
- Analysis Options Lints
- Fonts README
- Lint Package Analysis Options
- Web Index HTML
- Bicycle Icon Asset
- Images README
- iOS Launch Image README
- Misc Literal
- Widgetbook README

## God Nodes (most connected - your core abstractions)
1. `_` - 37 edges
2. `_` - 27 edges
3. `_` - 20 edges
4. `Flutter Design System Implementation Plan` - 19 edges
5. `Win32Window` - 18 edges
6. `Win32Window` - 18 edges
7. `BikeDrop Design System` - 18 edges
8. `BikeDrop App` - 14 edges
9. `Warenannahme-App Struktur- & Architekturplan` - 12 edges
10. `_` - 10 edges

## Surprising Connections (you probably didn't know these)
- `Kategorie dropdown (e.g. Bremsen)` --conceptually_related_to--> `AppDropdownField`  [INFERRED]
  docs/design/Create new Article Screen.png → lib/design_system/atoms/app_dropdown_field.dart
- `Lieferant dropdown (e.g. Paul Lange)` --conceptually_related_to--> `AppDropdownField`  [INFERRED]
  docs/design/Create new Article Screen.png → lib/design_system/atoms/app_dropdown_field.dart
- `AppDropdownField` --conceptually_related_to--> `AppDropdownField`  [INFERRED]
  docs/superpowers/specs/2026-08-12-app-dropdown-field-design.md → lib/design_system/atoms/app_dropdown_field.dart
- `AppImageUploadField` --conceptually_related_to--> `AppImageUploadField`  [INFERRED]
  docs/superpowers/specs/2026-08-16-image-upload-field-design.md → lib/design_system/atoms/app_image_upload_field.dart
- `Inline Error Banner: 'E-Mail oder Passwort falsch'` --conceptually_related_to--> `AppSnackbar`  [AMBIGUOUS]
  docs/design/Login-failed Screen.png → lib/design_system/molecules/app_snackbar.dart

## Import Cycles
- None detected.

## Hyperedges (group relationships)
- **design_system_lint Custom Lint Fixture Test Setup** — packages_design_system_lint_pubspec_design_system_lint, packages_design_system_lint_analysis_options_lint_rules, packages_design_system_lint_example_pubspec_design_system_lint_example, packages_design_system_lint_example_analysis_options_custom_lint_plugin_config [INFERRED 0.85]
- **bikedrop Multi-Platform App Target** — pubspec_bikedrop, web_index_bikedrop_web_app, windows_cmakelists_bikedrop, linux_cmakelists_runner [INFERRED 0.80]
- **Widgetbook Component Catalog App** — widgetbook_pubspec_bikedrop_widgetbook, widgetbook_web_index_bikedrop_widgetbook_web_app, widgetbook_windows_cmakelists_bikedrop_widgetbook, widgetbook_build_use_case_builder_config [INFERRED 0.80]
- **BikeDrop Tech Stack** — readme_flutter, readme_riverpod, readme_supabase [EXTRACTED 1.00]
- **BikeDrop v1 Screens** — readme_login_screen, readme_uebersicht_screen, readme_ware_erfassen_screen, readme_artikel_detail_screen [EXTRACTED 1.00]
- **Repository Pattern Architecture** — docs_superpowers_plans_2026_07_28_warenannahme_app_struktur_supabaserepository, docs_superpowers_plans_2026_07_28_warenannahme_app_struktur_items_provider, docs_superpowers_plans_2026_07_28_warenannahme_app_struktur_overview_screen [INFERRED 0.85]
- **Tokens Forming AppTheme** — docs_superpowers_plans_2026_07_29_flutter_design_system_app_colors, docs_superpowers_plans_2026_07_29_flutter_design_system_app_typography, docs_superpowers_plans_2026_07_29_flutter_design_system_app_spacing [EXTRACTED 1.00]
- **Design System Lint Enforcement** — docs_superpowers_plans_2026_07_29_flutter_design_system_design_system_lint_package, docs_superpowers_plans_2026_07_29_flutter_design_system_avoid_hardcoded_colors_rule, docs_superpowers_plans_2026_07_29_flutter_design_system_avoid_hardcoded_text_style_rule [EXTRACTED 1.00]
- **DeleteConfirmationDialog Composition** — docs_superpowers_specs_2026_08_04_atomic_design_widgetbook_design_deleteconfirmationdialog, docs_superpowers_specs_2026_08_04_atomic_design_widgetbook_design_appsecondarybutton, docs_superpowers_specs_2026_08_04_atomic_design_widgetbook_design_appprimarybutton [EXTRACTED 1.00]
- **ItemDetailScreen Status & Visibility Section** — docs_superpowers_specs_2026_08_15_status_segmented_control_toggle_card_design_itemdetailscreen, docs_superpowers_specs_2026_08_15_status_segmented_control_toggle_card_design_appsegmentedcontrol, docs_superpowers_specs_2026_08_15_status_segmented_control_toggle_card_design_apptogglecard [EXTRACTED 1.00]
- **Shared Field Layout Token Pattern** — docs_superpowers_specs_2026_08_04_atomic_design_widgetbook_design_apptextfield, docs_superpowers_specs_2026_08_12_app_dropdown_field_design_appdropdownfield, docs_superpowers_specs_2026_08_15_status_segmented_control_toggle_card_design_appsegmentedcontrol [INFERRED 0.85]

## Communities (88 total, 11 thin omitted)

### Community 0 - "Widgetbook Windows Runner"
Cohesion: 0.05
Nodes (56): PluginRegistry, RegisterPlugins(), DartProject, HWND, LPARAM, LRESULT, UINT, WPARAM (+48 more)

### Community 1 - "BikeDrop Windows Runner"
Cohesion: 0.05
Nodes (56): PluginRegistry, RegisterPlugins(), DartProject, HWND, LPARAM, LRESULT, UINT, WPARAM (+48 more)

### Community 2 - "Design System Docs & Plans"
Cohesion: 0.07
Nodes (54): BikeDrop Design System, Category Badge Colors, Color Palette, Column Header, Delete Confirmation Dialog, Inline Error Hint, Input Field, List Row (+46 more)

### Community 3 - "Item Detail Screen Specs"
Cohesion: 0.07
Nodes (47): Article Detail Screen (Artikel-Detail), Kategorie (Category) Dropdown, Papierkorb (Delete) Button, Name Text Field, Foto ändern (Change Photo) Control, Article Detail Screen.png, EK-Preis (Purchase Price) Field, Menge (Quantity) Field (+39 more)

### Community 4 - "App Localizations (l10n)"
Cohesion: 0.06
Nodes (37): app_localizations.dart, app_localizations_de.dart, app_localizations_en.dart, dart:async, AppLocalizations, _AppLocalizationsDelegate, AppLocalizationsDe, loginButtonLabel (+29 more)

### Community 5 - "iOS/macOS App Delegates"
Cohesion: 0.07
Nodes (23): Any, Cocoa, Flutter, FlutterAppDelegate, FlutterImplicitEngineBridge, FlutterImplicitEngineDelegate, FlutterMacOS, FlutterPluginRegistry (+15 more)

### Community 6 - "AppColors Token"
Cohesion: 0.07
Nodes (32): Color, _, accent, accentHover, accentPressed, accentTint, AppColors, background (+24 more)

### Community 7 - "Design System Atoms/Molecules"
Cohesion: 0.10
Nodes (25): build, onTap, build, icon, label, onPressed, AppSecondaryButton, build (+17 more)

### Community 8 - "AppSpacing Token"
Cohesion: 0.08
Nodes (26): _, AppSpacing, buttonRadius, cardRadius, dialogRadius, dividerWeight, fieldBorderWidth, fieldHeight (+18 more)

### Community 9 - "Linux Runner"
Cohesion: 0.10
Nodes (20): FlPluginRegistry, GApplication, gboolean, gchar, GObject, GtkApplication, fl_register_plugins(), main() (+12 more)

### Community 10 - "Overview Screen & Item List Tile"
Cohesion: 0.09
Nodes (22): ../atoms/category_badge.dart, Article Empty List Screen (Bestand - leer), Article List Screen (Bestand / Übersicht mockup), Column header row (ARTIKEL / STÜCK / SHOP), Bestand header (title, article/piece count summary, refresh action), Category tag chip (e.g. BREMSEN, REIFEN, E-BIKE, ZUBEHÖR, PFLEGE), Article list row (thumbnail, name, category tag, timestamp, quantity, shop-visibility eye icon), Shop visibility indicator (eye / eye-off icon per item) (+14 more)

### Community 11 - "AppTypography Token"
Cohesion: 0.09
Nodes (23): app_colors.dart, app_spacing.dart, app_typography.dart, _, AppTheme, light, _, AppTypography (+15 more)

### Community 12 - "Create Article Screen Widgets"
Cohesion: 0.14
Nodes (20): EK-Preis (purchase price) field, Image Upload Field with Kamera/Galerie buttons, Kategorie dropdown (e.g. Bremsen), Lieferant dropdown (e.g. Paul Lange), Menge (quantity) field, Name text field (e.g. Shimano XT Bremsscheibe 203), Speichern primary button, Create Article Screen Mockup (Ware erfassen, filled) (+12 more)

### Community 13 - "Warenannahme App Structure Plan"
Cohesion: 0.21
Nodes (19): Warenannahme-App Struktur- & Architekturplan, authStateProvider, CaptureScreen, Item Model, ItemDetailScreen, ItemListTile (planned widget), items Table Migration & RLS, ItemsNotifier / itemsProvider (+11 more)

### Community 14 - "BikeDrop README & Architecture Decisions"
Cohesion: 0.12
Nodes (19): app_de.arb (Template ARB File), app_localizations.dart (Generated Output), l10n.yaml Localization Config, Artikel-Detail Screen, BikeDrop App, bikedrop-web (Angular Customer Site), Category as Dropdown Decision, Flutter (+11 more)

### Community 15 - "AppDropdownField & AppSegmentedControl"
Cohesion: 0.12
Nodes (16): ../atoms/app_segment.dart, bool get, build, errorText, _hasError, items, label, onChanged (+8 more)

### Community 16 - "Widgetbook Dropdown/Badge Use Cases"
Cohesion: 0.14
Nodes (13): @widgetbook, Category, CategoryLabel, appDropdownFieldInteractive, errorText, label, selected, appImageUploadFieldDefault (+5 more)

### Community 17 - "Design System Barrel Exports"
Cohesion: 0.14
Nodes (15): atoms/app_dropdown_field.dart, atoms/app_image_upload_field.dart, ../atoms/app_primary_button.dart, ../atoms/app_secondary_button.dart, atoms/app_text_field.dart, _, show, molecules/app_segmented_control.dart (+7 more)

### Community 18 - "design_system_lint Analyzer Plugin"
Cohesion: 0.12
Nodes (14): DartLintRule, package:analyzer/error/error.dart, package:analyzer/error/listener.dart, package:custom_lint_builder/custom_lint_builder.dart, createPlugin, _DesignSystemLintPlugin, getLintRules, AvoidHardcodedColors (+6 more)

### Community 19 - "Widget Tests (Image Upload/Secondary Button/Delete Dialog)"
Cohesion: 0.12
Nodes (11): package:bikedrop/design_system/atoms/app_image_upload_field.dart, package:bikedrop/design_system/atoms/app_secondary_button.dart, package:bikedrop/design_system/organisms/delete_confirmation_dialog.dart, package:bikedrop/main.dart, package:bikedrop_widgetbook/main.dart, package:flutter_test/flutter_test.dart, main, main (+3 more)

### Community 20 - "Widgetbook Use-Case Barrel"
Cohesion: 0.12
Nodes (15): package:bikedrop_widgetbook/use_cases/atoms/app_dropdown_field.dart, package:bikedrop_widgetbook/use_cases/atoms/app_icon_button.dart, package:bikedrop_widgetbook/use_cases/atoms/app_primary_button.dart, package:bikedrop_widgetbook/use_cases/atoms/app_secondary_button.dart, package:bikedrop_widgetbook/use_cases/atoms/app_segment.dart, package:bikedrop_widgetbook/use_cases/atoms/app_text_field.dart, package:bikedrop_widgetbook/use_cases/atoms/category_badge.dart, package:bikedrop_widgetbook/use_cases/molecules/app_segmented_control.dart (+7 more)

### Community 21 - "Item Detail & Capture Screen State"
Cohesion: 0.16
Nodes (13): ../design_system/design_system.dart, Neuer Artikel Form Mockup, Fuer Kunden Sichtbar Toggle, Supplier Catalog Prefill Banner, Status Segmented Control (Im Shop / Bestellt / Fehlt), build, CaptureScreen, build (+5 more)

### Community 22 - "Login Screen & Auth"
Cohesion: 0.18
Nodes (14): Anmelden (Login) Primary Button, BikeDrop Branding (logo, wordmark, Wareneingang subtitle), E-Mail / Passwort Input Fields (red-outlined, error state), Inline Error Banner: 'E-Mail oder Passwort falsch', Login Error State (Fehlerzustand), Login Failed Screen (01b), Anmelden (Login) Primary Button, BikeDrop App Branding (icon, wordmark, subtitle) (+6 more)

### Community 23 - "AppTextField Atom"
Cohesion: 0.14
Nodes (13): build, controller, errorText, _hasError, keyboardType, label, obscureText, onChanged (+5 more)

### Community 24 - "main.dart Entry Point"
Cohesion: 0.18
Nodes (9): build, main, MyApp, package:bikedrop/features/item_detail_screen.dart, package:bikedrop/l10n/app_localizations.dart, package:flutter/material.dart, build, SingleChildScrollView (+1 more)

### Community 25 - "Widgetbook Windows Runner Utils"
Cohesion: 0.23
Nodes (9): _In_, _In_opt_, wWinMain(), string, vector, wchar_t, CreateAndAttachConsole(), GetCommandLineArguments() (+1 more)

### Community 26 - "BikeDrop Windows Runner Utils"
Cohesion: 0.23
Nodes (9): _In_, _In_opt_, wWinMain(), string, vector, wchar_t, CreateAndAttachConsole(), GetCommandLineArguments() (+1 more)

### Community 27 - "QuantityStepper Molecule"
Cohesion: 0.18
Nodes (10): ../atoms/app_icon_button.dart, int?, build, _canDecrement, _canIncrement, label, max, min (+2 more)

### Community 28 - "CategoryBadge/ItemListTile Tests"
Cohesion: 0.18
Nodes (9): Container, dart:convert, package:bikedrop/design_system/atoms/category_badge.dart, package:bikedrop/design_system/molecules/item_list_tile.dart, main, container, main, _onePixelPng (+1 more)

### Community 29 - "AppIconButton Tests"
Cohesion: 0.18
Nodes (8): IconButton, package:bikedrop/design_system/atoms/app_icon_button.dart, package:bikedrop/design_system/tokens/app_spacing.dart, package:bikedrop/design_system/tokens/app_theme.dart, main, _wrap, main, main

### Community 30 - "Web App Manifest"
Cohesion: 0.18
Nodes (10): background_color, description, display, icons, name, orientation, prefer_related_applications, short_name (+2 more)

### Community 31 - "Widgetbook Web App Manifest"
Cohesion: 0.18
Nodes (10): background_color, description, display, icons, name, orientation, prefer_related_applications, short_name (+2 more)

### Community 32 - "ListColumnHeader/Tokens Tests"
Cohesion: 0.20
Nodes (7): Divider, package:bikedrop/design_system/molecules/list_column_header.dart, package:bikedrop/design_system/tokens/app_colors.dart, package:bikedrop/design_system/tokens/app_typography.dart, main, main, main

### Community 33 - "AppPrimaryButton/AppTextField Tests"
Cohesion: 0.25
Nodes (6): ElevatedButton, package:bikedrop/design_system/atoms/app_primary_button.dart, package:bikedrop/design_system/atoms/app_text_field.dart, main, main, Text

### Community 34 - "AppSegment Tests"
Cohesion: 0.29
Nodes (6): AnimatedContainer, package:bikedrop/design_system/atoms/app_segment.dart, _container, main, _text, _wrap

### Community 35 - "Offline/Validation Error Screen"
Cohesion: 0.48
Nodes (7): Erneut (Retry) Action, Form Validation Errors (Foto ist Pflicht, Menge angeben, Kategorie wählen), Für Kunden sichtbar Toggle (Erst intern prüfen), Offline Snackbar (Kein Internet. Eingaben bleiben erhalten.), Internet Connection Failed Screen (03b Ware erfassen), Speichern (Save) Button, Ware erfassen Form (Item Capture Form)

### Community 36 - "AppToggleCard Molecule"
Cohesion: 0.29
Nodes (6): build, description, onChanged, title, value, ValueChanged

### Community 37 - "Widgetbook Icon Button Use Case"
Cohesion: 0.33
Nodes (4): IconData, package:widgetbook/widgetbook.dart, appIconButtonDefault, enabled

### Community 38 - "AppIconButton Atom"
Cohesion: 0.33
Nodes (5): AppIconButton, build, icon, onPressed, tooltip

### Community 39 - "Login Screen & AppSegment Widgetbook"
Cohesion: 0.33
Nodes (4): build, package:bikedrop/design_system/design_system.dart, appSegmentDefault, selected

### Community 40 - "Widgetbook App Entry Point"
Cohesion: 0.33
Nodes (5): main.directories.g.dart, ThemeData, build, main, WidgetbookApp

### Community 41 - "QuantityStepper Tests"
Cohesion: 0.33
Nodes (5): package:bikedrop/design_system/molecules/quantity_stepper.dart, _decrement, _increment, main, _wrap

### Community 42 - "Git Workflow Docs"
Cohesion: 0.60
Nodes (5): Branch Prefixes (feature/fix/chore/docs), Git Aliases (feature/fix/chore/docs shortcuts), GitHub Flow, main Branch Protection, New Task Workflow Steps

### Community 43 - "AppDropdownField Tests"
Cohesion: 0.40
Nodes (4): InputDecorator, package:bikedrop/design_system/atoms/app_dropdown_field.dart, main, _wrap

### Community 44 - "AppSegmentedControl Tests"
Cohesion: 0.40
Nodes (4): package:bikedrop/design_system/molecules/app_segmented_control.dart, main, _Status, _wrap

### Community 45 - "AppToggleCard Tests"
Cohesion: 0.40
Nodes (4): package:bikedrop/design_system/molecules/app_toggle_card.dart, Switch, main, _wrap

### Community 46 - "Widgetbook Image Upload/Secondary Button Use Cases"
Cohesion: 0.40
Nodes (3): package:widgetbook_annotation/widgetbook_annotation.dart, appSecondaryButtonInteractive, isDisabled

### Community 47 - "Widgetbook AppSnackbar Use Case"
Cohesion: 0.40
Nodes (4): actionLabel, appSnackbarInteractive, message, withAction

### Community 48 - "Widgetbook AppToggleCard Use Case"
Cohesion: 0.40
Nodes (4): appToggleCardInteractive, description, title, value

### Community 49 - "Widgetbook QuantityStepper Use Case"
Cohesion: 0.40
Nodes (4): max, min, quantity, quantityStepperDefault

### Community 50 - "Delete Article Screen & Dialog"
Cohesion: 0.67
Nodes (4): Delete Article Screen (Mockup), Artikel (Article Detail) Screen, Delete Confirmation Dialog (UI element), DeleteConfirmationDialog

### Community 51 - "AppSnackbar Tests"
Cohesion: 0.50
Nodes (3): package:bikedrop/design_system/molecules/app_snackbar.dart, SnackBar, main

### Community 52 - "design_system_lint Good-Colors Fixture"
Cohesion: 0.50
Nodes (3): NotAColor, useIt, value

### Community 53 - "Widgetbook AppPrimaryButton Use Case"
Cohesion: 0.50
Nodes (3): appPrimaryButtonInteractive, hasIcon, isDisabled

### Community 54 - "Widgetbook AppTextField Use Case"
Cohesion: 0.50
Nodes (3): appTextFieldInteractive, errorText, obscureText

### Community 55 - "Widgetbook AppSegmentedControl Use Case"
Cohesion: 0.50
Nodes (3): appSegmentedControlInteractive, label, selected

### Community 56 - "Widgetbook Delete Dialog Use Case"
Cohesion: 0.50
Nodes (3): deleteConfirmationDialogDefault, message, title

### Community 58 - "Linux CMake Build"
Cohesion: 1.00
Nodes (3): Linux Runner CMake Project (bikedrop), Linux Flutter Library Target, Linux bikedrop App Executable Target

### Community 59 - "design_system_lint Package Config"
Cohesion: 0.67
Nodes (3): design_system_lint Example custom_lint Plugin Config, design_system_lint_example Fixture App Package, design_system_lint Custom Analyzer Lint Package

### Community 60 - "BikeDrop Pubspec & Widgetbook Config"
Cohesion: 0.67
Nodes (3): bikedrop Flutter App Package, Widgetbook use_case_builder Build Config, bikedrop_widgetbook Component Catalog Package

### Community 62 - "Widgetbook Windows CMake Build"
Cohesion: 1.00
Nodes (3): Widgetbook Windows CMake Project (bikedrop_widgetbook), Widgetbook Windows Flutter Library Target, Widgetbook bikedrop_widgetbook App Executable Target

### Community 63 - "BikeDrop Windows CMake Build"
Cohesion: 1.00
Nodes (3): Windows CMake Project (bikedrop), Windows Flutter Library Target, Windows bikedrop App Executable Target

## Ambiguous Edges - Review These
- `AppSnackbar` → `Inline Error Banner: 'E-Mail oder Passwort falsch'`  [AMBIGUOUS]
  docs/design/Login-failed Screen.png · relation: conceptually_related_to
- `Ware erfassen Form (Item Capture Form)` → `Erneut (Retry) Action`  [AMBIGUOUS]
  docs/design/Internet Connection Failed Screen.png · relation: conceptually_related_to
- `E-Mail Input Field` → `Passwort Input Field (with visibility toggle)`  [AMBIGUOUS]
  docs/design/Login Screen.png · relation: shares_data_with
- `Atomic Design Restructuring & Widgetbook Plan` → `Flutter Design System (BikeDrop) Design Spec`  [AMBIGUOUS]
  docs/superpowers/plans/2026-08-04-atomic-design-widgetbook.md · relation: references
- `ItemListTile Implementation Plan` → `Flutter Design System (BikeDrop) Design Spec`  [AMBIGUOUS]
  docs/superpowers/plans/2026-08-06-item-list-tile.md · relation: references

## Knowledge Gaps
- **331 isolated node(s):** `label`, `items`, `onChanged`, `value`, `errorText` (+326 more)
  These have ≤1 connection - possible missing edges or undocumented components.
- **11 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **What is the exact relationship between `AppSnackbar` and `Inline Error Banner: 'E-Mail oder Passwort falsch'`?**
  _Edge tagged AMBIGUOUS (relation: conceptually_related_to) - confidence is low._
- **What is the exact relationship between `Ware erfassen Form (Item Capture Form)` and `Erneut (Retry) Action`?**
  _Edge tagged AMBIGUOUS (relation: conceptually_related_to) - confidence is low._
- **What is the exact relationship between `E-Mail Input Field` and `Passwort Input Field (with visibility toggle)`?**
  _Edge tagged AMBIGUOUS (relation: shares_data_with) - confidence is low._
- **What is the exact relationship between `Atomic Design Restructuring & Widgetbook Plan` and `Flutter Design System (BikeDrop) Design Spec`?**
  _Edge tagged AMBIGUOUS (relation: references) - confidence is low._
- **What is the exact relationship between `ItemListTile Implementation Plan` and `Flutter Design System (BikeDrop) Design Spec`?**
  _Edge tagged AMBIGUOUS (relation: references) - confidence is low._
- **Why does `_` connect `AppColors Token` to `Widgetbook Dropdown/Badge Use Cases`, `main.dart Entry Point`, `App Localizations (l10n)`?**
  _High betweenness centrality (0.073) - this node is a cross-community bridge._
- **Why does `ItemDetailScreen` connect `Item Detail Screen Specs` to `Create Article Screen Widgets`, `Item Detail & Capture Screen State`?**
  _High betweenness centrality (0.020) - this node is a cross-community bridge._