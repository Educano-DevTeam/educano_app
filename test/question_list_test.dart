import 'dart:convert';

import 'package:educano_app/services/questions_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

import 'support/fake_api.dart';

void main() {
  setUpAll(() {
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
    FakeApi.install();
  });

  setUp(FakeApi.reset);

  test('requests question pages using only supported filters', () async {
    FakeApi.responseOverrides['GET /questions'] = http.Response(
      jsonEncode({
        'dados': [],
        'paginacao': {'pagina': 2, 'totalPaginas': 4, 'total': 100},
      }),
      200,
      headers: {'content-type': 'application/json; charset=utf-8'},
    );

    final result = await QuestionsService.instance.list(
      page: 2,
      search: 'equações',
      difficulty: 'MEDIO',
    );

    expect(result.questions, isEmpty);
    expect(result.page, 2);
    expect(result.totalPages, 4);
    expect(result.total, 100);
    expect(FakeApi.queryParametersByPath['/questions'], {
      'pagina': '2',
      'limite': '30',
      'busca': 'equações',
      'dificuldade': 'MEDIO',
    });
  });
}
