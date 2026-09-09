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
        mainAxisSize: MainAxisSize.min,
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
