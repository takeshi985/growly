import 'package:flutter/material.dart';

import '../theme/growly_tokens.dart';

class GrowlyMetricChip extends StatelessWidget {
  const GrowlyMetricChip({
    super.key,
    required this.icon,
    required this.value,
    required this.label,
    this.color = GrowlyColors.brand,
  });

  final IconData icon;
  final String value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) => Semantics(
    label: '$label: $value',
    child: Container(
      constraints: const BoxConstraints(minHeight: 58),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: GrowlyColors.surface,
        borderRadius: BorderRadius.circular(GrowlyRadii.md),
        border: Border.all(color: GrowlyColors.outline),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 25),
          const SizedBox(width: 8),
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value, style: const TextStyle(fontWeight: FontWeight.w900)),
              Text(
                label,
                style: const TextStyle(
                  color: GrowlyColors.inkMuted,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}
