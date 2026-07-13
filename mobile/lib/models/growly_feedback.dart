class GrowlyFeedback {
  const GrowlyFeedback({
    required this.result,
    required this.action,
    required this.message,
    required this.canContinue,
    this.hint,
    this.explanation,
  });

  final String result;
  final String action;
  final String message;
  final String? hint;
  final String? explanation;
  final bool canContinue;

  factory GrowlyFeedback.fromJson(Map<String, dynamic> json) => GrowlyFeedback(
    result: json['result'] as String? ?? '',
    action: json['action'] as String? ?? '',
    message: json['message'] as String? ?? 'Продолжим маленькими шагами.',
    hint: json['hint'] as String?,
    explanation: json['explanation'] as String?,
    canContinue: json['can_continue'] as bool? ?? true,
  );
}
