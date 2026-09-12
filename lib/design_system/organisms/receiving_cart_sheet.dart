import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../enums/receiving_scan_status.dart';
import '../../features/article_form_screen.dart';
import '../../models/receivingcartitem.dart';
import '../../providers/article_repository_provider.dart';
import '../../providers/receiving_cart_provider.dart';
import '../tokens/app_colors.dart';
import '../tokens/app_spacing.dart';
import 'receiving_cart_sheet_content.dart';

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
  static const double _minSize = 0.28;
  static const double _maxSize = 0.85;
  static const double _expandThreshold = 0.5;

  final _controller = DraggableScrollableController();

  /// `null` = kein Filter (beide Abschnitte sichtbar), `true`/`false` blendet
  /// auf "Ergänzung nötig" bzw. "Vollständige Artikel" ein.
  bool? _groupFilter;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Springt direkt auf Peek- oder volle Ansicht — bewusst [jumpTo] statt
  /// eines animierten [DraggableScrollableController.animateTo]: Der
  /// Wechsel aendert die Widget-Struktur (Kopfzeile, Filter-Chips,
  /// Footer-Button erscheinen/verschwinden). Passiert das waehrend eine
  /// animateTo()-Animation noch laeuft, bricht DraggableScrollableSheet die
  /// Animation an ihrem aktuellen Wert ab, statt sie zu Ende zu fuehren.
  /// jumpTo hat keinen Ticker, den ein struktureller Rebuild unterbrechen
  /// koennte.
  void _toggleExpanded(bool expanded) =>
      _controller.jumpTo(expanded ? _minSize : _maxSize);

  Future<void> _openAnlegenForm(ReceivingCartItem item) async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (_) => ArticleFormScreen(
          catalogArticle: item.catalogData,
          scannedEan: item.ean,
          scannedName: item.suggestedName,
        ),
      ),
    );
    if (!mounted) return;
    final resolved = await ref
        .read(articleRepositoryProvider)
        .getArticleByEan(item.ean);
    if (resolved != null) {
      ref.read(receivingCartProvider.notifier).resolveUnknown(item, resolved);
    }
  }

  @override
  Widget build(BuildContext context) {
    final items = ref.watch(receivingCartProvider);
    if (items.isEmpty) return const SizedBox.shrink();

    final totalQuantity = items.fold<int>(
      0,
      (sum, item) => sum + item.quantity,
    );
    final counts = <ReceivingScanStatus, int>{
      for (final status in ReceivingScanStatus.values)
        status: items.where((item) => item.scanStatus == status).length,
    };
    final openCount = counts[ReceivingScanStatus.unknown] ?? 0;
    final summary =
        '${items.length} Positionen · $totalQuantity Stk · $openCount offen';

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
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(AppSpacing.dialogRadius),
            ),
          ),

          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, _) {
              final expanded =
                  _controller.isAttached &&
                  _controller.size >= _expandThreshold;
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
                onQuantityChanged: (item, quantity) => ref
                    .read(receivingCartProvider.notifier)
                    .updateQuantity(item, quantity),
                onAnlegenTap: _openAnlegenForm,
                onToggleExpand: () => _toggleExpanded(expanded),
              );
            },
          ),
        );
      },
    );
  }
}
