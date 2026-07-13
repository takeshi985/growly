import 'package:flutter/material.dart';

import '../api/growly_api_client.dart';
import '../models/curriculum.dart';
import '../widgets/error_state.dart';
import '../widgets/loading_state.dart';

class CurriculumScreen extends StatefulWidget {
  const CurriculumScreen({
    super.key,
    required this.apiClient,
    required this.childId,
  });

  final GrowlyApiClient apiClient;
  final int childId;

  @override
  State<CurriculumScreen> createState() => _CurriculumScreenState();
}

class _CurriculumScreenState extends State<CurriculumScreen> {
  late Future<_CurriculumData> _curriculum;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() => setState(() {
    _curriculum = _fetchCurriculum();
  });

  Future<_CurriculumData> _fetchCurriculum() async {
    final results = await Future.wait<Object>([
      widget.apiClient.catalog(),
      widget.apiClient.lessonMap(widget.childId),
    ]);
    return _CurriculumData(
      courses: results[0] as List<Course>,
      lessonMap: results[1] as LessonMap,
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Карта обучения')),
    body: SafeArea(
      child: FutureBuilder<_CurriculumData>(
        future: _curriculum,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const LoadingState(message: 'Строим учебный маршрут…');
          }
          if (snapshot.hasError || !snapshot.hasData) {
            return ErrorState(message: '${snapshot.error}', onRetry: _load);
          }
          return _content(snapshot.data!);
        },
      ),
    ),
  );

  Widget _content(_CurriculumData data) {
    final map = data.lessonMap;
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
      children: [
        Card(
          color: Theme.of(context).colorScheme.primaryContainer,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  map.course.title,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 6),
                Text(map.course.description),
                const SizedBox(height: 8),
                Text('Возраст: ${map.course.ageMin}–${map.course.ageMax} лет'),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'Доступные курсы',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 10),
        for (final course in data.courses) ...[
          Card(
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              leading: const Icon(Icons.school_rounded),
              title: Text(course.title),
              subtitle: Text(
                '${course.unitsCount} раздела · ${course.lessonsCount} урока',
              ),
            ),
          ),
          const SizedBox(height: 10),
        ],
        const SizedBox(height: 12),
        Text(
          'Маршрут ${map.child.name}',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 12),
        for (final unit in map.units) ...[
          Text(unit.title, style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 10),
          for (final lesson in unit.lessons) ...[
            _LessonCard(lesson: lesson),
            const SizedBox(height: 10),
          ],
          const SizedBox(height: 14),
        ],
      ],
    );
  }
}

class _CurriculumData {
  const _CurriculumData({required this.courses, required this.lessonMap});

  final List<Course> courses;
  final LessonMap lessonMap;
}

class _LessonCard extends StatelessWidget {
  const _LessonCard({required this.lesson});

  final Lesson lesson;

  @override
  Widget build(BuildContext context) {
    final (icon, label) = switch (lesson.status) {
      'completed' => (Icons.check_circle_rounded, 'Завершено'),
      'in_progress' => (Icons.timelapse_rounded, 'В процессе'),
      'needs_review' => (Icons.replay_circle_filled_rounded, 'Нужно повторить'),
      'locked' => (Icons.lock_rounded, 'Закрыто'),
      _ => (Icons.play_circle_outline_rounded, 'Доступно'),
    };
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 30, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    lesson.title,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  if (lesson.objective.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(lesson.objective),
                  ],
                  const SizedBox(height: 8),
                  Text('$label · ${lesson.completionPercentage}%'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
