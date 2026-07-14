import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mobile/api/growly_api_client.dart';
import 'package:mobile/app.dart';
import 'package:mobile/screens/child_home_screen.dart';
import 'package:mobile/screens/child_setup_screen.dart';
import 'package:mobile/screens/role_selection_screen.dart';
import 'package:mobile/storage/device_preferences.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('role selection renders both reversible role options', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(home: RoleSelectionScreen(onSelected: (_) {})),
    );
    expect(find.text('Growly'), findsOneWidget);
    expect(find.text('Ребёнок'), findsOneWidget);
    expect(find.text('Родитель'), findsOneWidget);
  });

  testWidgets('selecting child only reports a pending role', (tester) async {
    DeviceRole? selected;
    await tester.pumpWidget(
      MaterialApp(
        home: RoleSelectionScreen(onSelected: (role) => selected = role),
      ),
    );
    await tester.tap(find.text('Ребёнок'));
    expect(selected, DeviceRole.child);
  });

  testWidgets('child setup provides standalone and parent connection choices', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: ChildSetupScreen(
          onBack: () {},
          onComplete: ({required connectParent}) async {},
        ),
      ),
    );
    expect(find.text('Начать без телефона родителя'), findsOneWidget);
    expect(find.text('Подключить родителя сейчас'), findsOneWidget);
  });

  testWidgets('completing child setup leaves setup and opens child home', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final apiClient = GrowlyApiClient(
      client: MockClient(
        (_) async => http.Response(
          jsonEncode(<String, dynamic>{
            'data': <String, dynamic>{
              'parent': <String, dynamic>{
                'id': 1,
                'email': 'parent@growly.test',
              },
              'child': <String, dynamic>{'id': 2, 'name': 'Миша', 'age': 6},
              'links': <String, dynamic>{
                'session': '/session',
                'progress': '/progress',
                'lesson_map': '/lesson_map',
              },
            },
          }),
          200,
        ),
      ),
      baseUrl: 'http://test',
    );

    await tester.pumpWidget(
      GrowlyApp(apiClient: apiClient, preferences: DevicePreferences()),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.arrow_forward_rounded).first);
    await tester.pumpAndSettle();
    expect(find.byType(ChildSetupScreen), findsOneWidget);

    await tester.tap(find.byType(InkWell).first);
    await tester.pumpAndSettle();

    expect(find.byType(ChildHomeScreen), findsOneWidget);
  });
}
