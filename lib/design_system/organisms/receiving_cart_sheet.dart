import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../enums/receiving_scan_status.dart';
import '../../features/article_form_screen.dart';
import '../../models/receivingcartitem.dart';
import '../../providers/article_repository_provider.dart';
import '../../providers/receiving_cart_provider.dart';
import '../atoms/app_icon_button.dart';
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
  /// Passt Drag-Handle + Kopfzeile + bis zu 2 Vorschau-Zeilen bequem hinein
  /// (~220-230dp) — kleiner gewaehlt zeigt die (lazy gebaute) Liste im
  /// Peek-Zustand unzuverlaessig nur 1 statt 2 Zeilen, je nach Bildschirmhoehe.
  static const double _minSize = 0.28;
  static const double _maxSize = 0.85;

  /// Erst ab hier zeigen wir die volle Ansicht (Kopfzeile, Filter-Chips,
  /// Liste, CTA-Button) — deren fixer Rahmen (ohne die Liste selbst)
  /// braucht ca. 250-260dp. Bei einem niedrigeren Schwellenwert kann die
  /// Box waehrend des Ziehens kurzzeitig kleiner sein als dieser fixe
  /// Rahmen und einen RenderFlex-Overflow ausloesen.
  static const double _expandThreshold = 0.5;

  final _controller = DraggableScrollableController();
  ReceivingScanStatus? _filter;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Springt direkt auf die volle Ansicht — bewusst [jumpTo] statt eines
  /// animierten [DraggableScrollableController.animateTo]: Der Wechsel von
  /// Peek- zu voller Ansicht aendert die Widget-Struktur (Kopfzeile,
  /// Filter-Chips, Footer-Button erscheinen/verschwinden). Passiert das
  /// waehrend eine animateTo()-Animation noch laeuft, bricht
  /// DraggableScrollableSheet die Animation an ihrem aktuellen Wert ab,
  /// statt sie zu Ende zu fuehren. jumpTo hat keinen Ticker, den ein
  /// struktureller Rebuild unterbrechen koennte.
  void _expand() => _controller.jumpTo(_maxSize);

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
          // Bewusst ein lokal auf _controller hoerendes AnimatedBuilder statt
          // eines setState() im aeusseren State: DraggableScrollableSheet
          // ruft seinen eigenen builder NICHT bei jeder Groessenaenderung
          // (Drag/animateTo) neu auf, und ein setState() hier aussen wuerde
          // eine neue DraggableScrollableSheet-Instanz erzeugen, was dessen
          // didUpdateWidget die laufende Animation abbrechen laesst (sie
          // friert beim aktuellen Wert ein). Das AnimatedBuilder rebuilt nur
          // sich selbst bei jeder Notification, ohne das Sheet-Widget
          // anzufassen.
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, _) {
              final expanded = _controller.isAttached && _controller.size >= _expandThreshold;
              return _SheetContent(
                items: items,
                summary: summary,
                counts: counts,
                filter: _filter,
                expanded: expanded,
                scrollController: scrollController,
                onFilterTap: (status) => setState(() => _filter = _filter == status ? null : status),
                onQuantityChanged: (item, quantity) =>
                    ref.read(receivingCartProvider.notifier).updateQuantity(item, quantity),
                onAnlegenTap: _openAnlegenForm,
                onExpandTap: _expand,
              );
            },
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

/// Peek- und volle Ansicht teilen sich bewusst EINE [ListView] (per [Key]
/// stabil ueber Rebuilds hinweg identifiziert), statt zwischen zwei
/// unterschiedlichen Scrollable-Widgets (z.B. SingleChildScrollView vs.
/// ListView) am selben [scrollController] zu wechseln. Ein Wechsel des
/// Scrollable-*Typs* haengt eine neue ScrollPosition an denselben
/// Controller — das bringt DraggableScrollableSheet's interne
/// Groessen-Verfolgung durcheinander und friert eine gerade laufende
/// Drag-/animateTo()-Animation beim aktuellen Wert ein.
class _SheetContent extends StatelessWidget {
  const _SheetContent({
    required this.items,
    required this.summary,
    required this.counts,
    required this.filter,
    required this.expanded,
    required this.scrollController,
    required this.onFilterTap,
    required this.onQuantityChanged,
    required this.onAnlegenTap,
    required this.onExpandTap,
  });

  final List<ReceivingCartItem> items;
  final String summary;
  final Map<ReceivingScanStatus, int> counts;
  final ReceivingScanStatus? filter;
  final bool expanded;
  final ScrollController scrollController;
  final ValueChanged<ReceivingScanStatus> onFilterTap;
  final void Function(ReceivingCartItem item, int quantity) onQuantityChanged;
  final void Function(ReceivingCartItem item) onAnlegenTap;

  /// Zieht das Sheet programmatisch auf die volle Ansicht hoch — die
  /// Alternative zum Drag-Gestus fuer alle, die lieber tippen.
  final VoidCallback onExpandTap;

  @override
  Widget build(BuildContext context) {
    final visible = !expanded
        ? items.take(2).toList()
        : filter == null
        ? items
        : items.where((item) => item.scanStatus == filter).toList();

    return Column(
      children: [
        _dragHandle(),
        expanded ? _buildExpandedHeader() : _buildPeekHeader(),
        if (expanded) const Divider(height: 1, color: AppColors.listDivider),
        Expanded(
          child: ListView.separated(
            key: const ValueKey('receiving-cart-list'),
            controller: scrollController,
            physics: const ClampingScrollPhysics(),
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
        if (expanded)
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

  Widget _buildPeekHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPaddingH),
      child: Row(
        children: [
          Expanded(
            child: Text(
              summary,
              style: AppTypography.body.copyWith(fontSize: 13, color: AppColors.textSecondary),
            ),
          ),
          AppIconButton(
            icon: Symbols.open_in_full,
            tooltip: 'Warenkorb ganz anzeigen',
            onPressed: onExpandTap,
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
    );
  }
}
