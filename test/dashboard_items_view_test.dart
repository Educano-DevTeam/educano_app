import 'dart:convert';

import 'package:educano_app/features/dashboard/views/dashboard_items_view.dart';
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

  setUp(() {
    FakeApi.reset();
    FakeApi.responseOverrides['GET /items'] = http.Response(
      jsonEncode({
        'dados': [
          {
            'id': 'active',
            'nome': 'Boost ativo',
            'descricao': 'Multiplica o XP',
            'preco': 80,
            'icone': 'RAIO',
            'cor': '#425BC2',
            'status': 'ATIVO',
          },
          {
            'id': 'inactive',
            'nome': 'Escudo inativo',
            'descricao': 'Protege a sequência',
            'preco': 150,
            'icone': 'ESCUDO',
            'cor': '#79B425',
            'status': 'INATIVO',
          },
        ],
        'paginacao': {'totalPaginas': 1},
      }),
      200,
      headers: {'content-type': 'application/json; charset=utf-8'},
    );
  });

  testWidgets('search and status filters run locally on loaded items', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: DashboardItemsView())),
    );
    await tester.pumpAndSettle();

    expect(find.text('Boost ativo'), findsOneWidget);
    expect(find.text('Escudo inativo (fora da loja)'), findsOneWidget);

    await tester.enterText(find.byType(TextField).first, 'escudo');
    await tester.pumpAndSettle();

    expect(find.text('Boost ativo'), findsNothing);
    expect(find.text('Escudo inativo (fora da loja)'), findsOneWidget);
    expect(
      FakeApi.requests.where((request) => request == 'GET /items'),
      hasLength(1),
    );

    await tester.enterText(find.byType(TextField).first, '');
    final statusFilter = find.byType(DropdownButton<String>).first;
    await tester.ensureVisible(statusFilter);
    await tester.pumpAndSettle();
    await tester.tap(statusFilter);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Fora da loja').last);
    await tester.pumpAndSettle();

    expect(find.text('Boost ativo'), findsNothing);
    expect(find.text('Escudo inativo (fora da loja)'), findsOneWidget);
    expect(
      FakeApi.requests.where((request) => request == 'GET /items'),
      hasLength(1),
    );
  });
}
