# Atomic Design Restructuring & Widgetbook Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Reorganize `lib/design_system/widgets/` into Atomic-Design categories (`tokens/`, `atoms/`, `molecules/`, `organisms/`), rename `lib/screens/` to `lib/features/`, and stand up a standalone Widgetbook app that catalogs every atom/molecule/organism in isolation from Riverpod/navigation/real data.

**Architecture:** Pure structural refactor of the existing `lib/design_system/` package plus a new sibling Flutter app (`widgetbook/`) that depends on the main `bikedrop` package via a `path: ../` dependency to reuse `design_system/` directly. No business logic changes; `models/`, `providers/`, `repository/`, `core/` stay untouched.

**Tech Stack:** Flutter (installed: 3.31.0-1.0.pre.421, channel master), Dart 3.8.0-265.0.dev, `widgetbook` + `widgetbook_annotation` + `widgetbook_generator` + `build_runner` for the catalog app.

## Global Constraints

- No behavior changes to any widget — only file location and import paths change. Every existing test must still pass after each task, with only import paths edited (assertions unchanged).
- `models/`, `providers/`, `repository/`, `core/` are out of scope and must not be touched (see `docs/superpowers/specs/2026-08-04-atomic-design-widgetbook-design.md`, "Out of Scope").
- The `design_system.dart` barrel export's public API (what symbols it exports) does not change — only the internal `export` paths change — so `lib/features/login_screen.dart` keeps importing `package:bikedrop/design_system/design_system.dart` unmodified.
- `widgetbook/` lives at the repo root as a sibling of `lib/`, not inside `packages/` (that directory is reserved for pure-Dart tooling packages like `design_system_lint`).
- Widgetbook dependency versions must resolve against the **installed** toolchain (Flutter 3.31.0, Dart 3.8.0-265.0.dev pre-release). Do not hand-pin exact versions in `pubspec.yaml` — use lower-bound-only constraints (e.g. `widgetbook: ^3.0.0`) so `flutter pub get` picks the highest version whose own `environment:` constraint the installed SDK actually satisfies. `widgetbook` versions `>=3.20.0` require Flutter `>=3.32.0`, which is newer than what's installed — pub will correctly skip those on its own as long as the constraint isn't artificially narrowed.
- `widgetbook/pubspec.yaml`'s own `environment: sdk:` must read `^3.8.0-265.0.dev`, mirroring the root `pubspec.yaml`, so it builds against the same SDK.

---

### Task 1: Move design tokens into `design_system/tokens/`

**Files:**
- Move: `lib/design_system/app_colors.dart` → `lib/design_system/tokens/app_colors.dart`
- Move: `lib/design_system/app_spacing.dart` → `lib/design_system/tokens/app_spacing.dart`
- Move: `lib/design_system/app_typography.dart` → `lib/design_system/tokens/app_typography.dart`
- Move: `lib/design_system/app_theme.dart` → `lib/design_system/tokens/app_theme.dart`
- Modify: `lib/design_system/design_system.dart`
- Modify: `packages/design_system_lint/lib/src/avoid_hardcoded_colors.dart:24`
- Move: `test/design_system/app_colors_test.dart` → `test/design_system/tokens/app_colors_test.dart`
- Move: `test/design_system/app_spacing_test.dart` → `test/design_system/tokens/app_spacing_test.dart`
- Move: `test/design_system/app_theme_test.dart` → `test/design_system/tokens/app_theme_test.dart`
- Move: `test/design_system/app_typography_test.dart` → `test/design_system/tokens/app_typography_test.dart`

**Interfaces:**
- Produces: `lib/design_system/tokens/app_colors.dart` (class `AppColors`, enum `Category`, class `CategoryColorPair` — unchanged), `tokens/app_spacing.dart` (class `AppSpacing`), `tokens/app_typography.dart` (class `AppTypography`), `tokens/app_theme.dart` (class `AppTheme`). All four files keep their existing relative imports (`import 'app_colors.dart';` etc.) unchanged — they still sit next to each other, just one directory deeper.

- [ ] **Step 1: Move the four token files with git, preserving history**

```bash
mkdir -p lib/design_system/tokens
git mv lib/design_system/app_colors.dart lib/design_system/tokens/app_colors.dart
git mv lib/design_system/app_spacing.dart lib/design_system/tokens/app_spacing.dart
git mv lib/design_system/app_typography.dart lib/design_system/tokens/app_typography.dart
git mv lib/design_system/app_theme.dart lib/design_system/tokens/app_theme.dart
```

No content edits needed in these four files — their imports of each other (`import 'app_colors.dart';`) are still valid since all four moved together.

- [ ] **Step 2: Update the barrel export**

In `lib/design_system/design_system.dart`, change:

```dart
export 'app_colors.dart';
export 'app_typography.dart';
export 'app_spacing.dart';
export 'app_theme.dart';
```

to:

```dart
export 'tokens/app_colors.dart';
export 'tokens/app_typography.dart';
export 'tokens/app_spacing.dart';
export 'tokens/app_theme.dart';
```

(Leave the four `export 'widgets/...'` lines below untouched for now — Tasks 2–4 handle those.)

- [ ] **Step 3: Fix the design_system_lint allowed-file path**

In `packages/design_system_lint/lib/src/avoid_hardcoded_colors.dart`, the `_isAllowedFile` method currently exempts `lib/design_system/app_colors.dart` from the "no hardcoded colors" rule. After the move, that path no longer exists, so change:

```dart
    return normalized.endsWith('lib/design_system/app_colors.dart');
```

to:

```dart
    return normalized.endsWith('lib/design_system/tokens/app_colors.dart');
```

- [ ] **Step 4: Move and update the four token test files**

```bash
mkdir -p test/design_system/tokens
git mv test/design_system/app_colors_test.dart test/design_system/tokens/app_colors_test.dart
git mv test/design_system/app_spacing_test.dart test/design_system/tokens/app_spacing_test.dart
git mv test/design_system/app_theme_test.dart test/design_system/tokens/app_theme_test.dart
git mv test/design_system/app_typography_test.dart test/design_system/tokens/app_typography_test.dart
```

Update the `package:bikedrop/design_system/...` imports in each moved test file:

`test/design_system/tokens/app_colors_test.dart` — change `import 'package:bikedrop/design_system/app_colors.dart';` to `import 'package:bikedrop/design_system/tokens/app_colors.dart';`

`test/design_system/tokens/app_spacing_test.dart` — change `import 'package:bikedrop/design_system/app_spacing.dart';` to `import 'package:bikedrop/design_system/tokens/app_spacing.dart';`

`test/design_system/tokens/app_theme_test.dart` — change:
```dart
import 'package:bikedrop/design_system/app_colors.dart';
import 'package:bikedrop/design_system/app_spacing.dart';
import 'package:bikedrop/design_system/app_theme.dart';
```
to:
```dart
import 'package:bikedrop/design_system/tokens/app_colors.dart';
import 'package:bikedrop/design_system/tokens/app_spacing.dart';
import 'package:bikedrop/design_system/tokens/app_theme.dart';
```

`test/design_system/tokens/app_typography_test.dart` — change:
```dart
import 'package:bikedrop/design_system/app_colors.dart';
import 'package:bikedrop/design_system/app_typography.dart';
```
to:
```dart
import 'package:bikedrop/design_system/tokens/app_colors.dart';
import 'package:bikedrop/design_system/tokens/app_typography.dart';
```

- [ ] **Step 5: Run the token tests to verify they still pass**

Run: `flutter test test/design_system/tokens/`
Expected: PASS, 4 files, same assertions as before (only import paths changed).

- [ ] **Step 6: Commit**

```bash
git add lib/design_system/tokens lib/design_system/design_system.dart packages/design_system_lint/lib/src/avoid_hardcoded_colors.dart test/design_system/tokens
git commit -m "refactor: move design system tokens into design_system/tokens/"
```

---

### Task 2: Move atoms into `design_system/atoms/`

**Files:**
- Move: `lib/design_system/widgets/app_primary_button.dart` → `lib/design_system/atoms/app_primary_button.dart`
- Move: `lib/design_system/widgets/app_secondary_button.dart` → `lib/design_system/atoms/app_secondary_button.dart`
- Move: `lib/design_system/widgets/app_text_field.dart` → `lib/design_system/atoms/app_text_field.dart`
- Move: `lib/design_system/widgets/category_badge.dart` → `lib/design_system/atoms/category_badge.dart`
- Modify: `lib/design_system/design_system.dart`
- Move: `test/design_system/widgets/app_primary_button_test.dart` → `test/design_system/atoms/app_primary_button_test.dart`
- Move: `test/design_system/widgets/app_secondary_button_test.dart` → `test/design_system/atoms/app_secondary_button_test.dart`
- Move: `test/design_system/widgets/app_text_field_test.dart` → `test/design_system/atoms/app_text_field_test.dart`
- Move: `test/design_system/widgets/category_badge_test.dart` → `test/design_system/atoms/category_badge_test.dart`

**Interfaces:**
- Consumes: `AppColors`, `AppSpacing`, `AppTypography` from `lib/design_system/tokens/` (Task 1).
- Produces: `AppPrimaryButton({required String label, required VoidCallback? onPressed, IconData? icon})`, `AppSecondaryButton({required String label, required VoidCallback? onPressed})`, `AppTextField({required String label, TextEditingController? controller, String? errorText, bool obscureText, TextInputType? keyboardType, ValueChanged<String>? onChanged})`, `CategoryBadge({required Category category})` — all in `lib/design_system/atoms/`, unchanged signatures. Task 4 (organisms) imports `AppPrimaryButton`/`AppSecondaryButton` from here.

- [ ] **Step 1: Move the four atom files with git**

```bash
mkdir -p lib/design_system/atoms
git mv lib/design_system/widgets/app_primary_button.dart lib/design_system/atoms/app_primary_button.dart
git mv lib/design_system/widgets/app_secondary_button.dart lib/design_system/atoms/app_secondary_button.dart
git mv lib/design_system/widgets/app_text_field.dart lib/design_system/atoms/app_text_field.dart
git mv lib/design_system/widgets/category_badge.dart lib/design_system/atoms/category_badge.dart
```

- [ ] **Step 2: Fix token imports in each moved atom file**

Each file currently imports tokens as `../app_colors.dart` (i.e. one level up from `widgets/`, straight into `design_system/`). Now that tokens live in `design_system/tokens/`, update each to `../tokens/app_colors.dart` etc.

`lib/design_system/atoms/app_primary_button.dart` — change:
```dart
import '../app_colors.dart';
import '../app_spacing.dart';
import '../app_typography.dart';
```
to:
```dart
import '../tokens/app_colors.dart';
import '../tokens/app_spacing.dart';
import '../tokens/app_typography.dart';
```

`lib/design_system/atoms/app_secondary_button.dart` — same three-line change (`../app_colors.dart` → `../tokens/app_colors.dart`, `../app_spacing.dart` → `../tokens/app_spacing.dart`, `../app_typography.dart` → `../tokens/app_typography.dart`).

`lib/design_system/atoms/app_text_field.dart` — same three-line change.

`lib/design_system/atoms/category_badge.dart` — change:
```dart
import '../app_colors.dart';
import '../app_typography.dart';
```
to:
```dart
import '../tokens/app_colors.dart';
import '../tokens/app_typography.dart';
```

- [ ] **Step 3: Update the barrel export**

In `lib/design_system/design_system.dart`, change:
```dart
export 'widgets/app_primary_button.dart';
export 'widgets/app_secondary_button.dart';
export 'widgets/app_text_field.dart';
export 'widgets/category_badge.dart';
```
to:
```dart
export 'atoms/app_primary_button.dart';
export 'atoms/app_secondary_button.dart';
export 'atoms/app_text_field.dart';
export 'atoms/category_badge.dart';
```

- [ ] **Step 4: Move and update the four atom test files**

```bash
mkdir -p test/design_system/atoms
git mv test/design_system/widgets/app_primary_button_test.dart test/design_system/atoms/app_primary_button_test.dart
git mv test/design_system/widgets/app_secondary_button_test.dart test/design_system/atoms/app_secondary_button_test.dart
git mv test/design_system/widgets/app_text_field_test.dart test/design_system/atoms/app_text_field_test.dart
git mv test/design_system/widgets/category_badge_test.dart test/design_system/atoms/category_badge_test.dart
```

`test/design_system/atoms/app_primary_button_test.dart` — change `import 'package:bikedrop/design_system/widgets/app_primary_button.dart';` to `import 'package:bikedrop/design_system/atoms/app_primary_button.dart';`

`test/design_system/atoms/app_secondary_button_test.dart` — change `import 'package:bikedrop/design_system/widgets/app_secondary_button.dart';` to `import 'package:bikedrop/design_system/atoms/app_secondary_button.dart';`

`test/design_system/atoms/app_text_field_test.dart` — change `import 'package:bikedrop/design_system/widgets/app_text_field.dart';` to `import 'package:bikedrop/design_system/atoms/app_text_field.dart';`

`test/design_system/atoms/category_badge_test.dart` — change:
```dart
import 'package:bikedrop/design_system/app_colors.dart';
import 'package:bikedrop/design_system/widgets/category_badge.dart';
```
to:
```dart
import 'package:bikedrop/design_system/tokens/app_colors.dart';
import 'package:bikedrop/design_system/atoms/category_badge.dart';
```

- [ ] **Step 5: Run the atom tests to verify they still pass**

Run: `flutter test test/design_system/atoms/`
Expected: PASS, 4 files, same assertions as before.

- [ ] **Step 6: Commit**

```bash
git add lib/design_system/atoms lib/design_system/design_system.dart test/design_system/atoms
git commit -m "refactor: move button/field/badge widgets into design_system/atoms/"
```

---

### Task 3: Move molecules into `design_system/molecules/`

**Files:**
- Move: `lib/design_system/widgets/list_column_header.dart` → `lib/design_system/molecules/list_column_header.dart`
- Move: `lib/design_system/widgets/app_snackbar.dart` → `lib/design_system/molecules/app_snackbar.dart`
- Move: `lib/widgets/item_list_tile.dart` (empty, 0 bytes) → `lib/design_system/molecules/item_list_tile.dart`
- Modify: `lib/design_system/design_system.dart`
- Move: `test/design_system/widgets/list_column_header_test.dart` → `test/design_system/molecules/list_column_header_test.dart`
- Move: `test/design_system/widgets/app_snackbar_test.dart` → `test/design_system/molecules/app_snackbar_test.dart`

**Interfaces:**
- Consumes: `AppColors`, `AppSpacing`, `AppTypography` from `lib/design_system/tokens/` (Task 1).
- Produces: `ListColumnHeader({required String label})`, `AppSnackbar.show(BuildContext context, String message, {String? actionLabel, VoidCallback? onAction})` — both in `lib/design_system/molecules/`, unchanged signatures. `item_list_tile.dart` stays an empty placeholder (no class defined yet); it is intentionally excluded from the Widgetbook use-case tasks (7-9) since there is nothing to catalog yet.

- [ ] **Step 1: Move the files with git**

```bash
mkdir -p lib/design_system/molecules
git mv lib/design_system/widgets/list_column_header.dart lib/design_system/molecules/list_column_header.dart
git mv lib/design_system/widgets/app_snackbar.dart lib/design_system/molecules/app_snackbar.dart
git mv lib/widgets/item_list_tile.dart lib/design_system/molecules/item_list_tile.dart
```

- [ ] **Step 2: Fix token imports in the two non-empty molecule files**

`lib/design_system/molecules/list_column_header.dart` — change:
```dart
import '../app_colors.dart';
import '../app_spacing.dart';
import '../app_typography.dart';
```
to:
```dart
import '../tokens/app_colors.dart';
import '../tokens/app_spacing.dart';
import '../tokens/app_typography.dart';
```

`lib/design_system/molecules/app_snackbar.dart` — same three-line change (`../app_colors.dart` → `../tokens/app_colors.dart`, `../app_spacing.dart` → `../tokens/app_spacing.dart`, `../app_typography.dart` → `../tokens/app_typography.dart`).

`lib/design_system/molecules/item_list_tile.dart` stays empty — no edit needed.

- [ ] **Step 3: Remove the now-empty `lib/widgets/` directory**

```bash
rmdir lib/widgets
```

- [ ] **Step 4: Update the barrel export**

In `lib/design_system/design_system.dart`, change:
```dart
export 'widgets/app_snackbar.dart';
export 'widgets/delete_confirmation_dialog.dart';
export 'widgets/list_column_header.dart';
```
to (drop the `delete_confirmation_dialog.dart` line here — Task 4 adds it back under `organisms/`; do not export `item_list_tile.dart` yet since the file is empty and has no public symbol):
```dart
export 'molecules/app_snackbar.dart';
export 'molecules/list_column_header.dart';
```

- [ ] **Step 5: Move and update the two molecule test files**

```bash
mkdir -p test/design_system/molecules
git mv test/design_system/widgets/list_column_header_test.dart test/design_system/molecules/list_column_header_test.dart
git mv test/design_system/widgets/app_snackbar_test.dart test/design_system/molecules/app_snackbar_test.dart
```

`test/design_system/molecules/list_column_header_test.dart` — change:
```dart
import 'package:bikedrop/design_system/app_colors.dart';
import 'package:bikedrop/design_system/widgets/list_column_header.dart';
```
to:
```dart
import 'package:bikedrop/design_system/tokens/app_colors.dart';
import 'package:bikedrop/design_system/molecules/list_column_header.dart';
```

`test/design_system/molecules/app_snackbar_test.dart` — change:
```dart
import 'package:bikedrop/design_system/app_colors.dart';
import 'package:bikedrop/design_system/widgets/app_snackbar.dart';
```
to:
```dart
import 'package:bikedrop/design_system/tokens/app_colors.dart';
import 'package:bikedrop/design_system/molecules/app_snackbar.dart';
```

- [ ] **Step 6: Run the molecule tests to verify they still pass**

Run: `flutter test test/design_system/molecules/`
Expected: PASS, 2 files, same assertions as before.

- [ ] **Step 7: Commit**

```bash
git add lib/design_system/molecules lib/design_system/design_system.dart test/design_system/molecules
git add lib/widgets 2>/dev/null || true
git commit -m "refactor: move snackbar/column-header/item-tile into design_system/molecules/"
```

---

### Task 4: Move the organism into `design_system/organisms/`

**Files:**
- Move: `lib/design_system/widgets/delete_confirmation_dialog.dart` → `lib/design_system/organisms/delete_confirmation_dialog.dart`
- Modify: `lib/design_system/design_system.dart`
- Move: `test/design_system/widgets/delete_confirmation_dialog_test.dart` → `test/design_system/organisms/delete_confirmation_dialog_test.dart`

**Interfaces:**
- Consumes: `AppColors`, `AppSpacing`, `AppTypography` from `lib/design_system/tokens/` (Task 1); `AppPrimaryButton`, `AppSecondaryButton` from `lib/design_system/atoms/` (Task 2).
- Produces: `DeleteConfirmationDialog.show(BuildContext context, {String title = 'Löschen?', String message = ''}) → Future<bool>` in `lib/design_system/organisms/`, unchanged signature.

- [ ] **Step 1: Move the file with git**

```bash
mkdir -p lib/design_system/organisms
git mv lib/design_system/widgets/delete_confirmation_dialog.dart lib/design_system/organisms/delete_confirmation_dialog.dart
rmdir lib/design_system/widgets
```

- [ ] **Step 2: Fix imports in the moved file**

In `lib/design_system/organisms/delete_confirmation_dialog.dart`, change:
```dart
import '../app_colors.dart';
import '../app_spacing.dart';
import '../app_typography.dart';
import 'app_primary_button.dart';
import 'app_secondary_button.dart';
```
to:
```dart
import '../tokens/app_colors.dart';
import '../tokens/app_spacing.dart';
import '../tokens/app_typography.dart';
import '../atoms/app_primary_button.dart';
import '../atoms/app_secondary_button.dart';
```

(The button imports change from same-directory `'app_primary_button.dart'` to `'../atoms/app_primary_button.dart'` because the buttons now live in a sibling `atoms/` directory instead of alongside this file.)

- [ ] **Step 3: Update the barrel export**

In `lib/design_system/design_system.dart`, add the organism export (there is no longer a `widgets/` prefix left to reuse — this is a new line since Task 3 dropped the old `widgets/delete_confirmation_dialog.dart` line):

```dart
export 'organisms/delete_confirmation_dialog.dart';
```

Place it after the `molecules/` exports so the barrel reads tokens → atoms → molecules → organisms top to bottom.

- [ ] **Step 4: Move and update the test file**

```bash
mkdir -p test/design_system/organisms
git mv test/design_system/widgets/delete_confirmation_dialog_test.dart test/design_system/organisms/delete_confirmation_dialog_test.dart
```

Change `import 'package:bikedrop/design_system/widgets/delete_confirmation_dialog.dart';` to `import 'package:bikedrop/design_system/organisms/delete_confirmation_dialog.dart';`

- [ ] **Step 5: Remove the now-empty `test/design_system/widgets/` directory**

```bash
rmdir test/design_system/widgets
```

- [ ] **Step 6: Run the organism test to verify it still passes**

Run: `flutter test test/design_system/organisms/`
Expected: PASS, 1 file, same assertions as before.

- [ ] **Step 7: Commit**

```bash
git add lib/design_system/organisms lib/design_system/design_system.dart test/design_system/organisms
git commit -m "refactor: move delete confirmation dialog into design_system/organisms/"
```

---

### Task 5: Rename `lib/screens/` to `lib/features/`

**Files:**
- Move: `lib/screens/login_screen.dart` → `lib/features/login_screen.dart`
- Move: `lib/screens/overview_screen.dart` (empty) → `lib/features/overview_screen.dart`
- Move: `lib/screens/capture_screen.dart` (empty) → `lib/features/capture_screen.dart`
- Move: `lib/screens/item_detail_screen.dart` (empty) → `lib/features/item_detail_screen.dart`
- Modify: `lib/main.dart`
- Move: `test/screens/capture_screen_test.dart` (empty) → `test/features/capture_screen_test.dart`

**Interfaces:**
- Consumes: `package:bikedrop/design_system/design_system.dart` barrel (unchanged public API from Tasks 1–4).
- Produces: `LoginScreen` (StatelessWidget, no constructor args) in `lib/features/login_screen.dart`, imported by `lib/main.dart`.

- [ ] **Step 1: Move the screen files with git**

```bash
mkdir -p lib/features
git mv lib/screens/login_screen.dart lib/features/login_screen.dart
git mv lib/screens/overview_screen.dart lib/features/overview_screen.dart
git mv lib/screens/capture_screen.dart lib/features/capture_screen.dart
git mv lib/screens/item_detail_screen.dart lib/features/item_detail_screen.dart
rmdir lib/screens
```

`lib/features/login_screen.dart` needs no content edit — it already imports the barrel (`package:bikedrop/design_system/design_system.dart`), which keeps the same public API after Tasks 1–4.

- [ ] **Step 2: Update `lib/main.dart`**

Change:
```dart
import 'package:bikedrop/screens/login_screen.dart';
```
to:
```dart
import 'package:bikedrop/features/login_screen.dart';
```

- [ ] **Step 3: Move the screen test file**

```bash
mkdir -p test/features
git mv test/screens/capture_screen_test.dart test/features/capture_screen_test.dart
rmdir test/screens
```

The file is empty — no content edit needed.

- [ ] **Step 4: Run the full test suite to verify nothing broke**

Run: `flutter test`
Expected: PASS for every existing test (the design-system suite from Tasks 1–4, plus `test/widget_test.dart`, which is unrelated to this rename and was already failing/passing independently before this plan — do not fix it as part of this task, it's the stock Flutter counter smoke test).

- [ ] **Step 5: Commit**

```bash
git add lib/features lib/main.dart test/features
git commit -m "refactor: rename lib/screens to lib/features"
```

---

### Task 6: Final verification of the main app after the restructure

**Files:** none (verification only).

- [ ] **Step 1: Run static analysis on the whole project**

Run: `flutter analyze`
Expected: No errors. (Pre-existing warnings unrelated to this refactor, if any, are out of scope.)

- [ ] **Step 2: Run the full test suite**

Run: `flutter test`
Expected: All tests under `test/design_system/` (tokens/atoms/molecules/organisms) and `test/features/` PASS.

- [ ] **Step 3: Confirm no stray references to the old paths remain**

Run:
```bash
grep -rn "design_system/widgets/\|bikedrop/screens/\|design_system/app_colors\.dart\|design_system/app_spacing\.dart\|design_system/app_typography\.dart\|design_system/app_theme\.dart\|'\.\./app_colors\.dart'\|'\.\./app_spacing\.dart'\|'\.\./app_typography\.dart'" lib/ test/ packages/design_system_lint/lib/ --include="*.dart"
```
Expected: No output. This checks for the old flat paths specifically:
- `design_system/widgets/`, `bikedrop/screens/` — directories that no longer exist.
- `design_system/app_colors.dart` (etc., without a `tokens/` segment) — the old flat package-style import used by test files before Task 1. This pattern does **not** match `design_system/tokens/app_colors.dart`, so it won't false-positive on the legitimate same-directory `import 'app_colors.dart';` inside `lib/design_system/tokens/app_typography.dart` / `app_theme.dart` (those keep that import unchanged, correctly, per Task 1 Step 1).
- `'../app_colors.dart'` (etc.) — the old one-level-up relative import used by atom/molecule/organism widgets before Tasks 2–4 added the `tokens/` segment. Does not match the corrected `'../tokens/app_colors.dart'`.

- [ ] **Step 4: Commit (only if any stray references were fixed in Step 3)**

If Step 3 found and required fixing anything, stage and commit those fixes with message `fix: correct remaining design system import paths`. If Step 3 was clean, there is nothing to commit — skip this step.

---

### Task 7: Scaffold the `widgetbook/` Flutter app

**Files:**
- Create: `widgetbook/` (via `flutter create`, full standard Flutter app scaffold)

**Interfaces:**
- Produces: a runnable default Flutter app at `widgetbook/` named `bikedrop_widgetbook`, targeting `web` and `windows`, which Task 8 will repurpose.

- [ ] **Step 1: Generate the app scaffold from the repo root**

```bash
flutter create --platforms=web,windows --project-name bikedrop_widgetbook --org com.example widgetbook
```

- [ ] **Step 2: Verify the default scaffold analyzes and its default test passes**

```bash
cd widgetbook && flutter analyze && flutter test && cd ..
```
Expected: No analyzer errors; the default `widgetbook/test/widget_test.dart` (stock counter test) passes.

- [ ] **Step 3: Commit the scaffold**

```bash
git add widgetbook
git commit -m "chore: scaffold widgetbook app"
```

---

### Task 8: Wire up Widgetbook dependencies and codegen config

**Files:**
- Modify: `widgetbook/pubspec.yaml`
- Create: `widgetbook/build.yaml`

**Interfaces:**
- Produces: `widgetbook/pubspec.yaml` with `bikedrop` reachable as `package:bikedrop/design_system/design_system.dart`, and `widgetbook`/`widgetbook_annotation` importable for Task 9 onward.

- [ ] **Step 1: Edit `widgetbook/pubspec.yaml`**

Replace the generated `name:`/`environment:`/`dependencies:`/`dev_dependencies:` sections with:

```yaml
name: bikedrop_widgetbook
description: "Isolated component catalog for the BikeDrop design system."
publish_to: 'none'
version: 1.0.0+1

environment:
  sdk: ^3.8.0-265.0.dev

dependencies:
  flutter:
    sdk: flutter
  bikedrop:
    path: ../
  widgetbook: ^3.0.0
  widgetbook_annotation: ^3.0.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^5.0.0
  build_runner: ^2.4.0
  widgetbook_generator: ^3.0.0
```

Keep the `flutter:` section (assets/`uses-material-design: true`) that `flutter create` generated at the bottom of the file as-is.

- [ ] **Step 2: Create `widgetbook/build.yaml`**

```yaml
targets:
  $default:
    builders:
      widgetbook_generator:
        generate_for:
          - lib/**
```

- [ ] **Step 3: Fetch dependencies**

```bash
cd widgetbook && flutter pub get && cd ..
```
Expected: Resolves successfully. If it fails to resolve `widgetbook`/`widgetbook_generator` because no version satisfies both the lower bound and the installed SDK, re-check `flutter --version` — the constraints in Step 1 are intentionally open-ended (`^3.0.0`) so pub should be able to fall back to an older compatible release automatically; a resolution failure here means the installed Flutter/Dart SDK is older than every published `widgetbook` release supports, which would require upgrading Flutter before continuing.

- [ ] **Step 4: Commit**

```bash
git add widgetbook/pubspec.yaml widgetbook/pubspec.lock widgetbook/build.yaml
git commit -m "chore: add widgetbook dependencies and codegen config"
```

---

### Task 9: Write the Widgetbook app shell

**Files:**
- Modify: `widgetbook/lib/main.dart` (replace generated counter app entirely)
- Delete: `widgetbook/test/widget_test.dart` (stock counter test, no longer applicable)
- Create: `widgetbook/test/widgetbook_app_test.dart`

**Interfaces:**
- Consumes: `AppTheme` from `package:bikedrop/design_system/design_system.dart` (Task 1).
- Produces: `WidgetbookApp` (StatelessWidget) in `widgetbook/lib/main.dart`, the root widget every use-case in Tasks 10–12 gets cataloged under. Also produces `lib/main.directories.g.dart` once codegen runs (Step 3), imported by `main.dart`.

- [ ] **Step 1: Replace `widgetbook/lib/main.dart`**

```dart
import 'package:bikedrop/design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';

import 'main.directories.g.dart';

void main() {
  runApp(const WidgetbookApp());
}

class WidgetbookApp extends StatelessWidget {
  const WidgetbookApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Widgetbook.material(
      directories: directories,
      addons: [
        DeviceFrameAddon(
          devices: [Devices.ios.iPhone13, Devices.android.samsungGalaxyA50],
        ),
        TextScaleAddon(min: 1, max: 2),
        ThemeAddon<ThemeData>(
          themes: [
            WidgetbookTheme(name: 'BikeDrop', data: AppTheme.light()),
          ],
          themeBuilder: (context, theme, child) => Theme(
            data: theme,
            child: child,
          ),
        ),
      ],
    );
  }
}
```

- [ ] **Step 2: Delete the stock counter test**

```bash
rm widgetbook/test/widget_test.dart
```

- [ ] **Step 3: Run codegen so `main.directories.g.dart` exists**

```bash
cd widgetbook && dart run build_runner build --delete-conflicting-outputs && cd ..
```
Expected: Generates `widgetbook/lib/main.directories.g.dart` exporting a `directories` list (empty, since no `@UseCase` exists yet — Tasks 10–12 add them).

- [ ] **Step 4: Write a smoke test for the app shell**

```dart
// widgetbook/test/widgetbook_app_test.dart
import 'package:bikedrop_widgetbook/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('WidgetbookApp builds without throwing', (tester) async {
    await tester.pumpWidget(const WidgetbookApp());
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
  });
}
```

- [ ] **Step 5: Run analyze and the smoke test**

```bash
cd widgetbook && flutter analyze && flutter test test/widgetbook_app_test.dart && cd ..
```
Expected: No analyzer errors; the smoke test passes.

- [ ] **Step 6: Commit**

```bash
git add widgetbook/lib/main.dart widgetbook/lib/main.directories.g.dart widgetbook/test/widgetbook_app_test.dart
git rm widgetbook/test/widget_test.dart
git commit -m "feat: add Widgetbook app shell with theme/device/text-scale addons"
```

---

### Task 10: Atom use-cases

**Files:**
- Create: `widgetbook/lib/use_cases/atoms/app_primary_button.dart`
- Create: `widgetbook/lib/use_cases/atoms/app_secondary_button.dart`
- Create: `widgetbook/lib/use_cases/atoms/app_text_field.dart`
- Create: `widgetbook/lib/use_cases/atoms/category_badge.dart`

**Interfaces:**
- Consumes: `AppPrimaryButton`, `AppSecondaryButton`, `AppTextField`, `CategoryBadge`, `Category` from `package:bikedrop/design_system/design_system.dart` (Task 2).

- [ ] **Step 1: `widgetbook/lib/use_cases/atoms/app_primary_button.dart`**

```dart
import 'package:bikedrop/design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart' as widgetbook;
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

@widgetbook.UseCase(name: 'Default', type: AppPrimaryButton)
Widget appPrimaryButtonDefault(BuildContext context) {
  return Center(
    child: AppPrimaryButton(
      label: context.knobs.string(label: 'Label', initialValue: 'Speichern'),
      onPressed: () {},
    ),
  );
}

@widgetbook.UseCase(name: 'With icon', type: AppPrimaryButton)
Widget appPrimaryButtonWithIcon(BuildContext context) {
  return Center(
    child: AppPrimaryButton(
      label: context.knobs.string(label: 'Label', initialValue: 'Speichern'),
      icon: Icons.check,
      onPressed: () {},
    ),
  );
}

@widgetbook.UseCase(name: 'Disabled', type: AppPrimaryButton)
Widget appPrimaryButtonDisabled(BuildContext context) {
  return Center(
    child: AppPrimaryButton(
      label: context.knobs.string(label: 'Label', initialValue: 'Speichern'),
      onPressed: null,
    ),
  );
}
```

- [ ] **Step 2: `widgetbook/lib/use_cases/atoms/app_secondary_button.dart`**

```dart
import 'package:bikedrop/design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart' as widgetbook;
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

@widgetbook.UseCase(name: 'Default', type: AppSecondaryButton)
Widget appSecondaryButtonDefault(BuildContext context) {
  return Center(
    child: AppSecondaryButton(
      label: context.knobs.string(label: 'Label', initialValue: 'Abbrechen'),
      onPressed: () {},
    ),
  );
}

@widgetbook.UseCase(name: 'Disabled', type: AppSecondaryButton)
Widget appSecondaryButtonDisabled(BuildContext context) {
  return Center(
    child: AppSecondaryButton(
      label: context.knobs.string(label: 'Label', initialValue: 'Abbrechen'),
      onPressed: null,
    ),
  );
}
```

- [ ] **Step 3: `widgetbook/lib/use_cases/atoms/app_text_field.dart`**

```dart
import 'package:bikedrop/design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart' as widgetbook;
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

@widgetbook.UseCase(name: 'Default', type: AppTextField)
Widget appTextFieldDefault(BuildContext context) {
  return Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: AppTextField(
        label: context.knobs.string(label: 'Label', initialValue: 'Name'),
      ),
    ),
  );
}

@widgetbook.UseCase(name: 'Error', type: AppTextField)
Widget appTextFieldError(BuildContext context) {
  return Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: AppTextField(
        label: context.knobs.string(label: 'Label', initialValue: 'Name'),
        errorText: context.knobs.string(
          label: 'Fehlertext',
          initialValue: 'Pflichtfeld',
        ),
      ),
    ),
  );
}

@widgetbook.UseCase(name: 'Obscured', type: AppTextField)
Widget appTextFieldObscured(BuildContext context) {
  return Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: AppTextField(
        label: context.knobs.string(label: 'Label', initialValue: 'Passwort'),
        obscureText: true,
      ),
    ),
  );
}
```

- [ ] **Step 4: `widgetbook/lib/use_cases/atoms/category_badge.dart`**

```dart
import 'package:bikedrop/design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart' as widgetbook;
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

@widgetbook.UseCase(name: 'Default', type: CategoryBadge)
Widget categoryBadgeDefault(BuildContext context) {
  final category = context.knobs.list<Category>(
    label: 'Kategorie',
    options: Category.values,
    labelBuilder: (category) => category.name,
  );

  return Center(child: CategoryBadge(category: category));
}
```

- [ ] **Step 5: Regenerate and verify**

```bash
cd widgetbook && dart run build_runner build --delete-conflicting-outputs && flutter analyze && cd ..
```
Expected: No errors; `widgetbook/lib/main.directories.g.dart` now contains entries for all 8 atom use-cases (3 + 2 + 3) plus `category_badge`'s.

- [ ] **Step 6: Commit**

```bash
git add widgetbook/lib/use_cases/atoms widgetbook/lib/main.directories.g.dart
git commit -m "feat: add Widgetbook use-cases for atoms"
```

---

### Task 11: Molecule use-cases

**Files:**
- Create: `widgetbook/lib/use_cases/molecules/list_column_header.dart`
- Create: `widgetbook/lib/use_cases/molecules/app_snackbar.dart`

**Interfaces:**
- Consumes: `ListColumnHeader`, `AppSnackbar`, `AppPrimaryButton` from `package:bikedrop/design_system/design_system.dart` (Tasks 2–3).

- [ ] **Step 1: `widgetbook/lib/use_cases/molecules/list_column_header.dart`**

```dart
import 'package:bikedrop/design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart' as widgetbook;
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

@widgetbook.UseCase(name: 'Default', type: ListColumnHeader)
Widget listColumnHeaderDefault(BuildContext context) {
  return Padding(
    padding: const EdgeInsets.all(24),
    child: ListColumnHeader(
      label: context.knobs.string(label: 'Label', initialValue: 'Artikel'),
    ),
  );
}
```

- [ ] **Step 2: `widgetbook/lib/use_cases/molecules/app_snackbar.dart`**

```dart
import 'package:bikedrop/design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart' as widgetbook;
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

@widgetbook.UseCase(name: 'Default', type: AppSnackbar)
Widget appSnackbarDefault(BuildContext context) {
  final message = context.knobs.string(
    label: 'Nachricht',
    initialValue: 'Keine Verbindung',
  );

  return Center(
    child: AppPrimaryButton(
      label: 'Snackbar zeigen',
      onPressed: () => AppSnackbar.show(context, message),
    ),
  );
}

@widgetbook.UseCase(name: 'With action', type: AppSnackbar)
Widget appSnackbarWithAction(BuildContext context) {
  final message = context.knobs.string(
    label: 'Nachricht',
    initialValue: 'Keine Verbindung',
  );
  final actionLabel = context.knobs.string(
    label: 'Aktion-Label',
    initialValue: 'Erneut versuchen',
  );

  return Center(
    child: AppPrimaryButton(
      label: 'Snackbar zeigen',
      onPressed: () => AppSnackbar.show(
        context,
        message,
        actionLabel: actionLabel,
        onAction: () {},
      ),
    ),
  );
}
```

- [ ] **Step 3: Regenerate and verify**

```bash
cd widgetbook && dart run build_runner build --delete-conflicting-outputs && flutter analyze && cd ..
```
Expected: No errors; `main.directories.g.dart` now also lists `list_column_header` (1 use-case) and `app_snackbar` (2 use-cases).

- [ ] **Step 4: Widget test that the snackbar use-case actually shows the snackbar**

```dart
// widgetbook/test/use_cases/app_snackbar_use_case_test.dart
import 'package:bikedrop_widgetbook/use_cases/molecules/app_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:widgetbook/widgetbook.dart';

void main() {
  testWidgets('tapping the trigger button shows the snackbar', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => appSnackbarDefault(context),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Snackbar zeigen'));
    await tester.pumpAndSettle();

    expect(find.text('Keine Verbindung'), findsOneWidget);
  });
}
```

Run: `cd widgetbook && flutter test test/use_cases/app_snackbar_use_case_test.dart && cd ..`
Expected: PASS. (Note: `context.knobs.string` falls back to `initialValue` when there is no `WidgetbookState` in the widget tree above it — this is standard Widgetbook knob behavior in plain `MaterialApp` tests, so no `Widgetbook`-specific test harness is required here.)

- [ ] **Step 5: Commit**

```bash
git add widgetbook/lib/use_cases/molecules widgetbook/lib/main.directories.g.dart widgetbook/test/use_cases
git commit -m "feat: add Widgetbook use-cases for molecules"
```

---

### Task 12: Organism use-case

**Files:**
- Create: `widgetbook/lib/use_cases/organisms/delete_confirmation_dialog.dart`
- Create: `widgetbook/test/use_cases/delete_confirmation_dialog_use_case_test.dart`

**Interfaces:**
- Consumes: `DeleteConfirmationDialog`, `AppPrimaryButton` from `package:bikedrop/design_system/design_system.dart` (Tasks 2, 4).

- [ ] **Step 1: `widgetbook/lib/use_cases/organisms/delete_confirmation_dialog.dart`**

```dart
import 'package:bikedrop/design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart' as widgetbook;
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

@widgetbook.UseCase(name: 'Default', type: DeleteConfirmationDialog)
Widget deleteConfirmationDialogDefault(BuildContext context) {
  final title = context.knobs.string(label: 'Titel', initialValue: 'Löschen?');
  final message = context.knobs.string(
    label: 'Nachricht',
    initialValue: 'Artikel wirklich löschen?',
  );

  return Center(
    child: AppPrimaryButton(
      label: 'Dialog öffnen',
      onPressed: () => DeleteConfirmationDialog.show(
        context,
        title: title,
        message: message,
      ),
    ),
  );
}
```

- [ ] **Step 2: Regenerate and verify**

```bash
cd widgetbook && dart run build_runner build --delete-conflicting-outputs && flutter analyze && cd ..
```
Expected: No errors; `main.directories.g.dart` now also lists `delete_confirmation_dialog` (1 use-case).

- [ ] **Step 3: Widget test that the use-case opens the dialog**

```dart
// widgetbook/test/use_cases/delete_confirmation_dialog_use_case_test.dart
import 'package:bikedrop_widgetbook/use_cases/organisms/delete_confirmation_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:widgetbook/widgetbook.dart';

void main() {
  testWidgets('tapping the trigger button opens the dialog', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => deleteConfirmationDialogDefault(context),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Dialog öffnen'));
    await tester.pumpAndSettle();

    expect(find.text('Artikel wirklich löschen?'), findsOneWidget);
  });
}
```

Run: `cd widgetbook && flutter test test/use_cases/delete_confirmation_dialog_use_case_test.dart && cd ..`
Expected: PASS.

- [ ] **Step 4: Commit**

```bash
git add widgetbook/lib/use_cases/organisms widgetbook/lib/main.directories.g.dart widgetbook/test/use_cases/delete_confirmation_dialog_use_case_test.dart
git commit -m "feat: add Widgetbook use-case for delete confirmation dialog"
```

---

### Task 13: Final Widgetbook verification

**Files:** none (verification only).

- [ ] **Step 1: Full analyze + test run inside `widgetbook/`**

```bash
cd widgetbook && flutter analyze && flutter test && cd ..
```
Expected: No errors; all tests (the app shell smoke test from Task 9 and the two use-case interaction tests from Tasks 11–12) pass.

- [ ] **Step 2: Confirm the generated directory tree has all 7 widgets**

Count the `@widgetbook.UseCase` annotations across the source files directly (more reliable than grepping generated-code internals, whose exact symbol names aren't guaranteed):

```bash
grep -rc "@widgetbook.UseCase" widgetbook/lib/use_cases | awk -F: '{sum += $2} END {print sum}'
```
Expected: `13` (3 primary-button + 2 secondary-button + 3 text-field + 1 badge + 1 column-header + 2 snackbar + 1 dialog = 13 use-cases total). Then confirm `widgetbook/lib/main.directories.g.dart` is non-empty and contains no `TODO`/error markers — open it and skim for one `directories` list entry per widget type (7 types).

- [ ] **Step 3: Manual visual check (not automatable — do this yourself)**

```bash
cd widgetbook && flutter run -d chrome
```

Click through the left-hand tree (`atoms` → `molecules` → `organisms`) and confirm every widget renders with the BikeDrop theme applied, the knobs panel lets you edit labels/text live, and the device-frame/text-scale addons work.

- [ ] **Step 4: Final full-repo sanity check**

From the repo root (not inside `widgetbook/`):

```bash
flutter analyze && flutter test
```

Expected: No errors; confirms the main `bikedrop` app is still unaffected by everything added in Tasks 7–12 (the `widgetbook` package only depends on `bikedrop`, never the other way around).

No commit needed for this task — it's pure verification. If Step 1, 2, or 4 surfaces a failure, fix it in place, re-run the relevant command, then commit the fix with an appropriate message before considering the plan complete.
