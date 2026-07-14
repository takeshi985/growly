import 'package:flutter/material.dart';

import '../theme/growly_theme.dart';
import '../widgets/growly_card.dart';
import '../widgets/growly_mascot.dart';
import '../theme/growly_tokens.dart';

class ChildSetupScreen extends StatelessWidget {
  const ChildSetupScreen({
    super.key,
    required this.onComplete,
    required this.onBack,
  });
  final Future<void> Function({required bool connectParent}) onComplete;
  final VoidCallback onBack;
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      leading: IconButton(
        onPressed: onBack,
        icon: const Icon(Icons.arrow_back_rounded),
      ),
    ),
    body: SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 620),
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              const Center(child: GrowlyMascot(size: 100)),
              const SizedBox(height: 10),
              Text(
                'Как настроить Growly?',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 24),
              _SetupOption(
                icon: Icons.rocket_launch_rounded,
                title: 'Начать без телефона родителя',
                description:
                    'Ребёнок сможет заниматься сразу. Родителя можно подключить позже в настройках.',
                color: GrowlyTheme.softGreen,
                action: () => onComplete(connectParent: false),
              ),
              const SizedBox(height: 14),
              _SetupOption(
                icon: Icons.link_rounded,
                title: 'Подключить родителя сейчас',
                description:
                    'Покажем QR-код и 8-значный код для телефона родителя.',
                color: GrowlyTheme.softYellow,
                action: () => onComplete(connectParent: true),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

class _SetupOption extends StatelessWidget {
  const _SetupOption({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
    required this.action,
  });
  final IconData icon;
  final String title;
  final String description;
  final Color color;
  final Future<void> Function() action;
  @override
  Widget build(BuildContext context) => InkWell(
    onTap: action,
    borderRadius: BorderRadius.circular(24),
    child: GrowlyCard(
      color: color,
      padding: const EdgeInsets.all(22),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: GrowlyColors.surface,
              borderRadius: BorderRadius.circular(GrowlyRadii.md),
            ),
            child: Icon(icon, size: 31, color: GrowlyColors.brand),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 7),
                Text(description),
              ],
            ),
          ),
          const Icon(Icons.arrow_forward_rounded),
        ],
      ),
    ),
  );
}
