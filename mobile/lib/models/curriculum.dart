import 'child_profile.dart';

class Course {
  const Course({
    required this.id,
    required this.title,
    required this.slug,
    required this.description,
    required this.ageMin,
    required this.ageMax,
    required this.unitsCount,
    required this.lessonsCount,
  });

  final int id;
  final String title;
  final String slug;
  final String description;
  final int ageMin;
  final int ageMax;
  final int unitsCount;
  final int lessonsCount;

  factory Course.fromJson(Map<String, dynamic> json) => Course(
    id: _integer(json['id']),
    title: json['title'] as String? ?? '',
    slug: json['slug'] as String? ?? '',
    description: json['description'] as String? ?? '',
    ageMin: _integer(json['age_min']),
    ageMax: _integer(json['age_max']),
    unitsCount: _integer(json['units_count']),
    lessonsCount: _integer(json['lessons_count']),
  );
}

class Lesson {
  const Lesson({
    required this.id,
    required this.title,
    required this.slug,
    required this.objective,
    required this.status,
    required this.completedTasks,
    required this.totalTasks,
    required this.completionPercentage,
  });

  final int id;
  final String title;
  final String slug;
  final String objective;
  final String status;
  final int completedTasks;
  final int totalTasks;
  final int completionPercentage;

  factory Lesson.fromJson(Map<String, dynamic> json) => Lesson(
    id: _integer(json['id']),
    title: json['title'] as String? ?? '',
    slug: json['slug'] as String? ?? '',
    objective: json['objective'] as String? ?? '',
    status: json['status'] as String? ?? 'available',
    completedTasks: _integer(json['completed_tasks']),
    totalTasks: _integer(json['total_tasks'] ?? json['tasks_count']),
    completionPercentage: _integer(json['completion_percentage']),
  );
}

class CurriculumUnit {
  const CurriculumUnit({
    required this.id,
    required this.title,
    required this.area,
    required this.lessons,
  });

  final int id;
  final String title;
  final String area;
  final List<Lesson> lessons;

  factory CurriculumUnit.fromJson(Map<String, dynamic> json) => CurriculumUnit(
    id: _integer(json['id']),
    title: json['title'] as String? ?? '',
    area: json['area'] as String? ?? '',
    lessons: _list(json['lessons']).map(Lesson.fromJson).toList(),
  );
}

class LessonMap {
  const LessonMap({
    required this.child,
    required this.course,
    required this.units,
  });

  final ChildProfile child;
  final Course course;
  final List<CurriculumUnit> units;

  factory LessonMap.fromJson(Map<String, dynamic> json) => LessonMap(
    child: ChildProfile.fromJson(_map(json['child'])),
    course: Course.fromJson(_map(json['course'])),
    units: _list(json['units']).map(CurriculumUnit.fromJson).toList(),
  );
}

int _integer(Object? value) => (value as num?)?.toInt() ?? 0;
Map<String, dynamic> _map(Object? value) =>
    value is Map<String, dynamic> ? value : <String, dynamic>{};
List<Map<String, dynamic>> _list(Object? value) => value is List
    ? value.whereType<Map<String, dynamic>>().toList()
    : <Map<String, dynamic>>[];
