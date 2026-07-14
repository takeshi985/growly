import 'package:flutter/material.dart';

import '../theme/growly_tokens.dart';
import '../widgets/growly_button.dart';
import '../widgets/growly_card.dart';
import '../widgets/growly_mascot.dart';

class LessonResultScreen extends StatelessWidget {
  const LessonResultScreen({
    super.key,
    required this.correctAnswers,
    required this.elapsed,
    required this.xp,
  });

  final int correctAnswers;
  final Duration elapsed;
  final int xp;

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: Column(
              children: [
                const GrowlyMascot(size: 132, mood: GrowlyMood.proud),
                const SizedBox(height: 14),
                Text(
                  'Маршрут пройден!',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.displaySmall,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Ты не сдавался и сделал ещё один шаг вперёд.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: _ResultMetric(
                        icon: Icons.check_circle_rounded,
                        value: '$correctAnswers',
                        label: 'верных',
                        color: GrowlyColors.success,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _ResultMetric(
                        icon: Icons.stars_rounded,
                        value: '+$xp',
                        label: 'XP',
                        color: GrowlyColors.accent,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _ResultMetric(
                        icon: Icons.timer_rounded,
                        value: _durationLabel(elapsed),
                        label: 'время',
                        color: GrowlyColors.imagination,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                const GrowlyCard(
                  color: GrowlyColors.rewardSoft,
                  child: Row(
                    children: [
                      Icon(
                        Icons.workspace_premium_rounded,
                        size: 42,
                        color: GrowlyColors.accent,
                      ),
                      SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Награда за старание',
                              style: TextStyle(fontWeight: FontWeight.w900),
                            ),
                            SizedBox(height: 3),
                            Text('Звезда маршрута добавлена в коллекцию.'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 26),
                GrowlyButton(
                  label: 'Вернуться к маршруту',
                  icon: Icons.arrow_forward_rounded,
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

class _ResultMetric extends StatelessWidget {
  const _ResultMetric({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) => GrowlyCard(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 15),
    child: Column(
      children: [
        Icon(icon, color: color, size: 29),
        const SizedBox(height: 7),
        Text(
          value,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: GrowlyColors.inkMuted),
        ),
      ],
    ),
  );
}

String _durationLabel(Duration duration) {
  final minutes = duration.inMinutes;
  final seconds = duration.inSeconds.remainder(60);
  return minutes > 0
      ? '$minutes:${seconds.toString().padLeft(2, '0')}'
      : '$secondsс';
}
