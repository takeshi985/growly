import 'child_profile.dart';

class ProgressSummary {
  const ProgressSummary({
    required this.totalSkills,
    required this.masteredSkills,
    required this.skillsNeedingReview,
    required this.totalTasks,
    required this.completedTasks,
    required this.completionPercentage,
  });

  final int totalSkills;
  final int masteredSkills;
  final int skillsNeedingReview;
  final int totalTasks;
  final int completedTasks;
  final int completionPercentage;

  factory ProgressSummary.fromJson(Map<String, dynamic> json) =>
      ProgressSummary(
        totalSkills: _integer(json['total_skills']),
        masteredSkills: _integer(json['mastered_skills']),
        skillsNeedingReview: _integer(json['skills_needing_review']),
        totalTasks: _integer(json['total_tasks']),
        completedTasks: _integer(json['completed_tasks']),
        completionPercentage: _integer(json['completion_percentage']),
      );
}

class SkillProgress {
  const SkillProgress({
    required this.id,
    required this.title,
    required this.area,
    required this.areaLabel,
    required this.status,
    required this.statusLabel,
    required this.statusDescription,
    required this.totalTasks,
    required this.completedTasks,
    required this.completionPercentage,
    required this.attemptsCount,
    required this.incorrectAttemptsCount,
    required this.hintsUsedCount,
    required this.tasksNeedingReviewCount,
    required this.recommendationPriority,
  });

  final int id;
  final String title;
  final String area;
  final String areaLabel;
  final String status;
  final String statusLabel;
  final String statusDescription;
  final int totalTasks;
  final int completedTasks;
  final int completionPercentage;
  final int attemptsCount;
  final int incorrectAttemptsCount;
  final int hintsUsedCount;
  final int tasksNeedingReviewCount;
  final String recommendationPriority;

  factory SkillProgress.fromJson(Map<String, dynamic> json) => SkillProgress(
    id: _integer(json['id']),
    title: json['title'] as String? ?? '',
    area: json['area'] as String? ?? '',
    areaLabel: json['area_label'] as String? ?? '',
    status: json['status'] as String? ?? 'not_started',
    statusLabel: json['status_label'] as String? ?? 'Не начато',
    statusDescription: json['status_description'] as String? ?? '',
    totalTasks: _integer(json['total_tasks']),
    completedTasks: _integer(json['completed_tasks']),
    completionPercentage: _integer(json['completion_percentage']),
    attemptsCount: _integer(json['attempts_count']),
    incorrectAttemptsCount: _integer(json['incorrect_attempts_count']),
    hintsUsedCount: _integer(json['hints_used_count']),
    tasksNeedingReviewCount: _integer(json['tasks_needing_review_count']),
    recommendationPriority: json['recommendation_priority'] as String? ?? 'low',
  );
}

class ProgressRecommendation {
  const ProgressRecommendation({
    required this.skillId,
    required this.priority,
    required this.title,
    required this.message,
  });

  final int skillId;
  final String priority;
  final String title;
  final String message;

  factory ProgressRecommendation.fromJson(Map<String, dynamic> json) =>
      ProgressRecommendation(
        skillId: _integer(json['skill_id']),
        priority: json['priority'] as String? ?? 'low',
        title: json['title'] as String? ?? '',
        message: json['message'] as String? ?? '',
      );
}

class ParentProgress {
  const ParentProgress({
    required this.child,
    required this.summary,
    required this.skills,
    required this.recommendations,
  });

  final ChildProfile child;
  final ProgressSummary summary;
  final List<SkillProgress> skills;
  final List<ProgressRecommendation> recommendations;

  factory ParentProgress.fromJson(Map<String, dynamic> json) => ParentProgress(
    child: ChildProfile.fromJson(_map(json['child'])),
    summary: ProgressSummary.fromJson(_map(json['summary'])),
    skills: _list(json['skills']).map(SkillProgress.fromJson).toList(),
    recommendations: _list(
      json['recommendations'],
    ).map(ProgressRecommendation.fromJson).toList(),
  );
}

int _integer(Object? value) => (value as num?)?.toInt() ?? 0;
Map<String, dynamic> _map(Object? value) =>
    value is Map<String, dynamic> ? value : <String, dynamic>{};
List<Map<String, dynamic>> _list(Object? value) => value is List
    ? value.whereType<Map<String, dynamic>>().toList()
    : <Map<String, dynamic>>[];
