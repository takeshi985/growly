class TaskAttempt {
  const TaskAttempt({
    required this.id,
    required this.taskId,
    required this.selectedAnswer,
    required this.isCorrect,
    required this.attemptNumber,
    required this.hintUsed,
  });

  final int id;
  final int taskId;
  final String selectedAnswer;
  final bool isCorrect;
  final int attemptNumber;
  final bool hintUsed;

  factory TaskAttempt.fromJson(Map<String, dynamic> json) => TaskAttempt(
    id: (json['id'] as num?)?.toInt() ?? 0,
    taskId: (json['task_id'] as num?)?.toInt() ?? 0,
    selectedAnswer: json['selected_answer'] as String? ?? '',
    isCorrect: json['is_correct'] as bool? ?? false,
    attemptNumber: (json['attempt_number'] as num?)?.toInt() ?? 0,
    hintUsed: json['hint_used'] as bool? ?? false,
  );
}
