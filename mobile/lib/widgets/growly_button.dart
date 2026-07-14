import 'package:flutter/material.dart';

import '../theme/growly_tokens.dart';

class GrowlyButton extends StatefulWidget {
  const GrowlyButton({
    super.key,
    required this.label,
    required this.icon,
    this.onPressed,
    this.secondary = false,
  });

  final String label;
  final IconData icon;
  final VoidCallback? onPressed;
  final bool secondary;

  @override
  State<GrowlyButton> createState() => _GrowlyButtonState();
}

class _GrowlyButtonState extends State<GrowlyButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onPressed != null;
    final child = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(widget.icon),
          const SizedBox(width: 10),
          Flexible(
            child: Text(
              widget.label,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );

    if (widget.secondary) {
      return SizedBox(
        width: double.infinity,
        child: OutlinedButton(onPressed: widget.onPressed, child: child),
      );
    }

    return Semantics(
      button: true,
      enabled: enabled,
      label: widget.label,
      child: GestureDetector(
        onTapDown: enabled ? (_) => setState(() => _pressed = true) : null,
        onTapCancel: enabled ? () => setState(() => _pressed = false) : null,
        onTapUp: enabled
            ? (_) {
                setState(() => _pressed = false);
                widget.onPressed?.call();
              }
            : null,
        child: AnimatedContainer(
          duration: GrowlyMotion.reduce(context)
              ? Duration.zero
              : GrowlyMotion.press,
          curve: GrowlyMotion.curve,
          width: double.infinity,
          transform: Matrix4.translationValues(0, _pressed ? 4 : 0, 0),
          decoration: BoxDecoration(
            color: enabled ? GrowlyColors.brand : GrowlyColors.disabled,
            borderRadius: BorderRadius.circular(GrowlyRadii.md),
            boxShadow: _pressed || !enabled
                ? const []
                : const [
                    BoxShadow(
                      color: GrowlyColors.brandPressed,
                      offset: Offset(0, 5),
                    ),
                  ],
          ),
          child: DefaultTextStyle.merge(
            style: const TextStyle(color: Colors.white),
            child: IconTheme.merge(
              data: const IconThemeData(color: Colors.white),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}
