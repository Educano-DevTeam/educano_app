import 'dart:async';

import 'package:flutter/material.dart';
import '../../../core/navigation/app_routes.dart';
import '../../../core/theme/educano_colors.dart';
import '../widgets/app_buttons.dart';
import '../widgets/app_card.dart';
import '../widgets/chip_selector.dart';
import '../widgets/dashboard_scaffold.dart';
import '../models/exam_session.dart';
import '../models/exam_mock_questions.dart';

/// Tela "Configurar/Iniciar" — o aluno escolhe matéria(s), dificuldade e
/// quantidade de questões antes de iniciar um novo simulado.
class ExamConfigView extends StatefulWidget {
  const ExamConfigView({super.key});

  static const routeName = '/simulados/configurar';

  @override
  State<ExamConfigView> createState() => _ExamConfigViewState();
}

class _ExamConfigViewState extends State<ExamConfigView> {
  final Set<String> _subjects = {'Matemática'};
  final Set<String> _difficulty = {'Médio'};
  int _questionCount = 3;

  static const _subjectOptions = [
    'Matemática',
    'Linguagens',
    'Ciências da Natureza',
    'Ciências Humanas',
    'Redação',
  ];

  static const _difficultyOptions = ['Fácil', 'Médio', 'Difícil'];

  static const _questionCountOptions = [1, 2, 3];

  void _toggleSubject(String subject) {
    setState(() {
      if (_subjects.contains(subject)) {
        _subjects.remove(subject);
      } else {
        _subjects.add(subject);
      }
    });
  }

  void _toggleDifficulty(String difficulty) {
    setState(() {
      _difficulty
        ..clear()
        ..add(difficulty);
    });
  }

  bool get _canStart => _subjects.isNotEmpty && _difficulty.isNotEmpty;

  Future<void> _confirmStart(ExamSession session) async {
    final start = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Antes de come\u00e7ar'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Responda com calma.'),
            SizedBox(height: 12),
            Text('Fique em um lugar silencioso.'),
            SizedBox(height: 12),
            Text('Boa sorte!'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Iniciar Simulado'),
          ),
        ],
      ),
    );

    if (start == true && mounted) {
      Navigator.of(context).pushReplacementNamed(
        AppRoutes.exam,
        arguments: session,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final arg = ModalRoute.of(context)?.settings.arguments;
    final activity = arg is ExamSession ? arg : null;
    return DashboardScaffold(
      title: activity == null ? 'Configurar Simulado' : 'Atividade',
      activeNavIndex: 1,
      maxContentWidth: 1200,
      showBackButton: true,
      onBack: () => Navigator.of(context).maybePop(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (activity == null)
            const Text(
              'Personalize seu simulado antes de começar.',
              style: TextStyle(
                fontSize: 14,
                color: EducanoColors.textSecondary,
              ),
            ),
          if (activity == null) ...[
            AppCard(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ChipSelectorGroup(title: 'Disciplina', options: _subjectOptions, selected: _subjects, onSelected: _toggleSubject),
                  const SizedBox(height: 30),
                  const Text('Número de questões', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: EducanoColors.textPrimary)),
                  const SizedBox(height: 12),
                  Wrap(spacing: 8, runSpacing: 8, children: [for (final count in _questionCountOptions) SelectableChip(label: '$count questões', selected: _questionCount == count, onTap: () => setState(() => _questionCount = count))]),
                  const SizedBox(height: 30),
                  const Text('Tempo', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: EducanoColors.textPrimary)),
                  const SizedBox(height: 12),
                  SelectableChip(label: '${(_questionCount * 2.5).round()} min', selected: true, onTap: () {}),
                  const SizedBox(height: 30),
                  ChipSelectorGroup(title: 'Nível de dificuldade', options: _difficultyOptions, selected: _difficulty, onSelected: _toggleDifficulty),
                ],
              ),
            ),
          ],
          SizedBox(height: activity == null ? 20 : 28),
          PrimaryButton(
            label: 'Iniciar Simulado',
            icon: Icons.play_arrow_rounded,
            onPressed: _canStart
                ? () {
                    final session =
                        activity ??
                        ExamSession(
                          title: 'Simulado de ${_subjects.join(', ')}',
                          questions: ExamMockQuestions.all
                              .take(_questionCount)
                              .toList(growable: false),
                          durationMinutes: (_questionCount * 2.5).round(),
                        );
                    unawaited(_confirmStart(session));
                  }
                : null,
          ),
        ],
      ),
    );
  }
}
