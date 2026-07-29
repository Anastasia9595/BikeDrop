# Flutter Design System Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build `lib/design_system/` (tokens, ThemeData, component widgets) plus a `custom_lint` package that flags hardcoded colors/text styles, so every new screen or widget in BikeDrop automatically uses only the values from `docs/BikeDrop Design System.md`.

**Architecture:** Pure Dart/Flutter constants (`AppColors`, `AppTypography`, `AppSpacing`) feed a single `AppTheme.light()` `ThemeData`. Standard Material widgets pick up styling automatically via the theme; components the design doc defines beyond standard Material styling (primary/secondary button, category badge, snackbar, delete dialog, list column header) get dedicated widgets in `lib/design_system/widgets/`. A separate local Dart package `packages/design_system_lint` (using `custom_lint_builder`) adds two analyzer lints that flag raw `Color(...)`/`Colors.*` and raw `TextStyle(...)` usage outside the token files.

**Tech Stack:** Flutter/Dart, `flutter_test` (existing dev dependency), `custom_lint` + `custom_lint_builder` (new), `analyzer` (transitive, for the lint package).

## Global Constraints

- All values must match `docs/BikeDrop Design System.md` exactly (hex colors, weights, letter-spacing, px sizes). Where the doc gives a range (e.g. "20–24px", "54–56px"), pick one concrete value inside the range and use it consistently — do not introduce a second value for the same purpose elsewhere.
- No screen/widget may construct `Color(...)`, use `Colors.*`, or construct `TextStyle(...)` directly — always go through `AppColors`/`AppTypography` or the theme.
- `lib/design_system/` structure is fixed: `app_colors.dart`, `app_typography.dart`, `app_spacing.dart`, `app_theme.dart`, `widgets/`, `design_system.dart` (barrel export).
- Font family is `Archivo`, referenced by name in `AppTypography`; the actual `.ttf` files are supplied by the user later under `assets/fonts/` — do not fail if they're missing at build time (Flutter falls back silently).
- The `design_system_lint` package covers exactly two rules: `avoid_hardcoded_colors`, `avoid_hardcoded_text_style`. No spacing/radius lint (see spec, out of scope — high false-positive risk).
- Existing files to migrate: `lib/main.dart` (drop `ColorScheme.fromSeed`, use `AppTheme.light()`), `lib/screens/login_screen.dart` (use `AppTypography`/`AppPrimaryButton`). Other screens (`overview_screen.dart`, `capture_screen.dart`, `item_detail_screen.dart`, `widgets/item_list_tile.dart`) are empty/unused — do not touch them.
- Spec: `docs/superpowers/specs/2026-07-29-flutter-design-system-design.md`.

---

## Task 1: `AppColors` + `Category` enum

**Files:**
- Create: `lib/design_system/app_colors.dart`
- Test: `test/design_system/app_colors_test.dart`

**Interfaces:**
- Produces: `class AppColors` with static `Color` fields: `accent`, `accentHover`, `accentPressed`, `accentTint`, `textPrimary`, `textSecondary`, `textTertiary`, `textQuaternary`, `textQuaternaryLight`, `border`, `divider`, `surface`, `surfaceDark`, `white`, `snackbarBg`, `snackbarAccent`. Static `Map<Category, CategoryColorPair> categoryColors`.
- Produces: `enum Category { bremsen, reifen, eBike, zubehoer, pflege }`
- Produces: `class CategoryColorPair { final Color background; final Color text; const CategoryColorPair(this.background, this.text); }`

- [ ] **Step 1: Write the failing test**

```dart
// test/design_system/app_colors_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bikedrop/design_system/app_colors.dart';

void main() {
  test('core palette matches design doc hex values', () {
    expect(AppColors.accent, const Color(0xFFEC3013));
    expect(AppColors.accentHover, const Color(0xFFDD2B0F));
    expect(AppColors.accentPressed, const Color(0xFFAE1800));
    expect(AppColors.accentTint, const Color(0xFFFFF2EF));
    expect(AppColors.textPrimary, const Color(0xFF201E1D));
    expect(AppColors.textSecondary, const Color(0xFF605D5D));
    expect(AppColors.textTertiary, const Color(0xFF7D7979));
    expect(AppColors.textQuaternary, const Color(0xFF9B9797));
    expect(AppColors.textQuaternaryLight, const Color(0xFFBAB6B6));
    expect(AppColors.border, const Color(0xFFD7D3D3));
    expect(AppColors.divider, const Color(0xFFEAE7E7));
    expect(AppColors.surface, const Color(0xFFF8F4F4));
    expect(AppColors.surfaceDark, const Color(0xFFEAE7E7));
    expect(AppColors.white, const Color(0xFFFFFFFF));
    expect(AppColors.snackbarBg, const Color(0xFF201E1D));
    expect(AppColors.snackbarAccent, const Color(0xFFFF9783));
  });

  test('category color pairs match design doc table', () {
    expect(AppColors.categoryColors[Category.bremsen]!.background, const Color(0xFFFFE0D9));
    expect(AppColors.categoryColors[Category.bremsen]!.text, const Color(0xFF7C1405));
    expect(AppColors.categoryColors[Category.reifen]!.background, const Color(0xFFE2EEFC));
    expect(AppColors.categoryColors[Category.reifen]!.text, const Color(0xFF1A4A8A));
    expect(AppColors.categoryColors[Category.eBike]!.background, const Color(0xFFE6F0E0));
    expect(AppColors.categoryColors[Category.eBike]!.text, const Color(0xFF33591F));
    expect(AppColors.categoryColors[Category.zubehoer]!.background, const Color(0xFFF3E8FB));
    expect(AppColors.categoryColors[Category.zubehoer]!.text, const Color(0xFF5C2A8A));
    expect(AppColors.categoryColors[Category.pflege]!.background, const Color(0xFFFDF1CF));
    expect(AppColors.categoryColors[Category.pflege]!.text, const Color(0xFF8A5A00));
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/design_system/app_colors_test.dart`
Expected: FAIL — `package:bikedrop/design_system/app_colors.dart` doesn't exist.

- [ ] **Step 3: Write the implementation**

```dart
// lib/design_system/app_colors.dart
import 'package:flutter/material.dart';

enum Category { bremsen, reifen, eBike, zubehoer, pflege }

class CategoryColorPair {
  const CategoryColorPair(this.background, this.text);

  final Color background;
  final Color text;
}

class AppColors {
  const AppColors._();

  static const Color accent = Color(0xFFEC3013);
  static const Color accentHover = Color(0xFFDD2B0F);
  static const Color accentPressed = Color(0xFFAE1800);
  static const Color accentTint = Color(0xFFFFF2EF);

  static const Color textPrimary = Color(0xFF201E1D);
  static const Color textSecondary = Color(0xFF605D5D);
  static const Color textTertiary = Color(0xFF7D7979);
  static const Color textQuaternary = Color(0xFF9B9797);
  static const Color textQuaternaryLight = Color(0xFFBAB6B6);

  static const Color border = Color(0xFFD7D3D3);
  static const Color divider = Color(0xFFEAE7E7);
  static const Color surface = Color(0xFFF8F4F4);
  static const Color surfaceDark = Color(0xFFEAE7E7);
  static const Color white = Color(0xFFFFFFFF);

  static const Color snackbarBg = Color(0xFF201E1D);
  static const Color snackbarAccent = Color(0xFFFF9783);

  static const Map<Category, CategoryColorPair> categoryColors = {
    Category.bremsen: CategoryColorPair(Color(0xFFFFE0D9), Color(0xFF7C1405)),
    Category.reifen: CategoryColorPair(Color(0xFFE2EEFC), Color(0xFF1A4A8A)),
    Category.eBike: CategoryColorPair(Color(0xFFE6F0E0), Color(0xFF33591F)),
    Category.zubehoer: CategoryColorPair(Color(0xFFF3E8FB), Color(0xFF5C2A8A)),
    Category.pflege: CategoryColorPair(Color(0xFFFDF1CF), Color(0xFF8A5A00)),
  };
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/design_system/app_colors_test.dart`
Expected: PASS

- [ ] **Step 5: Commit**

```bash
git add lib/design_system/app_colors.dart test/design_system/app_colors_test.dart
git commit -m "Add AppColors design tokens and Category enum"
```

---

## Task 2: `AppTypography` + Archivo font registration

**Files:**
- Create: `lib/design_system/app_typography.dart`
- Modify: `pubspec.yaml`
- Create: `assets/fonts/README.md`
- Test: `test/design_system/app_typography_test.dart`

**Interfaces:**
- Consumes: none
- Produces: `class AppTypography` with static `TextStyle` getters: `screenTitle`, `loginWordmark`, `body`, `fieldLabel`, `sectionKicker`, `buttonLabel`, `listNumber`.

- [ ] **Step 1: Write the failing test**

```dart
// test/design_system/app_typography_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bikedrop/design_system/app_colors.dart';
import 'package:bikedrop/design_system/app_typography.dart';

void main() {
  test('text styles match design doc weights/sizes/spacing', () {
    expect(AppTypography.screenTitle.fontFamily, 'Archivo');
    expect(AppTypography.screenTitle.fontWeight, FontWeight.w800);
    expect(AppTypography.screenTitle.fontSize, 24);
    expect(AppTypography.screenTitle.letterSpacing, closeTo(-0.48, 0.001));

    expect(AppTypography.loginWordmark.fontWeight, FontWeight.w800);
    expect(AppTypography.loginWordmark.fontSize, 44);
    expect(AppTypography.loginWordmark.letterSpacing, closeTo(-1.32, 0.001));

    expect(AppTypography.body.fontWeight, FontWeight.w400);
    expect(AppTypography.body.fontSize, 15);
    expect(AppTypography.body.height, 1.5);

    expect(AppTypography.fieldLabel.fontWeight, FontWeight.w600);
    expect(AppTypography.fieldLabel.fontSize, 13);
    expect(AppTypography.fieldLabel.letterSpacing, closeTo(0.52, 0.001));
    expect(AppTypography.fieldLabel.color, AppColors.textSecondary);

    expect(AppTypography.sectionKicker.fontWeight, FontWeight.w800);
    expect(AppTypography.sectionKicker.fontSize, 11);
    expect(AppTypography.sectionKicker.letterSpacing, closeTo(1.76, 0.001));

    expect(AppTypography.buttonLabel.fontWeight, FontWeight.w800);
    expect(AppTypography.buttonLabel.fontSize, 17);

    expect(AppTypography.listNumber.fontWeight, FontWeight.w800);
    expect(AppTypography.listNumber.fontSize, 18);
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/design_system/app_typography_test.dart`
Expected: FAIL — `package:bikedrop/design_system/app_typography.dart` doesn't exist.

- [ ] **Step 3: Write the implementation**

```dart
// lib/design_system/app_typography.dart
import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTypography {
  const AppTypography._();

  static const String fontFamily = 'Archivo';

  static const TextStyle screenTitle = TextStyle(
    fontFamily: fontFamily,
    fontWeight: FontWeight.w800,
    fontSize: 24,
    letterSpacing: -0.48,
  );

  static const TextStyle loginWordmark = TextStyle(
    fontFamily: fontFamily,
    fontWeight: FontWeight.w800,
    fontSize: 44,
    letterSpacing: -1.32,
  );

  static const TextStyle body = TextStyle(
    fontFamily: fontFamily,
    fontWeight: FontWeight.w400,
    fontSize: 15,
    height: 1.5,
  );

  static const TextStyle fieldLabel = TextStyle(
    fontFamily: fontFamily,
    fontWeight: FontWeight.w600,
    fontSize: 13,
    letterSpacing: 0.52,
    color: AppColors.textSecondary,
  );

  static const TextStyle sectionKicker = TextStyle(
    fontFamily: fontFamily,
    fontWeight: FontWeight.w800,
    fontSize: 11,
    letterSpacing: 1.76,
  );

  static const TextStyle buttonLabel = TextStyle(
    fontFamily: fontFamily,
    fontWeight: FontWeight.w800,
    fontSize: 17,
  );

  static const TextStyle listNumber = TextStyle(
    fontFamily: fontFamily,
    fontWeight: FontWeight.w800,
    fontSize: 18,
  );
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/design_system/app_typography_test.dart`
Expected: PASS

- [ ] **Step 5: Register the Archivo font family in `pubspec.yaml`**

In `pubspec.yaml`, under the existing `flutter:` section (after `uses-material-design: true`), add:

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

- [ ] **Step 6: Add a placeholder note for the font files**

```markdown
<!-- assets/fonts/README.md -->
# Archivo font files

Download Archivo (weights 400/500/600/700/800) from Google Fonts and place the
`.ttf` files here with these exact names, matching the `pubspec.yaml` entry:

- Archivo-Regular.ttf (400)
- Archivo-Medium.ttf (500)
- Archivo-SemiBold.ttf (600)
- Archivo-Bold.ttf (700)
- Archivo-ExtraBold.ttf (800)

Without these files the app falls back to the platform default font — it still
builds and runs.
```

- [ ] **Step 7: Verify `pubspec.yaml` is still valid**

Run: `flutter pub get`
Expected: completes without error (missing font asset files do not fail `pub get` or `flutter run`, only a missing *asset* referenced in `assets:` would — `fonts:` entries degrade gracefully).

- [ ] **Step 8: Commit**

```bash
git add lib/design_system/app_typography.dart test/design_system/app_typography_test.dart pubspec.yaml assets/fonts/README.md
git commit -m "Add AppTypography design tokens and register Archivo font family"
```

---

## Task 3: `AppSpacing`

**Files:**
- Create: `lib/design_system/app_spacing.dart`
- Test: `test/design_system/app_spacing_test.dart`

**Interfaces:**
- Produces: `class AppSpacing` with static `double` fields: `screenPaddingH`, `cardRadius`, `buttonRadius`, `dialogRadius`, `photoTileRadius`, `fieldHeight`, `fieldBorderWidth`, `primaryButtonHeight`, `minTapTarget`, `switchTrackWidth`, `switchTrackHeight`, `switchThumbSize`, `listRowPaddingV`, `listRowGap`, `snackbarBottomOffset`, `dividerWeight`.

- [ ] **Step 1: Write the failing test**

```dart
// test/design_system/app_spacing_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:bikedrop/design_system/app_spacing.dart';

void main() {
  test('spacing tokens match design doc values', () {
    expect(AppSpacing.screenPaddingH, 20.0);
    expect(AppSpacing.cardRadius, 14.0);
    expect(AppSpacing.buttonRadius, 14.0);
    expect(AppSpacing.dialogRadius, 22.0);
    expect(AppSpacing.photoTileRadius, 16.0);
    expect(AppSpacing.fieldHeight, 56.0);
    expect(AppSpacing.fieldBorderWidth, 1.5);
    expect(AppSpacing.primaryButtonHeight, 60.0);
    expect(AppSpacing.minTapTarget, 44.0);
    expect(AppSpacing.switchTrackWidth, 58.0);
    expect(AppSpacing.switchTrackHeight, 34.0);
    expect(AppSpacing.switchThumbSize, 28.0);
    expect(AppSpacing.listRowPaddingV, 12.0);
    expect(AppSpacing.listRowGap, 12.0);
    expect(AppSpacing.snackbarBottomOffset, 136.0);
    expect(AppSpacing.dividerWeight, 2.0);
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/design_system/app_spacing_test.dart`
Expected: FAIL — `package:bikedrop/design_system/app_spacing.dart` doesn't exist.

- [ ] **Step 3: Write the implementation**

```dart
// lib/design_system/app_spacing.dart
class AppSpacing {
  const AppSpacing._();

  static const double screenPaddingH = 20.0;
  static const double cardRadius = 14.0;
  static const double buttonRadius = 14.0;
  static const double dialogRadius = 22.0;
  static const double photoTileRadius = 16.0;
  static const double fieldHeight = 56.0;
  static const double fieldBorderWidth = 1.5;
  static const double primaryButtonHeight = 60.0;
  static const double minTapTarget = 44.0;
  static const double switchTrackWidth = 58.0;
  static const double switchTrackHeight = 34.0;
  static const double switchThumbSize = 28.0;
  static const double listRowPaddingV = 12.0;
  static const double listRowGap = 12.0;
  static const double snackbarBottomOffset = 136.0;
  static const double dividerWeight = 2.0;
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/design_system/app_spacing_test.dart`
Expected: PASS

- [ ] **Step 5: Commit**

```bash
git add lib/design_system/app_spacing.dart test/design_system/app_spacing_test.dart
git commit -m "Add AppSpacing design tokens"
```

---

## Task 4: `AppTheme` + barrel export

**Files:**
- Create: `lib/design_system/app_theme.dart`
- Create: `lib/design_system/design_system.dart`
- Test: `test/design_system/app_theme_test.dart`

**Interfaces:**
- Consumes: `AppColors` (Task 1), `AppTypography` (Task 2), `AppSpacing` (Task 3).
- Produces: `class AppTheme { static ThemeData light(); }`
- Produces: barrel file `design_system.dart` exporting `app_colors.dart`, `app_typography.dart`, `app_spacing.dart`, `app_theme.dart`, and everything under `widgets/` (populated in later tasks; safe to list now, files will exist by the time this barrel is used).

- [ ] **Step 1: Write the failing test**

```dart
// test/design_system/app_theme_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bikedrop/design_system/app_colors.dart';
import 'package:bikedrop/design_system/app_spacing.dart';
import 'package:bikedrop/design_system/app_theme.dart';

void main() {
  test('AppTheme.light wires tokens into ThemeData', () {
    final theme = AppTheme.light();

    expect(theme.colorScheme.primary, AppColors.accent);
    expect(theme.colorScheme.error, AppColors.accent);
    expect(theme.colorScheme.surface, AppColors.white);
    expect(theme.scaffoldBackgroundColor, AppColors.surface);
    expect(theme.dividerTheme.color, AppColors.divider);
    expect(theme.dividerTheme.thickness, AppSpacing.dividerWeight);

    final inputBorder = theme.inputDecorationTheme.enabledBorder as OutlineInputBorder;
    expect(inputBorder.borderSide.color, AppColors.border);
    expect(inputBorder.borderSide.width, AppSpacing.fieldBorderWidth);
    expect(inputBorder.borderRadius, BorderRadius.circular(AppSpacing.buttonRadius));

    expect(theme.snackBarTheme.backgroundColor, AppColors.snackbarBg);
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/design_system/app_theme_test.dart`
Expected: FAIL — `package:bikedrop/design_system/app_theme.dart` doesn't exist.

- [ ] **Step 3: Write the implementation**

```dart
// lib/design_system/app_theme.dart
import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_spacing.dart';
import 'app_typography.dart';

class AppTheme {
  const AppTheme._();

  static ThemeData light() {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.accent,
      brightness: Brightness.light,
    ).copyWith(
      primary: AppColors.accent,
      error: AppColors.accent,
      surface: AppColors.white,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.surface,
      fontFamily: AppTypography.fontFamily,
      textTheme: const TextTheme(
        titleLarge: AppTypography.screenTitle,
        displayLarge: AppTypography.loginWordmark,
        bodyMedium: AppTypography.body,
        labelSmall: AppTypography.fieldLabel,
        labelLarge: AppTypography.buttonLabel,
      ),
      dividerTheme: DividerThemeData(
        color: AppColors.divider,
        thickness: AppSpacing.dividerWeight,
        space: AppSpacing.dividerWeight,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accent,
          foregroundColor: AppColors.white,
          minimumSize: Size.fromHeight(AppSpacing.primaryButtonHeight),
          textStyle: AppTypography.buttonLabel,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.buttonRadius),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.textPrimary,
          side: BorderSide(color: AppColors.border, width: AppSpacing.fieldBorderWidth),
          minimumSize: Size.fromHeight(AppSpacing.primaryButtonHeight),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.buttonRadius),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: false,
        contentPadding: EdgeInsets.symmetric(
          horizontal: AppSpacing.screenPaddingH,
          vertical: (AppSpacing.fieldHeight - AppTypography.body.fontSize!) / 2,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.buttonRadius),
          borderSide: BorderSide(color: AppColors.border, width: AppSpacing.fieldBorderWidth),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.buttonRadius),
          borderSide: BorderSide(color: AppColors.accent, width: AppSpacing.fieldBorderWidth),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.buttonRadius),
          borderSide: BorderSide(color: AppColors.accent, width: AppSpacing.fieldBorderWidth),
        ),
        labelStyle: AppTypography.fieldLabel,
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected) ? AppColors.white : AppColors.white,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (states) =>
              states.contains(WidgetState.selected) ? AppColors.accent : AppColors.border,
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.snackbarBg,
        contentTextStyle: AppTypography.body.copyWith(color: AppColors.white),
        actionTextColor: AppColors.snackbarAccent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
```

```dart
// lib/design_system/design_system.dart
export 'app_colors.dart';
export 'app_typography.dart';
export 'app_spacing.dart';
export 'app_theme.dart';
export 'widgets/app_primary_button.dart';
export 'widgets/app_secondary_button.dart';
export 'widgets/app_text_field.dart';
export 'widgets/category_badge.dart';
export 'widgets/app_snackbar.dart';
export 'widgets/delete_confirmation_dialog.dart';
export 'widgets/list_column_header.dart';
```

Note: the barrel file references `widgets/*.dart` files that don't exist yet — they're created in Tasks 6–12. This means `design_system.dart` will not compile in isolation until then. Do not add `design_system.dart` to any `import` statement before Task 12 is done; the barrel file itself can exist (it's just an export list) but is only actually imported once all widgets exist.

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/design_system/app_theme_test.dart`
Expected: PASS

- [ ] **Step 5: Commit**

```bash
git add lib/design_system/app_theme.dart lib/design_system/design_system.dart test/design_system/app_theme_test.dart
git commit -m "Add AppTheme and design system barrel export"
```

---

## Task 5: Migrate `main.dart` to `AppTheme`

**Files:**
- Modify: `lib/main.dart:14-19`

**Interfaces:**
- Consumes: `AppTheme.light()` (Task 4).

- [ ] **Step 1: Replace the placeholder theme**

In `lib/main.dart`, replace:

```dart
      theme: ThemeData(
       
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
```

with:

```dart
      theme: AppTheme.light(),
```

and add the import at the top:

```dart
import 'package:bikedrop/design_system/app_theme.dart';
```

- [ ] **Step 2: Verify the app still analyzes and builds**

Run: `flutter analyze lib/main.dart`
Expected: `No issues found!`

- [ ] **Step 3: Commit**

```bash
git add lib/main.dart
git commit -m "Wire main.dart to AppTheme instead of the default deepPurple seed"
```

---

## Task 6: `AppPrimaryButton`

**Files:**
- Create: `lib/design_system/widgets/app_primary_button.dart`
- Test: `test/design_system/widgets/app_primary_button_test.dart`

**Interfaces:**
- Consumes: `AppColors`, `AppSpacing`, `AppTypography`.
- Produces: `class AppPrimaryButton extends StatelessWidget { const AppPrimaryButton({required String label, required VoidCallback? onPressed, IconData? icon, super.key}); }`

- [ ] **Step 1: Write the failing test**

```dart
// test/design_system/widgets/app_primary_button_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bikedrop/design_system/widgets/app_primary_button.dart';

void main() {
  testWidgets('renders label and calls onPressed when tapped', (tester) async {
    var tapped = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AppPrimaryButton(
            label: 'Speichern',
            onPressed: () => tapped = true,
          ),
        ),
      ),
    );

    expect(find.text('Speichern'), findsOneWidget);
    await tester.tap(find.byType(AppPrimaryButton));
    expect(tapped, isTrue);
  });

  testWidgets('does not call onPressed when disabled', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AppPrimaryButton(label: 'Speichern', onPressed: null),
        ),
      ),
    );

    final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
    expect(button.onPressed, isNull);
  });

  testWidgets('shows icon when provided', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AppPrimaryButton(label: 'Speichern', icon: Icons.check, onPressed: () {}),
        ),
      ),
    );

    expect(find.byIcon(Icons.check), findsOneWidget);
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/design_system/widgets/app_primary_button_test.dart`
Expected: FAIL — `package:bikedrop/design_system/widgets/app_primary_button.dart` doesn't exist.

- [ ] **Step 3: Write the implementation**

```dart
// lib/design_system/widgets/app_primary_button.dart
import 'package:flutter/material.dart';
import '../app_colors.dart';
import '../app_spacing.dart';
import '../app_typography.dart';

class AppPrimaryButton extends StatelessWidget {
  const AppPrimaryButton({required this.label, required this.onPressed, this.icon, super.key});

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final disabled = onPressed == null;

    return Opacity(
      opacity: disabled ? 0.45 : 1.0,
      child: Container(
        height: AppSpacing.primaryButtonHeight,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppSpacing.buttonRadius),
          boxShadow: disabled
              ? const []
              : [
                  BoxShadow(
                    color: AppColors.accent.withValues(alpha: 0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 9),
                  ),
                ],
        ),
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.accent,
            disabledBackgroundColor: AppColors.accent,
            foregroundColor: AppColors.white,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSpacing.buttonRadius),
            ),
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.screenPaddingH),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: AppTypography.buttonLabel.copyWith(color: AppColors.white)),
              if (icon != null) Icon(icon, color: AppColors.white),
            ],
          ),
        ),
      ),
    );
  }
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/design_system/widgets/app_primary_button_test.dart`
Expected: PASS

- [ ] **Step 5: Commit**

```bash
git add lib/design_system/widgets/app_primary_button.dart test/design_system/widgets/app_primary_button_test.dart
git commit -m "Add AppPrimaryButton design system widget"
```

---

## Task 7: `AppSecondaryButton`

**Files:**
- Create: `lib/design_system/widgets/app_secondary_button.dart`
- Test: `test/design_system/widgets/app_secondary_button_test.dart`

**Interfaces:**
- Consumes: `AppColors`, `AppSpacing`.
- Produces: `class AppSecondaryButton extends StatelessWidget { const AppSecondaryButton({required String label, required VoidCallback? onPressed, super.key}); }`

- [ ] **Step 1: Write the failing test**

```dart
// test/design_system/widgets/app_secondary_button_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bikedrop/design_system/widgets/app_secondary_button.dart';

void main() {
  testWidgets('renders label and calls onPressed when tapped', (tester) async {
    var tapped = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AppSecondaryButton(label: 'Abbrechen', onPressed: () => tapped = true),
        ),
      ),
    );

    expect(find.text('Abbrechen'), findsOneWidget);
    await tester.tap(find.byType(AppSecondaryButton));
    expect(tapped, isTrue);
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/design_system/widgets/app_secondary_button_test.dart`
Expected: FAIL — `package:bikedrop/design_system/widgets/app_secondary_button.dart` doesn't exist.

- [ ] **Step 3: Write the implementation**

```dart
// lib/design_system/widgets/app_secondary_button.dart
import 'package:flutter/material.dart';
import '../app_colors.dart';
import '../app_spacing.dart';

class AppSecondaryButton extends StatelessWidget {
  const AppSecondaryButton({required this.label, required this.onPressed, super.key});

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: AppSpacing.primaryButtonHeight,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: AppColors.white,
          foregroundColor: AppColors.textPrimary,
          side: BorderSide(color: AppColors.border, width: AppSpacing.fieldBorderWidth),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.buttonRadius),
          ),
        ),
        child: Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
        ),
      ),
    );
  }
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/design_system/widgets/app_secondary_button_test.dart`
Expected: PASS

- [ ] **Step 5: Commit**

```bash
git add lib/design_system/widgets/app_secondary_button.dart test/design_system/widgets/app_secondary_button_test.dart
git commit -m "Add AppSecondaryButton design system widget"
```

---

## Task 8: `AppTextField`

**Files:**
- Create: `lib/design_system/widgets/app_text_field.dart`
- Test: `test/design_system/widgets/app_text_field_test.dart`

**Interfaces:**
- Consumes: `AppColors`, `AppSpacing`, `AppTypography`.
- Produces: `class AppTextField extends StatelessWidget { const AppTextField({required String label, TextEditingController? controller, String? errorText, bool obscureText = false, TextInputType? keyboardType, ValueChanged<String>? onChanged, super.key}); }`

- [ ] **Step 1: Write the failing test**

```dart
// test/design_system/widgets/app_text_field_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bikedrop/design_system/widgets/app_text_field.dart';

void main() {
  testWidgets('shows label above the field and forwards input', (tester) async {
    String? changed;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AppTextField(
            label: 'Name',
            onChanged: (value) => changed = value,
          ),
        ),
      ),
    );

    expect(find.text('NAME'), findsOneWidget);
    await tester.enterText(find.byType(TextField), 'Kettenöl');
    expect(changed, 'Kettenöl');
  });

  testWidgets('shows error text when provided', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AppTextField(label: 'Name', errorText: 'Pflichtfeld'),
        ),
      ),
    );

    expect(find.text('Pflichtfeld'), findsOneWidget);
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/design_system/widgets/app_text_field_test.dart`
Expected: FAIL — `package:bikedrop/design_system/widgets/app_text_field.dart` doesn't exist.

- [ ] **Step 3: Write the implementation**

```dart
// lib/design_system/widgets/app_text_field.dart
import 'package:flutter/material.dart';
import '../app_colors.dart';
import '../app_spacing.dart';
import '../app_typography.dart';

class AppTextField extends StatelessWidget {
  const AppTextField({
    required this.label,
    this.controller,
    this.errorText,
    this.obscureText = false,
    this.keyboardType,
    this.onChanged,
    super.key,
  });

  final String label;
  final TextEditingController? controller;
  final String? errorText;
  final bool obscureText;
  final TextInputType? keyboardType;
  final ValueChanged<String>? onChanged;

  bool get _hasError => errorText != null && errorText!.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final borderColor = _hasError ? AppColors.accent : AppColors.border;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label.toUpperCase(), style: AppTypography.fieldLabel),
        const SizedBox(height: 6),
        SizedBox(
          height: AppSpacing.fieldHeight,
          child: TextField(
            controller: controller,
            obscureText: obscureText,
            keyboardType: keyboardType,
            onChanged: onChanged,
            style: AppTypography.body.copyWith(color: AppColors.textPrimary),
            decoration: InputDecoration(
              contentPadding: EdgeInsets.symmetric(horizontal: AppSpacing.screenPaddingH),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSpacing.buttonRadius),
                borderSide: BorderSide(color: borderColor, width: AppSpacing.fieldBorderWidth),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSpacing.buttonRadius),
                borderSide: BorderSide(color: borderColor, width: AppSpacing.fieldBorderWidth),
              ),
            ),
          ),
        ),
        if (_hasError) ...[
          const SizedBox(height: 4),
          Text(
            errorText!,
            style: AppTypography.body.copyWith(color: AppColors.accentPressed, fontSize: 12),
          ),
        ],
      ],
    );
  }
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/design_system/widgets/app_text_field_test.dart`
Expected: PASS

- [ ] **Step 5: Commit**

```bash
git add lib/design_system/widgets/app_text_field.dart test/design_system/widgets/app_text_field_test.dart
git commit -m "Add AppTextField design system widget"
```

---

## Task 9: `CategoryBadge`

**Files:**
- Create: `lib/design_system/widgets/category_badge.dart`
- Test: `test/design_system/widgets/category_badge_test.dart`

**Interfaces:**
- Consumes: `AppColors`, `Category` (Task 1).
- Produces: `class CategoryBadge extends StatelessWidget { const CategoryBadge({required Category category, super.key}); }`

- [ ] **Step 1: Write the failing test**

```dart
// test/design_system/widgets/category_badge_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bikedrop/design_system/app_colors.dart';
import 'package:bikedrop/design_system/widgets/category_badge.dart';

void main() {
  testWidgets('renders category label in the matching colors', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: CategoryBadge(category: Category.reifen)),
      ),
    );

    expect(find.text('REIFEN'), findsOneWidget);

    final container = tester.widget<Container>(find.byType(Container));
    final decoration = container.decoration as BoxDecoration;
    expect(decoration.color, AppColors.categoryColors[Category.reifen]!.background);

    final text = tester.widget<Text>(find.text('REIFEN'));
    expect(text.style!.color, AppColors.categoryColors[Category.reifen]!.text);
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/design_system/widgets/category_badge_test.dart`
Expected: FAIL — `package:bikedrop/design_system/widgets/category_badge.dart` doesn't exist.

- [ ] **Step 3: Write the implementation**

```dart
// lib/design_system/widgets/category_badge.dart
import 'package:flutter/material.dart';
import '../app_colors.dart';

class CategoryBadge extends StatelessWidget {
  const CategoryBadge({required this.category, super.key});

  final Category category;

  String get _label => switch (category) {
        Category.bremsen => 'BREMSEN',
        Category.reifen => 'REIFEN',
        Category.eBike => 'E-BIKE',
        Category.zubehoer => 'ZUBEHÖR',
        Category.pflege => 'PFLEGE',
      };

  @override
  Widget build(BuildContext context) {
    final pair = AppColors.categoryColors[category]!;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
      decoration: BoxDecoration(
        color: pair.background,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        _label,
        style: TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 10,
          letterSpacing: 0.4,
          color: pair.text,
        ),
      ),
    );
  }
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/design_system/widgets/category_badge_test.dart`
Expected: PASS

- [ ] **Step 5: Commit**

```bash
git add lib/design_system/widgets/category_badge.dart test/design_system/widgets/category_badge_test.dart
git commit -m "Add CategoryBadge design system widget"
```

---

## Task 10: `AppSnackbar`

**Files:**
- Create: `lib/design_system/widgets/app_snackbar.dart`
- Test: `test/design_system/widgets/app_snackbar_test.dart`

**Interfaces:**
- Consumes: `AppColors`, `AppSpacing`, `AppTypography`.
- Produces: `class AppSnackbar { static void show(BuildContext context, String message, {String? actionLabel, VoidCallback? onAction}); }`

- [ ] **Step 1: Write the failing test**

```dart
// test/design_system/widgets/app_snackbar_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bikedrop/design_system/app_colors.dart';
import 'package:bikedrop/design_system/widgets/app_snackbar.dart';

void main() {
  testWidgets('shows message and triggers action callback', (tester) async {
    var actionTapped = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: ElevatedButton(
                onPressed: () => AppSnackbar.show(
                  context,
                  'Keine Verbindung',
                  actionLabel: 'Erneut versuchen',
                  onAction: () => actionTapped = true,
                ),
                child: const Text('Trigger'),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Trigger'));
    await tester.pump();

    expect(find.text('Keine Verbindung'), findsOneWidget);
    final snackBar = tester.widget<SnackBar>(find.byType(SnackBar));
    expect(snackBar.backgroundColor, AppColors.snackbarBg);

    await tester.tap(find.text('Erneut versuchen'));
    expect(actionTapped, isTrue);
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/design_system/widgets/app_snackbar_test.dart`
Expected: FAIL — `package:bikedrop/design_system/widgets/app_snackbar.dart` doesn't exist.

- [ ] **Step 3: Write the implementation**

```dart
// lib/design_system/widgets/app_snackbar.dart
import 'package:flutter/material.dart';
import '../app_colors.dart';
import '../app_spacing.dart';
import '../app_typography.dart';

class AppSnackbar {
  const AppSnackbar._();

  static void show(
    BuildContext context,
    String message, {
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        content: Text(message, style: AppTypography.body.copyWith(color: AppColors.white)),
        backgroundColor: AppColors.snackbarBg,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        ),
        margin: EdgeInsets.only(
          left: AppSpacing.screenPaddingH,
          right: AppSpacing.screenPaddingH,
          bottom: AppSpacing.snackbarBottomOffset,
        ),
        action: actionLabel != null && onAction != null
            ? SnackBarAction(
                label: actionLabel,
                textColor: AppColors.snackbarAccent,
                onPressed: onAction,
              )
            : null,
      ),
    );
  }
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/design_system/widgets/app_snackbar_test.dart`
Expected: PASS

- [ ] **Step 5: Commit**

```bash
git add lib/design_system/widgets/app_snackbar.dart test/design_system/widgets/app_snackbar_test.dart
git commit -m "Add AppSnackbar design system helper"
```

---

## Task 11: `DeleteConfirmationDialog`

**Files:**
- Create: `lib/design_system/widgets/delete_confirmation_dialog.dart`
- Test: `test/design_system/widgets/delete_confirmation_dialog_test.dart`

**Interfaces:**
- Consumes: `AppColors`, `AppSpacing`, `AppSecondaryButton` (Task 7), `AppPrimaryButton` (Task 6).
- Produces: `class DeleteConfirmationDialog { static Future<bool> show(BuildContext context, {String title = 'Löschen?', String message = ''}); }`

- [ ] **Step 1: Write the failing test**

```dart
// test/design_system/widgets/delete_confirmation_dialog_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bikedrop/design_system/widgets/delete_confirmation_dialog.dart';

void main() {
  testWidgets('returns true when Löschen is tapped', (tester) async {
    bool? result;

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: ElevatedButton(
              onPressed: () async {
                result = await DeleteConfirmationDialog.show(
                  context,
                  message: 'Artikel wirklich löschen?',
                );
              },
              child: const Text('Trigger'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Trigger'));
    await tester.pumpAndSettle();

    expect(find.text('Artikel wirklich löschen?'), findsOneWidget);
    await tester.tap(find.text('Löschen'));
    await tester.pumpAndSettle();

    expect(result, isTrue);
  });

  testWidgets('returns false when Abbrechen is tapped', (tester) async {
    bool? result;

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: ElevatedButton(
              onPressed: () async {
                result = await DeleteConfirmationDialog.show(context, message: 'Sicher?');
              },
              child: const Text('Trigger'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Trigger'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Abbrechen'));
    await tester.pumpAndSettle();

    expect(result, isFalse);
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/design_system/widgets/delete_confirmation_dialog_test.dart`
Expected: FAIL — `package:bikedrop/design_system/widgets/delete_confirmation_dialog.dart` doesn't exist.

- [ ] **Step 3: Write the implementation**

```dart
// lib/design_system/widgets/delete_confirmation_dialog.dart
import 'package:flutter/material.dart';
import '../app_colors.dart';
import '../app_spacing.dart';
import '../app_typography.dart';
import 'app_primary_button.dart';
import 'app_secondary_button.dart';

class DeleteConfirmationDialog {
  const DeleteConfirmationDialog._();

  static Future<bool> show(
    BuildContext context, {
    String title = 'Löschen?',
    String message = '',
  }) async {
    final result = await showDialog<bool>(
      context: context,
      barrierColor: AppColors.textPrimary.withValues(alpha: 0.55),
      builder: (context) => Dialog(
        backgroundColor: AppColors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.dialogRadius),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: AppTypography.screenTitle),
              const SizedBox(height: 12),
              Text(message, style: AppTypography.body.copyWith(color: AppColors.textSecondary)),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: AppSecondaryButton(
                      label: 'Abbrechen',
                      onPressed: () => Navigator.of(context).pop(false),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: AppPrimaryButton(
                      label: 'Löschen',
                      onPressed: () => Navigator.of(context).pop(true),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    return result ?? false;
  }
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/design_system/widgets/delete_confirmation_dialog_test.dart`
Expected: PASS

- [ ] **Step 5: Commit**

```bash
git add lib/design_system/widgets/delete_confirmation_dialog.dart test/design_system/widgets/delete_confirmation_dialog_test.dart
git commit -m "Add DeleteConfirmationDialog design system widget"
```

---

## Task 12: `ListColumnHeader`

**Files:**
- Create: `lib/design_system/widgets/list_column_header.dart`
- Test: `test/design_system/widgets/list_column_header_test.dart`

**Interfaces:**
- Consumes: `AppColors`, `AppSpacing`.
- Produces: `class ListColumnHeader extends StatelessWidget { const ListColumnHeader({required String label, super.key}); }`

- [ ] **Step 1: Write the failing test**

```dart
// test/design_system/widgets/list_column_header_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bikedrop/design_system/app_colors.dart';
import 'package:bikedrop/design_system/widgets/list_column_header.dart';

void main() {
  testWidgets('renders uppercased label and a divider below', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: ListColumnHeader(label: 'Artikel')),
      ),
    );

    expect(find.text('ARTIKEL'), findsOneWidget);
    final divider = tester.widget<Divider>(find.byType(Divider));
    expect(divider.color, AppColors.divider);
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/design_system/widgets/list_column_header_test.dart`
Expected: FAIL — `package:bikedrop/design_system/widgets/list_column_header.dart` doesn't exist.

- [ ] **Step 3: Write the implementation**

```dart
// lib/design_system/widgets/list_column_header.dart
import 'package:flutter/material.dart';
import '../app_colors.dart';
import '../app_spacing.dart';

class ListColumnHeader extends StatelessWidget {
  const ListColumnHeader({required this.label, super.key});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 11,
            color: AppColors.textTertiary,
          ),
        ),
        Divider(color: AppColors.divider, thickness: AppSpacing.dividerWeight),
      ],
    );
  }
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/design_system/widgets/list_column_header_test.dart`
Expected: PASS

- [ ] **Step 5: Verify the full design system barrel now compiles**

Run: `flutter analyze lib/design_system/design_system.dart`
Expected: `No issues found!`

- [ ] **Step 6: Commit**

```bash
git add lib/design_system/widgets/list_column_header.dart test/design_system/widgets/list_column_header_test.dart
git commit -m "Add ListColumnHeader design system widget"
```

---

## Task 13: Migrate `login_screen.dart` to the design system

**Files:**
- Modify: `lib/screens/login_screen.dart`

**Interfaces:**
- Consumes: `AppTypography`, `AppSpacing`, `AppColors`, `AppPrimaryButton` (Task 6), all via `package:bikedrop/design_system/design_system.dart`.

- [ ] **Step 1: Rewrite the screen using design system tokens/widgets**

```dart
// lib/screens/login_screen.dart
import 'package:flutter/material.dart';
import 'package:bikedrop/design_system/design_system.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.screenPaddingH),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text('BikeDrop', style: AppTypography.loginWordmark),
                const SizedBox(height: 16),
                Text(
                  'Willkommen zurück!',
                  style: AppTypography.body.copyWith(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 32),
                AppPrimaryButton(
                  label: 'Login',
                  onPressed: () {
                    // Handle login action
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
```

- [ ] **Step 2: Verify it analyzes cleanly**

Run: `flutter analyze lib/screens/login_screen.dart`
Expected: `No issues found!`

- [ ] **Step 3: Run the existing widget tree smoke test**

Run: `flutter test`
Expected: all tests (Tasks 1–12 plus any pre-existing) PASS.

- [ ] **Step 4: Commit**

```bash
git add lib/screens/login_screen.dart
git commit -m "Migrate login_screen.dart to design system tokens and widgets"
```

---

## Task 14: `design_system_lint` package scaffold + `avoid_hardcoded_colors`

**Files:**
- Create: `packages/design_system_lint/pubspec.yaml`
- Create: `packages/design_system_lint/analysis_options.yaml`
- Create: `packages/design_system_lint/lib/design_system_lint.dart`
- Create: `packages/design_system_lint/lib/src/avoid_hardcoded_colors.dart`
- Create: `packages/design_system_lint/example/pubspec.yaml`
- Create: `packages/design_system_lint/example/analysis_options.yaml`
- Create: `packages/design_system_lint/example/lib/good_colors.dart`
- Create: `packages/design_system_lint/example/lib/bad_colors.dart`

**Interfaces:**
- Produces: a `custom_lint` plugin, `getLintRules()` returning `[AvoidHardcodedColors()]` for now (extended in Task 15).

- [ ] **Step 1: Create the lint package's `pubspec.yaml`**

```yaml
# packages/design_system_lint/pubspec.yaml
name: design_system_lint
description: Custom analyzer lints enforcing BikeDrop's design system tokens.
version: 0.1.0
publish_to: none

environment:
  sdk: ^3.8.0

dependencies:
  analyzer: ^6.4.0
  custom_lint_builder: ^0.6.7

dev_dependencies:
  lints: ^4.0.0
```

- [ ] **Step 2: Create the plugin entrypoint**

```dart
// packages/design_system_lint/lib/design_system_lint.dart
import 'package:custom_lint_builder/custom_lint_builder.dart';
import 'src/avoid_hardcoded_colors.dart';

PluginBase createPlugin() => _DesignSystemLintPlugin();

class _DesignSystemLintPlugin extends PluginBase {
  @override
  List<LintRule> getLintRules(CustomLintConfigs configs) => [
        AvoidHardcodedColors(),
      ];
}
```

- [ ] **Step 3: Write the `avoid_hardcoded_colors` rule**

```dart
// packages/design_system_lint/lib/src/avoid_hardcoded_colors.dart
import 'package:analyzer/error/error.dart' show ErrorSeverity;
import 'package:custom_lint_builder/custom_lint_builder.dart';

class AvoidHardcodedColors extends DartLintRule {
  AvoidHardcodedColors() : super(code: _code);

  static const _code = LintCode(
    name: 'avoid_hardcoded_colors',
    problemMessage:
        'Do not construct Color(...) or use Colors.* outside app_colors.dart. Use AppColors instead.',
    errorSeverity: ErrorSeverity.WARNING,
  );

  bool _isAllowedFile(String path) {
    final normalized = path.replaceAll('\\', '/');
    return normalized.endsWith('lib/design_system/app_colors.dart');
  }

  @override
  void run(CustomLintResolver resolver, ErrorReporter reporter, CustomLintContext context) {
    if (_isAllowedFile(resolver.path)) return;

    context.registry.addInstanceCreationExpression((node) {
      final typeName = node.staticType?.getDisplayString();
      if (typeName == 'Color') {
        reporter.atNode(node, _code);
      }
    });

    context.registry.addPrefixedIdentifier((node) {
      if (node.prefix.name == 'Colors') {
        reporter.atNode(node, _code);
      }
    });
  }
}
```

- [ ] **Step 4: Create an `example/` fixture app that consumes the lint package**

```yaml
# packages/design_system_lint/example/pubspec.yaml
name: design_system_lint_example
publish_to: none
environment:
  sdk: ^3.8.0
dependencies:
  flutter:
    sdk: flutter
dev_dependencies:
  custom_lint: ^0.6.7
  design_system_lint:
    path: ../
```

```yaml
# packages/design_system_lint/example/analysis_options.yaml
analyzer:
  plugins:
    - custom_lint
```

```dart
// packages/design_system_lint/example/lib/good_colors.dart
// No hardcoded colors here — nothing should be flagged.
class NotAColor {
  const NotAColor(this.value);
  final int value;
}

void useIt() {
  const NotAColor(1);
}
```

```dart
// packages/design_system_lint/example/lib/bad_colors.dart
import 'package:flutter/material.dart';

class BadWidget extends StatelessWidget {
  const BadWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF123456), // expect: avoid_hardcoded_colors
      child: const Icon(Icons.star, color: Colors.red), // expect: avoid_hardcoded_colors
    );
  }
}
```

- [ ] **Step 5: Run the lint against the example app and verify it flags `bad_colors.dart` only**

Run:
```bash
cd packages/design_system_lint/example
flutter pub get
dart run custom_lint
```
Expected: output lists two `avoid_hardcoded_colors` findings, both in `lib/bad_colors.dart` (one for `Color(0xFF123456)`, one for `Colors.red`), and none in `lib/good_colors.dart`.

- [ ] **Step 6: Commit**

```bash
cd ../../..
git add packages/design_system_lint
git commit -m "Add design_system_lint package with avoid_hardcoded_colors rule"
```

---

## Task 15: `avoid_hardcoded_text_style` + wire lint into the main app

**Files:**
- Create: `packages/design_system_lint/lib/src/avoid_hardcoded_text_style.dart`
- Modify: `packages/design_system_lint/lib/design_system_lint.dart`
- Create: `packages/design_system_lint/example/lib/good_text_style.dart`
- Create: `packages/design_system_lint/example/lib/bad_text_style.dart`
- Modify: `pubspec.yaml` (bikedrop root)
- Modify: `analysis_options.yaml` (bikedrop root)

**Interfaces:**
- Consumes: `DartLintRule`, `LintCode`, `PluginBase` (same `custom_lint_builder` API as Task 14).
- Produces: `getLintRules()` now returns `[AvoidHardcodedColors(), AvoidHardcodedTextStyle()]`.

- [ ] **Step 1: Write the `avoid_hardcoded_text_style` rule**

```dart
// packages/design_system_lint/lib/src/avoid_hardcoded_text_style.dart
import 'package:analyzer/error/error.dart' show ErrorSeverity;
import 'package:custom_lint_builder/custom_lint_builder.dart';

class AvoidHardcodedTextStyle extends DartLintRule {
  AvoidHardcodedTextStyle() : super(code: _code);

  static const _code = LintCode(
    name: 'avoid_hardcoded_text_style',
    problemMessage:
        'Do not construct TextStyle(...) outside app_typography.dart. Use AppTypography instead.',
    errorSeverity: ErrorSeverity.WARNING,
  );

  bool _isAllowedFile(String path) {
    final normalized = path.replaceAll('\\', '/');
    return normalized.endsWith('lib/design_system/app_typography.dart');
  }

  @override
  void run(CustomLintResolver resolver, ErrorReporter reporter, CustomLintContext context) {
    if (_isAllowedFile(resolver.path)) return;

    context.registry.addInstanceCreationExpression((node) {
      final typeName = node.staticType?.getDisplayString();
      if (typeName == 'TextStyle') {
        reporter.atNode(node, _code);
      }
    });
  }
}
```

- [ ] **Step 2: Register the new rule in the plugin**

```dart
// packages/design_system_lint/lib/design_system_lint.dart
import 'package:custom_lint_builder/custom_lint_builder.dart';
import 'src/avoid_hardcoded_colors.dart';
import 'src/avoid_hardcoded_text_style.dart';

PluginBase createPlugin() => _DesignSystemLintPlugin();

class _DesignSystemLintPlugin extends PluginBase {
  @override
  List<LintRule> getLintRules(CustomLintConfigs configs) => [
        AvoidHardcodedColors(),
        AvoidHardcodedTextStyle(),
      ];
}
```

- [ ] **Step 3: Add fixture files to the example app**

```dart
// packages/design_system_lint/example/lib/good_text_style.dart
// No hardcoded TextStyle here — nothing should be flagged.
String describe() => 'plain string, no styles';
```

```dart
// packages/design_system_lint/example/lib/bad_text_style.dart
import 'package:flutter/material.dart';

class BadText extends StatelessWidget {
  const BadText({super.key});

  @override
  Widget build(BuildContext context) {
    return const Text(
      'hello',
      style: TextStyle(fontSize: 20), // expect: avoid_hardcoded_text_style
    );
  }
}
```

- [ ] **Step 4: Run the lint against the example app and verify both rules fire**

Run:
```bash
cd packages/design_system_lint/example
dart run custom_lint
```
Expected: output lists the two `avoid_hardcoded_colors` findings from Task 14 plus one `avoid_hardcoded_text_style` finding in `lib/bad_text_style.dart`; no findings in either `good_*.dart` file.

- [ ] **Step 5: Wire the lint package into the main `bikedrop` app**

In `pubspec.yaml` (repo root), add to `dev_dependencies`:

```yaml
  custom_lint: ^0.6.7
  design_system_lint:
    path: packages/design_system_lint
```

Create/modify `analysis_options.yaml` at the repo root (create if it doesn't exist; if `flutter_lints` is already included via `include: package:flutter_lints/flutter.yaml`, add the `analyzer:` block alongside it):

```yaml
include: package:flutter_lints/flutter.yaml

analyzer:
  plugins:
    - custom_lint
```

- [ ] **Step 6: Run the lint against the real app and confirm it's clean**

Run:
```bash
cd ../../..
flutter pub get
dart run custom_lint
```
Expected: no findings — by this point `main.dart` (Task 5) and `login_screen.dart` (Task 13) only use design system tokens/widgets, and the token files themselves are excluded by path.

- [ ] **Step 7: Commit**

```bash
git add packages/design_system_lint pubspec.yaml analysis_options.yaml
git commit -m "Add avoid_hardcoded_text_style rule and wire design_system_lint into bikedrop"
```

---

## Task 16: `CLAUDE.md` project rule

**Files:**
- Create: `CLAUDE.md`

- [ ] **Step 1: Write the project instructions file**

```markdown
# BikeDrop

Flutter app (Android/iOS) for goods-receiving ("Warenannahme"). See
`docs/superpowers/specs/2026-07-26-warenannahme-app-design.md` for the app
architecture and `docs/BikeDrop Design System.md` for the visual design
language.

## Design system

All UI code (screens, widgets) MUST use `lib/design_system/` exclusively for
visual values:

- Colors → `AppColors` (`package:bikedrop/design_system/app_colors.dart`)
- Text styles → `AppTypography`
- Spacing/radii/sizes → `AppSpacing`
- Standard-Material-plus components (primary/secondary button, text field,
  category badge, snackbar, delete dialog, list column header) →
  `lib/design_system/widgets/`, import via
  `package:bikedrop/design_system/design_system.dart`

Never construct `Color(...)`, use `Colors.*`, or construct `TextStyle(...)`
directly in screen/widget code — always go through the tokens above or the
app's `ThemeData` (`AppTheme.light()`, wired in `main.dart`). A `custom_lint`
rule (`packages/design_system_lint`) catches the color/text-style cases
automatically (`dart run custom_lint`); spacing/radius values are not
lint-enforced, so apply the same rule by hand for those.

If a screen needs a visual value that doesn't exist yet in `lib/design_system/`,
add it there first (matching `docs/BikeDrop Design System.md`) rather than
inlining it in the screen.
```

- [ ] **Step 2: Commit**

```bash
git add CLAUDE.md
git commit -m "Add CLAUDE.md documenting the design system usage rule"
```

---

## Self-Review Notes

- **Spec coverage:** Tokens (Task 1–3), `AppTheme` (Task 4), barrel export (Task 4), all seven component widgets (Task 6–12), font registration (Task 2), lint package with both rules (Task 14–15), `main.dart`/`login_screen.dart` migration (Task 5, 13), `CLAUDE.md` (Task 16) — all spec sections have a corresponding task.
- **Type consistency:** `AppColors`, `AppTypography`, `AppSpacing`, `Category`, `CategoryColorPair` are defined once in Task 1–3 and referenced with identical names/signatures in every later task.
- **Out of scope confirmed:** no spacing/radius lint rule added; no dark theme; no `.ttf` files created (README placeholder only, Task 2); other screens untouched.
