import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hugeicons/hugeicons.dart';

import 'cart_colors.dart';

/// Pill-shaped quantity stepper used inside the cart item card.
/// Tapping the number turns it into an editable field so the user can
/// type a quantity directly instead of tapping +/- repeatedly.
class CartQtyStepper extends StatefulWidget {
  const CartQtyStepper({
    super.key,
    required this.value,
    required this.onChanged,
    this.maxValue,
    this.onLimitExceeded,
  });

  final int value;
  final ValueChanged<int> onChanged;
  final int? maxValue;
  final ValueChanged<int>? onLimitExceeded;

  @override
  State<CartQtyStepper> createState() => _CartQtyStepperState();
}

class _CartQtyStepperState extends State<CartQtyStepper> {
  bool _editing = false;
  late final TextEditingController _controller = TextEditingController(
    text: '${widget.value}',
  );
  late final FocusNode _focusNode = FocusNode()
    ..addListener(() {
      if (!_focusNode.hasFocus && _editing) _commit();
    });

  @override
  void didUpdateWidget(covariant CartQtyStepper oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_editing && oldWidget.value != widget.value) {
      _controller.text = '${widget.value}';
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _startEditing() {
    setState(() {
      _editing = true;
      _controller.text = '${widget.value}';
      _controller.selection = TextSelection(
        baseOffset: 0,
        extentOffset: _controller.text.length,
      );
    });
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _focusNode.requestFocus(),
    );
  }

  void _commit() {
    final parsed = int.tryParse(_controller.text.trim());
    var next = (parsed == null || parsed < 1) ? 1 : parsed;
    final max = widget.maxValue;
    if (max != null && next > max) {
      next = max < 1 ? widget.value : max;
      HapticFeedback.mediumImpact();
      widget.onLimitExceeded?.call(max);
    }
    setState(() {
      _editing = false;
      _controller.text = '$next';
    });
    if (next != widget.value) widget.onChanged(next);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 36,
      decoration: BoxDecoration(
        color: cartPrimarySoft,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _CartStepBtn(
            icon: HugeIcons.strokeRoundedRemove01,
            onTap: widget.value > 1
                ? () => widget.onChanged(widget.value - 1)
                : null,
          ),
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: _editing ? null : _startEditing,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: _editing
                  ? SizedBox(
                      width: 30,
                      child: TextField(
                        controller: _controller,
                        focusNode: _focusNode,
                        autofocus: true,
                        textAlign: TextAlign.center,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: cartInk,
                        ),
                        decoration: const InputDecoration(
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                          border: InputBorder.none,
                        ),
                        onSubmitted: (_) => _commit(),
                        onTapOutside: (_) => _commit(),
                      ),
                    )
                  : Text(
                      '${widget.value}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: cartInk,
                      ),
                    ),
            ),
          ),
          _CartStepBtn(
            icon: HugeIcons.strokeRoundedAdd01,
            onTap: () {
              final max = widget.maxValue;
              if (max != null && widget.value >= max) {
                HapticFeedback.mediumImpact();
                widget.onLimitExceeded?.call(max);
                return;
              }
              widget.onChanged(widget.value + 1);
            },
          ),
        ],
      ),
    );
  }
}

class _CartStepBtn extends StatelessWidget {
  const _CartStepBtn({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: SizedBox(
        width: 36,
        height: 36,
        child: Icon(
          icon,
          size: 17,
          color: enabled ? cartPrimaryDeep : cartMuted.withAlpha(100),
        ),
      ),
    );
  }
}
