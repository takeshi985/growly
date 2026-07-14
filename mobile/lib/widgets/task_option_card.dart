import 'package:flutter/material.dart';

import '../theme/growly_tokens.dart';

class TaskOptionCard extends StatelessWidget {
  const TaskOptionCard({
    super.key,
    required this.value,
    required this.label,
    required this.selected,
    required this.enabled,
    required this.onTap,
  });

  final String value;
  final String label;
  final bool selected;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: selected ? GrowlyColors.brandSoft : GrowlyColors.surface,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(GrowlyRadii.lg),
        side: BorderSide(
          color: selected ? GrowlyColors.brand : GrowlyColors.outline,
          width: selected ? 2.5 : 1,
        ),
      ),
      child: InkWell(
        onTap: enabled ? onTap : null,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: selected ? GrowlyColors.brand : GrowlyColors.canvas,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  value.characters.firstOrNull?.toUpperCase() ?? '•',
                  style: TextStyle(
                    color: selected ? Colors.white : GrowlyColors.ink,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (selected)
                const Icon(
                  Icons.check_circle_rounded,
                  color: GrowlyColors.brand,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
