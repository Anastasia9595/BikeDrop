# Wareneingang: Warenkorb-Bottom-Sheet Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add a bottom sheet to the Wareneingang scanner screen that fills a cart-like list with a randomly picked article (catalog / own inventory / unknown placeholder) each time one of the three demo scenario buttons is tapped, with a peek/expand interaction, status filter chips, per-row quantity stepper, and a manual-entry path for unknown items.

**Architecture:** A new `autoDispose` Riverpod `Notifier` (`ReceivingCartNotifier`) holds the cart as `List<ReceivingCartItem>` (existing, previously-unused model). `ScannerScreen` gains a generic optional `overlay` slot (a `Stack` over its existing body) so it stays domain-agnostic; the Wareneingang call site in `OverviewScreen` supplies a new `ReceivingCartSheet` organism as that overlay and wires the three fixed demo EANs to the notifier's `addFromCatalog()` / `addFromOwnArticles()` / `addUnknown()` methods. `KpiFilterCard`/`KpiFilterRow` are generalized from `ArticleStatus`-specific to generic label/color/tint entries so both the Overview screen and the new sheet can reuse them unmodified in shape.

**Tech Stack:** Flutter, `flutter_riverpod` ^2.6.1 (plain `Provider`/`NotifierProvider`, no codegen), `material_symbols_icons`, existing hand-rolled design system under `lib/design_system/`.

## Global Constraints

- Scope is **UI/interaction only**: "Wareneingang abschließen" closes the scanner screen; no `ArticleRepository` writes happen from this feature.
- Reuse existing atoms/molecules unmodified where they fit (`QuantityStepper`, `AppPrimaryButton`, `AppSpacing`/`AppColors`/`AppTypography` tokens); only generalize a component when it is genuinely reused, never duplicate a near-identical one.
- Light theme only — reuse the existing `AppColors` tokens, no dark-mode-specific styling.
- Follow existing file/test layout: `test/` mirrors `lib/`; widgetbook use-cases mirror `lib/design_system/` under `widgetbook/lib/use_cases/`.
- Package name is `bikedrop` (imports as `package:bikedrop/...`).
- Random selection must be injectable/deterministic in tests (no direct `Random()` calls inside notifier methods without a seam).

---

### Task 1: `ReceivingScanStatus` enum + status color tokens

**Files:**
- Create: `lib/enums/receiving_scan_status.dart`
- Modify: `lib/design_system/tokens/app_colors.dart`
- Test: `test/enums/receiving_scan_status_test.dart`
- Test: `test/design_system/tokens/app_colors_test.dart` (append)

**Interfaces:**
- Produces: `enum ReceivingScanStatus { inStock, catalogMatch, unknown }`, extension `ReceivingScanStatusLabel.label` (String), extension `ReceivingCartItemScanStatus.scanStatus` on `ReceivingCartItem` (getter returning `ReceivingScanStatus`), `AppColors.receivingStatusColors` (`Map<ReceivingScanStatus, Color>`), `AppColors.receivingStatusTints` (`Map<ReceivingScanStatus, Color>`).
- Consumes: existing `ReceivingCartItem` (`lib/models/receivingcartitem.dart`, fields `resolvedArticle`, `catalogData`).

- [ ] **Step 1: Write the failing test for the enum, label and derived status**

```dart
// test/enums/receiving_scan_status_test.dart
import 'package:bikedrop/enums/receiving_scan_status.dart';
import 'package:bikedrop/models/article.dart';
import 'package:bikedrop/models/catalogarticle.dart';
import 'package:bikedrop/models/receivingcartitem.dart';
import 'package:bikedrop/enums/article_status.dart';
import 'package:bikedrop/enums/category.dart';
import 'package:flutter_test/flutter_test.dart';

Article _article() {
  final now = DateTime(2026, 1, 1);
  return Article(
    ean: '4711234567899',
    name: 'KMC Kette X11',
    category: Category.antrieb,
    quantity: 1,
    minQuantity: 0,
    purchasePrice: 1,
    sellingPrice: 2,
    status: ArticleStatus.inStock,
    createdAt: now,
    updatedAt: now,
  );
}

const _catalogArticle = CatalogArticle(
  name: 'Abus Bordo 6000 Faltschloss 90cm',
  category: Category.zubehoer,
  ean: '4029876501233',
);

void main() {
  test('labels match the German copy', () {
    expect(ReceivingScanStatus.inStock.label, 'Im Bestand');
    expect(ReceivingScanStatus.catalogMatch.label, 'Katalogtreffer');
    expect(ReceivingScanStatus.unknown.label, 'Unbekannt');
  });

  test('a resolved own article is inStock', () {
    final item = ReceivingCartItem(
      ean: '4711234567899',
      quantity: 1,
      resolvedArticle: _article(),
    );
    expect(item.scanStatus, ReceivingScanStatus.inStock);
  });

  test('a catalog-only match is catalogMatch', () {
    final item = ReceivingCartItem(
      ean: '4029876501233',
      quantity: 1,
      catalogData: _catalogArticle,
    );
    expect(item.scanStatus, ReceivingScanStatus.catalogMatch);
  });

  test('neither resolved nor catalog data is unknown', () {
    final item = ReceivingCartItem(ean: '978020137962', quantity: 1);
    expect(item.scanStatus, ReceivingScanStatus.unknown);
  });

  test('a resolved article wins even if catalog data is also set', () {
    final item = ReceivingCartItem(
      ean: '4711234567899',
      quantity: 1,
      resolvedArticle: _article(),
      catalogData: _catalogArticle,
    );
    expect(item.scanStatus, ReceivingScanStatus.inStock);
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/enums/receiving_scan_status_test.dart`
Expected: FAIL — `Target of URI doesn't exist: 'package:bikedrop/enums/receiving_scan_status.dart'`.

- [ ] **Step 3: Create the enum, label and extension**

```dart
// lib/enums/receiving_scan_status.dart
import '../models/receivingcartitem.dart';

/// Auflösungsstatus einer gescannten Position im Wareneingangs-Warenkorb.
/// Anders als [ArticleStatus] (Bestandsstatus eines Artikels) beschreibt
/// dies, WOHER die Zeile ihre Daten hat, nicht ihren Lagerbestand.
enum ReceivingScanStatus { inStock, catalogMatch, unknown }

extension ReceivingScanStatusLabel on ReceivingScanStatus {
  String get label => switch (this) {
    ReceivingScanStatus.inStock => 'Im Bestand',
    ReceivingScanStatus.catalogMatch => 'Katalogtreffer',
    ReceivingScanStatus.unknown => 'Unbekannt',
  };
}

/// Leitet den Scan-Status aus den vorhandenen Daten ab, statt ihn separat
/// zu speichern — [ReceivingCartItem.resolvedArticle]/[catalogData] bleiben
/// die einzige Quelle der Wahrheit.
extension ReceivingCartItemScanStatus on ReceivingCartItem {
  ReceivingScanStatus get scanStatus {
    if (resolvedArticle != null) return ReceivingScanStatus.inStock;
    if (catalogData != null) return ReceivingScanStatus.catalogMatch;
    return ReceivingScanStatus.unknown;
  }
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/enums/receiving_scan_status_test.dart`
Expected: PASS (5 tests)

- [ ] **Step 5: Write the failing test for the AppColors maps**

Append to `test/design_system/tokens/app_colors_test.dart` (add the import and a new `test(...)` inside `main()`, alongside the existing ones):

```dart
import 'package:bikedrop/enums/receiving_scan_status.dart';
```

```dart
  test('receiving scan status colors and tints are defined for all statuses', () {
    for (final status in ReceivingScanStatus.values) {
      expect(AppColors.receivingStatusColors[status], isNotNull, reason: '$status');
      expect(AppColors.receivingStatusTints[status], isNotNull, reason: '$status');
    }
    expect(AppColors.receivingStatusColors[ReceivingScanStatus.inStock], AppColors.statusColorSuccess);
    expect(AppColors.receivingStatusColors[ReceivingScanStatus.catalogMatch], AppColors.infoBlue);
    expect(AppColors.receivingStatusColors[ReceivingScanStatus.unknown], AppColors.statusColorWarning);
  });
```

- [ ] **Step 6: Run test to verify it fails**

Run: `flutter test test/design_system/tokens/app_colors_test.dart`
Expected: FAIL — `receivingStatusColors` isn't defined on `AppColors`.

- [ ] **Step 7: Add the maps to `AppColors`**

In `lib/design_system/tokens/app_colors.dart`, add the import:

```dart
import '../../enums/receiving_scan_status.dart';
```

and, after the existing `statusOnColors` map, add:

```dart
  /// Punktfarbe je [ReceivingScanStatus] im Wareneingangs-Warenkorb —
  /// dieselben Töne wie die Demo-Szenario-Buttons im Scanner-Grid, damit
  /// Button und Zeilen-Icon optisch zusammengehören.
  static const Map<ReceivingScanStatus, Color> receivingStatusColors = {
    ReceivingScanStatus.inStock: statusColorSuccess,
    ReceivingScanStatus.catalogMatch: infoBlue,
    ReceivingScanStatus.unknown: statusColorWarning,
  };

  static const Map<ReceivingScanStatus, Color> receivingStatusTints = {
    ReceivingScanStatus.inStock: Color(0xFFEAF6ED),
    ReceivingScanStatus.catalogMatch: Color(0xFFE2EEFC),
    ReceivingScanStatus.unknown: Color(0xFFF5EDE0),
  };
```

- [ ] **Step 8: Run test to verify it passes**

Run: `flutter test test/design_system/tokens/app_colors_test.dart test/enums/receiving_scan_status_test.dart`
Expected: PASS

- [ ] **Step 9: Commit**

```bash
git add lib/enums/receiving_scan_status.dart lib/design_system/tokens/app_colors.dart test/enums/receiving_scan_status_test.dart test/design_system/tokens/app_colors_test.dart
git commit -m "feat: add ReceivingScanStatus enum and its color tokens"
```

---

### Task 2: `CatalogRepository.getCatalogArticles()`

**Files:**
- Modify: `lib/interface/catalog_interface.dart`
- Modify: `lib/repository/mockcatalog_repository.dart`
- Test: `test/repository/mockcatalog_repository_test.dart` (append)

**Interfaces:**
- Produces: `Future<List<CatalogArticle>> getCatalogArticles()` on `CatalogRepository` / `MockCatalogRepository`.
- Consumes: existing `_ensureLoaded()` cache in `MockCatalogRepository`.

- [ ] **Step 1: Write the failing test**

Append to `test/repository/mockcatalog_repository_test.dart`:

```dart
  test('liefert alle Katalogartikel', () async {
    final repository = MockCatalogRepository();

    final articles = await repository.getCatalogArticles();

    expect(articles, hasLength(8));
    expect(articles.map((a) => a.ean), contains('4029876501233'));
  });

  test('liefert eine unveraenderliche Liste', () async {
    final repository = MockCatalogRepository();

    final articles = await repository.getCatalogArticles();

    expect(() => articles.add(_catalogArticle), throwsUnsupportedError);
  });
```

Add this fixture near the top of the file (below the imports):

```dart
const _catalogArticle = CatalogArticle(
  name: 'Test',
  category: Category.zubehoer,
  ean: '0000000000000',
);
```

and the import:

```dart
import 'package:bikedrop/models/catalogarticle.dart';
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/repository/mockcatalog_repository_test.dart`
Expected: FAIL — `The method 'getCatalogArticles' isn't defined for the type 'MockCatalogRepository'`.

- [ ] **Step 3: Add the method to the interface and the mock**

In `lib/interface/catalog_interface.dart`:

```dart
abstract class CatalogRepository {
  Future<CatalogArticle?> lookupByEan(String ean);

  /// Alle Katalogartikel — genutzt, um im Wareneingangs-Demo-Flow zufaellig
  /// einen Katalogtreffer zu simulieren.
  Future<List<CatalogArticle>> getCatalogArticles();
}
```

In `lib/repository/mockcatalog_repository.dart`, add after `lookupByEan`:

```dart
  @override
  Future<List<CatalogArticle>> getCatalogArticles() async {
    final catalog = await _ensureLoaded();
    return List.unmodifiable(catalog.values);
  }
```

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/repository/mockcatalog_repository_test.dart`
Expected: PASS

- [ ] **Step 5: Commit**

```bash
git add lib/interface/catalog_interface.dart lib/repository/mockcatalog_repository.dart test/repository/mockcatalog_repository_test.dart
git commit -m "feat: add getCatalogArticles to CatalogRepository"
```

---

### Task 3: Generalize `KpiFilterCard`

**Files:**
- Modify: `lib/design_system/atoms/kpi_filter_card.dart`
- Modify: `widgetbook/lib/use_cases/atoms/app_kpi_card.dart`
- Test: `test/design_system/atoms/kpi_filter_card_test.dart` (rewrite)

**Interfaces:**
- Produces: `KpiFilterCard({required int value, required String label, required Color color, required Color tint, bool selected = false, VoidCallback? onTap})` — the `status: ArticleStatus` parameter is removed.

> Note: `test/design_system/atoms/kpi_filter_card_test.dart` currently has 4 pre-existing failing tests (`paints the card in the status color`, `uses dark ink on the yellow "bestellt" card`, `uses white foreground on green and red`, `keeps the icon when the card is wide enough`) — they test an older filled-icon design that a prior refactor (commit `79feb1a`) replaced with the current dot-indicator design, without updating the tests. This task replaces the whole file with tests matching the *current* dot design, generalized. Confirm this pre-existing breakage first:

- [ ] **Step 1: Confirm the pre-existing failures (baseline, not caused by this task)**

Run: `flutter test test/design_system/atoms/kpi_filter_card_test.dart`
Expected: 4 pre-existing FAILs (as listed above), 6 PASS — this is the state before this task's changes.

- [ ] **Step 2: Rewrite the test file for the generalized, dot-indicator API**

```dart
// test/design_system/atoms/kpi_filter_card_test.dart
import 'package:bikedrop/design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

const _green = AppColors.statusColorSuccess;
const _greenTint = Color(0xFFEAF6ED);

Widget _wrap(Widget child) =>
    MaterialApp(home: Scaffold(body: Center(child: child)));

Material _material(WidgetTester tester) => tester.widget<Material>(
  find.ancestor(of: find.byType(InkWell), matching: find.byType(Material)).first,
);

Container _dot(WidgetTester tester) => tester
    .widgetList<Container>(find.byType(Container))
    .firstWhere(
      (c) =>
          c.decoration is BoxDecoration &&
          (c.decoration! as BoxDecoration).shape == BoxShape.circle,
    );

void main() {
  testWidgets('shows the value and the label', (tester) async {
    await tester.pumpWidget(
      _wrap(const KpiFilterCard(value: 432, label: 'Im Bestand', color: _green, tint: _greenTint)),
    );

    expect(find.text('432'), findsOneWidget);
    expect(find.text('Im Bestand'), findsOneWidget);
  });

  testWidgets('paints the dot in the given color', (tester) async {
    await tester.pumpWidget(
      _wrap(const KpiFilterCard(value: 7, label: 'X', color: _green, tint: _greenTint)),
    );

    expect((_dot(tester).decoration! as BoxDecoration).color, _green);
  });

  testWidgets('is white with dark text when not selected', (tester) async {
    await tester.pumpWidget(
      _wrap(const KpiFilterCard(value: 1, label: 'X', color: _green, tint: _greenTint)),
    );

    expect(_material(tester).color, AppColors.white);
    expect(tester.widget<Text>(find.text('1')).style!.color, AppColors.textPrimary);
  });

  testWidgets('uses the tint background and the given color as text when selected', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        const KpiFilterCard(value: 1, label: 'X', color: _green, tint: _greenTint, selected: true),
      ),
    );

    expect(_material(tester).color, _greenTint);
    expect(tester.widget<Text>(find.text('1')).style!.color, _green);
  });

  testWidgets('reports taps', (tester) async {
    var taps = 0;
    await tester.pumpWidget(
      _wrap(
        KpiFilterCard(value: 5, label: 'X', color: _green, tint: _greenTint, onTap: () => taps++),
      ),
    );

    await tester.tap(find.byType(KpiFilterCard));
    expect(taps, 1);
  });

  testWidgets('is not tappable without a callback', (tester) async {
    await tester.pumpWidget(
      _wrap(const KpiFilterCard(value: 5, label: 'X', color: _green, tint: _greenTint)),
    );

    expect(tester.widget<InkWell>(find.byType(InkWell)).onTap, isNull);
  });
}
```

- [ ] **Step 3: Run test to verify it fails**

Run: `flutter test test/design_system/atoms/kpi_filter_card_test.dart`
Expected: FAIL — `KpiFilterCard` has no `label`/`color`/`tint` parameters yet.

- [ ] **Step 4: Generalize `KpiFilterCard`**

Replace the contents of `lib/design_system/atoms/kpi_filter_card.dart`:

```dart
import 'package:flutter/material.dart';

import '../tokens/app_colors.dart';
import '../tokens/app_typography.dart';

/// Generischer Filter-Chip: farbiger Punkt, Label und Anzahl, filtert eine
/// Liste beim Antippen darauf. Kennt keine Domäne — Farbe/Label/Tint kommen
/// als primitive Parameter vom Aufrufer (z.B. aus [ArticleStatus] oder
/// `ReceivingScanStatus` gebaut), damit dieselbe Kachel für mehrere
/// Status-Enums wiederverwendbar ist.
///
/// Im Ruhezustand weiss mit duennem Rahmen, im ausgewaehlten Zustand ein
/// zarter Farbton ([tint]) als Hintergrund. Der Punkt traegt in beiden
/// Zustaenden die volle [color].
class KpiFilterCard extends StatelessWidget {
  const KpiFilterCard({
    super.key,
    required this.value,
    required this.label,
    required this.color,
    required this.tint,
    this.selected = false,
    this.onTap,
  });

  final int value;
  final String label;
  final Color color;
  final Color tint;

  /// Markiert den Chip als aktiven Filter.
  final bool selected;

  final VoidCallback? onTap;

  static const double _borderWidth = 1.5;
  static const double _paddingH = 16;
  static const double _paddingV = 10;
  static const double _dotSize = 8;
  static const double _dotGap = 8;
  static const double _valueGap = 6;

  @override
  Widget build(BuildContext context) {
    final borderColor = selected ? color : AppColors.border;
    final backgroundColor = selected ? tint : AppColors.white;
    final textColor = selected ? color : AppColors.textPrimary;

    return Material(
      color: backgroundColor,
      shape: const StadiumBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        customBorder: const StadiumBorder(),
        child: Container(
          decoration: ShapeDecoration(
            shape: StadiumBorder(
              side: BorderSide(color: borderColor, width: _borderWidth),
            ),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: _paddingH,
            vertical: _paddingV,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: _dotSize,
                height: _dotSize,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
              const SizedBox(width: _dotGap),
              Text(
                label,
                style: AppTypography.kpiLabel.copyWith(color: textColor),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(width: _valueGap),
              Text(
                value.toString(),
                style: AppTypography.kpiLabel.copyWith(
                  color: textColor,
                  fontWeight: FontWeight.w800,
                ),
                maxLines: 1,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

- [ ] **Step 5: Run test to verify it passes**

Run: `flutter test test/design_system/atoms/kpi_filter_card_test.dart`
Expected: PASS (6 tests)

- [ ] **Step 6: Update the widgetbook use-case**

Replace `widgetbook/lib/use_cases/atoms/app_kpi_card.dart`:

```dart
import 'package:bikedrop/design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart' as widgetbook;
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

@widgetbook.UseCase(name: 'Default', type: KpiFilterCard)
Widget kpiFilterCardDefault(BuildContext context) {
  final status = context.knobs.object.dropdown<ArticleStatus>(
    label: 'Status (nur zur Vorschau)',
    options: ArticleStatus.values,
    labelBuilder: (status) => status.label,
  );

  return Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: SizedBox(
        // Etwa so breit wie eine von drei Kacheln auf einem 390-dp-Geraet.
        width: 111,
        child: KpiFilterCard(
          value: context.knobs.int.input(label: 'Wert', initialValue: 432),
          label: status.label,
          color: AppColors.statusColors[status]!,
          tint: AppColors.statusColorTints[status]!,
          selected: context.knobs.boolean(label: 'Als Filter aktiv'),
          onTap: () {},
        ),
      ),
    ),
  );
}
```

- [ ] **Step 7: Run the full test suite to check for other breakage**

Run: `flutter test`
Expected: `test/design_system/organisms/kpi_filter_row_test.dart` and `test/features/overview_screen_test.dart` now FAIL (they still use the old `status:` param) — this is expected and fixed in Task 4. Confirm no *other* files fail.

- [ ] **Step 8: Commit**

```bash
git add lib/design_system/atoms/kpi_filter_card.dart widgetbook/lib/use_cases/atoms/app_kpi_card.dart test/design_system/atoms/kpi_filter_card_test.dart
git commit -m "refactor: generalize KpiFilterCard beyond ArticleStatus"
```

---

### Task 4: Generalize `KpiFilterRow` + wire `OverviewScreen`

**Files:**
- Modify: `lib/design_system/organisms/kpi_filter_row.dart`
- Modify: `widgetbook/lib/use_cases/organisms/kpi_filter_row.dart`
- Modify: `lib/features/overview_screen.dart`
- Test: `test/design_system/organisms/kpi_filter_row_test.dart` (rewrite)
- Test: `test/features/overview_screen_test.dart` (modify 2 spots)

**Interfaces:**
- Consumes: `KpiFilterCard` from Task 3.
- Produces: `class KpiFilterEntry { const KpiFilterEntry({required Object key, required String label, required Color color, required Color tint, required int count}); }`, `KpiFilterRow({required List<KpiFilterEntry> entries, Object? selectedKey, ValueChanged<Object>? onEntryTap})`.

- [ ] **Step 1: Rewrite the failing test for the generalized row**

```dart
// test/design_system/organisms/kpi_filter_row_test.dart
import 'package:bikedrop/design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

const _green = AppColors.statusColorSuccess;
const _greenTint = Color(0xFFEAF6ED);
const _yellow = AppColors.statusColorWarning;
const _yellowTint = Color(0xFFF5EDE0);
const _red = AppColors.statusColorError;
const _redTint = Color(0xFFFCEAEA);

const _entries = [
  KpiFilterEntry(key: 'inStock', label: 'Im Shop', color: _green, tint: _greenTint, count: 6),
  KpiFilterEntry(key: 'bestellt', label: 'Bestellt', color: _yellow, tint: _yellowTint, count: 2),
  KpiFilterEntry(key: 'fehlt', label: 'Fehlt', color: _red, tint: _redTint, count: 1),
];

Future<void> _pump(WidgetTester tester, Widget row, {double width = 390}) async {
  tester.view.physicalSize = Size(width, 640);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPaddingH),
          child: row,
        ),
      ),
    ),
  );
}

void main() {
  testWidgets('shows one card per entry with its count', (tester) async {
    await _pump(tester, const KpiFilterRow(entries: _entries));

    expect(find.byType(KpiFilterCard), findsNWidgets(3));
    expect(find.text('6'), findsOneWidget);
    expect(find.text('2'), findsOneWidget);
    expect(find.text('1'), findsOneWidget);
  });

  testWidgets('keeps the given entry order', (tester) async {
    await _pump(tester, const KpiFilterRow(entries: _entries));

    final labels = tester
        .widgetList<KpiFilterCard>(find.byType(KpiFilterCard))
        .map((card) => card.label)
        .toList();

    expect(labels, ['Im Shop', 'Bestellt', 'Fehlt']);
  });

  testWidgets('marks only the selected entry', (tester) async {
    await _pump(tester, const KpiFilterRow(entries: _entries, selectedKey: 'bestellt'));

    final selectedLabels = tester
        .widgetList<KpiFilterCard>(find.byType(KpiFilterCard))
        .where((card) => card.selected)
        .map((card) => card.label);

    expect(selectedLabels, ['Bestellt']);
  });

  testWidgets('reports the tapped key', (tester) async {
    final tapped = <Object>[];
    await _pump(tester, KpiFilterRow(entries: _entries, onEntryTap: tapped.add));

    await tester.tap(find.text('Fehlt'));
    await tester.tap(find.text('Im Shop'));

    expect(tapped, ['fehlt', 'inStock']);
  });

  testWidgets('is display-only without a callback', (tester) async {
    await _pump(tester, const KpiFilterRow(entries: _entries));

    for (final card in tester.widgetList<KpiFilterCard>(find.byType(KpiFilterCard))) {
      expect(card.onTap, isNull);
    }
  });

  testWidgets('does not overflow on a 320 dp screen', (tester) async {
    await _pump(tester, const KpiFilterRow(entries: _entries), width: 320);

    expect(tester.takeException(), isNull);
    expect(find.text('Bestellt'), findsOneWidget);
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/design_system/organisms/kpi_filter_row_test.dart`
Expected: FAIL — `KpiFilterEntry` undefined.

- [ ] **Step 3: Generalize `KpiFilterRow` and add `KpiFilterEntry`**

Replace the contents of `lib/design_system/organisms/kpi_filter_row.dart`:

```dart
import 'package:flutter/material.dart';

import '../atoms/kpi_filter_card.dart';
import '../tokens/app_spacing.dart';

/// Ein Eintrag der [KpiFilterRow]: Zählwert plus die Optik seiner Kachel.
/// [key] identifiziert den Eintrag beim Antippen und bei "welcher ist
/// ausgewaehlt" — typischerweise ein Enum-Wert des Aufrufers (z.B.
/// `ArticleStatus.inStock` oder `ReceivingScanStatus.unknown`).
class KpiFilterEntry {
  const KpiFilterEntry({
    required this.key,
    required this.label,
    required this.color,
    required this.tint,
    required this.count,
  });

  final Object key;
  final String label;
  final Color color;
  final Color tint;
  final int count;
}

/// Beliebig viele Filter-Kacheln nebeneinander, wie sie unter der Suchleiste
/// des Overview-Screens oder im Kopf des Wareneingangs-Warenkorbs stehen.
///
/// Zustandslos: welche Eintraege es gibt, welcher als Filter aktiv ist und
/// was ein Tipp ausloest, entscheidet der aufrufende Screen. Dieses Widget
/// kennt kein Status-Enum und keine Farbtabelle.
class KpiFilterRow extends StatelessWidget {
  const KpiFilterRow({
    super.key,
    required this.entries,
    this.selectedKey,
    this.onEntryTap,
  });

  final List<KpiFilterEntry> entries;

  /// Der als Filter aktive Schluessel, oder `null` fuer "kein Filter".
  final Object? selectedKey;

  /// Wird mit dem Schluessel der angetippten Kachel gerufen. Ist der
  /// Callback `null`, sind die Kacheln reine Anzeige.
  final ValueChanged<Object>? onEntryTap;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.listRowGap,
      runSpacing: AppSpacing.listRowGap,
      children: [
        for (final entry in entries)
          KpiFilterCard(
            value: entry.count,
            label: entry.label,
            color: entry.color,
            tint: entry.tint,
            selected: selectedKey == entry.key,
            onTap: onEntryTap == null ? null : () => onEntryTap!(entry.key),
          ),
      ],
    );
  }
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/design_system/organisms/kpi_filter_row_test.dart`
Expected: PASS (6 tests)

- [ ] **Step 5: Update the widgetbook use-case**

Replace `widgetbook/lib/use_cases/organisms/kpi_filter_row.dart`:

```dart
import 'package:bikedrop/design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart' as widgetbook;
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

KpiFilterEntry _entry(ArticleStatus status, int count) => KpiFilterEntry(
  key: status,
  label: status.label,
  color: AppColors.statusColors[status]!,
  tint: AppColors.statusColorTints[status]!,
  count: count,
);

@widgetbook.UseCase(name: 'Default', type: KpiFilterRow)
Widget kpiFilterRowDefault(BuildContext context) {
  final entries = [
    _entry(ArticleStatus.inStock, context.knobs.int.input(label: 'Im Shop', initialValue: 432)),
    _entry(ArticleStatus.bestellt, context.knobs.int.input(label: 'Bestellt', initialValue: 12)),
    _entry(ArticleStatus.fehlt, context.knobs.int.input(label: 'Fehlt', initialValue: 7)),
  ];
  final selected = context.knobs.object.dropdown<ArticleStatus?>(
    label: 'Aktiver Filter',
    options: [null, ...ArticleStatus.values],
    labelBuilder: (status) => status?.label ?? 'Kein Filter',
  );

  return Padding(
    padding: const EdgeInsets.all(AppSpacing.screenPaddingH),
    child: KpiFilterRow(
      entries: entries,
      selectedKey: selected,
      onEntryTap: (_) {},
    ),
  );
}
```

- [ ] **Step 6: Update `OverviewScreen`'s call site**

In `lib/features/overview_screen.dart`, add a helper function near `_countByStatus`:

```dart
/// Baut die drei Filter-Kacheln aus den Status-Zaehlern. Bewusst nicht
/// `ArticleStatus.values`: die Kacheln laufen von "alles gut" nach
/// "Problem" — gruen, gelb, rot. Die Enum-Reihenfolge waere gruen, rot, gelb.
List<KpiFilterEntry> _kpiEntries(Map<ArticleStatus, int> counts) {
  const order = [ArticleStatus.inStock, ArticleStatus.bestellt, ArticleStatus.fehlt];
  return [
    for (final status in order)
      KpiFilterEntry(
        key: status,
        label: status.label,
        color: AppColors.statusColors[status]!,
        tint: AppColors.statusColorTints[status]!,
        count: counts[status] ?? 0,
      ),
  ];
}
```

Replace the `KpiFilterRow(...)` call inside `build()`:

```dart
                KpiFilterRow(
                  entries: _kpiEntries(_countByStatus(articlesAsync.requireValue)),
                  selectedKey: statusFilter,
                  onEntryTap: (key) =>
                      ref.read(statusFilterProvider.notifier).state =
                          statusFilter == key ? null : key as ArticleStatus,
                ),
```

- [ ] **Step 7: Update the two `overview_screen_test.dart` spots that read `KpiFilterCard.status`**

Replace (around line 104-108):

```dart
    KpiFilterCard card(ArticleStatus status) => tester.widget<KpiFilterCard>(
      find.byWidgetPredicate(
        (w) => w is KpiFilterCard && w.status == status,
      ),
    );
```

with:

```dart
    KpiFilterCard card(ArticleStatus status) => tester.widget<KpiFilterCard>(
      find.byWidgetPredicate(
        (w) => w is KpiFilterCard && w.label == status.label,
      ),
    );
```

Replace (around line 190-193):

```dart
    final inStock = tester.widget<KpiFilterCard>(
      find.byWidgetPredicate(
        (w) => w is KpiFilterCard && w.status == ArticleStatus.inStock,
      ),
    );
```

with:

```dart
    final inStock = tester.widget<KpiFilterCard>(
      find.byWidgetPredicate(
        (w) => w is KpiFilterCard && w.label == ArticleStatus.inStock.label,
      ),
    );
```

- [ ] **Step 8: Run the full test suite**

Run: `flutter test`
Expected: PASS — `overview_screen_test.dart`, `kpi_filter_row_test.dart`, `kpi_filter_card_test.dart` all green; no other file references `KpiFilterCard.status`/`KpiFilterRow.counts` anymore.

- [ ] **Step 9: Commit**

```bash
git add lib/design_system/organisms/kpi_filter_row.dart widgetbook/lib/use_cases/organisms/kpi_filter_row.dart lib/features/overview_screen.dart test/design_system/organisms/kpi_filter_row_test.dart test/features/overview_screen_test.dart
git commit -m "refactor: generalize KpiFilterRow with KpiFilterEntry"
```

---

### Task 5: `ReceivingCartNotifier` + `receivingCartProvider`

**Files:**
- Create: `lib/providers/receiving_cart_provider.dart`
- Test: `test/providers/receiving_cart_provider_test.dart`

**Interfaces:**
- Consumes: `articleRepositoryProvider` (`lib/providers/article_repository_provider.dart`), `catalogRepositoryProvider` (`lib/providers/catalog_repository_provider.dart`), `ReceivingCartItem` (`lib/models/receivingcartitem.dart`), `Article.packSize`/`Article.ean`, `CatalogArticle.ean`.
- Produces: `final receivingCartRandomProvider = Provider<Random>(...)`; `class ReceivingCartNotifier extends AutoDisposeNotifier<List<ReceivingCartItem>>` with methods `addFromCatalog()`, `addFromOwnArticles()`, `addUnknown(String ean)`, `updateQuantity(ReceivingCartItem item, int quantity)`, `resolveUnknown(ReceivingCartItem item, Article resolvedArticle)`; `final receivingCartProvider = NotifierProvider.autoDispose<ReceivingCartNotifier, List<ReceivingCartItem>>(ReceivingCartNotifier.new)`.

- [ ] **Step 1: Write the failing tests**

```dart
// test/providers/receiving_cart_provider_test.dart
import 'dart:math';

import 'package:bikedrop/enums/article_status.dart';
import 'package:bikedrop/enums/category.dart';
import 'package:bikedrop/interface/article_interface.dart';
import 'package:bikedrop/interface/catalog_interface.dart';
import 'package:bikedrop/models/article.dart';
import 'package:bikedrop/models/catalogarticle.dart';
import 'package:bikedrop/providers/article_repository_provider.dart';
import 'package:bikedrop/providers/catalog_repository_provider.dart';
import 'package:bikedrop/providers/receiving_cart_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// Waehlt immer den ersten Eintrag — macht Zufallsauswahl im Test
/// deterministisch, ohne `Random` selbst nachbauen zu muessen.
class _FirstRandom implements Random {
  @override
  int nextInt(int max) => 0;
  @override
  double nextDouble() => 0;
  @override
  bool nextBool() => false;
}

class _FakeCatalogRepository implements CatalogRepository {
  _FakeCatalogRepository(this.articles);
  final List<CatalogArticle> articles;

  @override
  Future<CatalogArticle?> lookupByEan(String ean) async =>
      articles.where((a) => a.ean == ean).firstOrNull;

  @override
  Future<List<CatalogArticle>> getCatalogArticles() async => articles;
}

class _FakeArticleRepository implements ArticleRepository {
  _FakeArticleRepository(this.articles);
  final List<Article> articles;

  @override
  Future<List<Article>> getArticles() async => articles;
  @override
  Future<Article?> getArticleByEan(String ean) => throw UnimplementedError();
  @override
  Future<Article?> getArticleById(String id) => throw UnimplementedError();
  @override
  Future<List<Article>> searchArticlesByName(String query) => throw UnimplementedError();
  @override
  Future<Article> createArticle(Article article) => throw UnimplementedError();
  @override
  Future<Article> updateArticle(Article article) => throw UnimplementedError();
  @override
  Future<Article> changeQuantity(String id, int newQuantity) => throw UnimplementedError();
  @override
  Future<void> deleteArticle(String id) => throw UnimplementedError();
  @override
  Future<List<String>> getSuppliers() => throw UnimplementedError();
}

const _catalogArticle = CatalogArticle(
  name: 'Abus Bordo 6000 Faltschloss 90cm',
  category: Category.zubehoer,
  ean: '4029876501233',
);

Article _ownArticle({String? ean, int packSize = 1}) {
  final now = DateTime(2026, 1, 1);
  return Article(
    ean: ean,
    name: 'KMC Kette X11',
    category: Category.antrieb,
    quantity: 5,
    minQuantity: 0,
    packSize: packSize,
    purchasePrice: 1,
    sellingPrice: 2,
    status: ArticleStatus.inStock,
    createdAt: now,
    updatedAt: now,
  );
}

ProviderContainer _container({
  List<CatalogArticle> catalog = const [_catalogArticle],
  List<Article> ownArticles = const [],
}) {
  final container = ProviderContainer(
    overrides: [
      catalogRepositoryProvider.overrideWithValue(_FakeCatalogRepository(catalog)),
      articleRepositoryProvider.overrideWithValue(_FakeArticleRepository(ownArticles)),
      receivingCartRandomProvider.overrideWithValue(_FirstRandom()),
    ],
  );
  return container;
}

void main() {
  test('starts empty', () {
    final container = _container();
    addTearDown(container.dispose);

    expect(container.read(receivingCartProvider), isEmpty);
  });

  test('addFromCatalog adds a new line for the picked catalog article', () async {
    final container = _container();
    addTearDown(container.dispose);

    await container.read(receivingCartProvider.notifier).addFromCatalog();

    final cart = container.read(receivingCartProvider);
    expect(cart, hasLength(1));
    expect(cart.single.catalogData?.ean, '4029876501233');
    expect(cart.single.quantity, 1);
    expect(cart.single.resolvedArticle, isNull);
  });

  test('addFromCatalog merges into the existing line on a repeat pick', () async {
    final container = _container();
    addTearDown(container.dispose);
    final notifier = container.read(receivingCartProvider.notifier);

    await notifier.addFromCatalog();
    await notifier.addFromCatalog();

    final cart = container.read(receivingCartProvider);
    expect(cart, hasLength(1));
    expect(cart.single.quantity, 2);
  });

  test('addFromCatalog does nothing when the catalog is empty', () async {
    final container = _container(catalog: const []);
    addTearDown(container.dispose);

    await container.read(receivingCartProvider.notifier).addFromCatalog();

    expect(container.read(receivingCartProvider), isEmpty);
  });

  test('addFromOwnArticles adds a new line with quantity = packSize', () async {
    final container = _container(
      ownArticles: [_ownArticle(ean: '4711234567899', packSize: 3)],
    );
    addTearDown(container.dispose);

    await container.read(receivingCartProvider.notifier).addFromOwnArticles();

    final cart = container.read(receivingCartProvider);
    expect(cart, hasLength(1));
    expect(cart.single.resolvedArticle?.ean, '4711234567899');
    expect(cart.single.quantity, 3);
    expect(cart.single.catalogData, isNull);
  });

  test('addFromOwnArticles merges by adding packSize on a repeat pick', () async {
    final container = _container(
      ownArticles: [_ownArticle(ean: '4711234567899', packSize: 2)],
    );
    addTearDown(container.dispose);
    final notifier = container.read(receivingCartProvider.notifier);

    await notifier.addFromOwnArticles();
    await notifier.addFromOwnArticles();

    final cart = container.read(receivingCartProvider);
    expect(cart, hasLength(1));
    expect(cart.single.quantity, 4);
  });

  test('addFromOwnArticles ignores articles without an ean', () async {
    final container = _container(ownArticles: [_ownArticle(ean: null)]);
    addTearDown(container.dispose);

    await container.read(receivingCartProvider.notifier).addFromOwnArticles();

    expect(container.read(receivingCartProvider), isEmpty);
  });

  test('addUnknown always appends a new line, never merges', () async {
    final container = _container();
    addTearDown(container.dispose);
    final notifier = container.read(receivingCartProvider.notifier);

    notifier.addUnknown('978020137962');
    notifier.addUnknown('978020137962');

    final cart = container.read(receivingCartProvider);
    expect(cart, hasLength(2));
    expect(cart.every((item) => item.quantity == 1), isTrue);
    expect(cart.every((item) => item.resolvedArticle == null && item.catalogData == null), isTrue);
  });

  test('updateQuantity changes only the targeted line', () async {
    final container = _container();
    addTearDown(container.dispose);
    final notifier = container.read(receivingCartProvider.notifier);

    notifier.addUnknown('111');
    notifier.addUnknown('222');
    final target = container.read(receivingCartProvider)[0];

    notifier.updateQuantity(target, 9);

    final cart = container.read(receivingCartProvider);
    expect(cart[0].quantity, 9);
    expect(cart[1].quantity, 1);
  });

  test('resolveUnknown replaces exactly the targeted line, even with a shared ean', () async {
    final container = _container(
      ownArticles: [_ownArticle(ean: '978020137962', packSize: 1)],
    );
    addTearDown(container.dispose);
    final notifier = container.read(receivingCartProvider.notifier);

    notifier.addUnknown('978020137962');
    notifier.addUnknown('978020137962');
    final firstUnknown = container.read(receivingCartProvider)[0];
    final resolved = _ownArticle(ean: '978020137962');

    notifier.resolveUnknown(firstUnknown, resolved);

    final cart = container.read(receivingCartProvider);
    expect(cart[0].resolvedArticle, resolved);
    expect(cart[1].resolvedArticle, isNull);
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/providers/receiving_cart_provider_test.dart`
Expected: FAIL — `Target of URI doesn't exist: 'package:bikedrop/providers/receiving_cart_provider.dart'`.

- [ ] **Step 3: Implement the notifier and provider**

```dart
// lib/providers/receiving_cart_provider.dart
import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/article.dart';
import '../models/receivingcartitem.dart';
import 'article_repository_provider.dart';
import 'catalog_repository_provider.dart';

/// Injektionspunkt fuer den Zufall — im Produktivbetrieb ein echter
/// [Random], in Tests durch einen deterministischen Stellvertreter ersetzbar.
final receivingCartRandomProvider = Provider<Random>((ref) => Random());

/// Haelt den Wareneingangs-Warenkorb fuer die Dauer eines Scanner-Screen-
/// Aufrufs. `autoDispose`, damit jeder neue Aufruf von "Wareneingang" leer
/// beginnt, sobald niemand mehr zuhoert (Screen geschlossen).
class ReceivingCartNotifier extends AutoDisposeNotifier<List<ReceivingCartItem>> {
  late final Random _random;

  @override
  List<ReceivingCartItem> build() {
    _random = ref.read(receivingCartRandomProvider);
    return [];
  }

  /// Zieht zufaellig einen Katalogartikel. Existiert bereits eine Zeile mit
  /// derselben Katalog-EAN, wird deren Menge erhoeht statt einer neuen Zeile.
  Future<void> addFromCatalog() async {
    final catalogArticles = await ref.read(catalogRepositoryProvider).getCatalogArticles();
    if (catalogArticles.isEmpty) return;

    final picked = catalogArticles[_random.nextInt(catalogArticles.length)];
    final index = state.indexWhere((item) => item.catalogData?.ean == picked.ean);
    if (index == -1) {
      state = [...state, ReceivingCartItem(ean: picked.ean, quantity: 1, catalogData: picked)];
    } else {
      _incrementAt(index, 1);
    }
  }

  /// Zieht zufaellig einen eigenen Artikel mit EAN (nur scannbare Artikel
  /// kommen infrage). Existiert bereits eine Zeile mit demselben Artikel,
  /// wird deren Menge um [Article.packSize] erhoeht statt einer neuen Zeile.
  Future<void> addFromOwnArticles() async {
    final articles = (await ref.read(articleRepositoryProvider).getArticles())
        .where((a) => a.ean != null)
        .toList();
    if (articles.isEmpty) return;

    final picked = articles[_random.nextInt(articles.length)];
    final index = state.indexWhere((item) => item.resolvedArticle?.id == picked.id);
    if (index == -1) {
      state = [
        ...state,
        ReceivingCartItem(ean: picked.ean!, quantity: picked.packSize, resolvedArticle: picked),
      ];
    } else {
      _incrementAt(index, picked.packSize);
    }
  }

  /// Fuegt immer eine neue Zeile an — unbekannte Zeilen haben keine
  /// Identitaet, ueber die man sinnvoll zusammenfuehren koennte, auch wenn
  /// mehrere Zeilen zufaellig dieselbe (Demo-)EAN tragen.
  void addUnknown(String ean) {
    state = [...state, ReceivingCartItem(ean: ean, quantity: 1)];
  }

  void updateQuantity(ReceivingCartItem item, int quantity) {
    state = [
      for (final current in state)
        identical(current, item) ? current.copyWith(quantity: quantity) : current,
    ];
  }

  /// Ersetzt genau diese eine Zeile (per Objekt-Referenz identifiziert,
  /// nicht per EAN — mehrere "Unbekannt"-Zeilen koennen dieselbe EAN
  /// tragen) mit einem aufgeloesten Artikel.
  void resolveUnknown(ReceivingCartItem item, Article resolvedArticle) {
    state = [
      for (final current in state)
        identical(current, item)
            ? current.copyWith(
                ean: resolvedArticle.ean ?? current.ean,
                resolvedArticle: resolvedArticle,
              )
            : current,
    ];
  }

  void _incrementAt(int index, int amount) {
    final existing = state[index];
    state = [
      for (var i = 0; i < state.length; i++)
        if (i == index) existing.copyWith(quantity: existing.quantity + amount) else state[i],
    ];
  }
}

final receivingCartProvider =
    NotifierProvider.autoDispose<ReceivingCartNotifier, List<ReceivingCartItem>>(
  ReceivingCartNotifier.new,
);
```

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/providers/receiving_cart_provider_test.dart`
Expected: PASS (11 tests)

- [ ] **Step 5: Commit**

```bash
git add lib/providers/receiving_cart_provider.dart test/providers/receiving_cart_provider_test.dart
git commit -m "feat: add ReceivingCartNotifier for the Wareneingang cart"
```

---

### Task 6: `ReceivingCartItemTile` molecule

**Files:**
- Create: `lib/design_system/molecules/receiving_cart_item_tile.dart`
- Modify: `lib/design_system/design_system.dart` (export)
- Create: `widgetbook/lib/use_cases/molecules/receiving_cart_item_tile.dart`
- Test: `test/design_system/molecules/receiving_cart_item_tile_test.dart`

**Interfaces:**
- Consumes: `ReceivingCartItem`, `ReceivingScanStatus`/`scanStatus` getter (Task 1), `AppColors.receivingStatusColors` (Task 1), `QuantityStepper` (existing, unmodified).
- Produces: `ReceivingCartItemTile({required ReceivingCartItem item, required ValueChanged<int> onQuantityChanged, required VoidCallback onAnlegenTap})`.

- [ ] **Step 1: Write the failing test**

```dart
// test/design_system/molecules/receiving_cart_item_tile_test.dart
import 'package:bikedrop/design_system/design_system.dart';
import 'package:bikedrop/enums/article_status.dart';
import 'package:bikedrop/enums/category.dart';
import 'package:bikedrop/models/article.dart';
import 'package:bikedrop/models/catalogarticle.dart';
import 'package:bikedrop/models/receivingcartitem.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Article _article() {
  final now = DateTime(2026, 1, 1);
  return Article(
    ean: '4711234567899',
    name: 'KMC Kette X11',
    category: Category.antrieb,
    quantity: 5,
    minQuantity: 0,
    purchasePrice: 1,
    sellingPrice: 2,
    status: ArticleStatus.inStock,
    createdAt: now,
    updatedAt: now,
  );
}

const _catalogArticle = CatalogArticle(
  name: 'Abus Bordo 6000 Faltschloss 90cm',
  category: Category.zubehoer,
  ean: '4029876501233',
);

Widget _wrap(ReceivingCartItem item, {ValueChanged<int>? onQuantityChanged, VoidCallback? onAnlegenTap}) {
  return MaterialApp(
    home: Scaffold(
      body: ReceivingCartItemTile(
        item: item,
        onQuantityChanged: onQuantityChanged ?? (_) {},
        onAnlegenTap: onAnlegenTap ?? () {},
      ),
    ),
  );
}

void main() {
  testWidgets('shows the resolved article name and its EAN', (tester) async {
    await tester.pumpWidget(
      _wrap(ReceivingCartItem(ean: '4711234567899', quantity: 3, resolvedArticle: _article())),
    );

    expect(find.text('KMC Kette X11'), findsOneWidget);
    expect(find.text('EAN 4711234567899'), findsOneWidget);
  });

  testWidgets('shows the catalog article name when only the catalog matched', (tester) async {
    await tester.pumpWidget(
      _wrap(ReceivingCartItem(ean: '4029876501233', quantity: 1, catalogData: _catalogArticle)),
    );

    expect(find.text('Abus Bordo 6000 Faltschloss 90cm'), findsOneWidget);
  });

  testWidgets('falls back to a generic name for an unknown item', (tester) async {
    await tester.pumpWidget(_wrap(const ReceivingCartItem(ean: '978020137962', quantity: 1)));

    expect(find.text('Unbekannter Artikel'), findsOneWidget);
  });

  testWidgets('shows a QuantityStepper and no Anlegen-button for a known item', (tester) async {
    await tester.pumpWidget(
      _wrap(ReceivingCartItem(ean: '4711234567899', quantity: 3, resolvedArticle: _article())),
    );

    expect(find.byType(QuantityStepper), findsOneWidget);
    expect(find.text('Anlegen'), findsNothing);
  });

  testWidgets('reports quantity changes from the stepper', (tester) async {
    var reported = -1;
    await tester.pumpWidget(
      _wrap(
        ReceivingCartItem(ean: '4711234567899', quantity: 3, resolvedArticle: _article()),
        onQuantityChanged: (q) => reported = q,
      ),
    );

    await tester.tap(find.byTooltip('Menge erhöhen'));
    expect(reported, 4);
  });

  testWidgets('shows an Anlegen-button and no stepper for an unknown item', (tester) async {
    await tester.pumpWidget(_wrap(const ReceivingCartItem(ean: '978020137962', quantity: 1)));

    expect(find.text('Anlegen'), findsOneWidget);
    expect(find.byType(QuantityStepper), findsNothing);
  });

  testWidgets('reports a tap on Anlegen', (tester) async {
    var tapped = false;
    await tester.pumpWidget(
      _wrap(const ReceivingCartItem(ean: '978020137962', quantity: 1), onAnlegenTap: () => tapped = true),
    );

    await tester.tap(find.text('Anlegen'));
    expect(tapped, isTrue);
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/design_system/molecules/receiving_cart_item_tile_test.dart`
Expected: FAIL — `Target of URI doesn't exist: '...receiving_cart_item_tile.dart'`.

- [ ] **Step 3: Implement the molecule**

```dart
// lib/design_system/molecules/receiving_cart_item_tile.dart
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../enums/receiving_scan_status.dart';
import '../../models/receivingcartitem.dart';
import '../tokens/app_colors.dart';
import '../tokens/app_spacing.dart';
import '../tokens/app_typography.dart';
import 'quantity_stepper.dart';

/// Eine gescannte Position im Wareneingangs-Warenkorb: farbiger Status-Kreis,
/// Name + EAN, und rechts entweder ein Mengen-Steller (bekannt/Katalog) oder
/// ein "Anlegen"-Button (unbekannt). Passt nicht zu [ItemListTile] — das hat
/// Kategorie-Badge/Thumbnail/`QuantityDisplay` fest verdrahtet und kennt
/// weder EAN-Untertitel noch den Status-Kreis.
class ReceivingCartItemTile extends StatelessWidget {
  const ReceivingCartItemTile({
    required this.item,
    required this.onQuantityChanged,
    required this.onAnlegenTap,
    super.key,
  });

  final ReceivingCartItem item;
  final ValueChanged<int> onQuantityChanged;
  final VoidCallback onAnlegenTap;

  String get _name {
    final resolved = item.resolvedArticle;
    if (resolved != null) return resolved.name;
    final catalog = item.catalogData;
    if (catalog != null) return catalog.name;
    return 'Unbekannter Artikel';
  }

  IconData get _icon => switch (item.scanStatus) {
    ReceivingScanStatus.inStock => Symbols.check_circle,
    ReceivingScanStatus.catalogMatch => Symbols.grid_view,
    ReceivingScanStatus.unknown => Symbols.question_mark_rounded,
  };

  @override
  Widget build(BuildContext context) {
    final status = item.scanStatus;
    final color = AppColors.receivingStatusColors[status]!;
    final isUnknown = status == ReceivingScanStatus.unknown;

    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: AppSpacing.listRowMinHeight),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.screenPaddingH,
          vertical: AppSpacing.listRowPaddingV,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: AppSpacing.listThumbnailSize,
              height: AppSpacing.listThumbnailSize,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Icon(_icon, color: color, size: AppSpacing.iconSize),
            ),
            const SizedBox(width: AppSpacing.listRowGap),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.body.copyWith(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'EAN ${item.ean}',
                    style: AppTypography.body.copyWith(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.listRowGap),
            if (isUnknown)
              SizedBox(
                height: 36,
                child: OutlinedButton(
                  onPressed: onAnlegenTap,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.textPrimary,
                    side: const BorderSide(
                      color: AppColors.border,
                      width: AppSpacing.fieldBorderWidth,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppSpacing.buttonRadius),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Symbols.add, size: 16, color: AppColors.textPrimary),
                      const SizedBox(width: 4),
                      Text(
                        'Anlegen',
                        style: AppTypography.secondaryButtonLabel.copyWith(
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              SizedBox(
                width: 120,
                child: QuantityStepper(
                  label: 'Menge',
                  showLabel: false,
                  quantity: item.quantity,
                  min: 1,
                  onChanged: onQuantityChanged,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
```

- [ ] **Step 4: Export the new molecule**

In `lib/design_system/design_system.dart`, add next to the other molecule exports:

```dart
export 'molecules/receiving_cart_item_tile.dart';
```

- [ ] **Step 5: Run test to verify it passes**

Run: `flutter test test/design_system/molecules/receiving_cart_item_tile_test.dart`
Expected: PASS (7 tests)

- [ ] **Step 6: Add the widgetbook use-case**

```dart
// widgetbook/lib/use_cases/molecules/receiving_cart_item_tile.dart
import 'package:bikedrop/design_system/design_system.dart';
import 'package:bikedrop/enums/article_status.dart';
import 'package:bikedrop/enums/category.dart';
import 'package:bikedrop/models/article.dart';
import 'package:bikedrop/models/catalogarticle.dart';
import 'package:bikedrop/models/receivingcartitem.dart';
import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart' as widgetbook;
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

Article _demoArticle() {
  final now = DateTime(2026, 1, 1);
  return Article(
    ean: '4711234567899',
    name: 'KMC Kette X11',
    category: Category.antrieb,
    quantity: 5,
    minQuantity: 0,
    purchasePrice: 1,
    sellingPrice: 2,
    status: ArticleStatus.inStock,
    createdAt: now,
    updatedAt: now,
  );
}

const _demoCatalogArticle = CatalogArticle(
  name: 'Abus Bordo 6000 Faltschloss 90cm',
  category: Category.zubehoer,
  ean: '4029876501233',
);

@widgetbook.UseCase(name: 'Interactive', type: ReceivingCartItemTile)
Widget receivingCartItemTileInteractive(BuildContext context) {
  final scenario = context.knobs.object.dropdown<String>(
    label: 'Szenario',
    options: const ['Im Bestand', 'Katalogtreffer', 'Unbekannt'],
  );
  final quantity = context.knobs.int.input(label: 'Menge', initialValue: 2);

  final item = switch (scenario) {
    'Im Bestand' => ReceivingCartItem(
      ean: '4711234567899',
      quantity: quantity,
      resolvedArticle: _demoArticle(),
    ),
    'Katalogtreffer' => ReceivingCartItem(
      ean: '4029876501233',
      quantity: quantity,
      catalogData: _demoCatalogArticle,
    ),
    _ => ReceivingCartItem(ean: '978020137962', quantity: quantity),
  };

  return Center(
    child: ReceivingCartItemTile(
      item: item,
      onQuantityChanged: (_) {},
      onAnlegenTap: () {},
    ),
  );
}
```

- [ ] **Step 7: Commit**

```bash
git add lib/design_system/molecules/receiving_cart_item_tile.dart lib/design_system/design_system.dart widgetbook/lib/use_cases/molecules/receiving_cart_item_tile.dart test/design_system/molecules/receiving_cart_item_tile_test.dart
git commit -m "feat: add ReceivingCartItemTile molecule"
```

---

### Task 7: `ReceivingCartSheet` organism

**Files:**
- Create: `lib/design_system/organisms/receiving_cart_sheet.dart`
- Modify: `lib/design_system/design_system.dart` (export)
- Test: `test/design_system/organisms/receiving_cart_sheet_test.dart`

**Interfaces:**
- Consumes: `receivingCartProvider`/`ReceivingCartNotifier` (Task 5), `ReceivingCartItemTile` (Task 6), `KpiFilterRow`/`KpiFilterEntry` (Task 4), `AppColors.receivingStatusColors`/`receivingStatusTints` (Task 1), `ArticleFormScreen` (existing, `scannedEan` param), `articleRepositoryProvider.getArticleByEan` (existing).
- Produces: `class ReceivingCartSheet extends ConsumerStatefulWidget` (no constructor params beyond `key`) — reads/writes `receivingCartProvider` itself.

- [ ] **Step 1: Write the failing tests**

```dart
// test/design_system/organisms/receiving_cart_sheet_test.dart
import 'package:bikedrop/design_system/design_system.dart';
import 'package:bikedrop/enums/article_status.dart';
import 'package:bikedrop/enums/category.dart';
import 'package:bikedrop/interface/article_interface.dart';
import 'package:bikedrop/models/article.dart';
import 'package:bikedrop/models/receivingcartitem.dart';
import 'package:bikedrop/providers/article_repository_provider.dart';
import 'package:bikedrop/providers/receiving_cart_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _SeededCartNotifier extends ReceivingCartNotifier {
  _SeededCartNotifier(this._seed);
  final List<ReceivingCartItem> _seed;

  @override
  List<ReceivingCartItem> build() => _seed;
}

class _FakeArticleRepository implements ArticleRepository {
  _FakeArticleRepository({this.byEan = const {}});
  final Map<String, Article> byEan;

  @override
  Future<Article?> getArticleByEan(String ean) async => byEan[ean];
  @override
  Future<List<Article>> getArticles() async => byEan.values.toList();
  @override
  Future<Article?> getArticleById(String id) => throw UnimplementedError();
  @override
  Future<List<Article>> searchArticlesByName(String query) => throw UnimplementedError();
  @override
  Future<Article> createArticle(Article article) => throw UnimplementedError();
  @override
  Future<Article> updateArticle(Article article) => throw UnimplementedError();
  @override
  Future<Article> changeQuantity(String id, int newQuantity) => throw UnimplementedError();
  @override
  Future<void> deleteArticle(String id) => throw UnimplementedError();
  @override
  Future<List<String>> getSuppliers() async => [];
}

Article _article({required String ean, required String name}) {
  final now = DateTime(2026, 1, 1);
  return Article(
    ean: ean,
    name: name,
    category: Category.antrieb,
    quantity: 1,
    minQuantity: 0,
    purchasePrice: 1,
    sellingPrice: 2,
    status: ArticleStatus.inStock,
    createdAt: now,
    updatedAt: now,
  );
}

Future<ProviderContainer> _pump(
  WidgetTester tester, {
  required List<ReceivingCartItem> seed,
  Map<String, Article> articlesByEan = const {},
}) async {
  late final ProviderContainer container;
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        receivingCartProvider.overrideWith(() => _SeededCartNotifier(seed)),
        articleRepositoryProvider.overrideWithValue(_FakeArticleRepository(byEan: articlesByEan)),
      ],
      child: Builder(
        builder: (context) {
          container = ProviderScope.containerOf(context);
          return const MaterialApp(
            home: Scaffold(body: ReceivingCartSheet()),
          );
        },
      ),
    ),
  );
  await tester.pumpAndSettle();
  return container;
}

const _known = ReceivingCartItem.new;

void main() {
  testWidgets('shows nothing when the cart is empty', (tester) async {
    await _pump(tester, seed: const []);

    expect(find.byType(DraggableScrollableSheet), findsNothing);
  });

  testWidgets('peek state shows at most 2 rows and no filters or CTA', (tester) async {
    await _pump(
      tester,
      seed: [
        _known(ean: '1', quantity: 1),
        _known(ean: '2', quantity: 1),
        _known(ean: '3', quantity: 1),
      ],
    );

    expect(find.byType(DraggableScrollableSheet), findsOneWidget);
    expect(find.byType(ReceivingCartItemTile), findsNWidgets(2));
    expect(find.byType(KpiFilterRow), findsNothing);
    expect(find.textContaining('Wareneingang abschließen'), findsNothing);
  });

  testWidgets('dragging up reveals the header, filters, full list and CTA', (tester) async {
    await _pump(
      tester,
      seed: [
        _known(ean: '1', quantity: 2),
        _known(ean: '2', quantity: 1),
        _known(ean: '3', quantity: 1),
      ],
    );

    await tester.drag(find.byType(DraggableScrollableSheet), const Offset(0, -500));
    await tester.pumpAndSettle();

    expect(find.byType(KpiFilterRow), findsOneWidget);
    expect(find.byType(ReceivingCartItemTile), findsNWidgets(3));
    expect(find.text('Wareneingang abschließen (3 Artikel)'), findsOneWidget);
    expect(find.textContaining('3 Positionen'), findsOneWidget);
    expect(find.textContaining('4 Stk'), findsOneWidget);
  });

  testWidgets('tapping a filter chip narrows the expanded list', (tester) async {
    await _pump(
      tester,
      seed: [
        _known(ean: '1', quantity: 1),
        const ReceivingCartItem(ean: '978020137962', quantity: 1),
      ],
    );

    await tester.drag(find.byType(DraggableScrollableSheet), const Offset(0, -500));
    await tester.pumpAndSettle();
    expect(find.byType(ReceivingCartItemTile), findsNWidgets(2));

    await tester.tap(find.text('Unbekannt'));
    await tester.pumpAndSettle();

    expect(find.byType(ReceivingCartItemTile), findsNWidgets(1));
    expect(find.text('Unbekannter Artikel'), findsOneWidget);
  });

  testWidgets('the quantity stepper updates the cart provider', (tester) async {
    final container = await _pump(tester, seed: [_known(ean: '1', quantity: 1)]);

    await tester.drag(find.byType(DraggableScrollableSheet), const Offset(0, -500));
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Menge erhöhen'));
    await tester.pumpAndSettle();

    expect(container.read(receivingCartProvider).single.quantity, 2);
  });

  testWidgets('Anlegen pushes ArticleFormScreen and resolves the row afterwards', (tester) async {
    final container = await _pump(
      tester,
      seed: const [ReceivingCartItem(ean: '978020137962', quantity: 1)],
      articlesByEan: {'978020137962': _article(ean: '978020137962', name: 'Neuer Artikel')},
    );

    await tester.drag(find.byType(DraggableScrollableSheet), const Offset(0, -500));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Anlegen'));
    await tester.pumpAndSettle();
    expect(find.text('Artikel anlegen'), findsOneWidget);

    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();

    expect(container.read(receivingCartProvider).single.resolvedArticle?.name, 'Neuer Artikel');
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/design_system/organisms/receiving_cart_sheet_test.dart`
Expected: FAIL — `Target of URI doesn't exist: '...receiving_cart_sheet.dart'`.

- [ ] **Step 3: Implement the organism**

```dart
// lib/design_system/organisms/receiving_cart_sheet.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../enums/receiving_scan_status.dart';
import '../../features/article_form_screen.dart';
import '../../models/receivingcartitem.dart';
import '../../providers/article_repository_provider.dart';
import '../../providers/receiving_cart_provider.dart';
import '../atoms/app_primary_button.dart';
import '../molecules/receiving_cart_item_tile.dart';
import '../tokens/app_colors.dart';
import '../tokens/app_spacing.dart';
import '../tokens/app_typography.dart';
import 'kpi_filter_row.dart';

/// Persistentes Bottom Sheet ueber dem Wareneingangs-Scanner: zeigt den
/// Warenkorb aus [receivingCartProvider]. Leer -> unsichtbar. Sonst startet
/// es im Peek-Zustand (Vorschau von bis zu 2 Zeilen) und zeigt nach dem
/// Hochziehen Kopfzeile, Filter-Chips, die volle Liste und den
/// Abschliessen-Button.
class ReceivingCartSheet extends ConsumerStatefulWidget {
  const ReceivingCartSheet({super.key});

  @override
  ConsumerState<ReceivingCartSheet> createState() => _ReceivingCartSheetState();
}

class _ReceivingCartSheetState extends ConsumerState<ReceivingCartSheet> {
  static const double _minSize = 0.18;
  static const double _maxSize = 0.85;
  static const double _expandThreshold = 0.3;

  final _controller = DraggableScrollableController();
  ReceivingScanStatus? _filter;
  bool _expanded = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_handleSizeChanged);
  }

  void _handleSizeChanged() {
    final expanded = _controller.size >= _expandThreshold;
    if (expanded != _expanded) setState(() => _expanded = expanded);
  }

  @override
  void dispose() {
    _controller.removeListener(_handleSizeChanged);
    _controller.dispose();
    super.dispose();
  }

  Future<void> _openAnlegenForm(ReceivingCartItem item) async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute(builder: (_) => ArticleFormScreen(scannedEan: item.ean)),
    );
    if (!mounted) return;
    final resolved = await ref.read(articleRepositoryProvider).getArticleByEan(item.ean);
    if (resolved != null) {
      ref.read(receivingCartProvider.notifier).resolveUnknown(item, resolved);
    }
  }

  @override
  Widget build(BuildContext context) {
    final items = ref.watch(receivingCartProvider);
    if (items.isEmpty) return const SizedBox.shrink();

    final totalQuantity = items.fold<int>(0, (sum, item) => sum + item.quantity);
    final counts = <ReceivingScanStatus, int>{
      for (final status in ReceivingScanStatus.values)
        status: items.where((item) => item.scanStatus == status).length,
    };
    final openCount = counts[ReceivingScanStatus.unknown] ?? 0;
    final summary = '${items.length} Positionen · $totalQuantity Stk · $openCount offen';

    return DraggableScrollableSheet(
      controller: _controller,
      minChildSize: _minSize,
      initialChildSize: _minSize,
      maxChildSize: _maxSize,
      snap: true,
      builder: (context, scrollController) {
        return Material(
          color: AppColors.white,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(AppSpacing.dialogRadius)),
          ),
          child: _expanded
              ? _ExpandedContent(
                  items: items,
                  summary: summary,
                  counts: counts,
                  filter: _filter,
                  scrollController: scrollController,
                  onFilterTap: (status) => setState(() => _filter = _filter == status ? null : status),
                  onQuantityChanged: (item, quantity) =>
                      ref.read(receivingCartProvider.notifier).updateQuantity(item, quantity),
                  onAnlegenTap: _openAnlegenForm,
                )
              : _PeekContent(
                  items: items,
                  summary: summary,
                  scrollController: scrollController,
                  onQuantityChanged: (item, quantity) =>
                      ref.read(receivingCartProvider.notifier).updateQuantity(item, quantity),
                  onAnlegenTap: _openAnlegenForm,
                ),
        );
      },
    );
  }
}

Widget _dragHandle() => Container(
  width: 36,
  height: 4,
  margin: const EdgeInsets.symmetric(vertical: 12),
  decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(2)),
);

class _PeekContent extends StatelessWidget {
  const _PeekContent({
    required this.items,
    required this.summary,
    required this.scrollController,
    required this.onQuantityChanged,
    required this.onAnlegenTap,
  });

  final List<ReceivingCartItem> items;
  final String summary;
  final ScrollController scrollController;
  final void Function(ReceivingCartItem item, int quantity) onQuantityChanged;
  final void Function(ReceivingCartItem item) onAnlegenTap;

  @override
  Widget build(BuildContext context) {
    final preview = items.take(2).toList();
    return SingleChildScrollView(
      controller: scrollController,
      physics: const ClampingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _dragHandle(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPaddingH),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                summary,
                style: AppTypography.body.copyWith(fontSize: 13, color: AppColors.textSecondary),
              ),
            ),
          ),
          const SizedBox(height: 8),
          for (final item in preview)
            ReceivingCartItemTile(
              item: item,
              onQuantityChanged: (q) => onQuantityChanged(item, q),
              onAnlegenTap: () => onAnlegenTap(item),
            ),
        ],
      ),
    );
  }
}

class _ExpandedContent extends StatelessWidget {
  const _ExpandedContent({
    required this.items,
    required this.summary,
    required this.counts,
    required this.filter,
    required this.scrollController,
    required this.onFilterTap,
    required this.onQuantityChanged,
    required this.onAnlegenTap,
  });

  final List<ReceivingCartItem> items;
  final String summary;
  final Map<ReceivingScanStatus, int> counts;
  final ReceivingScanStatus? filter;
  final ScrollController scrollController;
  final ValueChanged<ReceivingScanStatus> onFilterTap;
  final void Function(ReceivingCartItem item, int quantity) onQuantityChanged;
  final void Function(ReceivingCartItem item) onAnlegenTap;

  @override
  Widget build(BuildContext context) {
    final visible = filter == null
        ? items
        : items.where((item) => item.scanStatus == filter).toList();

    return Column(
      children: [
        _dragHandle(),
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.screenPaddingH,
            0,
            AppSpacing.screenPaddingH,
            8,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Warenkorb', style: AppTypography.heading.copyWith(color: AppColors.textPrimary)),
              const SizedBox(height: 4),
              Text(summary, style: AppTypography.body.copyWith(fontSize: 13, color: AppColors.textSecondary)),
              const SizedBox(height: 12),
              KpiFilterRow(
                entries: [
                  for (final status in ReceivingScanStatus.values)
                    KpiFilterEntry(
                      key: status,
                      label: status.label,
                      color: AppColors.receivingStatusColors[status]!,
                      tint: AppColors.receivingStatusTints[status]!,
                      count: counts[status] ?? 0,
                    ),
                ],
                selectedKey: filter,
                onEntryTap: (key) => onFilterTap(key as ReceivingScanStatus),
              ),
            ],
          ),
        ),
        const Divider(height: 1, color: AppColors.listDivider),
        Expanded(
          child: ListView.separated(
            controller: scrollController,
            padding: EdgeInsets.zero,
            itemCount: visible.length,
            separatorBuilder: (context, index) => const Divider(height: 1, color: AppColors.listDivider),
            itemBuilder: (context, index) {
              final item = visible[index];
              return ReceivingCartItemTile(
                item: item,
                onQuantityChanged: (q) => onQuantityChanged(item, q),
                onAnlegenTap: () => onAnlegenTap(item),
              );
            },
          ),
        ),
        Padding(
          padding: EdgeInsets.only(
            left: AppSpacing.screenPaddingH,
            right: AppSpacing.screenPaddingH,
            top: 12,
            bottom: AppSpacing.screenPaddingV + MediaQuery.of(context).padding.bottom,
          ),
          child: AppPrimaryButton(
            label: 'Wareneingang abschließen (${items.length} Artikel)',
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
      ],
    );
  }
}
```

- [ ] **Step 4: Export the new organism**

In `lib/design_system/design_system.dart`, add next to the other organism exports:

```dart
export 'organisms/receiving_cart_sheet.dart';
```

- [ ] **Step 5: Run test to verify it passes**

Run: `flutter test test/design_system/organisms/receiving_cart_sheet_test.dart`
Expected: PASS (7 tests). `ArticleFormScreen` builds a plain `AppBar` with no custom `leading`, so Flutter renders its standard auto back button (`BackButton`) since the pushed route can pop.

- [ ] **Step 6: Commit**

```bash
git add lib/design_system/organisms/receiving_cart_sheet.dart lib/design_system/design_system.dart test/design_system/organisms/receiving_cart_sheet_test.dart
git commit -m "feat: add ReceivingCartSheet organism"
```

---

### Task 8: `ScannerScreen.overlay`

**Files:**
- Modify: `lib/features/scanner_screen.dart`
- Test: `test/features/scanner_screen_test.dart` (append)

**Interfaces:**
- Produces: `ScannerScreen({..., Widget? overlay})` — new optional constructor parameter, default `null`.

- [ ] **Step 1: Write the failing tests**

Append to `test/features/scanner_screen_test.dart`, inside `main()`:

```dart
  testWidgets('does not render anything extra without an overlay', (tester) async {
    await _pump(tester);

    expect(find.byKey(const ValueKey('scanner-overlay-probe')), findsNothing);
  });

  testWidgets('renders the given overlay on top of the content', (tester) async {
    final scanned = <String>[];
    await tester.pumpWidget(
      ProviderScope(
        overrides: [scannerProvider.overrideWithValue(FakeBarcodeScanner())],
        child: MaterialApp(
          home: ScannerScreen(
            title: 'Test',
            demoOptions: const [_option],
            onEanScanned: (context, ref, ean) async => scanned.add(ean),
            overlay: const Align(
              alignment: Alignment.bottomCenter,
              child: SizedBox(key: ValueKey('scanner-overlay-probe'), height: 40),
            ),
          ),
        ),
      ),
    );

    expect(find.byKey(const ValueKey('scanner-overlay-probe')), findsOneWidget);
    expect(find.byType(FakeCameraView), findsOneWidget);
  });

  testWidgets('an empty overlay does not block taps on the demo buttons behind it', (
    tester,
  ) async {
    final scanned = await _pump(tester, layout: DemoOptionsLayout.grid);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [scannerProvider.overrideWithValue(FakeBarcodeScanner())],
        child: MaterialApp(
          home: ScannerScreen(
            title: 'Test',
            demoOptions: const [_option],
            layout: DemoOptionsLayout.grid,
            onEanScanned: (context, ref, ean) async => scanned.add(ean),
            overlay: const SizedBox.shrink(),
          ),
        ),
      ),
    );

    await tester.tap(find.text(_option.label));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 900));
    await tester.pump();

    expect(scanned, [_option.ean]);
  });
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/features/scanner_screen_test.dart`
Expected: FAIL — `The named parameter 'overlay' isn't defined`.

- [ ] **Step 3: Add the `overlay` parameter**

In `lib/features/scanner_screen.dart`, update the constructor:

```dart
class ScannerScreen extends ConsumerStatefulWidget {
  const ScannerScreen({
    required this.title,
    required this.demoOptions,
    required this.onEanScanned,
    this.layout = DemoOptionsLayout.list,
    this.overlay,
    super.key,
  });

  final String title;
  final List<DemoScanOption> demoOptions;
  final Future<void> Function(BuildContext context, WidgetRef ref, String ean)
  onEanScanned;

  /// Liste mit Untertitel (Default, "Artikel anlegen") oder Grid ohne
  /// Untertitel ("Wareneingang").
  final DemoOptionsLayout layout;

  /// Optionales Overlay ueber dem Scanner-Inhalt, z.B. ein persistentes
  /// Bottom Sheet. Kennt der ScannerScreen selbst nicht — bleibt dadurch
  /// generisch und weiss nichts von Wareneingang/Warenkorb.
  final Widget? overlay;

  @override
  ConsumerState<ScannerScreen> createState() => _ScannerScreenState();
}
```

Update `build()`:

```dart
  @override
  Widget build(BuildContext context) {
    final content = _isFake
        ? FakeCameraView(
            demoOptions: widget.demoOptions,
            activeEan: _activeEan,
            layout: widget.layout,
            onTapWithoutBarcode: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => ArticleFormScreen()),
              );
            },
            onOptionTap: _simulate,
          )
        : const ScannerFrame(
            content: Center(child: Text('Kamera folgt in Phase 6')),
          );

    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: Stack(
        children: [
          content,
          if (widget.overlay != null) Positioned.fill(child: widget.overlay!),
        ],
      ),
    );
  }
```

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/features/scanner_screen_test.dart`
Expected: PASS — all tests including the 3 new ones.

- [ ] **Step 5: Commit**

```bash
git add lib/features/scanner_screen.dart test/features/scanner_screen_test.dart
git commit -m "feat: add optional overlay slot to ScannerScreen"
```

---

### Task 9: Wire the Wareneingang flow in `OverviewScreen`

**Files:**
- Modify: `lib/features/overview_screen.dart`
- Test: `test/features/overview_screen_test.dart` (append)

**Interfaces:**
- Consumes: `ScannerScreen.overlay` (Task 8), `ReceivingCartSheet` (Task 7), `receivingCartProvider`/`ReceivingCartNotifier` (Task 5).

- [ ] **Step 1: Write the failing test**

Append to `test/features/overview_screen_test.dart`, inside `main()`. First add the needed imports at the top of the file:

```dart
import 'package:bikedrop/interface/catalog_interface.dart';
import 'package:bikedrop/models/catalogarticle.dart';
import 'package:bikedrop/providers/catalog_repository_provider.dart';
```

```dart
  testWidgets('scanning Katalogartikel adds a row to the receiving cart sheet', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          articleRepositoryProvider.overrideWithValue(_FakeArticleRepository(articles: _articles)),
        ],
        child: const MaterialApp(home: OverviewScreen()),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Wareneingang'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Katalogartikel'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 900));
    await tester.pumpAndSettle();

    expect(find.byType(ReceivingCartItemTile), findsWidgets);
    expect(find.textContaining('1 Positionen'), findsOneWidget);
  });
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/features/overview_screen_test.dart`
Expected: FAIL — no `ReceivingCartItemTile` appears, since `onEanScanned` is still a no-op TODO.

- [ ] **Step 3: Wire the Wareneingang button**

In `lib/features/overview_screen.dart`, replace the Wareneingang `AppPrimaryButton`'s `onPressed` body:

```dart
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => ScannerScreen(
                            title: 'Wareneingang',
                            layout: DemoOptionsLayout.grid,
                            overlay: const ReceivingCartSheet(),
                            demoOptions: [
                              DemoScanOption(
                                ean: '4029876501233',
                                label: 'Katalogartikel',
                                subtitle:
                                    'EAN 4029876501233 · Abus Bordo 6000 Faltschloss 90cm',
                                icon: Symbols.grid_view,
                                color: AppColors.infoBlue,
                              ),
                              DemoScanOption(
                                ean: '4711234567899',
                                label: 'Eigener Artikel',
                                subtitle:
                                    'EAN 4711234567899 · Eigenes Produkt · KMC Kette X11',
                                icon: Symbols.check_circle,
                                color: AppColors.statusColorSuccess,
                              ),
                              DemoScanOption(
                                ean: '978020137962',
                                label: 'Unbekannt',
                                subtitle:
                                    'EAN 978020137962 · Unbekanntes Produkt',
                                icon: Symbols.question_mark_rounded,
                                color: AppColors.statusColorWarning,
                              ),
                              DemoScanOption(
                                ean: '4029876501234',
                                label: 'Ungültiger Barcode',
                                subtitle:
                                    'EAN 4029876501234 · falsche Prüfziffer',
                                icon: Symbols.warning_rounded,
                                color: AppColors.statusColorError,
                              ),
                            ],
                            onEanScanned:
                                (
                                  BuildContext context,
                                  WidgetRef ref,
                                  String ean,
                                ) async {
                                  final notifier = ref.read(receivingCartProvider.notifier);
                                  switch (ean) {
                                    case '4029876501233':
                                      await notifier.addFromCatalog();
                                    case '4711234567899':
                                      await notifier.addFromOwnArticles();
                                    case '978020137962':
                                      notifier.addUnknown(ean);
                                  }
                                },
                          ),
                        ),
                      );
                    },
```

Add the import at the top of the file:

```dart
import 'package:bikedrop/providers/receiving_cart_provider.dart';
```

(`ReceivingCartSheet` is already available via the existing `import 'package:bikedrop/design_system/design_system.dart';`.)

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/features/overview_screen_test.dart`
Expected: PASS — including the pre-existing `'tapping Wareneingang opens the scanner with the demo scenario grid'` test.

- [ ] **Step 5: Run the full test suite**

Run: `flutter test`
Expected: PASS — every test file green.

- [ ] **Step 6: Commit**

```bash
git add lib/features/overview_screen.dart test/features/overview_screen_test.dart
git commit -m "feat: fill the receiving cart sheet from the Wareneingang scanner"
```

---

### Task 10: Widgetbook registration + final verification

**Files:**
- Create: `widgetbook/lib/use_cases/organisms/receiving_cart_sheet.dart`
- Modify (generated): `widgetbook/lib/main.directories.g.dart`

**Interfaces:**
- Consumes: `ReceivingCartSheet` (Task 7), `receivingCartProvider` (Task 5).

- [ ] **Step 1: Add the widgetbook use-case for the sheet**

```dart
// widgetbook/lib/use_cases/organisms/receiving_cart_sheet.dart
import 'package:bikedrop/design_system/design_system.dart';
import 'package:bikedrop/models/receivingcartitem.dart';
import 'package:bikedrop/providers/receiving_cart_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:widgetbook/widgetbook.dart' as widgetbook;
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

class _SeededCartNotifier extends ReceivingCartNotifier {
  _SeededCartNotifier(this._seed);
  final List<ReceivingCartItem> _seed;

  @override
  List<ReceivingCartItem> build() => _seed;
}

@widgetbook.UseCase(name: 'Mit Positionen', type: ReceivingCartSheet)
Widget receivingCartSheetWithItems(BuildContext context) {
  return ProviderScope(
    overrides: [
      receivingCartProvider.overrideWith(
        () => _SeededCartNotifier(const [
          ReceivingCartItem(ean: '4055123456780', quantity: 2),
          ReceivingCartItem(ean: '4711234567899', quantity: 10),
          ReceivingCartItem(ean: '978020137962', quantity: 1),
        ]),
      ),
    ],
    child: const Scaffold(body: ReceivingCartSheet()),
  );
}
```

- [ ] **Step 2: Regenerate the widgetbook directory index**

Run: `cd widgetbook && dart run build_runner build --delete-conflicting-outputs && cd ..`
Expected: Output ends with `Succeeded after ...`. `widgetbook/lib/main.directories.g.dart` is modified with entries for `ReceivingCartItemTile` and `ReceivingCartSheet`.

- [ ] **Step 3: Run the full app test suite**

Run: `flutter test`
Expected: PASS, 0 failures.

- [ ] **Step 4: Run static analysis**

Run: `flutter analyze`
Expected: `No issues found!` (fix any lints this feature introduced — e.g. unused imports — before proceeding).

- [ ] **Step 5: Commit**

```bash
git add widgetbook/lib/use_cases/organisms/receiving_cart_sheet.dart widgetbook/lib/main.directories.g.dart
git commit -m "chore: register receiving cart widgetbook use-cases"
```

## Manual QA (after all tasks)

Not a substitute for the automated tests above, but do this once before calling the feature done:

1. `flutter run` (or use the `run` skill), navigate to Bestand → "Wareneingang".
2. Tap "Katalogartikel" — confirm the sheet appears at the bottom showing 1-2 rows.
3. Tap "Katalogartikel" again a few times — confirm quantities merge instead of piling up duplicate rows for the same article (may take a couple of taps since the pick is random among 8 catalog entries).
4. Tap "Eigener Artikel" and "Unbekannt" a few times each.
5. Drag the sheet up — confirm header counts, all 3 filter chips, full list, and the "Wareneingang abschließen (N Artikel)" button appear, and that it's rendered in the light theme (white sheet, existing `AppColors` tokens) even though the original reference screenshot was dark.
6. Tap a filter chip — confirm the list narrows; tap again — confirm it clears.
7. On an "Unbekannt" row, tap "Anlegen", fill in the form, save — confirm the row now shows the check icon/"Im Bestand" and the correct name.
8. Tap "Wareneingang abschließen" — confirm it returns to the Bestand overview without altering the stock list (UI-only scope).
