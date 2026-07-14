import 'progress.dart';

class GamificationSnapshot {
  const GamificationSnapshot({
    required this.xp,
    required this.level,
    required this.levelProgress,
    required this.streakDays,
    required this.dailyCompleted,
    this.dailyTarget = 3,
  });

  final int xp;
  final int level;
  final double levelProgress;
  final int streakDays;
  final int dailyCompleted;
  final int dailyTarget;

  factory GamificationSnapshot.fromJson(Map<String, dynamic> json) {
    final progress = _integer(json['level_progress_percentage']);
    return GamificationSnapshot(
      xp: _integer(json['xp']),
      level: _integer(json['level']).clamp(1, 1000000),
      levelProgress: progress.clamp(0, 100) / 100,
      streakDays: _integer(json['streak_days']),
      dailyCompleted: _integer(json['daily_completed']),
      dailyTarget: _integer(json['daily_target']).clamp(1, 1000),
    );
  }

  factory GamificationSnapshot.fromProgress(ProgressSummary progress) {
    final xp = progress.completedTasks * 10;
    return GamificationSnapshot(
      xp: xp,
      level: 1 + xp ~/ 100,
      levelProgress: (xp % 100) / 100,
      streakDays: progress.completedTasks > 0 ? 1 : 0,
      dailyCompleted: progress.completedTasks.clamp(0, 3),
    );
  }
}

int _integer(Object? value) => (value as num?)?.toInt() ?? 0;
