class GrowlyTask {
  const GrowlyTask({
    required this.id,
    required this.skillId,
    required this.skillTitle,
    required this.area,
    required this.areaLabel,
    required this.type,
    required this.question,
    required this.options,
    required this.difficulty,
  });

  final int id;
  final int skillId;
  final String skillTitle;
  final String area;
  final String areaLabel;
  final String type;
  final String question;
  final Map<String, String> options;
  final int difficulty;

  factory GrowlyTask.fromJson(Map<String, dynamic> json) {
    final rawOptions = json['options'];
    final options = <String, String>{};
    if (rawOptions is Map) {
      for (final entry in rawOptions.entries) {
        options[entry.key.toString()] = entry.value.toString();
      }
    }

    return GrowlyTask(
      id: (json['id'] as num?)?.toInt() ?? 0,
      skillId: (json['skill_id'] as num?)?.toInt() ?? 0,
      skillTitle: json['skill_title'] as String? ?? '',
      area: json['area'] as String? ?? '',
      areaLabel: json['area_label'] as String? ?? '',
      type: json['type'] as String? ?? '',
      question: json['question'] as String? ?? '',
      options: options,
      difficulty: (json['difficulty'] as num?)?.toInt() ?? 1,
    );
  }
}
