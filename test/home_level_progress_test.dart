import 'dart:convert';

import 'package:educano_app/core/models/level_progress.dart';
import 'package:educano_app/features/profile/views/profile_view.dart';
import 'package:educano_app/features/home/views/home_view.dart';
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

  test('uses the configured XP thresholds to calculate levels', () {
    final firstLevel = LevelProgress.fromTotalXp(249);
    expect(firstLevel.level, 1);
    expect(firstLevel.xpInLevel, 249);
    expect(firstLevel.xpRequiredForNextLevel, 250);
    expect(firstLevel.progress, closeTo(0.996, 0.001));

    final secondLevel = LevelProgress.fromTotalXp(250);
    expect(secondLevel.level, 2);
    expect(secondLevel.xpInLevel, 0);
    expect(secondLevel.xpRequiredForNextLevel, 500);

    expect(LevelProgress.fromTotalXp(750).level, 3);
    expect(LevelProgress.fromTotalXp(1750).level, 4);
    final fifthLevel = LevelProgress.fromTotalXp(3750);
    expect(fifthLevel.level, 5);
    expect(fifthLevel.xpRequiredForNextLevel, 5000);
    final sixthLevel = LevelProgress.fromTotalXp(8750);
    expect(sixthLevel.level, 6);
    expect(sixthLevel.xpRequiredForNextLevel, 10000);
  });

  test('treats negative XP as zero', () {
    final level = LevelProgress.fromTotalXp(-10);

    expect(level.level, 1);
    expect(level.xpInLevel, 0);
    expect(level.totalXp, 0);
  });

  testWidgets('home calculates the level from total XP in the profile API', (
    tester,
  ) async {
    FakeApi.responseOverrides['GET /users/me/profile'] = http.Response(
      jsonEncode({
        'perfil': {
          'xp': 120,
          'nivel': 99,
          'xpNoNivel': 999,
          'xpParaProximoNivel': 9999,
        },
      }),
      200,
      headers: {'content-type': 'application/json; charset=utf-8'},
    );

    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: HomeView())),
    );
    await tester.pumpAndSettle();

    expect(FakeApi.requests, contains('GET /users/me/profile'));
    expect(find.text('LEVEL 1'), findsOneWidget);
    expect(find.textContaining('120/250 XP para o Level 2'), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('profile calculates the same level from total XP as home', (
    tester,
  ) async {
    FakeApi.responseOverrides['GET /users/me/profile'] = http.Response(
      jsonEncode({
        'perfil': {'xp': 120, 'nivel': 99, 'urlFotoPerfil': ''},
      }),
      200,
      headers: {'content-type': 'application/json; charset=utf-8'},
    );
    FakeApi.responseOverrides['GET /courses/minhas-inscricoes'] = http.Response(
      jsonEncode({'cursos': []}),
      200,
      headers: {'content-type': 'application/json; charset=utf-8'},
    );
    FakeApi.responseOverrides['GET /tests/attempts/grades/monthly'] =
        http.Response(
          jsonEncode({'notas': {}}),
          200,
          headers: {'content-type': 'application/json; charset=utf-8'},
        );

    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: ProfileView())),
    );
    await tester.pumpAndSettle();

    expect(find.text('1'), findsOneWidget);
    expect(find.text('99'), findsNothing);
    await tester.pumpWidget(const SizedBox.shrink());
  });
}
