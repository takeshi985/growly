import 'child_profile.dart';
import 'growly_feedback.dart';
import 'gamification.dart';
import 'progress.dart';
import 'task.dart';
import 'task_attempt.dart';

class ChildSession {
  const ChildSession({
    required this.child,
    required this.progressSummary,
    required this.gamification,
    required this.recommendationsCount,
    required this.hasNextTask,
    required this.message,
    this.nextTask,
  });

  final ChildProfile child;
  final GrowlyTask? nextTask;
  final ProgressSummary progressSummary;
  final GamificationSnapshot gamification;
  final int recommendationsCount;
  final bool hasNextTask;
  final String message;

  factory ChildSession.fromJson(Map<String, dynamic> json) {
    final rawTask = json['next_task'];
    final state = _map(json['session_state']);
    return ChildSession(
      child: ChildProfile.fromJson(_map(json['child'])),
      nextTask: rawTask is Map<String, dynamic>
          ? GrowlyTask.fromJson(rawTask)
          : null,
      progressSummary: ProgressSummary.fromJson(_map(json['progress_summary'])),
      gamification: json['gamification'] is Map<String, dynamic>
          ? GamificationSnapshot.fromJson(_map(json['gamification']))
          : GamificationSnapshot.fromProgress(
              ProgressSummary.fromJson(_map(json['progress_summary'])),
            ),
      recommendationsCount:
          (json['recommendations_count'] as num?)?.toInt() ?? 0,
      hasNextTask: state['has_next_task'] as bool? ?? rawTask != null,
      message: state['message'] as String? ?? '',
    );
  }
}

class TaskAnswerResult {
  const TaskAnswerResult({
    required this.attempt,
    required this.feedback,
    required this.progressSummary,
    this.nextTask,
  });

  final TaskAttempt attempt;
  final GrowlyFeedback feedback;
  final GrowlyTask? nextTask;
  final ProgressSummary progressSummary;

  factory TaskAnswerResult.fromJson(Map<String, dynamic> json) {
    final rawTask = json['next_task'];
    return TaskAnswerResult(
      attempt: TaskAttempt.fromJson(_map(json['task_attempt'])),
      feedback: GrowlyFeedback.fromJson(_map(json['feedback'])),
      nextTask: rawTask is Map<String, dynamic>
          ? GrowlyTask.fromJson(rawTask)
          : null,
      progressSummary: ProgressSummary.fromJson(_map(json['progress_summary'])),
    );
  }
}

Map<String, dynamic> _map(Object? value) =>
    value is Map<String, dynamic> ? value : <String, dynamic>{};
