class ChildProfile {
  const ChildProfile({required this.id, required this.name, required this.age});

  final int id;
  final String name;
  final int age;

  factory ChildProfile.fromJson(Map<String, dynamic> json) {
    return ChildProfile(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: json['name'] as String? ?? 'Ребёнок',
      age: (json['age'] as num?)?.toInt() ?? 0,
    );
  }
}
