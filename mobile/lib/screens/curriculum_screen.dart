import 'package:flutter/material.dart';

import '../api/growly_api_client.dart';
import '../models/child_profile.dart';
import '../models/curriculum.dart';
import '../widgets/error_state.dart';
import '../widgets/level_map.dart';
import '../widgets/loading_state.dart';
import 'child_task_screen.dart';

class CurriculumScreen extends StatefulWidget {
  const CurriculumScreen({
    super.key,
    required this.apiClient,
    required this.childId,
    this.childMode = false,
    this.child,
  });
  final GrowlyApiClient apiClient;
  final int childId;
  final bool childMode;
  final ChildProfile? child;
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

  void _load() => setState(() => _curriculum = _fetch());
  Future<_CurriculumData> _fetch() async {
    final results = await Future.wait<Object>([
      widget.apiClient.catalog(),
      widget.apiClient.lessonMap(widget.childId),
    ]);
    return _CurriculumData(
      courses: results[0] as List<Course>,
      map: results[1] as LessonMap,
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Карта обучения')),
    body: SafeArea(
      child: FutureBuilder<_CurriculumData>(
        future: _curriculum,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done)
            return const LoadingState(message: 'Строим маршрут…');
          if (snapshot.hasError || !snapshot.hasData)
            return ErrorState(message: '${snapshot.error}', onRetry: _load);
          final data = snapshot.data!;
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
                        data.map.course.title,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 6),
                      Text(data.map.course.description),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              for (final unit in data.map.units) ...[
                Text(
                  unit.title,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                LevelMap(
                  lessons: unit.lessons,
                  readOnly: !widget.childMode,
                  onLessonTap: widget.childMode && widget.child != null
                      ? (_) => Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => ChildTaskScreen(
                              apiClient: widget.apiClient,
                              child: widget.child!,
                            ),
                          ),
                        )
                      : null,
                ),
                const SizedBox(height: 16),
              ],
            ],
          );
        },
      ),
    ),
  );
}

class _CurriculumData {
  const _CurriculumData({required this.courses, required this.map});
  final List<Course> courses;
  final LessonMap map;
}
