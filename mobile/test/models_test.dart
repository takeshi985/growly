import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/models/child_session.dart';
import 'package:mobile/models/demo_bootstrap.dart';
import 'package:mobile/models/growly_feedback.dart';
import 'package:mobile/models/progress.dart';
import 'package:mobile/models/task.dart';

void main() {
  test('DemoBootstrap parses the stable demo child and links', () {
    final bootstrap = DemoBootstrap.fromJson({
      'parent': {'id': 1, 'email': 'demo-parent@growly.local'},
      'child': {'id': 7, 'name': 'Миша', 'age': 6},
      'links': {
        'session': '/session',
        'progress': '/progress',
        'lesson_map': '/lesson-map',
      },
    });

    expect(bootstrap.child.id, 7);
    expect(bootstrap.child.name, 'Миша');
    expect(bootstrap.links.progress, '/progress');
  });

  test('ChildSession handles an optional next task', () {
    final session = ChildSession.fromJson({
      'child': {'id': 7, 'name': 'Миша', 'age': 6},
      'next_task': null,
      'progress_summary': {'total_tasks': 4, 'completed_tasks': 4},
      'recommendations_count': 0,
      'session_state': {'has_next_task': false, 'message': 'Можно отдохнуть.'},
    });

    expect(session.nextTask, isNull);
    expect(session.hasNextTask, isFalse);
    expect(session.message, 'Можно отдохнуть.');
    expect(session.gamification.level, greaterThanOrEqualTo(1));
  });

  test('ChildSession parses backend gamification metrics', () {
    final session = ChildSession.fromJson({
      'child': {'id': 1, 'name': 'Миша', 'age': 6},
      'progress_summary': <String, dynamic>{},
      'gamification': {
        'xp': 40,
        'level': 2,
        'level_progress_percentage': 35,
        'streak_days': 3,
        'daily_completed': 2,
        'daily_target': 3,
      },
    });

    expect(session.gamification.xp, 40);
    expect(session.gamification.level, 2);
    expect(session.gamification.levelProgress, .35);
    expect(session.gamification.streakDays, 3);
  });

  test('GrowlyTask parses without correctAnswer', () {
    final task = GrowlyTask.fromJson({
      'id': 3,
      'skill_id': 2,
      'skill_title': 'Счёт',
      'area': 'math',
      'area_label': 'Счёт',
      'type': 'multiple_choice',
      'question': 'Сколько?',
      'options': {'3': 3, '4': 4},
      'difficulty': 1,
      'correct_answer': '4',
    });

    expect(task.options, {'3': '3', '4': '4'});
    expect(task.question, 'Сколько?');
  });

  test('GrowlyFeedback gracefully parses optional help', () {
    final feedback = GrowlyFeedback.fromJson({
      'result': 'incorrect',
      'action': 'show_hint1',
      'message': 'Давай посмотрим вместе.',
      'hint': 'Считай по одному.',
      'can_continue': true,
    });

    expect(feedback.hint, 'Считай по одному.');
    expect(feedback.explanation, isNull);
    expect(feedback.canContinue, isTrue);
  });

  test('ParentProgress parses summary and skill metrics', () {
    final progress = ParentProgress.fromJson({
      'child': {'id': 7, 'name': 'Миша', 'age': 6},
      'summary': {
        'total_skills': 1,
        'mastered_skills': 0,
        'skills_needing_review': 1,
        'total_tasks': 2,
        'completed_tasks': 1,
        'completion_percentage': 50,
      },
      'skills': [
        {
          'id': 1,
          'title': 'Сравнение',
          'area': 'math',
          'area_label': 'Счёт',
          'status': 'needs_review',
          'status_label': 'Нужно повторить',
          'incorrect_attempts_count': 3,
          'hints_used_count': 2,
          'completion_percentage': 50,
        },
      ],
      'recommendations': [],
    });

    expect(progress.summary.completionPercentage, 50);
    expect(progress.skills.single.status, 'needs_review');
    expect(progress.skills.single.incorrectAttemptsCount, 3);
  });
}
