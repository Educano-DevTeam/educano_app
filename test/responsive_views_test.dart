import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:educano_app/core/theme/educano_theme.dart';
import 'package:educano_app/features/dashboard/views/dashboard_courses_view.dart';
import 'package:educano_app/features/student/views/account_plan_view.dart';
import 'package:educano_app/features/student/views/finish_simulado_view.dart';
import 'package:educano_app/features/student/views/student_progress_view.dart';
import 'package:educano_app/features/student/views/student_store_view.dart';

/// Larguras usadas nos frames do Figma.
///
/// [desktop] é a área de conteúdo de uma janela de 1440px menos a sidebar
/// (260px); [tablet] cobre a faixa intermediária e [mobile] o frame do celular.
const Size desktop = Size(1180, 900);
const Size tablet = Size(760, 900);
const Size mobile = Size(390, 844);

Future<void> _pumpView(WidgetTester tester, Widget view, Size size) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    MaterialApp(
      theme: EducanoTheme.lightTheme,
      home: Scaffold(body: view),
    ),
  );
  await tester.pump(const Duration(milliseconds: 300));

  expect(tester.takeException(), isNull);

  // Desmonta para cancelar timers/controllers antes do fim do teste.
  await tester.pumpWidget(const SizedBox.shrink());
}

void main() {
  final views = <String, Widget Function()>{
    'Cursos Cadastrados': () => const DashboardCoursesView(),
    'Meu Progresso': () => const StudentProgressView(),
    'Loja & Inventário': () => const StudentStoreView(),
    'Plano de Conta': () => const AccountPlanView(),
    'Finalizar Simulado': () => const FinishSimuladoView(),
  };

  final sizes = <String, Size>{
    'desktop': desktop,
    'tablet': tablet,
    'mobile': mobile,
  };

  for (final view in views.entries) {
    for (final size in sizes.entries) {
      testWidgets(
        '${view.key} renderiza sem overflow em ${size.key}',
        (tester) => _pumpView(tester, view.value(), size.value),
      );
    }
  }

  testWidgets('Finalizar Simulado mostra o aviso de envio definitivo', (
    tester,
  ) async {
    tester.view.physicalSize = desktop;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MaterialApp(
        theme: EducanoTheme.lightTheme,
        home: const Scaffold(body: FinishSimuladoView()),
      ),
    );

    expect(find.text('Finalizar Simulado'), findsOneWidget);
    expect(find.text('38/45'), findsOneWidget);
    expect(find.text('7'), findsOneWidget);
    expect(
      find.text('Você não poderá mais editar suas respostas depois de enviar.'),
      findsOneWidget,
    );
    expect(find.text('Revisar respostas'), findsOneWidget);
    expect(find.text('Finalizar e enviar'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('Trilha de simulados abre a tela de Finalizar Simulado', (
    tester,
  ) async {
    tester.view.physicalSize = desktop;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MaterialApp(
        theme: EducanoTheme.lightTheme,
        home: const Scaffold(body: StudentProgressView()),
      ),
    );

    Future<void> tapText(String label) async {
      final finder = find.text(label);
      await tester.ensureVisible(finder);
      await tester.pumpAndSettle();
      await tester.tap(finder);
      await tester.pumpAndSettle();
    }

    await tapText('Matemática Básica');
    await tapText('Simulados');
    await tapText('Módulo 5: Simulado Geral');
    await tapText('Prova Simulada');

    expect(find.text('Finalizar Simulado'), findsOneWidget);
    expect(find.text('38/45'), findsOneWidget);

    // "Revisar respostas" volta para a lista de módulos.
    await tester.tap(find.text('Revisar respostas'));
    await tester.pumpAndSettle();
    expect(find.text('Finalizar Simulado'), findsNothing);
    expect(find.text('Módulo 5: Simulado Geral'), findsOneWidget);

    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('Loja: aba de inventário renderiza no mobile', (tester) async {
    tester.view.physicalSize = mobile;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MaterialApp(
        theme: EducanoTheme.lightTheme,
        home: const Scaffold(body: StudentStoreView()),
      ),
    );

    await tester.tap(find.text('Inventário'));
    await tester.pumpAndSettle();

    expect(find.text('Escudo de Sequência'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('Finalizar Simulado pede confirmação antes de enviar', (
    tester,
  ) async {
    tester.view.physicalSize = desktop;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MaterialApp(
        theme: EducanoTheme.lightTheme,
        home: const Scaffold(body: FinishSimuladoView()),
      ),
    );

    await tester.tap(find.text('Finalizar e enviar'));
    await tester.pumpAndSettle();

    expect(find.text('Finalizar simulado?'), findsOneWidget);

    await tester.tap(find.text('Confirmar envio'));
    await tester.pumpAndSettle();

    expect(find.text('Respostas enviadas!'), findsOneWidget);
    expect(find.text('Finalizar e enviar'), findsNothing);

    await tester.pumpWidget(const SizedBox.shrink());
  });
}
