import 'package:flutter/material.dart';

import '../theme/growly_tokens.dart';

class GrowlyProgressBar extends StatelessWidget {
  const GrowlyProgressBar({
    super.key,
    required this.value,
    this.label,
    this.color = GrowlyColors.brand,
    this.height = 12,
  });

  final double value;
  final String? label;
  final Color color;
  final double height;

  @override
  Widget build(BuildContext context) {
    final normalized = value.clamp(0.0, 1.0);
    return Semantics(
      label: label ?? 'Прогресс',
      value: '${(normalized * 100).round()}%',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (label != null) ...[
            Text(label!, style: Theme.of(context).textTheme.labelMedium),
            const SizedBox(height: 7),
          ],
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: normalized),
            duration: GrowlyMotion.reduce(context)
                ? Duration.zero
                : GrowlyMotion.standard,
            curve: GrowlyMotion.curve,
            builder: (context, current, _) => ClipRRect(
              borderRadius: BorderRadius.circular(GrowlyRadii.pill),
              child: LinearProgressIndicator(
                value: current,
                minHeight: height,
                color: color,
                backgroundColor: GrowlyColors.outline,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
