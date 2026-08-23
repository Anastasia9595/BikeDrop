// lib/design_system/molecules/quantity_stepper.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:material_symbols_icons/symbols.dart';
import '../atoms/app_icon_button.dart';
import '../tokens/app_colors.dart';
import '../tokens/app_spacing.dart';
import '../tokens/app_typography.dart';

class QuantityStepper extends StatefulWidget {
  const QuantityStepper({
    required this.label,
    required this.quantity,
    required this.onChanged,
    this.min = 0,
    this.max,
    this.editable = false,
    this.showBorder = true,
    this.showLabel = true,
    super.key,
  });

  final int quantity;
  final ValueChanged<int> onChanged;
  final int min;
  final int? max;
  final String label;

  /// Wenn true, ist die Zahl in der Mitte wie ein Textfeld direkt
  /// editierbar (nur Ziffern erlaubt), statt nur über +/- änderbar zu sein.
  final bool editable;

  /// Blendet den Rahmen um -/Zahl/+ aus, z. B. wenn der Aufrufer das
  /// Feld bereits in einen eigenen Container einbettet.
  final bool showBorder;

  /// Blendet das Label über dem Feld aus, z. B. wenn der Aufrufer es
  /// selbst rendert (etwa zusammen mit einer Delta-Anzeige in einer Row).
  final bool showLabel;

  @override
  State<QuantityStepper> createState() => _QuantityStepperState();
}

class _QuantityStepperState extends State<QuantityStepper> {
  late final TextEditingController _controller = TextEditingController(
    text: '${widget.quantity}',
  );

  @override
  void didUpdateWidget(covariant QuantityStepper oldWidget) {
    super.didUpdateWidget(oldWidget);
    final text = '${widget.quantity}';
    if (widget.quantity != oldWidget.quantity && _controller.text != text) {
      _controller.value = TextEditingValue(
        text: text,
        selection: TextSelection.collapsed(offset: text.length),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool get _canDecrement => widget.quantity > widget.min;
  bool get _canIncrement => widget.max == null || widget.quantity < widget.max!;

  int _clamp(int value) {
    final max = widget.max;
    if (value < widget.min) return widget.min;
    if (max != null && value > max) return max;
    return value;
  }

  void _submit(String value) {
    final parsed = int.tryParse(value);
    if (parsed == null) {
      _controller.text = '${widget.quantity}';
      return;
    }
    final clamped = _clamp(parsed);
    if (clamped != widget.quantity) {
      widget.onChanged(clamped);
    } else {
      _controller.text = '$clamped';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.showLabel) ...[
          Text(
            widget.label.toUpperCase(),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.fieldLabel,
          ),
          const SizedBox(height: 6),
        ],
        Container(
          height: AppSpacing.fieldHeight,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppSpacing.buttonRadius),
            border:
                widget.showBorder
                    ? Border.all(
                      color: AppColors.border,
                      width: AppSpacing.fieldBorderWidth,
                    )
                    : null,
          ),
          child: Row(
            children: [
              AppIconButton(
                icon: Symbols.remove,
                tooltip: 'Menge verringern',
                onPressed:
                    _canDecrement
                        ? () => widget.onChanged(widget.quantity - 1)
                        : null,
              ),
              Expanded(
                child: Center(
                  child:
                      widget.editable
                          ? TextField(
                            controller: _controller,
                            textAlign: TextAlign.center,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            style: AppTypography.listNumber.copyWith(
                              color: AppColors.textPrimary,
                            ),
                            decoration: const InputDecoration(
                              isCollapsed: true,
                              border: InputBorder.none,
                            ),
                            onSubmitted: _submit,
                            onTapOutside: (_) {
                              _submit(_controller.text);
                              FocusManager.instance.primaryFocus?.unfocus();
                            },
                          )
                          : Text(
                            '${widget.quantity}',
                            style: AppTypography.listNumber.copyWith(
                              color: AppColors.textPrimary,
                            ),
                          ),
                ),
              ),
              AppIconButton(
                icon: Symbols.add,
                tooltip: 'Menge erhöhen',
                onPressed:
                    _canIncrement
                        ? () => widget.onChanged(widget.quantity + 1)
                        : null,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
