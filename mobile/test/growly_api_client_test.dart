import 'package:flutter_test/flutter_test.dart';
import 'package:http/testing.dart';
import 'package:mobile/api/growly_api_client.dart';

void main() {
  test('API client builds normalized URLs', () {
    final client = GrowlyApiClient(
      client: MockClient((_) async => throw UnimplementedError()),
      baseUrl: 'http://localhost:4000/',
    );

    expect(
      client.uri('/api/mobile/v1/health').toString(),
      'http://localhost:4000/api/mobile/v1/health',
    );
    expect(
      client.uri('api/mobile/v1/catalog').toString(),
      'http://localhost:4000/api/mobile/v1/catalog',
    );
  });
}
