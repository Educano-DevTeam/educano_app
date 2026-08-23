import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/constants/app_breakpoints.dart';
import '../../../core/theme/theme.dart';

const double _spacingMinimum = 8;
const double _spacingSmall = 16;
const double _spacingMedium = 24;
const double _spacingLarge = 32;

const double _radius = 18;

/// Largura máxima do painel de resumo no desktop (igual ao frame do Figma).
const double _panelMaxWidth = 640;

/// Aviso fixo — o aluno precisa ver isso antes e depois de enviar.
const String _lockWarning =
    'Você não poderá mais editar suas respostas depois de enviar.';

/// Tela exibida ao final de um simulado/atividade, antes do envio definitivo.
///
/// Mostra o resumo do progresso (respondidas, não respondidas e tempo
/// restante) e deixa o aluno voltar para revisar ou enviar em definitivo.
class FinishSimuladoView extends StatefulWidget {
  final String title;
  final String subtitle;

  final int totalQuestions;
  final int answeredQuestions;
  final Duration remainingTime;

  /// Volta para as questões do simulado.
  final VoidCallback? onReview;

  /// Chamado quando o aluno fecha a tela depois de enviar as respostas.
  final VoidCallback? onFinished;

  const FinishSimuladoView({
    super.key,
    this.title = 'Finalizar Simulado',
    this.subtitle = 'Revise seu progresso antes de enviar suas respostas.',
    this.totalQuestions = 45,
    this.answeredQuestions = 38,
    this.remainingTime = const Duration(minutes: 12, seconds: 34),
    this.onReview,
    this.onFinished,
  });

  @override
  State<FinishSimuladoView> createState() => _FinishSimuladoViewState();
}

class _FinishSimuladoViewState extends State<FinishSimuladoView> {
  late Duration _remaining;
  Timer? _ticker;
  bool _submitted = false;

  int get _unanswered => widget.totalQuestions - widget.answeredQuestions;

  bool get _timeIsOver => _remaining.inSeconds <= 0;

  String get _formattedTime {
    final totalSeconds = _remaining.inSeconds.clamp(0, 86400);
    final minutes = (totalSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (totalSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  void initState() {
    super.initState();
    _remaining = widget.remainingTime;
    _ticker = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remaining.inSeconds <= 0) {
        timer.cancel();
        return;
      }
      setState(() => _remaining -= const Duration(seconds: 1));
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  Future<void> _confirmSubmit() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_radius),
        ),
        title: const Text('Finalizar simulado?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _unanswered > 0
                  ? 'Você deixou $_unanswered de ${widget.totalQuestions} '
                      'questões sem resposta. Elas serão enviadas em branco.'
                  : 'Todas as ${widget.totalQuestions} questões foram '
                      'respondidas.',
              style: const TextStyle(color: EducanoColors.textSecondary),
            ),
            const SizedBox(height: _spacingSmall),
            const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.lock_outline_rounded,
                  size: 18,
                  color: EducanoColors.error,
                ),
                SizedBox(width: _spacingMinimum),
                Expanded(
                  child: Text(
                    _lockWarning,
                    style: TextStyle(
                      color: EducanoColors.error,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Confirmar envio'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    _ticker?.cancel();
    setState(() => _submitted = true);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Simulado enviado para correção!'),
        backgroundColor: EducanoColors.successGreen,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _review() {
    final onReview = widget.onReview;
    if (onReview != null) {
      onReview();
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Voltando para as questões do simulado...'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < AppBreakpoints.compact;

        return SingleChildScrollView(
          padding: EdgeInsets.all(isCompact ? _spacingSmall : _spacingMedium),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context, isCompact),
              SizedBox(height: isCompact ? _spacingMedium : _spacingLarge),
              _buildPanel(context, isCompact),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context, bool isCompact) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.title,
          style: isCompact
              ? Theme.of(context).textTheme.headlineSmall
              : Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: _spacingMinimum),
        Text(
          widget.subtitle,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: EducanoColors.textSecondary,
                fontSize: isCompact ? 13 : null,
              ),
        ),
      ],
    );
  }

  /// No desktop o conteúdo fica dentro de um card branco de largura fixa;
  /// no mobile ele ocupa a tela inteira, sem card (igual ao Figma).
  Widget _buildPanel(BuildContext context, bool isCompact) {
    final content = _submitted
        ? _buildSubmittedContent(context, isCompact)
        : _buildReviewContent(context, isCompact);

    if (isCompact) return content;

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: _panelMaxWidth),
      child: Container(
        padding: const EdgeInsets.all(_spacingMedium),
        decoration: BoxDecoration(
          color: EducanoColors.surface,
          borderRadius: BorderRadius.circular(_radius),
          border: Border.all(color: EducanoColors.border),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: content,
      ),
    );
  }

  Widget _buildReviewContent(BuildContext context, bool isCompact) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildSummary(isCompact),
        const SizedBox(height: _spacingMedium),
        if (_unanswered > 0) ...[
          _buildUnansweredAlert(),
          const SizedBox(height: _spacingSmall),
        ],
        _buildLockNotice(),
        const SizedBox(height: _spacingMedium),
        _buildActions(isCompact),
      ],
    );
  }

  Widget _buildSummary(bool isCompact) {
    final gap = SizedBox(width: isCompact ? _spacingMinimum : _spacingSmall);

    // Sem `stretch`: dentro de um scroll a altura é ilimitada. Os três blocos
    // já têm a mesma altura porque o rótulo é sempre uma linha só.
    return Row(
      children: [
        Expanded(
          child: _buildSummaryTile(
            value: '${widget.answeredQuestions}/${widget.totalQuestions}',
            label: 'Respondidas',
            background: EducanoColors.primaryBlue.withValues(alpha: 0.12),
            valueColor: EducanoColors.primaryBlue,
            isCompact: isCompact,
          ),
        ),
        gap,
        Expanded(
          child: _buildSummaryTile(
            value: '$_unanswered',
            label: isCompact ? 'Não resp.' : 'Não respondidas',
            background: EducanoColors.accentYellow.withValues(alpha: 0.18),
            valueColor: EducanoColors.accentYellow,
            isCompact: isCompact,
          ),
        ),
        gap,
        Expanded(
          child: _buildSummaryTile(
            value: _formattedTime,
            label: isCompact ? 'Tempo' : 'Tempo restante',
            background: EducanoColors.divider,
            valueColor:
                _timeIsOver ? EducanoColors.error : EducanoColors.textPrimary,
            isCompact: isCompact,
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryTile({
    required String value,
    required String label,
    required Color background,
    required Color valueColor,
    required bool isCompact,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: _spacingMinimum,
        vertical: isCompact ? 12 : _spacingSmall,
      ),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: TextStyle(
                fontSize: isCompact ? 20 : 28,
                fontWeight: FontWeight.bold,
                color: valueColor,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: isCompact ? 10 : 12,
              color: EducanoColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUnansweredAlert() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: _spacingSmall,
        vertical: 12,
      ),
      decoration: BoxDecoration(
        color: EducanoColors.error.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: EducanoColors.error.withValues(alpha: 0.35)),
      ),
      child: Text(
        'Atenção: você ainda tem $_unanswered questões não respondidas. '
        'Após finalizar, não será possível alterar suas respostas.',
        style: const TextStyle(
          color: EducanoColors.error,
          fontSize: 12,
          height: 1.4,
        ),
      ),
    );
  }

  Widget _buildLockNotice() {
    return const Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          Icons.lock_outline_rounded,
          size: 18,
          color: EducanoColors.textSecondary,
        ),
        SizedBox(width: _spacingMinimum),
        Expanded(
          child: Text(
            _lockWarning,
            style: TextStyle(
              color: EducanoColors.textSecondary,
              fontSize: 12,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActions(bool isCompact) {
    final reviewButton = OutlinedButton(
      onPressed: _review,
      style: OutlinedButton.styleFrom(
        foregroundColor: EducanoColors.primaryBlue,
        backgroundColor: EducanoColors.surface,
        side: const BorderSide(color: EducanoColors.primaryBlue),
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: const Text('Revisar respostas'),
    );

    final submitButton = ElevatedButton(
      onPressed: _confirmSubmit,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 14),
      ),
      child: const Text('Finalizar e enviar'),
    );

    if (isCompact) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          reviewButton,
          const SizedBox(height: _spacingMinimum),
          submitButton,
        ],
      );
    }

    return Row(
      children: [
        Expanded(child: reviewButton),
        const SizedBox(width: _spacingSmall),
        Expanded(child: submitButton),
      ],
    );
  }

  Widget _buildSubmittedContent(BuildContext context, bool isCompact) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Center(
          child: CircleAvatar(
            radius: 28,
            backgroundColor:
                EducanoColors.successGreen.withValues(alpha: 0.15),
            child: const Icon(
              Icons.check_rounded,
              color: EducanoColors.successGreen,
              size: 32,
            ),
          ),
        ),
        const SizedBox(height: _spacingSmall),
        Text(
          'Respostas enviadas!',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: isCompact ? 16 : 18,
            fontWeight: FontWeight.bold,
            color: EducanoColors.textPrimary,
          ),
        ),
        const SizedBox(height: _spacingMinimum),
        Text(
          '${widget.answeredQuestions} de ${widget.totalQuestions} questões '
          'foram enviadas para correção.',
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: EducanoColors.textSecondary,
            fontSize: 13,
          ),
        ),
        const SizedBox(height: _spacingSmall),
        const Text(
          'Suas respostas não podem mais ser editadas.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: EducanoColors.error,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: _spacingMedium),
        ElevatedButton(
          onPressed: widget.onFinished,
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 14),
          ),
          child: const Text('Concluir'),
        ),
      ],
    );
  }
}
