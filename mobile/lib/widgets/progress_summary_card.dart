import 'package:flutter/material.dart';

import '../models/progress.dart';
import '../theme/growly_tokens.dart';
import 'growly_progress_bar.dart';

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
          GrowlyProgressBar(
            value: summary.completionPercentage.clamp(0, 100) / 100,
            color: GrowlyColors.brand,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _SummaryValue(
                  value: '${summary.completedTasks}/${summary.totalTasks}',
                  label: 'заданий',
                ),
              ),
              Expanded(
                child: _SummaryValue(
                  value: '${summary.masteredSkills}',
                  label: 'освоено',
                ),
              ),
              Expanded(
                child: _SummaryValue(
                  value: '${summary.skillsNeedingReview}',
                  label: 'повторить',
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}

class _SummaryValue extends StatelessWidget {
  const _SummaryValue({required this.value, required this.label});
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Text(
        value,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
      ),
      Text(
        label,
        style: const TextStyle(fontSize: 12, color: GrowlyColors.inkMuted),
      ),
    ],
  );
}
