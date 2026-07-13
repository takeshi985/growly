import 'package:flutter/material.dart';

import '../storage/device_preferences.dart';

class RoleSelectionScreen extends StatefulWidget {
  const RoleSelectionScreen({super.key, required this.onSelected});

  final Future<void> Function(DeviceRole role) onSelected;

  @override
  State<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends State<RoleSelectionScreen> {
  bool _saving = false;

  Future<void> _select(DeviceRole role) async {
    setState(() => _saving = true);
    await widget.onSelected(role);
    if (mounted) setState(() => _saving = false);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 540),
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
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Выберите, как будет использоваться это устройство',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 28),
                _RoleCard(
                  icon: '🧒',
                  title: 'Я ребёнок',
                  subtitle: 'Здесь будут задания, уровни и подсказки.',
                  color: const Color(0xFFDDF2D8),
                  enabled: !_saving,
                  onTap: () => _select(DeviceRole.child),
                ),
                const SizedBox(height: 14),
                _RoleCard(
                  icon: '👨‍👩‍👧',
                  title: 'Я родитель',
                  subtitle: 'Здесь будет прогресс ребёнка и рекомендации.',
                  color: const Color(0xFFFFEBC4),
                  enabled: !_saving,
                  onTap: () => _select(DeviceRole.parent),
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
    required this.enabled,
    required this.onTap,
  });
  final String icon;
  final String title;
  final String subtitle;
  final Color color;
  final bool enabled;
  final VoidCallback onTap;
  @override
  State<_RoleCard> createState() => _RoleCardState();
}

class _RoleCardState extends State<_RoleCard> {
  bool _pressed = false;
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTapDown: widget.enabled ? (_) => setState(() => _pressed = true) : null,
    onTapCancel: () => setState(() => _pressed = false),
    onTapUp: widget.enabled
        ? (_) {
            setState(() => _pressed = false);
            widget.onTap();
          }
        : null,
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
