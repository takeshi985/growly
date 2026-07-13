import 'package:flutter/material.dart';

import '../api/growly_api_client.dart';
import '../models/progress.dart';
import '../widgets/error_state.dart';
import '../widgets/loading_state.dart';
import '../widgets/progress_summary_card.dart';

class ParentProgressScreen extends StatefulWidget {
  const ParentProgressScreen({
    super.key,
    required this.apiClient,
    required this.childId,
  });

  final GrowlyApiClient apiClient;
  final int childId;

  @override
  State<ParentProgressScreen> createState() => _ParentProgressScreenState();
}

class _ParentProgressScreenState extends State<ParentProgressScreen> {
  late Future<ParentProgress> _progress;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() => setState(() {
    _progress = widget.apiClient.parentProgress(widget.childId);
  });

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Прогресс ребёнка')),
    body: SafeArea(
      child: FutureBuilder<ParentProgress>(
        future: _progress,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const LoadingState(message: 'Собираем понятный отчёт…');
          }
          if (snapshot.hasError || !snapshot.hasData) {
            return ErrorState(message: '${snapshot.error}', onRetry: _load);
          }
          return _content(snapshot.data!);
        },
      ),
    ),
  );

  Widget _content(ParentProgress progress) => RefreshIndicator(
    onRefresh: () async => _load(),
    child: ListView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
      children: [
        Card(
          child: ListTile(
            contentPadding: const EdgeInsets.all(18),
            leading: CircleAvatar(
              child: Text(progress.child.name.characters.first),
            ),
            title: Text(
              progress.child.name,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
            ),
            subtitle: Text('${progress.child.age} лет'),
          ),
        ),
        const SizedBox(height: 14),
        ProgressSummaryCard(summary: progress.summary),
        const SizedBox(height: 24),
        Text('Навыки', style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 12),
        for (final skill in progress.skills) ...[
          _SkillCard(skill: skill),
          const SizedBox(height: 12),
        ],
        if (progress.recommendations.isNotEmpty) ...[
          const SizedBox(height: 12),
          Text(
            'Рекомендации',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 12),
          for (final recommendation in progress.recommendations) ...[
            Card(
              color: Theme.of(context).colorScheme.secondaryContainer,
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      recommendation.title,
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 6),
                    Text(recommendation.message),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
          ],
        ],
      ],
    ),
  );
}

class _SkillCard extends StatelessWidget {
  const _SkillCard({required this.skill});

  final SkillProgress skill;

  @override
  Widget build(BuildContext context) {
    final needsReview = skill.status == 'needs_review';
    return Card(
      color: needsReview
          ? Theme.of(context).colorScheme.tertiaryContainer
          : Theme.of(context).colorScheme.surface,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    skill.title,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                Chip(label: Text(skill.statusLabel)),
              ],
            ),
            Text(skill.areaLabel),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: skill.completionPercentage.clamp(0, 100) / 100,
              minHeight: 8,
              borderRadius: BorderRadius.circular(99),
            ),
            const SizedBox(height: 8),
            Text(
              '${skill.completionPercentage}% · ошибок: '
              '${skill.incorrectAttemptsCount} · подсказок: ${skill.hintsUsedCount}',
            ),
            if (skill.statusDescription.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(skill.statusDescription),
            ],
          ],
        ),
      ),
    );
  }
}
