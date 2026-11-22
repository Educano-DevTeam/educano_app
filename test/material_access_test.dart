import 'dart:convert';
import 'dart:typed_data';

import 'package:educano_app/services/api_client.dart';
import 'package:educano_app/services/courses_service.dart';
import 'package:educano_app/services/exams_service.dart';
import 'package:educano_app/services/users_service.dart';
import 'package:educano_app/features/course/models/course_models.dart';
import 'package:flutter/material.dart';
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

  test('loads the registered course cover icon and color', () {
    final course = CoursesService.courseFromApi({
      'curso': {
        'id': 'course-id',
        'nome': 'História',
        'categoria': 'CIENCIAS_HUMANAS',
        'cargaHoraria': 10,
        'descricao': 'Descrição',
        'cor': '#18A558',
        'iconeCapa': 'historia',
        'progresso': {'percentual': 0, 'concluidos': 0, 'total': 0},
        'responsavel': {'nome': 'Educano'},
        'sessoes': [],
      },
    });

    expect(course.icon, Icons.museum_rounded);
    expect(course.color, const Color(0xFF18A558));
    expect(course.imageUrl, isNull);
  });

  test(
    'reads enrollment status from the current-user enrollment endpoint',
    () async {
      const courseId = 'course-id';
      FakeApi.responseOverrides['GET /courses/$courseId/conteudo'] =
          http.Response(
            jsonEncode({
              'id': courseId,
              'nome': 'Curso inscrito',
              'categoria': 'EXATAS',
              'cargaHoraria': 10,
              'descricao': '',
              'cor': '#425BC2',
              'iconeCapa': 'livro',
              'progresso': {'total': 4, 'concluidos': 1, 'percentual': 25},
              'responsavel': {'id': 'owner-id', 'nome': 'Educano'},
              'professores': [],
              'sessoes': [],
            }),
            200,
            headers: {'content-type': 'application/json; charset=utf-8'},
          );
      FakeApi.responseOverrides['GET /courses/$courseId/inscricoes/me'] =
          http.Response(
            jsonEncode({'inscrito': true}),
            200,
            headers: {'content-type': 'application/json; charset=utf-8'},
          );

      final course = await CoursesService.instance.course(courseId);

      expect(
        FakeApi.requests,
        contains('GET /courses/$courseId/inscricoes/me'),
      );
      expect(course.enrolled, isTrue);
      expect(course.progress, 0.25);

      FakeApi.responseOverrides['GET /courses/$courseId/inscricoes/me'] =
          http.Response(
            jsonEncode({'inscrito': false}),
            200,
            headers: {'content-type': 'application/json; charset=utf-8'},
          );
      final visitorCourse = await CoursesService.instance.course(courseId);

      expect(visitorCourse.enrolled, isFalse);
    },
  );

  test('uploads a profile photo and refreshes its signed URL', () async {
    const fileId = 'profile-photo-id';
    const signedUrl = 'https://storage.example/profile.jpg?signature=fresh';
    const stableUrl = '$apiBaseUrl/files/$fileId';
    FakeApi.responseOverrides['POST /files'] = http.Response(
      jsonEncode({
        'arquivo': {'id': fileId, 'url': signedUrl},
      }),
      201,
      headers: {'content-type': 'application/json; charset=utf-8'},
    );
    FakeApi.responseOverrides['PATCH /users/me/profile'] = http.Response(
      jsonEncode({
        'perfil': {'urlFotoPerfil': stableUrl},
      }),
      200,
      headers: {'content-type': 'application/json; charset=utf-8'},
    );

    final uploadedProfile = await UsersService.instance.uploadPhoto(
      Uint8List.fromList([0, 1, 2]),
      'profile.png',
    );

    expect(FakeApi.requests, contains('POST /files'));
    expect(
      FakeApi.requestBodiesByPath['/users/me/profile'],
      {'urlFotoPerfil': stableUrl},
    );
    expect(uploadedProfile['urlFotoPerfil'], signedUrl);

    FakeApi.responseOverrides['GET /users/me/profile'] = http.Response(
      jsonEncode({
        'perfil': {'urlFotoPerfil': stableUrl},
      }),
      200,
      headers: {'content-type': 'application/json; charset=utf-8'},
    );
    FakeApi.responseOverrides['GET /files/$fileId'] = http.Response(
      jsonEncode({
        'arquivo': {'id': fileId, 'url': signedUrl},
      }),
      200,
      headers: {'content-type': 'application/json; charset=utf-8'},
    );

    final currentProfile = await UsersService.instance.myProfile();

    expect(FakeApi.requests, contains('GET /files/$fileId'));
    expect(currentProfile['urlFotoPerfil'], signedUrl);
  });

  test('loads monthly grade averages from the API', () async {
    FakeApi.responseOverrides['GET /tests/attempts/grades/monthly'] =
        http.Response(
          jsonEncode({
            'notas': {
              '2026': {
                'Novembro': {
                  'Atividade': {'media': 82.5, 'tentativas': 2},
                  'Simulado': {'media': 91, 'tentativas': 1},
                },
              },
            },
          }),
          200,
          headers: {'content-type': 'application/json; charset=utf-8'},
        );

    final grades = await ExamsService.instance.monthlyGrades();

    expect(
      FakeApi.queryParametersByPath['/tests/attempts/grades/monthly'],
      {'pagina': '1', 'limite': '7'},
    );
    expect(
      ((grades['notas'] as Map)['2026'] as Map)['Novembro'],
      isA<Map>(),
    );
  });

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

  test('creates an activity through its dedicated endpoint', () async {
    FakeApi.responseOverrides['POST /tests/activities'] = http.Response(
      '{}',
      201,
      headers: {'content-type': 'application/json; charset=utf-8'},
    );

    await CoursesService.instance.addMaterial(
      'course-id',
      'module-id',
      const CourseMaterial(
        id: 'draft-activity',
        kind: MaterialKind.activity,
        title: 'Revisão',
        description: '',
        activity: Activity(
          theme: 'Revisão',
          durationMinutes: 15,
          questions: [],
          questionIds: ['question-id'],
        ),
      ),
    );

    expect(FakeApi.requests, contains('POST /tests/activities'));
    expect(FakeApi.requestBodiesByPath['/tests/activities'], {
      'idModulo': 'module-id',
      'tema': 'Revisão',
      'tempoMinutos': 15,
      'questaoIds': ['question-id'],
    });
  });

  test('uploads an individual lesson through the lessons endpoint', () async {
    FakeApi.responseOverrides['POST /lessons'] = http.Response(
      '{}',
      201,
      headers: {'content-type': 'application/json; charset=utf-8'},
    );

    await CoursesService.instance.addMaterial(
      'course-id',
      'module-id',
      CourseMaterial(
        id: 'draft-lesson',
        kind: MaterialKind.pdf,
        title: 'Apostila',
        description: '',
        fileName: 'apostila.pdf',
        fileBytes: Uint8List.fromList(utf8.encode('%PDF-1.7')),
        pageCount: 12,
      ),
    );

    expect(FakeApi.requests, contains('POST /lessons'));
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
