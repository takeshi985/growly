import 'package:flutter/material.dart';

import '../theme/growly_tokens.dart';

class DragCountTask extends StatefulWidget {
  const DragCountTask({
    super.key,
    required this.options,
    required this.enabled,
    required this.onChanged,
  });
  final Map<String, dynamic> options;
  final bool enabled;
  final ValueChanged<String> onChanged;
  @override
  State<DragCountTask> createState() => _DragCountTaskState();
}

class _DragCountTaskState extends State<DragCountTask> {
  late int _total;
  int _left = 0;
  int _right = 0;
  @override
  void initState() {
    super.initState();
    _total = (widget.options['total'] as num?)?.toInt() ?? 5;
    _notify();
  }

  void _notify() => widget.onChanged('left=$_left;right=$_right');
  void _drop(String basket) {
    if (!widget.enabled || _left + _right >= _total) return;
    setState(() {
      if (basket == 'left') {
        _left++;
      } else {
        _right++;
      }
      _notify();
    });
  }

  void _reset() => setState(() {
    _left = 0;
    _right = 0;
    _notify();
  });
  @override
  Widget build(BuildContext context) {
    final remaining = _total - _left - _right;
    return Column(
      children: [
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 8,
          runSpacing: 8,
          children: List.generate(
            remaining,
            (index) => Draggable<String>(
              data: 'apple-$index',
              feedback: const Material(
                color: Colors.transparent,
                child: Icon(
                  Icons.apple_rounded,
                  size: 48,
                  color: Color(0xFFC9505A),
                ),
              ),
              childWhenDragging: const Icon(
                Icons.circle_outlined,
                size: 38,
                color: Color(0xFFB8C3BF),
              ),
              maxSimultaneousDrags: widget.enabled ? 1 : 0,
              child: const Icon(
                Icons.apple_rounded,
                size: 44,
                color: Color(0xFFC9505A),
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(
              child: _Basket(
                id: 'left',
                count: _left,
                onAccept: (_) => _drop('left'),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _Basket(
                id: 'right',
                count: _right,
                onAccept: (_) => _drop('right'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        TextButton.icon(
          onPressed: widget.enabled ? _reset : null,
          icon: const Icon(Icons.refresh_rounded),
          label: const Text('Начать сначала'),
        ),
      ],
    );
  }
}

class _Basket extends StatefulWidget {
  const _Basket({
    required this.id,
    required this.count,
    required this.onAccept,
  });
  final String id;
  final int count;
  final ValueChanged<String> onAccept;
  @override
  State<_Basket> createState() => _BasketState();
}

class _BasketState extends State<_Basket> {
  bool _hovering = false;
  @override
  Widget build(BuildContext context) => DragTarget<String>(
    onWillAcceptWithDetails: (_) {
      setState(() => _hovering = true);
      return true;
    },
    onLeave: (_) => setState(() => _hovering = false),
    onAcceptWithDetails: (details) {
      setState(() => _hovering = false);
      widget.onAccept(details.data);
    },
    builder: (context, _, _) => AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      height: 128,
      decoration: BoxDecoration(
        color: _hovering ? GrowlyColors.rewardSoft : GrowlyColors.accentSoft,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: _hovering ? GrowlyColors.accent : Colors.transparent,
          width: 3,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.shopping_basket_rounded,
            size: 48,
            color: Color(0xFF8B5A2B),
          ),
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: widget.count.toDouble()),
            duration: const Duration(milliseconds: 220),
            builder: (context, value, _) => Text(
              '${value.round()} яблок',
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
    ),
  );
}
