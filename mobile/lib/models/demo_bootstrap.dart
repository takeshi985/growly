import 'child_profile.dart';

class DemoParent {
  const DemoParent({required this.id, required this.email});

  final int id;
  final String email;

  factory DemoParent.fromJson(Map<String, dynamic> json) => DemoParent(
    id: (json['id'] as num?)?.toInt() ?? 0,
    email: json['email'] as String? ?? '',
  );
}

class DemoLinks {
  const DemoLinks({
    required this.session,
    required this.progress,
    required this.lessonMap,
  });

  final String session;
  final String progress;
  final String lessonMap;

  factory DemoLinks.fromJson(Map<String, dynamic> json) => DemoLinks(
    session: json['session'] as String? ?? '',
    progress: json['progress'] as String? ?? '',
    lessonMap: json['lesson_map'] as String? ?? '',
  );
}

class DemoBootstrap {
  const DemoBootstrap({
    required this.parent,
    required this.child,
    required this.links,
  });

  final DemoParent parent;
  final ChildProfile child;
  final DemoLinks links;

  factory DemoBootstrap.fromJson(Map<String, dynamic> json) => DemoBootstrap(
    parent: DemoParent.fromJson(_map(json['parent'])),
    child: ChildProfile.fromJson(_map(json['child'])),
    links: DemoLinks.fromJson(_map(json['links'])),
  );
}

Map<String, dynamic> _map(Object? value) =>
    value is Map<String, dynamic> ? value : <String, dynamic>{};
