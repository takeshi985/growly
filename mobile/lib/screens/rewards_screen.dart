import 'package:flutter/material.dart';

import '../models/gamification.dart';
import '../theme/growly_tokens.dart';
import '../widgets/growly_card.dart';
import '../widgets/growly_mascot.dart';

class RewardsScreen extends StatelessWidget {
  const RewardsScreen({super.key, required this.gamification});
  final GamificationSnapshot gamification;

  @override
  Widget build(BuildContext context) => ListView(
    key: const PageStorageKey('rewards'),
    padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
    children: [
      const Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Мои награды',
                  style: TextStyle(fontSize: 27, fontWeight: FontWeight.w900),
                ),
                SizedBox(height: 5),
                Text('Здесь живут твои учебные победы.'),
              ],
            ),
          ),
          GrowlyMascot(size: 76, mood: GrowlyMood.proud),
        ],
      ),
      const SizedBox(height: 20),
      GrowlyCard(
        color: GrowlyColors.rewardSoft,
        child: Row(
          children: [
            const Icon(
              Icons.stars_rounded,
              size: 46,
              color: GrowlyColors.accent,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${gamification.xp} XP',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const Text('Каждый балл заработан за настоящее задание.'),
                ],
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: 22),
      Text('Значки', style: Theme.of(context).textTheme.titleLarge),
      const SizedBox(height: 12),
      GridView.extent(
        maxCrossAxisExtent: 180,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: .92,
        children: [
          _Badge(
            icon: Icons.flag_rounded,
            title: 'Первый шаг',
            unlocked: gamification.xp >= 10,
          ),
          _Badge(
            icon: Icons.calculate_rounded,
            title: 'Исследователь чисел',
            unlocked: gamification.xp >= 30,
          ),
          _Badge(
            icon: Icons.local_fire_department_rounded,
            title: 'Серия',
            unlocked: gamification.streakDays >= 2,
          ),
          const _Badge(
            icon: Icons.workspace_premium_rounded,
            title: 'Новая вершина',
            unlocked: false,
          ),
        ],
      ),
    ],
  );
}

class _Badge extends StatelessWidget {
  const _Badge({
    required this.icon,
    required this.title,
    required this.unlocked,
  });
  final IconData icon;
  final String title;
  final bool unlocked;

  @override
  Widget build(BuildContext context) => Semantics(
    label: '$title, ${unlocked ? 'получен' : 'ещё не открыт'}',
    child: GrowlyCard(
      padding: const EdgeInsets.all(10),
      color: unlocked ? GrowlyColors.rewardSoft : GrowlyColors.surface,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            unlocked ? icon : Icons.lock_rounded,
            size: 44,
            color: unlocked ? GrowlyColors.accent : GrowlyColors.disabled,
          ),
          const SizedBox(height: 10),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.w800),
          ),
        ],
      ),
    ),
  );
}
