import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mobile/api/growly_api_client.dart';
import 'package:mobile/app.dart';

void main() {
  testWidgets('Growly app renders the home title', (tester) async {
    final client = MockClient((request) async {
      return http.Response(
        jsonEncode({
          'data': {
            'parent': {'id': 1, 'email': 'demo-parent@growly.local'},
            'child': {'id': 2, 'name': 'Миша', 'age': 6},
            'links': {
              'session': '/api/mobile/v1/children/2/session',
              'progress': '/api/mobile/v1/children/2/progress',
              'lesson_map': '/api/mobile/v1/children/2/lesson_map',
            },
          },
        }),
        200,
        headers: {'content-type': 'application/json; charset=utf-8'},
      );
    });

    await tester.pumpWidget(
      GrowlyApp(
        apiClient: GrowlyApiClient(client: client, baseUrl: 'http://test'),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Growly'), findsOneWidget);
    expect(find.text('Маленькие шаги к школе'), findsOneWidget);
    expect(find.text('Режим ребёнка'), findsOneWidget);
  });
}
