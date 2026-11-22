import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/layout/app_scaffold.dart';
import '../../../core/navigation/app_menu.dart';
import '../../../core/navigation/app_routes.dart';
import '../../../core/theme/educano_colors.dart';
import '../../../services/api_client.dart';
import '../../../services/exams_service.dart';
import '../models/exam_session.dart';

class ExamView extends StatefulWidget {
  const ExamView({super.key, required this.session});
  final ExamSession session;

  @override
  State<ExamView> createState() => _ExamViewState();
}

class _ExamViewState extends State<ExamView> {
  late int _index;
  late Duration _remaining;
  Timer? _timer;
  bool _allowExit = false;
  bool _exitDialogOpen = false;
  bool _usingHint = false;

  @override
  void initState() {
    super.initState();
    _index = 0;
    // O tempo restante vem do servidor (o simulado pode ter sido retomado).
    _remaining = Duration(
      seconds: widget.session.remainingSeconds ?? widget.session.durationMinutes * 60,
    );
    if (!widget.session.isReview) {
      _timer = Timer.periodic(const Duration(seconds: 1), (_) {
        if (_remaining.inSeconds <= 1) {
          _timer?.cancel();
          setState(() => _remaining = Duration.zero);
          _goToFinish();
        } else {
          setState(() => _remaining -= const Duration(seconds: 1));
        }
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _goToFinish() {
    _timer?.cancel();
    Navigator.of(context).pushReplacementNamed(
      AppRoutes.examFinish,
      arguments: widget.session,
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: EducanoColors.error),
    );
  }

  /// Marca a alternativa e salva a resposta na API (salvamento automático).
  Future<void> _answer(int option) async {
    final index = _index;
    final previous = widget.session.answers[index];
    setState(() => widget.session.answers[index] = option);
    if (widget.session.id == null) return;

    try {
      await ExamsService.instance.answer(widget.session, index, option);
    } on ApiException catch (error) {
      if (!mounted) return;
      if (error.code == 'TEMPO_ESGOTADO') {
        _goToFinish();
        return;
      }
      setState(() {
        if (previous == null) {
          widget.session.answers.remove(index);
        } else {
          widget.session.answers[index] = previous;
        }
      });
      _showError(error.message);
    } catch (_) {
      if (!mounted) return;
      setState(() {
        if (previous == null) {
          widget.session.answers.remove(index);
        } else {
          widget.session.answers[index] = previous;
        }
      });
      _showError('N\u00e3o foi poss\u00edvel salvar sua resposta. Tente novamente.');
    }
  }

  /// Usa uma Dica Extra do inventário para eliminar uma alternativa errada.
  Future<void> _useHint() async {
    if (widget.session.id == null || _usingHint) return;
    setState(() => _usingHint = true);
    try {
      final eliminated = await ExamsService.instance.useHint(widget.session, _index);
      if (!mounted) return;
      setState(() {
        if (eliminated != null) widget.session.eliminated[_index] = eliminated;
      });
    } on ApiException catch (error) {
      if (mounted) _showError(error.message);
    } catch (_) {
      if (mounted) {
        _showError('N\u00e3o foi poss\u00edvel usar a dica agora. Tente novamente.');
      }
    } finally {
      if (mounted) setState(() => _usingHint = false);
    }
  }

  Future<void> _requestExit() async {
    if (widget.session.isReview || _allowExit || _exitDialogOpen) return;
    _exitDialogOpen = true;
    final shouldExit = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Sair do simulado?'),
        content: Text(widget.session.id == null
            ? 'Se voc\u00ea sair agora, todas as suas respostas ser\u00e3o perdidas.'
            : 'Suas respostas ficam salvas. Voc\u00ea pode continuar em \u00daltimos Simulados enquanto o tempo n\u00e3o acabar.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Sair'),
          ),
        ],
      ),
    );
    _exitDialogOpen = false;
    if (shouldExit == true && mounted) {
      setState(() => _allowExit = true);
      await WidgetsBinding.instance.endOfFrame;
      if (mounted) Navigator.of(context).maybePop();
    }
  }

  void _handleBack() {
    if (widget.session.isReview) {
      Navigator.of(context).maybePop();
    } else {
      unawaited(_requestExit());
    }
  }

  String get _timeLabel {
    final seconds = _remaining.inSeconds.clamp(0, 999999);
    return '${(seconds ~/ 60).toString().padLeft(2, '0')}:${(seconds % 60).toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final questions = widget.session.questions;
    return PopScope<Object?>(
      canPop: widget.session.isReview || _allowExit,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && !widget.session.isReview) unawaited(_requestExit());
      },
      child: AppScaffold(
      selectedMenu: AppMenu.lastExams,
      child: LayoutBuilder(builder: (context, bounds) {
        final mobile = bounds.maxWidth < 700;
        if (questions.isEmpty) {
          return Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
            Text(widget.session.isActivity
                ? 'Esta atividade ainda nao possui questoes cadastradas.'
                : 'Nao ha questoes disponiveis para esta configuracao.'),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: () => Navigator.of(context).maybePop(),
              icon: const Icon(Icons.arrow_back),
              label: const Text('Voltar'),
            ),
          ]));
        }
        final question = questions[_index];
        final selected = widget.session.answers[_index];
        final canAdvance = widget.session.isReview || selected != null;
        final progress = (_index + 1) / questions.length;
        return SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(mobile ? 8 : 38, mobile ? 10 : 32, mobile ? 8 : 38, mobile ? 8 : 32),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1180),
              child: Container(
                padding: EdgeInsets.fromLTRB(mobile ? 16 : 32, mobile ? 18 : 22, mobile ? 16 : 32, mobile ? 14 : 22),
                decoration: BoxDecoration(
                  color: EducanoColors.surface,
                  border: Border.all(color: EducanoColors.cardBorder, width: 1.5),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                  Row(children: [
                    IconButton(
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
                      icon: const Icon(Icons.arrow_back, color: Colors.black, size: 30),
                      onPressed: _handleBack,
                    ),
                    const SizedBox(width: 8),
                    Expanded(child: Text(widget.session.title,
                      maxLines: 1, overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: mobile ? 18 : 28, fontWeight: FontWeight.w700, color: const Color(0xFF484848)))),
                    if (!widget.session.isReview) ...[
                      const SizedBox(width: 20),
                      Text('Tempo restante: $_timeLabel', style: TextStyle(fontSize: mobile ? 12 : 20, fontWeight: FontWeight.w700, color: const Color(0xFF484848))),
                    ],
                  ]),
                  const SizedBox(height: 12),
                  Row(children: [
                    Expanded(child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: LinearProgressIndicator(value: progress, minHeight: mobile ? 28 : 28,
                        backgroundColor: const Color(0xFFD9D9D9),
                        valueColor: const AlwaysStoppedAnimation(Color(0xFF20D500))),
                    )),
                    const SizedBox(width: 14),
                    Text('${(progress * 100).round()}%', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Color(0xFF484848))),
                  ]),
                  SizedBox(height: mobile ? 24 : 26),
                  Text(question.title, style: TextStyle(fontSize: mobile ? 24 : 27, fontWeight: FontWeight.w700, color: const Color(0xFF484848))),
                  SizedBox(height: mobile ? 26 : 32),
                  Text(question.statement, style: TextStyle(fontSize: mobile ? 19 : 22, height: 1.25, color: const Color(0xFF4B4B4B))),
                  SizedBox(height: mobile ? 26 : 32),
                  if (!widget.session.isReview && widget.session.id != null && !widget.session.eliminated.containsKey(_index))
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton.icon(
                        onPressed: _usingHint ? null : _useHint,
                        icon: const Icon(Icons.lightbulb_outline_rounded),
                        label: const Text('Usar Dica Extra'),
                      ),
                    ),
                  for (var i = 0; i < question.options.length; i++)
                    _AnswerOption(
                      label: '${String.fromCharCode(65 + i)}) ${question.options[i]}',
                      selected: selected == i,
                      correct: widget.session.isReview && question.correctOptionIndex == i,
                      incorrect: widget.session.isReview && selected == i && selected != question.correctOptionIndex,
                      eliminated: widget.session.eliminated[_index] == i,
                      enabled: !widget.session.isReview && widget.session.eliminated[_index] != i,
                      onTap: () => _answer(i),
                      mobile: mobile,
                    ),
                  // Gabarito comentado.
                  if (widget.session.isReview && question.explanation.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: EducanoColors.successLight,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Comentário: ${question.explanation}',
                        style: TextStyle(fontSize: mobile ? 14 : 16, height: 1.3),
                      ),
                    ),
                  ],
                  SizedBox(height: mobile ? 18 : 22),
                  Row(children: [
                    Expanded(child: _NavigationButton(
                      label: 'Anterior', icon: Icons.chevron_left, outlined: true,
                      enabled: _index > 0,
                      mobile: mobile,
                      onPressed: _index == 0 ? null : () => setState(() => _index--),
                    )),
                    SizedBox(width: mobile ? 14 : 24),
                    Expanded(child: _NavigationButton(
                      label: _index == questions.length - 1 ? (widget.session.isReview ? 'Resultado' : 'Finalizar') : 'Pr\u00f3xima',
                      icon: Icons.chevron_right, outlined: false, enabled: canAdvance, mobile: mobile,
                      onPressed: canAdvance ? () {
                        if (_index < questions.length - 1) {
                          setState(() => _index++);
                        } else if (widget.session.isReview) {
                          Navigator.of(context).maybePop();
                        } else {
                          _goToFinish();
                        }
                      } : null,
                    )),
                  ]),
                ]),
              ),
            ),
          ),
        );
      }),
      ),
    );
  }
}

class _AnswerOption extends StatelessWidget {
  const _AnswerOption({required this.label, required this.selected, required this.correct, required this.incorrect, required this.enabled, required this.onTap, required this.mobile, this.eliminated = false});
  final String label;
  final bool selected, correct, incorrect, enabled, mobile, eliminated;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Color? border = correct ? EducanoColors.successGreen : incorrect ? EducanoColors.error : null;
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Material(
        color: selected && !correct ? EducanoColors.primaryBlue : Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: enabled ? onTap : null,
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 14, vertical: mobile ? 10 : 9),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: border == null ? null : Border.all(color: border, width: 3),
            ),
            child: Text(label, style: TextStyle(fontSize: mobile ? 19 : 21, height: 1.2,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
              // Alternativa eliminada pela Dica Extra aparece riscada.
              decoration: eliminated ? TextDecoration.lineThrough : null,
              color: selected && !correct ? Colors.white : eliminated ? Colors.black38 : const Color(0xFF4B4B4B))),
          ),
        ),
      ),
    );
  }
}

class _NavigationButton extends StatelessWidget {
  const _NavigationButton({required this.label, required this.icon, required this.outlined, required this.enabled, required this.mobile, required this.onPressed});
  final String label;
  final IconData icon;
  final bool outlined, enabled, mobile;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final foreground = outlined
        ? (enabled ? const Color(0xFF858585) : const Color(0xFFBDBDBD))
        : (enabled ? Colors.white : EducanoColors.textSecondary);
    final child = Row(mainAxisAlignment: MainAxisAlignment.center, children: [
      if (outlined) Icon(icon, size: mobile ? 25 : 30),
      if (outlined) const SizedBox(width: 4),
      Text(label, style: TextStyle(fontSize: mobile ? 15 : 18, fontWeight: FontWeight.w700)),
      if (!outlined) const SizedBox(width: 3),
      if (!outlined) Icon(icon, size: mobile ? 24 : 30),
    ]);
    return SizedBox(height: mobile ? 42 : 54, child: outlined
      ? OutlinedButton(onPressed: onPressed, style: OutlinedButton.styleFrom(foregroundColor: foreground,
          side: BorderSide(color: enabled ? const Color(0xFFD5D5D5) : const Color(0xFFE5E5E5)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)), padding: EdgeInsets.zero), child: child)
      : ElevatedButton(onPressed: onPressed, style: ElevatedButton.styleFrom(backgroundColor: enabled ? EducanoColors.primaryBlue : EducanoColors.border,
          foregroundColor: foreground, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)), padding: EdgeInsets.zero), child: child));
  }
}
