import 'package:flutter/material.dart';

import '../models/progress.dart';

class ProgressSummaryCard extends StatelessWidget {
  const ProgressSummaryCard({super.key, required this.summary});

  final ProgressSummary summary;

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Общий прогресс',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              Text(
                '${summary.completionPercentage}%',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          LinearProgressIndicator(
            value: summary.completionPercentage.clamp(0, 100) / 100,
            minHeight: 10,
            borderRadius: BorderRadius.circular(99),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 16,
            runSpacing: 8,
            children: [
              Text(
                'Выполнено: ${summary.completedTasks}/${summary.totalTasks}',
              ),
              Text('Освоено навыков: ${summary.masteredSkills}'),
              Text('Повторить: ${summary.skillsNeedingReview}'),
            ],
          ),
        ],
      ),
    ),
  );
}
