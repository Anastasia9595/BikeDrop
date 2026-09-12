import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../enums/receiving_scan_status.dart';
import '../../models/receivingcartitem.dart';
import '../atoms/app_drag_handle.dart';
import '../atoms/app_icon_button.dart';
import '../atoms/app_primary_button.dart';
import '../molecules/list_section_header.dart';
import '../molecules/receiving_cart_item_tile.dart';
import '../tokens/app_colors.dart';
import '../tokens/app_spacing.dart';
import '../tokens/app_typography.dart';
import 'kpi_filter_row.dart';

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

  /// `null` = kein Filter (beide Abschnitte sichtbar), `true` blendet auf
  /// "Ergänzung nötig" ein, `false` auf "Vollständige Artikel".
  final bool? groupFilter;
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
        : groupFilter == null
        ? items
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
          // (flach vs. nach Status gruppiert), nicht der Widget-Typ. Wuerde
          // hier je nach [expanded] zwischen z.B. ListView und
          // CustomScrollView gewechselt, wuerde Flutter trotz gleichem Key
          // die Scroll-Position verwerfen, weil sich der runtimeType aendert.
          child: CustomScrollView(
            key: const ValueKey('receiving-cart-list'),
            physics: const ClampingScrollPhysics(),
            slivers: expanded
                ? _groupedSlivers(visible)
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

  /// Baut die zwei Abschnitte "Ergaenzung noetig" (unknown + catalogMatch)
  /// und "Vollstaendige Artikel" (inStock) als eigene Sliver-Gruppen. Ein
  /// leerer Abschnitt faellt komplett weg, statt einen Header ohne Zeilen
  /// darunter zu zeigen.
  List<Widget> _groupedSlivers(List<ReceivingCartItem> source) {
    final needsCompletion = source
        .where((item) => item.scanStatus.needsCompletion)
        .toList();
    final complete = source
        .where((item) => !item.scanStatus.needsCompletion)
        .toList();

    return [
      ..._sectionSlivers('Ergänzung nötig', needsCompletion),
      ..._sectionSlivers('Vollständige Artikel', complete),
    ];
  }

  List<Widget> _sectionSlivers(String title, List<ReceivingCartItem> section) {
    if (section.isEmpty) return const [];
    return [
      SliverToBoxAdapter(
        child: ListSectionHeader(title: title, count: section.length),
      ),
      _itemSliver(section),
    ];
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
          KpiFilterRow(
            entries: [
              KpiFilterEntry(
                key: true,
                label: 'Ergänzung nötig',
                color: AppColors.receivingStatusColors[ReceivingScanStatus.unknown]!,
                tint: AppColors.receivingStatusTints[ReceivingScanStatus.unknown]!,
                count:
                    (counts[ReceivingScanStatus.unknown] ?? 0) +
                    (counts[ReceivingScanStatus.catalogMatch] ?? 0),
              ),
              KpiFilterEntry(
                key: false,
                label: 'Vollständige Artikel',
                color: AppColors.receivingStatusColors[ReceivingScanStatus.inStock]!,
                tint: AppColors.receivingStatusTints[ReceivingScanStatus.inStock]!,
                count: counts[ReceivingScanStatus.inStock] ?? 0,
              ),
            ],
            selectedKey: groupFilter,
            onEntryTap: (key) => onFilterTap(key as bool),
          ),
        ],
      ),
    );
  }
}
