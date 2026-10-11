import 'package:flutter/material.dart';

import '../../../core/navigation/app_routes.dart';
import '../../../core/theme/educano_colors.dart';
import '../models/exam_session.dart';
import '../widgets/app_buttons.dart';
import '../widgets/app_card.dart';
import '../widgets/dashboard_scaffold.dart';
import 'last_exams_view.dart';

class ExamResultArgs {
  const ExamResultArgs({required this.title});
  final String title;
}

class _SubjectScore {
  const _SubjectScore({required this.subject, required this.correct, required this.total});
  final String subject;
  final int correct;
  final int total;
  double get ratio => total == 0 ? 0 : correct / total;
}

class ExamResultScreen extends StatelessWidget {
  const ExamResultScreen({super.key, this.args, this.session});
  static const routeName = '/simulados/nota';
  final ExamResultArgs? args;
  final ExamSession? session;

  List<_SubjectScore> get _scores => session == null ? const [] : [
        _SubjectScore(subject: session!.isActivity ? 'Atividade' : 'Simulado', correct: session!.correctCount, total: session!.questions.length),
      ];
  int get _totalCorrect => session?.correctCount ?? 0;
  int get _totalQuestions => session?.questions.length ?? 0;

  @override
  Widget build(BuildContext context) {
    final ratio = _totalQuestions == 0 ? 0.0 : _totalCorrect / _totalQuestions;
    final percent = (ratio * 100).round();
    final title = session?.title ?? args?.title ?? 'Simulado';
    return DashboardScaffold(
      title: 'Resultado do Simulado', activeNavIndex: 1, maxContentWidth: 1200,
      showBackButton: true, onBack: () => Navigator.of(context).maybePop(),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Text('$title${session == null ? '' : ' · ${session!.questions.length} questões'}', style: const TextStyle(fontSize: 14, color: EducanoColors.textSecondary)),
        const SizedBox(height: 18),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 34),
          decoration: BoxDecoration(color: EducanoColors.primaryBlue, borderRadius: BorderRadius.circular(16), boxShadow: const [BoxShadow(color: Color(0x22000000), blurRadius: 9, offset: Offset(0, 4))]),
          child: LayoutBuilder(builder: (context, constraints) {
            final compact = constraints.maxWidth < 600;
            final scoreCircle = Container(width: compact ? 112 : 160, height: compact ? 112 : 160, decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Text('$percent%', style: TextStyle(fontSize: compact ? 29 : 40, fontWeight: FontWeight.w700, color: EducanoColors.primaryBlue)), Text('de 100', style: TextStyle(fontSize: compact ? 11 : 14, color: EducanoColors.textSecondary))]));
            final message = Column(crossAxisAlignment: compact ? CrossAxisAlignment.center : CrossAxisAlignment.start, children: [Text(percent >= 70 ? 'Excelente desempenho! 🎉' : 'Continue praticando! 💪', textAlign: compact ? TextAlign.center : TextAlign.left, style: TextStyle(fontSize: compact ? 17 : 24, fontWeight: FontWeight.w700, color: Colors.white)), const SizedBox(height: 10), Text('Você acertou $_totalCorrect de $_totalQuestions questões.', textAlign: compact ? TextAlign.center : TextAlign.left, style: TextStyle(fontSize: compact ? 13 : 15, height: 1.4, color: EducanoColors.secondaryBlue))]);
            if (compact) return Column(children: [scoreCircle, const SizedBox(height: 14), message]);
            return Row(children: [scoreCircle, const SizedBox(width: 48), Expanded(child: message)]);
          }),
        ),
        const SizedBox(height: 20),
        AppCard(padding: const EdgeInsets.all(24), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Desempenho por área', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: EducanoColors.textPrimary)),
          const SizedBox(height: 18),
          for (final score in _scores) Padding(padding: const EdgeInsets.only(bottom: 16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [Expanded(child: Text(score.subject, style: const TextStyle(fontSize: 14, color: EducanoColors.textPrimary))), Text('${score.correct}/${score.total}${MediaQuery.sizeOf(context).width < 700 ? '' : ' acertos'}', style: const TextStyle(fontSize: 12, color: EducanoColors.textSecondary))]),
            const SizedBox(height: 8),
            ClipRRect(borderRadius: BorderRadius.circular(8), child: LinearProgressIndicator(value: score.ratio, minHeight: 10, backgroundColor: EducanoColors.divider, color: score.ratio >= .7 ? EducanoColors.successDark : EducanoColors.primaryBlue)),
          ])),
        ])),
        const SizedBox(height: 20),
        LayoutBuilder(builder: (context, constraints) {
          final compact = constraints.maxWidth < 700;
          final review = OutlineAppButton(label: 'Ver gabarito', height: 52, onPressed: session == null ? null : () => Navigator.of(context).pushNamed('/simulado', arguments: ExamSession(title: session!.title, questions: session!.questions, durationMinutes: session!.durationMinutes, isActivity: session!.isActivity, isReview: true, answers: session!.answers)));
          final back = PrimaryButton(label: session?.isActivity == true ? 'Voltar para Curso' : 'Voltar aos simulados', height: 52, onPressed: () {
            if (session?.isActivity == true) {
              Navigator.of(context).popUntil((route) => route.settings.name == AppRoutes.course);
            } else {
              Navigator.of(context).pushNamedAndRemoveUntil(UltimosSimuladosScreen.routeName, (route) => false);
            }
          });
          if (compact) return Column(children: [review, const SizedBox(height: 10), back]);
          return Row(children: [Expanded(child: review), const SizedBox(width: 16), Expanded(child: back)]);
        }),
      ]),
    );
  }
}
