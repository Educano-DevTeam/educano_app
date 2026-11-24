import 'package:educano_app/core/theme/educano_theme.dart';
import 'package:educano_app/core/widgets/ui/app_modal.dart';
import 'package:educano_app/features/course/models/course_models.dart';
import 'package:educano_app/features/course/widgets/course_editor_dialogs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('AppModal keeps its title and actions inside a narrow screen', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(360, 640));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MaterialApp(
        theme: EducanoTheme.lightTheme,
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: ElevatedButton(
                onPressed: () => AppModal.show<void>(
                  context: context,
                  title: 'Confirmar alteração',
                  child: const Text(
                    'Este conteúdo precisa caber em uma tela estreita sem ultrapassar os limites.',
                  ),
                  actions: [
                    OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancelar alteração'),
                    ),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Confirmar alteração completa'),
                    ),
                  ],
                ),
                child: const Text('Abrir modal'),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Abrir modal'));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('Confirmar alteração'), findsOneWidget);
    expect(find.text('Cancelar alteração'), findsOneWidget);
    expect(find.text('Confirmar alteração completa'), findsOneWidget);

    final modalRect = tester.getRect(find.byType(Dialog));
    expect(modalRect.left, greaterThanOrEqualTo(0));
    expect(modalRect.right, lessThanOrEqualTo(360));
  });

  testWidgets('lesson editor keeps the save action inside a narrow screen', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(360, 640));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MaterialApp(
        theme: EducanoTheme.lightTheme,
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: ElevatedButton(
                onPressed: () => showMaterialEditor(
                  context,
                  material: const CourseMaterial(
                    id: 'lesson-1',
                    kind: MaterialKind.video,
                    title: 'Introdução',
                    description: 'Aula de introdução',
                    fileName: 'introducao.mp4',
                    durationSeconds: 600,
                  ),
                ),
                child: const Text('Editar aula'),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Editar aula'));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('Salvar alterações'), findsOneWidget);

    final saveRect = tester.getRect(find.text('Salvar alterações'));
    expect(saveRect.left, greaterThanOrEqualTo(0));
    expect(saveRect.right, lessThanOrEqualTo(360));
  });
}
