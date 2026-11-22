import 'dart:async';

import 'package:flutter/material.dart';
import '../../../core/navigation/app_routes.dart';
import '../../../core/theme/educano_colors.dart';
import '../widgets/app_buttons.dart';
import '../widgets/app_card.dart';
import '../widgets/chip_selector.dart';
import '../widgets/dashboard_scaffold.dart';
import '../models/exam_session.dart';
import '../../../services/api_client.dart';
import '../../../services/exams_service.dart';
import '../../../services/questions_service.dart';

/// Tela de configuração de simulados por tema e dificuldade.
/// Configure tema, dificuldade, quantidade e duração.
class ExamConfigView extends StatefulWidget {
  const ExamConfigView({super.key});

  static const routeName = '/simulados/configurar';

  @override
  State<ExamConfigView> createState() => _ExamConfigViewState();
}

class _ExamConfigViewState extends State<ExamConfigView> {
  String? _selectedTheme = '';
  String? _themeLoadError;
  final Set<String> _difficulty = {'Médio'};
  final _customCountController = TextEditingController();
  final _customTimeController = TextEditingController();
  List<String> _availableThemes = [];
  int _questionCount = 10;
  int _durationMinutes = 10;
  bool _customCount = false;
  bool _customTime = false;

  @override
  void initState() {
    super.initState();
    unawaited(_loadAvailableThemes());
  }

  Future<void> _loadAvailableThemes() async {
    try {
      final themes = await QuestionsService.instance.themes();
      if (mounted) setState(() => _availableThemes = themes);
    } on ApiException catch (error) {
      if (mounted) setState(() => _themeLoadError = error.message);
    } catch (_) {
      if (mounted) {
        setState(() => _themeLoadError = 'N\u00e3o foi poss\u00edvel carregar os temas.');
      }
    }
  }


  static const _difficultyOptions = ['Fácil', 'Médio', 'Difícil'];

  static const _questionCountOptions = [10, 20, 50, 100];

  static const _timeOptionsByCount = {
    10: [10, 15, 20, 30],
    20: [20, 30, 40, 50],
    50: [50, 60, 75, 90],
    100: [60, 90, 105, 120],
  };

  List<int> get _timeOptions => _customCount
      ? const []
      : _timeOptionsByCount[_questionCount] ?? const [];

  @override
  void dispose() {
    _customCountController.dispose();
    _customTimeController.dispose();
    super.dispose();
  }

  void _selectQuestionCount(int? count) {
    setState(() {
      _customCount = count == null;
      if (count == null) {
        _customTime = true;
        final custom = int.tryParse(_customCountController.text.trim());
        if (custom != null) _questionCount = custom;
      } else {
        _questionCount = count;
        if (!_customTime ||
            !_timeOptionsByCount[count]!.contains(_durationMinutes)) {
          _customTime = false;
          _durationMinutes = _timeOptionsByCount[count]!.first;
        }
      }
    });
  }

  void _updateCustomCount(String value) {
    final count = int.tryParse(value.trim());
    setState(() {
      if (count != null) _questionCount = count;
    });
  }

  void _updateCustomTime(String value) {
    final minutes = int.tryParse(value.trim());
    setState(() {
      if (minutes != null) _durationMinutes = minutes;
    });
  }

  String _formatMinutes(int minutes) {
    if (minutes < 60) return '$minutes min';
    final hours = minutes ~/ 60;
    final rest = minutes % 60;
    if (rest == 0) return hours == 1 ? '1 hora' : '$hours horas';
    return '$hours:${rest.toString().padLeft(2, '0')} hora';
  }

  bool get _customCountValid {
    if (!_customCount) return true;
    final count = int.tryParse(_customCountController.text.trim());
    return count != null && count >= 1 && count <= 100;
  }

  bool get _customTimeValid {
    if (!_customTime) return true;
    final minutes = int.tryParse(_customTimeController.text.trim());
    return minutes != null && minutes >= 1 && minutes <= 600;
  }


  void _toggleDifficulty(String difficulty) {
    setState(() {
      _difficulty
        ..clear()
        ..add(difficulty);
    });
  }

  bool get _canStart =>
      _selectedTheme != null &&
      _difficulty.isNotEmpty &&
      _customCountValid &&
      _customTimeValid;

  bool _creating = false;

  /// Confirma e pede à API um simulado com as configurações escolhidas.
  Future<bool?> _confirmShortTime() => showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: const Text('Tempo abaixo do recomendado'),
      content: Text(
        'O ideal \u00e9 ter pelo menos 1 minuto por quest\u00e3o. '
        'Voc\u00ea selecionou $_questionCount quest\u00f5es para '
        '$_durationMinutes minutos. Deseja continuar mesmo assim?',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(false),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.of(dialogContext).pop(true),
          child: const Text('Continuar mesmo assim'),
        ),
      ],
    ),
  );

  Future<void> _createAndStart() async {
    if (_customTime && _durationMinutes < _questionCount) {
      final continueAnyway = await _confirmShortTime();
      if (continueAnyway != true || !mounted) return;
    }
    final confirmed = await _confirm();
    if (!confirmed || !mounted) return;

    setState(() => _creating = true);
    try {
      final session = await ExamsService.instance.create(
        theme: _selectedTheme!,
        difficulty: _difficulty.first,
        count: _questionCount,
        durationMinutes: _durationMinutes,
      );
      if (!mounted) return;
      Navigator.of(context).pushReplacementNamed(AppRoutes.exam, arguments: session);
    } on ApiException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.message),
          backgroundColor: EducanoColors.error,
          action: error.code == 'LIMITE_DO_PLANO'
              ? SnackBarAction(
                  label: 'Ver planos',
                  textColor: Colors.white,
                  onPressed: () => Navigator.of(context).pushNamed(AppRoutes.accountPlan),
                )
              : null,
        ),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('N\u00e3o foi poss\u00edvel iniciar o simulado. Tente novamente.'),
          backgroundColor: EducanoColors.error,
        ),
      );
    } finally {
      if (mounted) setState(() => _creating = false);
    }
  }

  Future<bool> _confirm() async {
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
    return start == true;
  }

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
                  DropdownButtonFormField<String>(
                    isExpanded: true,
                    initialValue: _selectedTheme,
                    decoration: InputDecoration(
                      labelText: 'Tema do simulado',
                      helperText: _themeLoadError,
                    ),
                    items: [
                      const DropdownMenuItem(
                        value: '',
                        child: Text('Todos'),
                      ),
                      ..._availableThemes.map(
                          (theme) => DropdownMenuItem(
                            value: theme,
                            child: Text(
                              theme.isEmpty
                                  ? theme
                                  : '${theme[0].toUpperCase()}${theme.substring(1).toLowerCase()}',
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                    ],
                    onChanged: (theme) =>
                        setState(() => _selectedTheme = theme),
                  ),
                  const SizedBox(height: 30),
                  const Text(
                    'N\u00famero de quest\u00f5es',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: EducanoColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final count in _questionCountOptions)
                        SelectableChip(
                          label: '$count quest\u00f5es',
                          selected: !_customCount && _questionCount == count,
                          onTap: () => _selectQuestionCount(count),
                        ),
                      SelectableChip(
                        label: 'Personalizado',
                        selected: _customCount,
                        onTap: () => _selectQuestionCount(null),
                      ),
                    ],
                  ),
                  if (_customCount) ...[
                    const SizedBox(height: 16),
                    TextField(
                      controller: _customCountController,
                      keyboardType: TextInputType.number,
                      onChanged: _updateCustomCount,
                      decoration: InputDecoration(
                        labelText: 'Quantidade personalizada',
                        helperText: 'Informe de 1 a 100 quest\u00f5es.',
                        errorText: _customCountValid
                            ? null
                            : 'Informe um n\u00famero entre 1 e 100.',
                      ),
                    ),
                  ],
                  const SizedBox(height: 30),
                  const Text(
                    'Tempo',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: EducanoColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final minutes in _timeOptions)
                        SelectableChip(
                          label: _formatMinutes(minutes),
                          selected: !_customTime &&
                              _durationMinutes == minutes,
                          onTap: () => setState(() {
                            _customTime = false;
                            _durationMinutes = minutes;
                          }),
                        ),
                      SelectableChip(
                        label: 'Personalizado',
                        selected: _customTime,
                        onTap: () => setState(() => _customTime = true),
                      ),
                    ],
                  ),
                  if (_customTime) ...[
                    const SizedBox(height: 16),
                    TextField(
                      controller: _customTimeController,
                      keyboardType: TextInputType.number,
                      onChanged: _updateCustomTime,
                      decoration: InputDecoration(
                        labelText: 'Tempo personalizado (minutos)',
                        helperText: 'Informe de 1 a 600 minutos.',
                        errorText: _customTimeValid
                            ? null
                            : 'Informe um n\u00famero entre 1 e 600.',
                      ),
                    ),
                  ],
                  const SizedBox(height: 30),
                  ChipSelectorGroup(
                    title: 'N\u00edvel de dificuldade',
                    options: _difficultyOptions,
                    selected: _difficulty,
                    onSelected: _toggleDifficulty,
                  ),
                ],
              ),
            ),
          ],
          SizedBox(height: activity == null ? 20 : 28),
          PrimaryButton(
            label: 'Iniciar Simulado',
            icon: Icons.play_arrow_rounded,
            isLoading: _creating,
            onPressed: _canStart && !_creating
                ? () => activity != null
                    ? unawaited(_confirmStart(activity))
                    : unawaited(_createAndStart())
                : null,
          ),
        ],
      ),
    );
  }
}
