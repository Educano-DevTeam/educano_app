import 'package:flutter/material.dart';

import '../../../core/theme/educano_colors.dart';
import '../widgets/app_buttons.dart';
import '../widgets/app_card.dart';
import '../widgets/dashboard_scaffold.dart';
import 'exam_result_view.dart';
import '../models/exam_session.dart';
import '../models/exam_history_store.dart';

class ExamFinishScreen extends StatefulWidget {
  const ExamFinishScreen({super.key, this.session});
  final ExamSession? session;
  static const routeName = '/simulados/finalizar';

  @override
  State<ExamFinishScreen> createState() => _ExamFinishScreenState();
}

class _ExamFinishScreenState extends State<ExamFinishScreen> {
  bool _loading = false;
  int get totalQuestions => widget.session?.questions.length ?? 0;
  int get answeredQuestions => widget.session?.answeredCount ?? 0;
  int get pendingQuestions => totalQuestions - answeredQuestions;

  void _finish() {
    if (_loading) return;
    setState(() => _loading = true);
    final session = widget.session;
    if (session != null) ExamHistoryStore.add(session);
    Future<void>.delayed(const Duration(milliseconds: 700), () {
      if (!mounted) return;
      Navigator.of(context).pushReplacementNamed(ExamResultScreen.routeName, arguments: session);
    });
  }

  @override
  Widget build(BuildContext context) => DashboardScaffold(
        title: 'Finalizar Simulado',
        activeNavIndex: 1,
        maxContentWidth: 1200,
        showBackButton: true,
        onBack: () => Navigator.of(context).maybePop(),
        child: AppCard(
          padding: const EdgeInsets.all(28),
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            const Text('Revise seu progresso antes de enviar suas respostas.', style: TextStyle(fontSize: 14, color: EducanoColors.textSecondary)),
            const SizedBox(height: 18),
            LayoutBuilder(builder: (context, constraints) {
              final compact = constraints.maxWidth < 500;
              return Row(children: [
                Expanded(child: _StatTile(label: 'Respondidas', value: '$answeredQuestions/$totalQuestions', color: EducanoColors.primaryBlue, background: EducanoColors.lightBlue, compact: compact)),
                SizedBox(width: compact ? 10 : 16),
                Expanded(child: _StatTile(label: compact ? 'Não resp.' : 'Não respondidas', value: '$pendingQuestions', color: EducanoColors.accentYellow, background: EducanoColors.warningLight, compact: compact)),
                SizedBox(width: compact ? 10 : 16),
                Expanded(child: _StatTile(label: compact ? 'Tempo' : 'Tempo estimado', value: '${widget.session?.durationMinutes ?? 0} min', color: EducanoColors.textPrimary, background: EducanoColors.divider, compact: compact)),
              ]);
            }),
            if (pendingQuestions > 0) ...[
              const SizedBox(height: 18),
              Container(padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14), decoration: BoxDecoration(color: EducanoColors.errorBackground, borderRadius: BorderRadius.circular(12)), child: Text('Atenção: você ainda tem $pendingQuestions questões não respondidas. Após finalizar, não será possível alterar suas respostas.', style: const TextStyle(fontSize: 13, height: 1.35, color: EducanoColors.error))),
            ],
            const SizedBox(height: 24),
            LayoutBuilder(builder: (context, constraints) {
              final compact = constraints.maxWidth < 700;
              final review = OutlineAppButton(label: 'Revisar respostas', height: 52, onPressed: () => Navigator.of(context).maybePop());
              final submit = PrimaryButton(label: 'Finalizar e enviar', height: 52, isLoading: _loading, onPressed: _finish);
              if (compact) return Column(children: [review, const SizedBox(height: 10), submit]);
              return Row(children: [Expanded(child: review), const SizedBox(width: 16), Expanded(child: submit)]);
            }),
          ]),
        ),
      );
}

class _StatTile extends StatelessWidget {
  const _StatTile({required this.label, required this.value, required this.color, required this.background, required this.compact});
  final String label;
  final String value;
  final Color color;
  final Color background;
  final bool compact;
  @override
  Widget build(BuildContext context) => Container(
        constraints: BoxConstraints(minHeight: compact ? 86 : 160),
        padding: EdgeInsets.symmetric(horizontal: 6, vertical: compact ? 10 : 24),
        decoration: BoxDecoration(color: background.withOpacity(.72), borderRadius: BorderRadius.circular(12)),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          FittedBox(fit: BoxFit.scaleDown, child: Text(value, style: TextStyle(fontSize: compact ? 20 : 32, fontWeight: FontWeight.w700, color: color))),
          const SizedBox(height: 4),
          Text(label, maxLines: 1, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center, style: TextStyle(fontSize: compact ? 10 : 12, color: EducanoColors.textSecondary)),
        ]),
      );
}
