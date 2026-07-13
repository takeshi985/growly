import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import '../models/child_session.dart';
import '../models/curriculum.dart';
import '../models/demo_bootstrap.dart';
import '../models/progress.dart';
import '../models/pairing.dart';
import 'api_exception.dart';

class GrowlyApiClient {
  GrowlyApiClient({
    http.Client? client,
    String baseUrl = apiBaseUrl,
    this.timeout = const Duration(seconds: 12),
  }) : _client = client ?? http.Client(),
       baseUrl = baseUrl.replaceFirst(RegExp(r'/$'), '');

  final http.Client _client;
  final String baseUrl;
  final Duration timeout;

  Uri uri(String path) =>
      Uri.parse('$baseUrl${path.startsWith('/') ? path : '/$path'}');

  Future<bool> health() async {
    final data = await _get('/api/mobile/v1/health');
    return data['status'] == 'ok';
  }

  Future<DemoBootstrap> demoBootstrap() async {
    return DemoBootstrap.fromJson(await _get('/api/mobile/v1/demo/bootstrap'));
  }

  Future<ChildSession> childSession(int childId) async {
    return ChildSession.fromJson(
      await _get('/api/mobile/v1/children/$childId/session'),
    );
  }

  Future<TaskAnswerResult> submitAnswer({
    required int childId,
    required int taskId,
    required String selectedAnswer,
    required bool hintUsed,
  }) async {
    final data = await _post(
      '/api/mobile/v1/children/$childId/tasks/$taskId/answer',
      <String, dynamic>{
        'answer': <String, dynamic>{
          'selected_answer': selectedAnswer,
          'hint_used': hintUsed,
        },
      },
    );
    return TaskAnswerResult.fromJson(data);
  }

  Future<ParentProgress> parentProgress(int childId) async {
    return ParentProgress.fromJson(
      await _get('/api/mobile/v1/children/$childId/progress'),
    );
  }

  Future<PairingOffer> createPairingSession(int childId) async {
    return PairingOffer.fromJson(
      await _post(
        '/api/mobile/v1/children/$childId/pairing_sessions',
        const {},
      ),
    );
  }

  Future<PairingClaim> claimPairingByCode(String code) async {
    return PairingClaim.fromJson(
      await _post('/api/mobile/v1/pairing_sessions/claim', {'code': code}),
    );
  }

  Future<PairingClaim> claimPairingByToken(String token) async {
    return PairingClaim.fromJson(
      await _post('/api/mobile/v1/pairing_sessions/claim', {'token': token}),
    );
  }

  Future<List<Course>> catalog() async {
    final data = await _get('/api/mobile/v1/catalog');
    final raw = data['courses'];
    if (raw is! List) return <Course>[];
    return raw.whereType<Map<String, dynamic>>().map(Course.fromJson).toList();
  }

  Future<LessonMap> lessonMap(int childId) async {
    return LessonMap.fromJson(
      await _get('/api/mobile/v1/children/$childId/lesson_map'),
    );
  }

  Future<Map<String, dynamic>> _get(String path) async {
    try {
      final response = await _client
          .get(uri(path), headers: const {'Accept': 'application/json'})
          .timeout(timeout);
      return _decode(response);
    } on TimeoutException {
      throw const ApiException('Backend не ответил вовремя. Попробуй ещё раз.');
    } on http.ClientException {
      throw const ApiException('Не получилось подключиться к backend.');
    }
  }

  Future<Map<String, dynamic>> _post(
    String path,
    Map<String, dynamic> body,
  ) async {
    try {
      final response = await _client
          .post(
            uri(path),
            headers: const {
              'Accept': 'application/json',
              'Content-Type': 'application/json',
            },
            body: jsonEncode(body),
          )
          .timeout(timeout);
      return _decode(response);
    } on TimeoutException {
      throw const ApiException('Backend не ответил вовремя. Попробуй ещё раз.');
    } on http.ClientException {
      throw const ApiException('Не получилось подключиться к backend.');
    }
  }

  Map<String, dynamic> _decode(http.Response response) {
    Object? decoded;
    try {
      decoded = jsonDecode(utf8.decode(response.bodyBytes));
    } on FormatException {
      throw ApiException(
        'Backend вернул непонятный ответ.',
        statusCode: response.statusCode,
      );
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiException(
        _errorMessage(decoded),
        statusCode: response.statusCode,
      );
    }

    if (decoded is! Map<String, dynamic>) {
      throw ApiException(
        'Backend вернул непонятный ответ.',
        statusCode: response.statusCode,
      );
    }

    final data = decoded['data'];
    if (data is! Map<String, dynamic>) {
      throw ApiException(
        'В ответе backend отсутствуют данные.',
        statusCode: response.statusCode,
      );
    }
    return data;
  }

  String _errorMessage(Object? decoded) {
    if (decoded is Map<String, dynamic> && decoded['errors'] != null) {
      return 'Backend отклонил запрос. Проверь данные и попробуй ещё раз.';
    }
    return 'Backend вернул ошибку. Попробуй ещё раз.';
  }

  void close() => _client.close();
}
