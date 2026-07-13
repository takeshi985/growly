import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mobile/api/growly_api_client.dart';
import 'package:mobile/models/curriculum.dart';
import 'package:mobile/screens/child_pairing_screen.dart';
import 'package:mobile/screens/parent_pairing_screen.dart';
import 'package:mobile/widgets/drag_count_task.dart';
import 'package:mobile/widgets/level_map.dart';

void main() {
  final apiClient = GrowlyApiClient(
    client: MockClient((_) async => throw UnimplementedError()),
    baseUrl: 'http://test',
  );

  testWidgets('parent pairing provides manual eight-digit code entry', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: ParentPairingScreen(apiClient: apiClient, onPaired: (_) async {}),
      ),
    );
    expect(find.text('Подключение к ребёнку'), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);
    expect(find.text('Подключиться'), findsOneWidget);
  });

  testWidgets('child pairing renders the eight-digit code area', (
    tester,
  ) async {
    final pairingClient = GrowlyApiClient(
      client: MockClient(
        (_) async => http.Response(
          jsonEncode({
            'data': {
              'child': {'id': 1, 'name': 'Миша', 'age': 6},
              'pairing': {
                'code': '48192736',
                'token': 'safe-token',
                'expires_at': '2026-07-13T00:00:00Z',
                'qr_payload': 'growly://pair?token=safe-token',
              },
            },
          }),
          201,
        ),
      ),
      baseUrl: 'http://test',
    );
    await tester.pumpWidget(
      MaterialApp(
        home: ChildPairingScreen(apiClient: pairingClient, childId: 1),
      ),
    );
    expect(find.text('Код для родителя'), findsOneWidget);
  });

  testWidgets('drag task and level map render', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Column(
            children: [
              DragCountTask(
                options: const {'total': 5},
                enabled: true,
                onChanged: (_) {},
              ),
              LevelMap(
                lessons: const [
                  Lesson(
                    id: 1,
                    title: 'Первый шаг',
                    slug: 'first',
                    objective: '',
                    status: 'available',
                    completedTasks: 0,
                    totalTasks: 1,
                    completionPercentage: 0,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
    expect(find.text('Начать сначала'), findsOneWidget);
    expect(find.text('Первый шаг'), findsOneWidget);
  });
}
