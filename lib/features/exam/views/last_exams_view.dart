import 'package:educano_app/features/exam/widgets/status_badge.dart';

import '../../../core/theme/educano_colors.dart';
import 'package:flutter/material.dart';
import '../widgets/app_card.dart';
import '../widgets/app_buttons.dart';
import '../widgets/dashboard_scaffold.dart';
import 'exam_result_view.dart';
import '../../../core/utils/api_mappers.dart';
import '../../../services/api_client.dart';
import '../../../services/exams_service.dart';
import '../../../core/navigation/app_routes.dart';

class ExamHistoryItem {
  const ExamHistoryItem({
    required this.title,
    required this.subject,
    required this.date,
    required this.status,
    this.score,
  });

  final String title;
  final String subject;
  final String date;
  final SimuladoStatus status;
  final String? score;
}

/// Tela "Últimos Simulados" — lista o histórico de simulados do aluno.
/// O botão "+ Novo Simulado" fica no canto superior direito, alinhado
/// com o título, seguindo o padrão definido para as telas que precisam
/// de uma ação de criação (em vez de um floating action button).
class UltimosSimuladosScreen extends StatefulWidget {
  const UltimosSimuladosScreen({super.key});

  static const routeName = '/simulados';

  @override
  State<UltimosSimuladosScreen> createState() => _UltimosSimuladosScreenState();
}

class _UltimosSimuladosScreenState extends State<UltimosSimuladosScreen> {
  late Future<List<Map<String, dynamic>>> _history = ExamsService.instance.history();

  void _reload() => setState(() => _history = ExamsService.instance.history());

  /// Abre o resultado de um simulado finalizado ou retoma um em andamento.
  Future<void> _open(Map<String, dynamic> record) async {
    try {
      final session = await ExamsService.instance.get(record['id'] as String);
      if (!mounted) return;
      final inProgress = !session.isFinished;
      final expired = inProgress && (session.remainingSeconds ?? 0) <= 0;
      if (expired) {
        // O tempo acabou: finaliza para calcular a nota.
        final finished = await ExamsService.instance.finish(session);
        if (!mounted) return;
        await Navigator.of(context).pushNamed(ExamResultScreen.routeName, arguments: finished);
      } else {
        await Navigator.of(context).pushNamed(
          inProgress ? AppRoutes.exam : ExamResultScreen.routeName,
          arguments: session,
        );
      }
      if (mounted) _reload();
    } on ApiException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.message), backgroundColor: EducanoColors.error),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final compact = MediaQuery.sizeOf(context).width < 700;
    return DashboardScaffold(
      title: 'Últimos Simulados',
      activeNavIndex: 1,
      maxContentWidth: 1200,
      actions: [
        PrimaryButton(
          label: compact ? '+ Novo' : '+ Novo Simulado',
          expand: false,
          height: 44,
          onPressed: () async {
            await Navigator.of(context).pushNamed(AppRoutes.examConfig);
            if (mounted) _reload();
          },
        ),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          FutureBuilder<List<Map<String, dynamic>>>(
            future: _history,
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      children: [
                        Text('${snapshot.error}'),
                        TextButton(onPressed: _reload, child: const Text('Tentar novamente')),
                      ],
                    ),
                  ),
                );
              }
              if (!snapshot.hasData) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: CircularProgressIndicator(),
                  ),
                );
              }
              return LayoutBuilder(
            builder: (context, constraints) {
              final mobile = constraints.maxWidth < 700;
              final records = snapshot.data!;
              if (records.isEmpty) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: Text('Você ainda não fez simulados.'),
                  ),
                );
              }
              final rows = records
                  .map(
                    (record) {
                      final finished = record['status'] == 'FINALIZADO';
                      final materias = (record['materias'] as List).cast<String>();
                      return _ExamHistoryCard(
                      compact: mobile,
                      item: ExamHistoryItem(
                        title: record['titulo'] as String,
                        subject: materias.isEmpty ? 'Simulado' : materias.join(', '),
                        date: ApiMappers.formatDate(record['finalizadoEm'] ?? record['iniciadoEm']),
                        status: finished ? SimuladoStatus.concluido : SimuladoStatus.emAndamento,
                        score: finished
                            ? '${record['acertos']}/${record['total']} acertos'
                            : record['expirado'] == true
                                ? 'Tempo esgotado'
                                : null,
                      ),
                      onTap: () => _open(record),
                    );
                    },
                  )
                  .toList();
              if (mobile)
                return Column(
                  children: [
                    for (final row in rows)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: row,
                      ),
                  ],
                );
              return Container(
                decoration: BoxDecoration(
                  color: EducanoColors.surface,
                  border: Border.all(
                    color: EducanoColors.cardBorder,
                    width: 1.5,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x10000000),
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                clipBehavior: Clip.antiAlias,
                child: Column(
                  children: [
                    for (var i = 0; i < rows.length; i++)
                      Column(
                        children: [
                          rows[i],
                          if (i < rows.length - 1)
                            const Divider(
                              height: 1,
                              color: EducanoColors.cardBorder,
                            ),
                        ],
                      ),
                  ],
                ),
              );
            },
          );
            },
          ),
        ],
      ),
    );
  }
}

class _ExamHistoryCard extends StatelessWidget {
  const _ExamHistoryCard({
    required this.item,
    required this.onTap,
    this.compact = false,
  });

  final ExamHistoryItem item;
  final VoidCallback onTap;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    if (compact) {
      return AppCard(
        onTap: onTap,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              item.title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: EducanoColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Text(
                    '${item.date} · ${item.score ?? '—'}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: EducanoColors.textSecondary,
                    ),
                  ),
                ),
                _StatusPill(status: item.status),
              ],
            ),
          ],
        ),
      );
    }
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
        child: Row(
          children: [
            Expanded(
              flex: 5,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: EducanoColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    '${item.date} · ${item.score ?? ''}',
                    style: const TextStyle(
                      fontSize: 13,
                      color: EducanoColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              width: 60,
              child: Text(
                item.score == null ? '—' : item.score!.split('/').first,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: EducanoColors.textPrimary,
                ),
              ),
            ),
            const SizedBox(width: 20),
            SizedBox(
              width: 150,
              child: Center(child: _StatusPill(status: item.status)),
            ),
            const SizedBox(width: 20),
            OutlinedButton(onPressed: onTap, child: const Text('Ver detalhes')),
          ],
        ),
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.status});
  final SimuladoStatus status;
  @override
  Widget build(BuildContext context) {
    final done = status == SimuladoStatus.concluido;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
      decoration: BoxDecoration(
        color: done ? EducanoColors.successLight : EducanoColors.warningLight,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        done ? 'Concluído' : 'Em andamento',
        style: TextStyle(
          color: done ? EducanoColors.successDark : EducanoColors.accentYellow,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
