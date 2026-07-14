import 'package:flutter/material.dart';

import '../models/gamification.dart';
import '../theme/growly_tokens.dart';
import '../widgets/growly_card.dart';
import '../widgets/growly_mascot.dart';
import '../widgets/growly_progress_bar.dart';

class DailyGoalsScreen extends StatelessWidget {
  const DailyGoalsScreen({super.key, required this.gamification});
  final GamificationSnapshot gamification;

  @override
  Widget build(BuildContext context) {
    final completed = gamification.dailyCompleted;
    final target = gamification.dailyTarget;
    return ListView(
      key: const PageStorageKey('daily-goals'),
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
      children: [
        Row(
          children: [
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Цели на сегодня',
                    style: TextStyle(fontSize: 27, fontWeight: FontWeight.w900),
                  ),
                  SizedBox(height: 5),
                  Text('Маленькие шаги — большой рост.'),
                ],
              ),
            ),
            GrowlyMascot(
              size: 76,
              mood: completed >= target ? GrowlyMood.proud : GrowlyMood.ready,
            ),
          ],
        ),
        const SizedBox(height: 20),
        GrowlyCard(
          color: GrowlyColors.brandSoft,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                completed >= target
                    ? 'Дневная цель выполнена!'
                    : 'Пройди 3 коротких задания',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              GrowlyProgressBar(
                value: completed / target,
                label: '$completed из $target заданий',
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _GoalTile(
          icon: Icons.school_rounded,
          title: 'Сделай одно задание',
          subtitle: 'Начни с самого короткого шага',
          done: completed >= 1,
        ),
        const SizedBox(height: 12),
        _GoalTile(
          icon: Icons.auto_awesome_rounded,
          title: 'Заработай 20 XP',
          subtitle: 'Любые два задания подходят',
          done: gamification.xp >= 20,
        ),
        const SizedBox(height: 12),
        _GoalTile(
          icon: Icons.local_fire_department_rounded,
          title: 'Поддержи серию',
          subtitle: 'Достаточно одного занятия сегодня',
          done: gamification.streakDays > 0,
        ),
      ],
    );
  }
}

class _GoalTile extends StatelessWidget {
  const _GoalTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.done,
  });
  final IconData icon;
  final String title;
  final String subtitle;
  final bool done;

  @override
  Widget build(BuildContext context) => GrowlyCard(
    child: Row(
      children: [
        CircleAvatar(
          radius: 25,
          backgroundColor: done
              ? GrowlyColors.successSoft
              : GrowlyColors.rewardSoft,
          child: Icon(
            done ? Icons.check_rounded : icon,
            color: done ? GrowlyColors.success : GrowlyColors.accent,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 3),
              Text(
                subtitle,
                style: const TextStyle(color: GrowlyColors.inkMuted),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
