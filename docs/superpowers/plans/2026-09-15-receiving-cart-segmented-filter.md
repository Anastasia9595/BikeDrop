# Warenkorb-Filter: Chips → exklusive Segmented-Control Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace the two "Ergänzung nötig" / "Vollständige Artikel" filter chips above the receiving cart list with an exclusive segmented control where exactly one of the two views is always shown.

**Architecture:** Extend the existing `AppSegment` atom + `AppSegmentedControl<T>` molecule (already used for the article-form status picker) with an optional colored dot per segment, then swap `KpiFilterRow` for `AppSegmentedControl<bool>` inside `ReceivingCartSheetContent`. The cart's filter state moves from nullable (`bool?`, `null` = both groups shown) to non-nullable (`bool`, always exactly one group shown), with the default segment picked from cart contents until the user taps one explicitly.

**Tech Stack:** Flutter, `flutter_riverpod`, `flutter_test`, Widgetbook (`build_runner`).

## Global Constraints

- Labels use the exact format `"Ergänzung nötig · 2"` / `"Vollständige Artikel · 1"` (middle dot `·`, not a hyphen).
- No pro-segment tinted background — only the status dot carries color; selected/unselected background and text stay the existing `AppSegment` look (`AppColors.textPrimary` pill / white text vs. transparent / `AppColors.textSecondary`).
- Tapping the already-active segment must be a no-op (already true for `AppSegment.onTap: null` when `selected`).
- Default segment on open: "Ergänzung nötig" (`true`), unless that group has 0 items, then "Vollständige Artikel" (`false`). Once the user taps a segment, that choice sticks for the lifetime of the sheet.
- Empty filtered list shows the text `'Keine Artikel in dieser Ansicht.'` (`AppTypography.body`, `AppColors.textSecondary`, no icon) instead of a blank scroll area.
- All existing tests in `test/design_system/organisms/receiving_cart_sheet_test.dart` must stay green (adapted where they reference the removed `KpiFilterRow`).

---

## Task 1: `AppSegment` — optional status dot

**Files:**
- Modify: `lib/design_system/atoms/app_segment.dart`
- Test: `test/design_system/atoms/app_segment_test.dart`

**Interfaces:**
- Produces: `AppSegment({required label, required selected, required onTap, Color? dotColor})` — new optional named param, default `null` (no behavior change for existing callers).

- [ ] **Step 1: Write the failing tests**

First, add this helper to `test/design_system/atoms/app_segment_test.dart` at the top level, right after the existing `_text` helper (line 13):

```dart
Container _dot(WidgetTester tester) => tester.widget<Container>(
  find.byWidgetPredicate(
    (w) =>
        w is Container &&
        w.decoration is BoxDecoration &&
        (w.decoration! as BoxDecoration).shape == BoxShape.circle,
  ),
);
```

Then append these three tests inside `main()`, after the existing `'calls onTap when tapped'` test:

```dart
  testWidgets('renders a colored dot when dotColor is set', (tester) async {
    await tester.pumpWidget(
      _wrap(
        AppSegment(
          label: 'Bestellt',
          selected: false,
          dotColor: Colors.orange,
          onTap: () {},
        ),
      ),
    );

    final decoration = _dot(tester).decoration! as BoxDecoration;
    expect(decoration.color, Colors.orange);
  });

  testWidgets('renders no dot when dotColor is not set', (tester) async {
    await tester.pumpWidget(
      _wrap(AppSegment(label: 'Bestellt', selected: false, onTap: () {})),
    );

    expect(
      find.byWidgetPredicate(
        (w) =>
            w is Container &&
            w.decoration is BoxDecoration &&
            (w.decoration! as BoxDecoration).shape == BoxShape.circle,
      ),
      findsNothing,
    );
  });

  testWidgets('keeps the dot fully colored when selected', (tester) async {
    await tester.pumpWidget(
      _wrap(
        AppSegment(
          label: 'Bestellt',
          selected: true,
          dotColor: Colors.orange,
          onTap: null,
        ),
      ),
    );

    final decoration = _dot(tester).decoration! as BoxDecoration;
    expect(decoration.color, Colors.orange);
  });
```

- [ ] **Step 2: Run tests to verify they fail**

Run: `flutter test test/design_system/atoms/app_segment_test.dart`
Expected: FAIL — `dotColor` is not a defined named parameter on `AppSegment`.

- [ ] **Step 3: Implement `dotColor` on `AppSegment`**

Replace the full contents of `lib/design_system/atoms/app_segment.dart` with:

```dart
// lib/design_system/atoms/app_segment.dart
import 'package:flutter/material.dart';
import '../tokens/app_colors.dart';
import '../tokens/app_spacing.dart';
import '../tokens/app_typography.dart';

class AppSegment extends StatelessWidget {
  const AppSegment({
    required this.label,
    required this.selected,
    required this.onTap,
    this.dotColor,
    super.key,
  });

  final String label;
  final bool selected;

  /// `null` schaltet das Segment inaktiv (z. B. das bereits ausgewählte).
  final VoidCallback? onTap;

  /// Optionaler Status-Punkt vor dem Label (z. B. orange/grün). Traegt in
  /// beiden Zustaenden (ausgewaehlt/nicht ausgewaehlt) die volle Farbe —
  /// nur Hintergrund/Text des Segments aendern sich bei Auswahl.
  final Color? dotColor;

  static const double _dotSize = 8;
  static const double _dotGap = 8;

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(
      AppSpacing.buttonRadius - AppSpacing.fieldBorderWidth,
    );

    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        onTap: onTap,
        borderRadius: borderRadius,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? AppColors.textPrimary : Colors.transparent,
            borderRadius: borderRadius,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (dotColor != null) ...[
                Container(
                  width: _dotSize,
                  height: _dotSize,
                  decoration: BoxDecoration(
                    color: dotColor,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: _dotGap),
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
          ),
        ),
      ),
    );
  }
}
```

- [ ] **Step 4: Run tests to verify they pass**

Run: `flutter test test/design_system/atoms/app_segment_test.dart`
Expected: PASS (all 7 tests — 4 existing + 3 new).

- [ ] **Step 5: Commit**

```bash
git add lib/design_system/atoms/app_segment.dart test/design_system/atoms/app_segment_test.dart
git commit -m "$(cat <<'EOF'
feat: add optional status dot to AppSegment

Co-Authored-By: Claude Sonnet 5 <noreply@anthropic.com>
EOF
)"
```

---

## Task 2: `AppSegmentedControl<T>` — `dotColorBuilder`

**Files:**
- Modify: `lib/design_system/molecules/app_segmented_control.dart`
- Test: `test/design_system/molecules/app_segmented_control_test.dart`

**Interfaces:**
- Consumes: `AppSegment({..., Color? dotColor})` from Task 1.
- Produces: `AppSegmentedControl<T>({..., Color Function(T)? dotColorBuilder})` — new optional named param, default `null`.

- [ ] **Step 1: Write the failing tests**

Add to `test/design_system/molecules/app_segmented_control_test.dart`. First add the import at the top of the file (after the existing `app_segmented_control.dart` import):

```dart
import 'package:bikedrop/design_system/atoms/app_segment.dart';
```

Then append inside `main()`, after the existing `'renders no label when not set'` test:

```dart
  testWidgets('passes dotColor from dotColorBuilder to each segment', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        AppSegmentedControl<_Status>(
          options: _Status.values,
          labelBuilder: (s) => switch (s) {
            _Status.imShop => 'Im Shop',
            _Status.bestellt => 'Bestellt',
            _Status.fehlt => 'Fehlt',
          },
          dotColorBuilder: (s) => switch (s) {
            _Status.imShop => Colors.green,
            _Status.bestellt => Colors.orange,
            _Status.fehlt => Colors.red,
          },
          value: _Status.imShop,
          onChanged: (_) {},
        ),
      ),
    );

    final bestellt = tester.widget<AppSegment>(
      find.byWidgetPredicate((w) => w is AppSegment && w.label == 'Bestellt'),
    );
    expect(bestellt.dotColor, Colors.orange);
  });

  testWidgets('leaves dotColor null when dotColorBuilder is not set', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        AppSegmentedControl<_Status>(
          options: _Status.values,
          labelBuilder: (s) => s.name,
          value: _Status.imShop,
          onChanged: (_) {},
        ),
      ),
    );

    final segment = tester.widget<AppSegment>(
      find.byWidgetPredicate(
        (w) => w is AppSegment && w.label == _Status.bestellt.name,
      ),
    );
    expect(segment.dotColor, isNull);
  });
```

- [ ] **Step 2: Run tests to verify they fail**

Run: `flutter test test/design_system/molecules/app_segmented_control_test.dart`
Expected: FAIL — `dotColorBuilder` is not a defined named parameter on `AppSegmentedControl`.

- [ ] **Step 3: Implement `dotColorBuilder` on `AppSegmentedControl<T>`**

Replace the full contents of `lib/design_system/molecules/app_segmented_control.dart` with:

```dart
// lib/design_system/molecules/app_segmented_control.dart
import 'package:flutter/material.dart';
import '../atoms/app_segment.dart';
import '../tokens/app_colors.dart';
import '../tokens/app_spacing.dart';
import '../tokens/app_typography.dart';

class AppSegmentedControl<T> extends StatelessWidget {
  const AppSegmentedControl({
    required this.options,
    required this.labelBuilder,
    required this.value,
    required this.onChanged,
    this.label,
    this.dotColorBuilder,
    super.key,
  });

  final List<T> options;
  final String Function(T) labelBuilder;
  final T value;
  final ValueChanged<T> onChanged;
  final String? label;

  /// Optionaler Status-Punkt pro Segment (z. B. orange/grün). `null` (Default)
  /// zeigt keine Punkte — unveraendertes Verhalten fuer bestehende Aufrufer.
  final Color Function(T)? dotColorBuilder;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(
            label!.toUpperCase(),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.fieldLabel,
          ),
          const SizedBox(height: AppSpacing.fieldLabelGap),
        ],
        Container(
          height: AppSpacing.fieldHeight,
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppSpacing.buttonRadius),
            border: Border.all(
              color: AppColors.border,
              width: AppSpacing.fieldBorderWidth,
            ),
          ),
          child: Row(
            children: [
              for (final option in options)
                Expanded(
                  child: AppSegment(
                    label: labelBuilder(option),
                    dotColor: dotColorBuilder?.call(option),
                    selected: option == value,
                    onTap: option == value ? null : () => onChanged(option),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
```

- [ ] **Step 4: Run tests to verify they pass**

Run: `flutter test test/design_system/molecules/app_segmented_control_test.dart`
Expected: PASS (all 8 tests — 6 existing + 2 new).

- [ ] **Step 5: Commit**

```bash
git add lib/design_system/molecules/app_segmented_control.dart test/design_system/molecules/app_segmented_control_test.dart
git commit -m "$(cat <<'EOF'
feat: add dotColorBuilder to AppSegmentedControl

Co-Authored-By: Claude Sonnet 5 <noreply@anthropic.com>
EOF
)"
```

---

## Task 3: Widgetbook stories for the new dot

**Files:**
- Modify: `widgetbook/lib/use_cases/atoms/app_segment.dart`
- Modify: `widgetbook/lib/use_cases/molecules/app_segmented_control.dart`

**Interfaces:**
- Consumes: `AppSegment({..., Color? dotColor})` and `AppSegmentedControl<T>({..., Color Function(T)? dotColorBuilder})` from Tasks 1–2.

- [ ] **Step 1: Add a dot knob to the `AppSegment` story**

Replace the full contents of `widgetbook/lib/use_cases/atoms/app_segment.dart` with:

```dart
import 'package:bikedrop/design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart' as widgetbook;
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

@widgetbook.UseCase(name: 'Default', type: AppSegment)
Widget appSegmentDefault(BuildContext context) {
  final selected = context.knobs.boolean(
    label: 'Ausgewählt',
    initialValue: false,
  );
  final withDot = context.knobs.boolean(
    label: 'Mit Status-Punkt',
    initialValue: false,
  );
  final dotColor = context.knobs.color(
    label: 'Punktfarbe',
    initialValue: AppColors.statusColorWarning,
  );

  return Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: SizedBox(
        width: 140,
        height: AppSpacing.fieldHeight,
        child: AppSegment(
          label: context.knobs.string(label: 'Label', initialValue: 'Bestellt'),
          selected: selected,
          dotColor: withDot ? dotColor : null,
          onTap: () {},
        ),
      ),
    ),
  );
}
```

- [ ] **Step 2: Add a `dotColorBuilder` to the `AppSegmentedControl` story**

Replace the full contents of `widgetbook/lib/use_cases/molecules/app_segmented_control.dart` with:

```dart
import 'package:bikedrop/design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart' as widgetbook;
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

@widgetbook.UseCase(name: 'Interactive', type: AppSegmentedControl)
Widget appSegmentedControlInteractive(BuildContext context) {
  final label = context.knobs.string(label: 'Label', initialValue: 'Status');
  final withDots = context.knobs.boolean(
    label: 'Mit Status-Punkten',
    initialValue: false,
  );

  ArticleStatus selected = ArticleStatus.inStock;

  return Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: StatefulBuilder(
        builder:
            (context, setState) => AppSegmentedControl<ArticleStatus>(
              label: label.isEmpty ? null : label,
              options: ArticleStatus.values,
              labelBuilder: (status) => status.label,
              dotColorBuilder: withDots
                  ? (status) => AppColors.statusColors[status]!
                  : null,
              value: selected,
              onChanged: (status) => setState(() => selected = status),
            ),
      ),
    ),
  );
}
```

`AppColors.statusColors` (`lib/design_system/tokens/app_colors.dart:67`) is confirmed to be `Map<ArticleStatus, Color>` — the same map the Overview screen's KPI chips use.

- [ ] **Step 3: Regenerate Widgetbook directories and verify it builds**

Run:
```bash
cd widgetbook && dart run build_runner build --delete-conflicting-outputs && cd ..
```
Expected: build completes with no errors, `widgetbook/lib/main.directories.g.dart` is updated (diff shows no structural change since no new use-case files were added, only knob changes inside existing ones — the generated directory file may be unchanged, that's fine).

Run: `cd widgetbook && flutter analyze && cd ..`
Expected: no new analyzer errors/warnings.

- [ ] **Step 4: Commit**

```bash
git add widgetbook/lib/use_cases/atoms/app_segment.dart widgetbook/lib/use_cases/molecules/app_segmented_control.dart widgetbook/lib/main.directories.g.dart
git commit -m "$(cat <<'EOF'
feat: add status-dot knobs to AppSegment/AppSegmentedControl stories

Co-Authored-By: Claude Sonnet 5 <noreply@anthropic.com>
EOF
)"
```

(Only include `main.directories.g.dart` in the `git add` if `git status` shows it as modified — if the generated file didn't change, drop it from the command.)

---

## Task 4: Swap the filter chips for the segmented control in the receiving cart

**Files:**
- Modify: `lib/design_system/organisms/receiving_cart_sheet_content.dart`
- Modify: `lib/design_system/organisms/receiving_cart_sheet.dart`
- Modify: `test/design_system/organisms/receiving_cart_sheet_test.dart`

**Interfaces:**
- Consumes: `AppSegmentedControl<T>({..., Color Function(T)? dotColorBuilder})` from Task 2.
- Produces: `ReceivingCartSheetContent.groupFilter` is now `bool` (was `bool?`) — any other future caller of this widget must supply a non-null value.

This task changes production code and its test together because `ReceivingCartSheetContent` and `ReceivingCartSheet` share one contract (the non-nullable `groupFilter`) — shipping one without the other doesn't compile.

- [ ] **Step 1: Update `ReceivingCartSheetContent`**

Replace the full contents of `lib/design_system/organisms/receiving_cart_sheet_content.dart` with:

```dart
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../enums/receiving_scan_status.dart';
import '../../models/receivingcartitem.dart';
import '../atoms/app_drag_handle.dart';
import '../atoms/app_icon_button.dart';
import '../atoms/app_primary_button.dart';
import '../molecules/app_segmented_control.dart';
import '../molecules/receiving_cart_item_tile.dart';
import '../tokens/app_colors.dart';
import '../tokens/app_spacing.dart';
import '../tokens/app_typography.dart';

/// Die Liste bekommt bewusst KEINEN Controller vom Sheet — sie verwaltet
/// ihre eigene ScrollPosition und bleibt so rein scrollbar. Ziehen auf einem
/// Item soll nie das Sheet resizen (nur [AppDragHandle] darf das per Drag),
/// dafuer aber ueber Rebuilds hinweg (Peek <-> voll) per [Key] eine stabile
/// Identitaet behalten, damit Flutter die Scroll-Position nicht verwirft.
class ReceivingCartSheetContent extends StatelessWidget {
  const ReceivingCartSheetContent({
    super.key,
    required this.items,
    required this.summary,
    required this.counts,
    required this.groupFilter,
    required this.expanded,
    required this.scrollController,
    required this.onFilterTap,
    required this.onQuantityChanged,
    required this.onAnlegenTap,
    required this.onToggleExpand,
  });

  final List<ReceivingCartItem> items;
  final String summary;
  final Map<ReceivingScanStatus, int> counts;

  /// `true` blendet auf "Ergänzung nötig" ein, `false` auf "Vollständige
  /// Artikel". Es ist immer genau eine der beiden Gruppen sichtbar — kein
  /// "beide" oder "keine".
  final bool groupFilter;
  final bool expanded;
  final ScrollController scrollController;
  final ValueChanged<bool> onFilterTap;
  final void Function(ReceivingCartItem item, int quantity) onQuantityChanged;
  final void Function(ReceivingCartItem item) onAnlegenTap;

  /// Faehrt das Sheet programmatisch auf die volle bzw. Peek-Ansicht — die
  /// Alternative zum Drag-Gestus fuer alle, die lieber tippen.
  final VoidCallback onToggleExpand;

  @override
  Widget build(BuildContext context) {
    final visible = !expanded
        ? _peekOrder(items).take(2).toList()
        : items
              .where((item) => item.scanStatus.needsCompletion == groupFilter)
              .toList();

    return Column(
      children: [
        AppDragHandle(scrollController: scrollController),
        expanded ? _buildExpandedHeader() : _buildPeekHeader(),
        if (expanded) const Divider(height: 1, color: AppColors.listDivider),
        Expanded(
          // Bewusst immer dieselbe CustomScrollView mit demselben [Key] —
          // beim Wechsel Peek <-> voll aendert sich nur die Sliver-Liste
          // (flach vs. gefiltert bzw. Empty State), nicht der Widget-Typ.
          // Wuerde hier je nach [expanded] zwischen z.B. ListView und
          // CustomScrollView gewechselt, wuerde Flutter trotz gleichem Key
          // die Scroll-Position verwerfen, weil sich der runtimeType aendert.
          child: CustomScrollView(
            key: const ValueKey('receiving-cart-list'),
            physics: const ClampingScrollPhysics(),
            slivers: expanded && visible.isEmpty
                ? [_emptyStateSliver()]
                : [_itemSliver(visible)],
          ),
        ),
        if (expanded)
          Padding(
            padding: EdgeInsets.only(
              left: AppSpacing.screenPaddingH,
              right: AppSpacing.screenPaddingH,
              top: 12,
              bottom:
                  AppSpacing.screenPaddingV +
                  MediaQuery.of(context).padding.bottom,
            ),
            child: AppPrimaryButton(
              label: 'Wareneingang abschließen (${items.length} Artikel)',
              onPressed: (counts[ReceivingScanStatus.unknown] ?? 0) > 0
                  ? null
                  : () => Navigator.of(context).pop(),
            ),
          ),
      ],
    );
  }

  /// "Ergaenzung noetig" zuerst, damit die Peek-Vorschau (nur 2 Zeilen)
  /// bevorzugt die Positionen zeigt, die noch eine Aktion brauchen, statt
  /// zufaellig von bereits vollstaendigen Artikeln dominiert zu werden.
  List<ReceivingCartItem> _peekOrder(List<ReceivingCartItem> source) {
    return [
      ...source.where((item) => item.scanStatus.needsCompletion),
      ...source.where((item) => !item.scanStatus.needsCompletion),
    ];
  }

  Widget _emptyStateSliver() {
    return SliverFillRemaining(
      hasScrollBody: false,
      child: Center(
        child: Text(
          'Keine Artikel in dieser Ansicht.',
          style: AppTypography.body.copyWith(color: AppColors.textSecondary),
        ),
      ),
    );
  }

  Widget _itemSliver(List<ReceivingCartItem> section) {
    return SliverList(
      delegate: SliverChildListDelegate([
        for (var i = 0; i < section.length; i++) ...[
          _buildTile(section[i]),
          if (i != section.length - 1)
            const Divider(height: 1, color: AppColors.listDivider),
        ],
      ]),
    );
  }

  Widget _buildTile(ReceivingCartItem item) {
    return ReceivingCartItemTile(
      item: item,
      onQuantityChanged: (q) => onQuantityChanged(item, q),
      onAnlegenTap: () => onAnlegenTap(item),
    );
  }

  Widget _buildPeekHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.screenPaddingH,
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              summary,
              style: AppTypography.body.copyWith(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          AppIconButton(
            icon: Symbols.keyboard_arrow_up,
            tooltip: 'Warenkorb ganz anzeigen',
            onPressed: onToggleExpand,
          ),
        ],
      ),
    );
  }

  Widget _buildExpandedHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenPaddingH,
        0,
        AppSpacing.screenPaddingH,
        8,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Warenkorb',
                  style: AppTypography.heading.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              AppIconButton(
                icon: Symbols.keyboard_arrow_down,
                tooltip: 'Warenkorb einklappen',
                onPressed: onToggleExpand,
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            summary,
            style: AppTypography.body.copyWith(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 12),
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
        ],
      ),
    );
  }
}
```

- [ ] **Step 2: Update `ReceivingCartSheet`**

In `lib/design_system/organisms/receiving_cart_sheet.dart`, apply these changes:

Replace:
```dart
  /// `null` = kein Filter (beide Abschnitte sichtbar), `true`/`false` blendet
  /// auf "Ergänzung nötig" bzw. "Vollständige Artikel" ein.
  bool? _groupFilter;
```
with:
```dart
  /// `null` = Nutzer hat noch nicht manuell gewaehlt; der Default wird dann
  /// bei jedem Build aus dem Warenkorb-Inhalt berechnet (siehe [build]).
  bool? _groupFilterOverride;
```

Replace:
```dart
    final openCount = counts[ReceivingScanStatus.unknown] ?? 0;
    final summary =
        '${items.length} Positionen · $totalQuantity Stk · $openCount offen';
```
with:
```dart
    final openCount = counts[ReceivingScanStatus.unknown] ?? 0;
    final summary =
        '${items.length} Positionen · $totalQuantity Stk · $openCount offen';
    final needsCompletionCount =
        openCount + (counts[ReceivingScanStatus.catalogMatch] ?? 0);
    final groupFilter = _groupFilterOverride ?? (needsCompletionCount > 0);
```

Replace:
```dart
              return ReceivingCartSheetContent(
                items: items,
                summary: summary,
                counts: counts,
                groupFilter: _groupFilter,
                expanded: expanded,
                scrollController: scrollController,
                onFilterTap: (group) => setState(
                  () => _groupFilter = _groupFilter == group ? null : group,
                ),
```
with:
```dart
              return ReceivingCartSheetContent(
                items: items,
                summary: summary,
                counts: counts,
                groupFilter: groupFilter,
                expanded: expanded,
                scrollController: scrollController,
                onFilterTap: (group) =>
                    setState(() => _groupFilterOverride = group),
```

Also update the class-level doc comment (currently says "...Kopfzeile, Filter-Chips, die volle Liste..." at the top of the file) — replace "Filter-Chips" with "Filter-Segmented-Control" there for accuracy:
```dart
/// Persistentes Bottom Sheet ueber dem Wareneingangs-Scanner: zeigt den
/// Warenkorb aus [receivingCartProvider]. Leer -> unsichtbar. Sonst startet
/// es im Peek-Zustand (Vorschau von bis zu 2 Zeilen) und zeigt nach dem
/// Hochziehen Kopfzeile, Filter-Segmented-Control, die volle Liste und den
/// Abschliessen-Button.
```

- [ ] **Step 3: Update the existing test file's `KpiFilterRow` references**

In `test/design_system/organisms/receiving_cart_sheet_test.dart`, replace every occurrence of `find.byType(KpiFilterRow)` with `find.byType(AppSegmentedControl<bool>)`. There are 8 occurrences — the safest way is a project-wide sed scoped to this one file:

```bash
sed -i '' 's/find\.byType(KpiFilterRow)/find.byType(AppSegmentedControl<bool>)/g' test/design_system/organisms/receiving_cart_sheet_test.dart
```

Then update the one test that taps the chip by its bare label, since the label now includes the count. Replace:
```dart
  testWidgets('tapping a filter chip narrows the expanded list', (tester) async {
    await _pump(
      tester,
      seed: [
        _known(ean: '1', quantity: 1),
        const ReceivingCartItem(ean: '978020137962', quantity: 1),
      ],
    );

    await tester.tap(find.byTooltip('Warenkorb ganz anzeigen'));
    await tester.pumpAndSettle();
    expect(find.byType(ReceivingCartItemTile), findsNWidgets(2));

    await tester.tap(find.text('Ergänzung nötig'));
    await tester.pumpAndSettle();

    expect(find.byType(ReceivingCartItemTile), findsNWidgets(1));
    expect(find.text('Unbekannter Artikel'), findsOneWidget);
  });
```
with:
```dart
  testWidgets(
    'tapping a segment narrows the expanded list to that group',
    (tester) async {
      await _pump(
        tester,
        seed: [
          _known(ean: '1', quantity: 1),
          const ReceivingCartItem(ean: '978020137962', quantity: 1),
        ],
      );

      await tester.tap(find.byTooltip('Warenkorb ganz anzeigen'));
      await tester.pumpAndSettle();
      // Default: "Ergänzung nötig" ist aktiv, weil 1 offener Artikel da ist.
      expect(find.byType(ReceivingCartItemTile), findsNWidgets(1));
      expect(find.text('Unbekannter Artikel'), findsOneWidget);

      await tester.tap(find.text('Vollständige Artikel · 1'));
      await tester.pumpAndSettle();

      expect(find.byType(ReceivingCartItemTile), findsNWidgets(1));
      expect(find.text('Artikel 1'), findsOneWidget);
    },
  );
```

(`'Artikel 1'` is the display name `_article(ean: '1', name: 'Artikel $ean')` produces for `_known(ean: '1', ...)` — see the `_article`/`_known` helpers at the top of the test file.)

- [ ] **Step 4: Add new tests for the exclusive/default/empty-state behavior**

Append inside `main()`, after the test from Step 3:

```dart
  testWidgets(
    'defaults to "Vollständige Artikel" when no article needs completion',
    (tester) async {
      await _pump(
        tester,
        seed: [_known(ean: '1', quantity: 1), _known(ean: '2', quantity: 1)],
      );

      await tester.tap(find.byTooltip('Warenkorb ganz anzeigen'));
      await tester.pumpAndSettle();

      expect(find.byType(ReceivingCartItemTile), findsNWidgets(2));
      expect(find.text('Vollständige Artikel · 2'), findsOneWidget);
    },
  );

  testWidgets(
    'tapping the already-active segment does not change the list',
    (tester) async {
      await _pump(
        tester,
        seed: [
          _known(ean: '1', quantity: 1),
          const ReceivingCartItem(ean: '978020137962', quantity: 1),
        ],
      );

      await tester.tap(find.byTooltip('Warenkorb ganz anzeigen'));
      await tester.pumpAndSettle();
      expect(find.byType(ReceivingCartItemTile), findsNWidgets(1));
      expect(find.text('Unbekannter Artikel'), findsOneWidget);

      await tester.tap(find.text('Ergänzung nötig · 1'));
      await tester.pumpAndSettle();

      expect(find.byType(ReceivingCartItemTile), findsNWidgets(1));
      expect(find.text('Unbekannter Artikel'), findsOneWidget);
    },
  );

  testWidgets(
    'switching to a segment with no matching articles shows the empty state',
    (tester) async {
      await _pump(tester, seed: [_known(ean: '1', quantity: 1)]);

      await tester.tap(find.byTooltip('Warenkorb ganz anzeigen'));
      await tester.pumpAndSettle();
      expect(find.text('Vollständige Artikel · 1'), findsOneWidget);

      await tester.tap(find.text('Ergänzung nötig · 0'));
      await tester.pumpAndSettle();

      expect(find.byType(ReceivingCartItemTile), findsNothing);
      expect(find.text('Keine Artikel in dieser Ansicht.'), findsOneWidget);
    },
  );
```

- [ ] **Step 5: Run the full test file**

Run: `flutter test test/design_system/organisms/receiving_cart_sheet_test.dart`
Expected: PASS (all tests, including the 3 new ones).

- [ ] **Step 6: Run `flutter analyze` for the whole `lib/` and `test/` tree**

Run: `flutter analyze`
Expected: no new errors/warnings (in particular: no unused-import warning for the removed `kpi_filter_row.dart`/`list_section_header.dart` imports, no leftover reference to `_groupFilter`).

- [ ] **Step 7: Commit**

```bash
git add lib/design_system/organisms/receiving_cart_sheet_content.dart lib/design_system/organisms/receiving_cart_sheet.dart test/design_system/organisms/receiving_cart_sheet_test.dart
git commit -m "$(cat <<'EOF'
feat: replace receiving cart filter chips with exclusive segmented control

Co-Authored-By: Claude Sonnet 5 <noreply@anthropic.com>
EOF
)"
```

---

## Task 5: Full verification pass

**Files:** none (verification only)

- [ ] **Step 1: Run the entire Flutter test suite**

Run: `flutter test`
Expected: PASS, 0 failures.

- [ ] **Step 2: Run the analyzer on the whole project**

Run: `flutter analyze`
Expected: no errors/warnings.

- [ ] **Step 3: Run the Widgetbook app's analyzer**

Run: `cd widgetbook && flutter analyze && cd ..`
Expected: no errors/warnings.

- [ ] **Step 4: Manual spot-check note**

This plan does not include a manual UI run (no simulator/device in this environment per the plan's authoring context) — if a simulator is available when executing, open the app, add at least one scanned-but-unresolved item and one resolved item to the receiving cart, expand the sheet, and confirm: exactly one segment is always highlighted, tapping the other segment swaps the list instantly, the dot colors match (orange for "Ergänzung nötig", green for "Vollständige Artikel"), and emptying one group via "Anlegen" shows the empty-state text when that segment is tapped.

- [ ] **Step 5: No commit for this task** — it only verifies work already committed in Tasks 1–4.
