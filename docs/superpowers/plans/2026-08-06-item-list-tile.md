# ItemListTile Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Implement the `ItemListTile` design-system molecule (a tappable inventory-item card: thumbnail, title, category badge, timestamp, quantity, status icon) and register it in Widgetbook.

**Architecture:** A single `StatelessWidget` in `lib/design_system/molecules/item_list_tile.dart`, built purely from existing design-system tokens (`AppColors`, `AppSpacing`, `AppTypography`) and the existing `CategoryBadge` atom. No new global typography tokens, no data model, no time-formatting logic (caller passes a pre-formatted timestamp string). Registered in the barrel export and given a Widgetbook use case with knobs, matching the existing `CategoryBadge`/`AppPrimaryButton` patterns.

**Tech Stack:** Flutter 3.31, `material_symbols_icons` (`Symbols.image`, `Symbols.visibility`), `widgetbook`/`widgetbook_annotation` + `build_runner` (already configured in `widgetbook/`).

## Global Constraints

- Spec: `docs/superpowers/specs/2026-08-06-item-list-tile-design.md` — this plan implements it exactly, with two deliberate corrections made during planning (see Task 1, Step 3 note and Task 1 icon-size note below) to fix internal inconsistencies found in the spec's literal wording.
- No raw colors/hex values, no raw `TextStyle(...)` construction outside `lib/design_system/tokens/` — only `AppColors`/`AppSpacing`/`AppTypography` tokens and `.copyWith(...)` on existing styles (see `docs/superpowers/specs/2026-07-29-flutter-design-system-design.md`, "Lint-Durchsetzung").
- `timestampLabel` is a plain pre-formatted `String` — no `DateTime`, no relative-time logic inside this widget.
- The eye/status icon (`Symbols.visibility`) is always rendered — no boolean parameter controls its visibility in this version.
- No `InkWell`/tap affordance should exist in the widget tree when `onTap` is `null` (not just an `InkWell` with a `null` callback).

---

### Task 1: `ItemListTile` widget (TDD)

**Files:**
- Create: `lib/design_system/molecules/item_list_tile.dart`
- Modify: `lib/design_system/design_system.dart` (add barrel export)
- Test: `test/design_system/molecules/item_list_tile_test.dart`

**Interfaces:**
- Consumes: `Category` enum + `AppColors.categoryColors` (from `lib/design_system/tokens/app_colors.dart`), `CategoryBadge` (from `lib/design_system/atoms/category_badge.dart`, ctor: `CategoryBadge({required Category category})`), `AppSpacing.{cardRadius, screenPaddingH, listRowPaddingV, listRowGap, photoTileRadius, iconButtonSize}`, `AppTypography.{body, listNumber}` (all `TextStyle`/`double` statics already defined).
- Produces: `ItemListTile` widget with ctor
  ```dart
  ItemListTile({
    required String title,
    required int quantity,
    required Category category,
    required String timestampLabel,
    ImageProvider? image,
    VoidCallback? onTap,
    Key? key,
  })
  ```
  Later tasks (Task 2) construct it exactly with these named parameters.

**Note on deviations from the spec's literal wording** (found while turning the spec into concrete code — both are sizing-only, no behavior change):
1. The spec didn't pin an explicit width/height for the thumbnail square. This plan uses `AppSpacing.iconButtonSize` (48.0) for both dimensions — an existing token, visually consistent with a compact list-row thumbnail.
2. The spec said the status icon should use `size: AppSpacing.iconButtonSize` (48.0), which is a *tap-target* token, not a glyph-size token — at 48px the status icon would render as large as the entire thumbnail, which contradicts the reference screenshot (small icon under the quantity number). This plan instead sizes it from `AppTypography.listNumber.fontSize` (18.0), pairing it visually with the quantity text directly above it — the same "derive icon size from the paired text style's `fontSize`" pattern already used for `AppPrimaryButton`'s icon (`lib/design_system/atoms/app_primary_button.dart:67`).

- [ ] **Step 1: Write the failing tests**

Create `test/design_system/molecules/item_list_tile_test.dart`:

```dart
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:bikedrop/design_system/molecules/item_list_tile.dart';
import 'package:bikedrop/design_system/tokens/app_colors.dart';

// 1x1 transparent PNG, so `Image`/`MemoryImage` can decode it synchronously
// in widget tests without needing real asset/network loading.
final _onePixelPng = base64Decode(
  'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNk+A8AAQUBAScY'
  '42YAAAAASUVORK5CYII=',
);

void main() {
  testWidgets('renders title, quantity and timestamp', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: ItemListTile(
            title: 'Shimano XT Scheibe 203',
            quantity: 12,
            category: Category.bremsen,
            timestampLabel: 'vor 4 Min',
          ),
        ),
      ),
    );

    expect(find.text('Shimano XT Scheibe 203'), findsOneWidget);
    expect(find.text('12'), findsOneWidget);
    expect(find.text('vor 4 Min'), findsOneWidget);
  });

  testWidgets('shows placeholder icon when no image is provided', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: ItemListTile(
            title: 'Kettenöl',
            quantity: 3,
            category: Category.pflege,
            timestampLabel: 'vor 1 Std',
          ),
        ),
      ),
    );

    expect(find.byIcon(Symbols.image), findsOneWidget);
    expect(find.byType(Image), findsNothing);
  });

  testWidgets('shows the image instead of the placeholder when provided', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ItemListTile(
            title: 'Kettenöl',
            quantity: 3,
            category: Category.pflege,
            timestampLabel: 'vor 1 Std',
            image: MemoryImage(_onePixelPng),
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.byType(Image), findsOneWidget);
    expect(find.byIcon(Symbols.image), findsNothing);
  });

  testWidgets('calls onTap when tapped', (tester) async {
    var tapped = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ItemListTile(
            title: 'Bremsbelag',
            quantity: 8,
            category: Category.bremsen,
            timestampLabel: 'vor 2 Min',
            onTap: () => tapped = true,
          ),
        ),
      ),
    );

    await tester.tap(find.byType(ItemListTile));
    expect(tapped, isTrue);
  });

  testWidgets('has no InkWell when onTap is not provided', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: ItemListTile(
            title: 'Bremsbelag',
            quantity: 8,
            category: Category.bremsen,
            timestampLabel: 'vor 2 Min',
          ),
        ),
      ),
    );

    expect(find.byType(InkWell), findsNothing);
  });
}
```

- [ ] **Step 2: Run tests to verify they fail**

Run: `flutter test test/design_system/molecules/item_list_tile_test.dart`
Expected: FAIL — `item_list_tile.dart` doesn't export `ItemListTile` yet (compile error / "Target of URI doesn't exist").

- [ ] **Step 3: Implement `ItemListTile`**

Create `lib/design_system/molecules/item_list_tile.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import '../atoms/category_badge.dart';
import '../tokens/app_colors.dart';
import '../tokens/app_spacing.dart';
import '../tokens/app_typography.dart';

class ItemListTile extends StatelessWidget {
  const ItemListTile({
    required this.title,
    required this.quantity,
    required this.category,
    required this.timestampLabel,
    this.image,
    this.onTap,
    super.key,
  });

  final String title;
  final int quantity;
  final Category category;
  final String timestampLabel;
  final ImageProvider? image;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final thumbnailImage = image;

    final content = Padding(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.screenPaddingH,
        vertical: AppSpacing.listRowPaddingV,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(AppSpacing.photoTileRadius),
            child: Container(
              width: AppSpacing.iconButtonSize,
              height: AppSpacing.iconButtonSize,
              color: AppColors.surface,
              alignment: Alignment.center,
              child: thumbnailImage != null
                  ? Image(image: thumbnailImage, fit: BoxFit.cover)
                  : Icon(Symbols.image, color: AppColors.textQuaternaryLight),
            ),
          ),
          SizedBox(width: AppSpacing.listRowGap),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.body.copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CategoryBadge(category: category),
                    const SizedBox(width: 8),
                    Text(
                      timestampLabel,
                      style: AppTypography.body.copyWith(
                        fontSize: 12,
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(width: AppSpacing.listRowGap),
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$quantity',
                style: AppTypography.listNumber.copyWith(color: AppColors.textPrimary),
              ),
              const SizedBox(height: 4),
              Icon(
                Symbols.visibility,
                size: AppTypography.listNumber.fontSize,
                color: AppColors.accent,
              ),
            ],
          ),
        ],
      ),
    );

    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
      ),
      clipBehavior: Clip.antiAlias,
      child: onTap != null
          ? Material(
              type: MaterialType.transparency,
              child: InkWell(onTap: onTap, child: content),
            )
          : content,
    );
  }
}
```

Add the barrel export — in `lib/design_system/design_system.dart`, add after `export 'molecules/app_snackbar.dart';`:

```dart
export 'molecules/item_list_tile.dart';
```

- [ ] **Step 4: Run tests to verify they pass**

Run: `flutter test test/design_system/molecules/item_list_tile_test.dart`
Expected: PASS (all 5 tests).

- [ ] **Step 5: Static analysis**

Run: `flutter analyze lib/design_system/molecules/item_list_tile.dart lib/design_system/design_system.dart`
Expected: "No issues found!"

- [ ] **Step 6: Commit**

```bash
git add lib/design_system/molecules/item_list_tile.dart lib/design_system/design_system.dart test/design_system/molecules/item_list_tile_test.dart
git commit -m "feat: add ItemListTile design-system molecule"
```

---

### Task 2: Widgetbook registration

**Files:**
- Create: `widgetbook/lib/use_cases/molecules/item_list_tile.dart`
- Modify (generated, no manual edits): `widgetbook/lib/main.directories.g.dart`

**Interfaces:**
- Consumes: `ItemListTile` ctor from Task 1 (exact signature above), `Category` enum (`Category.values`), knob helpers `context.knobs.string`, `context.knobs.int`, `context.knobs.object.dropdown<T>` (already used in `widgetbook/lib/use_cases/atoms/category_badge.dart`).
- Produces: nothing consumed by later tasks — this is the final task in the plan.

- [ ] **Step 1: Create the Widgetbook use case**

Create `widgetbook/lib/use_cases/molecules/item_list_tile.dart`:

```dart
import 'package:bikedrop/design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart' as widgetbook;
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

@widgetbook.UseCase(name: 'Default', type: ItemListTile)
Widget itemListTileDefault(BuildContext context) {
  final category = context.knobs.object.dropdown<Category>(
    label: 'Kategorie',
    options: Category.values,
    labelBuilder: (category) => category.name,
  );

  return Padding(
    padding: const EdgeInsets.all(24),
    child: ItemListTile(
      title: context.knobs.string(
        label: 'Titel',
        initialValue: 'Shimano XT Scheibe 203',
      ),
      quantity: context.knobs.int.input(label: 'Menge', initialValue: 12),
      category: category,
      timestampLabel: context.knobs.string(
        label: 'Zeitstempel',
        initialValue: 'vor 4 Min',
      ),
      onTap: context.knobs.boolean(label: 'Tippbar', initialValue: true)
          ? () {}
          : null,
    ),
  );
}
```

- [ ] **Step 2: Regenerate the Widgetbook directory index**

Run (from the `widgetbook/` directory):
```bash
cd widgetbook
dart run build_runner build --delete-conflicting-outputs
```
Expected: build succeeds; `widgetbook/lib/main.directories.g.dart` is rewritten and now contains a reference to `itemListTileDefault` / `ItemListTile` under the `molecules` group.

- [ ] **Step 3: Verify Widgetbook analyzes cleanly**

Run: `cd widgetbook && flutter analyze lib/use_cases/molecules/item_list_tile.dart lib/main.directories.g.dart`
Expected: "No issues found!"

- [ ] **Step 4: Commit**

```bash
git add widgetbook/lib/use_cases/molecules/item_list_tile.dart widgetbook/lib/main.directories.g.dart
git commit -m "feat: register ItemListTile in Widgetbook"
```
