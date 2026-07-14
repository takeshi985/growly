import 'package:flutter/material.dart';

import '../storage/device_preferences.dart';
import '../theme/growly_theme.dart';

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key, required this.onSelected});

  final ValueChanged<DeviceRole> onSelected;

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('🌱', style: TextStyle(fontSize: 64)),
                Text(
                  'Growly',
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: GrowlyTheme.darkGreen,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Выберите, как будет использоваться это устройство',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 28),
                _RoleCard(
                  icon: '🧒',
                  title: 'Ребёнок',
                  subtitle: 'Задания, уровни, подсказки и карта обучения',
                  color: GrowlyTheme.softGreen,
                  onTap: () => onSelected(DeviceRole.child),
                ),
                const SizedBox(height: 14),
                _RoleCard(
                  icon: '👨‍👩‍👧',
                  title: 'Родитель',
                  subtitle: 'Прогресс ребёнка, рекомендации и отчёты',
                  color: GrowlyTheme.softYellow,
                  onTap: () => onSelected(DeviceRole.parent),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

class _RoleCard extends StatefulWidget {
  const _RoleCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });
  final String icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;
  @override
  State<_RoleCard> createState() => _RoleCardState();
}

class _RoleCardState extends State<_RoleCard> {
  bool _pressed = false;
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTapDown: (_) => setState(() => _pressed = true),
    onTapCancel: () => setState(() => _pressed = false),
    onTapUp: (_) {
      setState(() => _pressed = false);
      widget.onTap();
    },
    child: AnimatedScale(
      duration: const Duration(milliseconds: 140),
      scale: _pressed ? .98 : 1,
      child: Card(
        color: widget.color,
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: Row(
            children: [
              Text(widget.icon, style: const TextStyle(fontSize: 42)),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title,
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 5),
                    Text(widget.subtitle),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_rounded),
            ],
          ),
        ),
      ),
    ),
  );
}
