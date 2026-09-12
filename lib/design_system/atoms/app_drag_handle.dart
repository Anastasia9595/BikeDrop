import 'package:flutter/material.dart';

import '../tokens/app_colors.dart';

/// Ziehgriff am oberen Rand eines Bottom Sheets. Haengt optional an einem
/// [scrollController], damit eine Ziehbewegung auf dem Griff selbst dort
/// landet, statt vom darunterliegenden scrollbaren Inhalt geschluckt zu
/// werden — sein Inhalt ist exakt so hoch wie sein eigenes Viewport, kann
/// also selbst nie scrollen, jede Ziehbewegung hier wird komplett an den
/// [scrollController] weitergereicht.
class AppDragHandle extends StatelessWidget {
  const AppDragHandle({required this.scrollController, super.key});

  final ScrollController scrollController;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 28,
      width: double.infinity,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SingleChildScrollView(
            key: const ValueKey('receiving-cart-drag-handle'),
            controller: scrollController,
            physics: const ClampingScrollPhysics(),
            child: const SizedBox(height: 28, width: double.infinity),
          ),
          IgnorePointer(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
