import 'package:flutter/material.dart';

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
    final colors = Theme.of(context).colorScheme;
    return Card(
      color: selected ? colors.primaryContainer : colors.surface,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: enabled ? onTap : null,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: selected ? colors.primary : colors.secondaryContainer,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  value.characters.firstOrNull?.toUpperCase() ?? '•',
                  style: TextStyle(
                    color: selected
                        ? colors.onPrimary
                        : colors.onSecondaryContainer,
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
              if (selected) const Icon(Icons.check_circle_rounded),
            ],
          ),
        ),
      ),
    );
  }
}
