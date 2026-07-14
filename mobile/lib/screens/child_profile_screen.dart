import 'package:flutter/material.dart';

import '../models/child_profile.dart';
import '../models/gamification.dart';
import '../theme/growly_tokens.dart';
import '../widgets/growly_button.dart';
import '../widgets/growly_card.dart';
import '../widgets/growly_mascot.dart';
import '../widgets/growly_metric_chip.dart';
import '../widgets/growly_progress_bar.dart';

class ChildProfileScreen extends StatelessWidget {
  const ChildProfileScreen({
    super.key,
    required this.child,
    required this.gamification,
    required this.onOpenPairing,
    required this.onOpenSettings,
  });

  final ChildProfile child;
  final GamificationSnapshot gamification;
  final VoidCallback onOpenPairing;
  final VoidCallback onOpenSettings;

  @override
  Widget build(BuildContext context) => ListView(
    key: const PageStorageKey('child-profile'),
    padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
    children: [
      GrowlyCard(
        color: GrowlyColors.brandSoft,
        child: Row(
          children: [
            const GrowlyMascot(size: 88, mood: GrowlyMood.happy),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    child.name,
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  Text('${child.age} лет · уровень ${gamification.level}'),
                ],
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: 16),
      Row(
        children: [
          Expanded(
            child: GrowlyMetricChip(
              icon: Icons.stars_rounded,
              value: '${gamification.xp}',
              label: 'XP',
              color: GrowlyColors.accent,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: GrowlyMetricChip(
              icon: Icons.local_fire_department_rounded,
              value: '${gamification.streakDays}',
              label: 'серия',
              color: GrowlyColors.accent,
            ),
          ),
        ],
      ),
      const SizedBox(height: 16),
      GrowlyCard(
        child: GrowlyProgressBar(
          value: gamification.levelProgress,
          label: 'Путь до уровня ${gamification.level + 1}',
        ),
      ),
      const SizedBox(height: 22),
      GrowlyButton(
        label: 'Подключить родителя',
        icon: Icons.link_rounded,
        secondary: true,
        onPressed: onOpenPairing,
      ),
      const SizedBox(height: 12),
      GrowlyButton(
        label: 'Настройки',
        icon: Icons.settings_rounded,
        secondary: true,
        onPressed: onOpenSettings,
      ),
    ],
  );
}
