import 'dart:convert';

import 'package:educano_app/services/api_client.dart';
import 'package:educano_app/services/courses_service.dart';
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

  test('requests a fresh temporary URL for a lesson file', () async {
    const materialId = 'material-test-id';
    const url = 'https://storage.example/material.pdf?signature=fresh';
    FakeApi.responseOverrides['GET /lessons/$materialId'] = http.Response(
      jsonEncode({
        'aula': {
          'arquivo': {
            'url': url,
            'nomeOriginal': 'material.pdf',
            'contentType': 'application/pdf',
          },
        },
      }),
      200,
      headers: {'content-type': 'application/json; charset=utf-8'},
    );

    final access = await CoursesService.instance.materialAccess(materialId);

    expect(FakeApi.requests, contains('GET /lessons/$materialId'));
    expect(access.url, url);
    expect(access.fileName, 'material.pdf');
    expect(access.mimeType, 'application/pdf');
  });

  test('downloads PDF bytes from the signed URL', () async {
    const url = 'https://storage.example/material.pdf?signature=fresh';
    final pdfBytes = utf8.encode('%PDF-1.7\n');
    FakeApi.responseOverrides['GET /material.pdf'] = http.Response.bytes(
      pdfBytes,
      200,
      headers: {'content-type': 'application/pdf'},
    );

    final bytes = await CoursesService.instance.materialPdfBytes(url);

    expect(bytes, pdfBytes);
    expect(FakeApi.requests, contains('GET /material.pdf'));
  });

  test('rejects a signed URL response that is not a PDF', () async {
    const url = 'https://storage.example/material.pdf?signature=fresh';
    FakeApi.responseOverrides['GET /material.pdf'] = http.Response(
      '<html>expired</html>',
      200,
    );

    await expectLater(
      CoursesService.instance.materialPdfBytes(url),
      throwsA(
        isA<ApiException>().having(
          (error) => error.statusCode,
          'statusCode',
          502,
        ),
      ),
    );
  });

  test(
    'keeps the generated course cover URL from my enrolled courses',
    () async {
      const courseId = 'course-with-cover';
      const coverUrl =
          'https://storage.example/course-cover.jpg?signature=fresh';
      FakeApi.responseOverrides['GET /courses/minhas-inscricoes'] =
          http.Response(
            jsonEncode({
              'cursos': [
                {'id': courseId, 'nome': 'Curso inscrito', 'capa': coverUrl},
              ],
            }),
            200,
            headers: {'content-type': 'application/json; charset=utf-8'},
          );
      FakeApi.responseOverrides['GET /courses/$courseId'] = http.Response(
        jsonEncode({
          'curso': {
            'id': courseId,
            'nome': 'Curso inscrito',
            'idCapa': 'cover-id',
            'arquivoCapa': {'id': 'cover-id', 'nomeOriginal': 'capa.jpg'},
          },
        }),
        200,
        headers: {'content-type': 'application/json; charset=utf-8'},
      );

      final courses = await CoursesService.instance.myCourses();

      expect(courses.single['capa'], coverUrl);
    },
  );

  test('normalizes generated cover URLs in supported API shapes', () {
    const coverUrl = 'https://storage.example/course-cover.jpg?signature=fresh';

    expect(CoursesService.courseCoverUrl({'capa': coverUrl}), coverUrl);
    expect(
      CoursesService.courseCoverUrl({
        'capa': {'url': coverUrl},
      }),
      coverUrl,
    );
    expect(
      CoursesService.courseCoverUrl({
        'arquivoCapa': {'url': coverUrl},
      }),
      coverUrl,
    );
    expect(CoursesService.courseCoverUrl({'idCapa': 'file-id'}), isNull);
  });
}
