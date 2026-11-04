import 'package:flutter/material.dart';

import '../../../core/constants/app_breakpoints.dart';
import '../../../core/theme/theme.dart';
import '../../../core/utils/api_mappers.dart';
import '../../../services/api_client.dart';
import '../../../services/progress_service.dart';

const double _spacingMinimum = 8;
const double _spacingSmall = 16;
const double _spacingMedium = 24;
const double _spacingLarge = 32;

const double _radius = 18;

// IBL30 – Alteração de Plano de Conta
class AccountPlanView extends StatefulWidget {
  const AccountPlanView({super.key});

  @override
  State<AccountPlanView> createState() => _AccountPlanViewState();
}

class _AccountPlanViewState extends State<AccountPlanView> {
  String _currentPlan = 'Básico';

  List<Map<String, dynamic>> _plans = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  /// Planos da API no formato dos cards da tela.
  Future<void> _load() async {
    try {
      final data = await ProgressService.instance.plans();
      final plans = (data['dados'] as List).cast<Map<String, dynamic>>();
      if (!mounted) return;
      setState(() {
        _plans = [
          for (final plan in plans)
            {
              'id': plan['id'],
              'name': plan['nome'],
              'price': (plan['precoCentavos'] as int) == 0
                  ? 'Grátis'
                  : 'R\$ ${((plan['precoCentavos'] as int) / 100).toStringAsFixed(2).replaceAll('.', ',')}/mês',
              'priceValue': (plan['precoCentavos'] as int) / 100,
              'color': ApiMappers.color(plan['cor'] as String?),
              'icon': ApiMappers.icon(plan['icone'] as String?, fallback: Icons.school_rounded),
              if (plan['destaque'] != null) 'badge': plan['destaque'],
              'features': (plan['beneficios'] as List).cast<String>(),
              'disabled': (plan['indisponiveis'] as List).cast<String>(),
            },
        ];
        final current = plans.where((p) => p['atual'] == true).firstOrNull;
        if (current != null) _currentPlan = current['nome'] as String;
        _loading = false;
        _error = null;
      });
    } on ApiException catch (error) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = error.message;
      });
    }
  }

  Future<void> _changePlan(String newPlan) async {
    final plan = _plans.firstWhere((p) => p['name'] == newPlan);
    try {
      final message = await ProgressService.instance.subscribe(plan['id'] as String);
      if (!mounted) return;
      setState(() => _currentPlan = newPlan);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: EducanoColors.successGreen,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } on ApiException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.message), backgroundColor: EducanoColors.error),
      );
    }
  }

  void _showChangePlanDialog(BuildContext context, String newPlan) {
    final plan = _plans.firstWhere((p) => p['name'] == newPlan);
    final isDowngrade = _plans.indexWhere((p) => p['name'] == newPlan) <
        _plans.indexWhere((p) => p['name'] == _currentPlan);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_radius),
        ),
        title: Text(isDowngrade ? 'Fazer Downgrade?' : 'Fazer Upgrade?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: (plan['color'] as Color).withValues(alpha: 0.15),
              child: Icon(
                plan['icon'] as IconData,
                color: plan['color'] as Color,
                size: 28,
              ),
            ),
            const SizedBox(height: _spacingSmall),
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style: const TextStyle(
                  color: EducanoColors.textPrimary,
                  fontSize: 14,
                ),
                children: [
                  const TextSpan(text: 'Você está prestes a alterar seu plano de '),
                  TextSpan(
                    text: _currentPlan,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const TextSpan(text: ' para '),
                  TextSpan(
                    text: newPlan,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: plan['color'] as Color,
                    ),
                  ),
                  const TextSpan(text: '.'),
                ],
              ),
            ),
            const SizedBox(height: _spacingSmall),
            Text(
              plan['price'] as String,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: plan['color'] as Color,
              ),
            ),
            if (isDowngrade)
              const Padding(
                padding: EdgeInsets.only(top: _spacingSmall),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline_rounded,
                      color: EducanoColors.warning,
                      size: 16,
                    ),
                    SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        'Você perderá acesso a recursos do plano atual.',
                        style: TextStyle(
                          color: EducanoColors.warning,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _changePlan(newPlan);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  isDowngrade ? EducanoColors.error : EducanoColors.primaryBlue,
            ),
            child: Text(isDowngrade ? 'Confirmar Downgrade' : 'Confirmar Upgrade'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < AppBreakpoints.compact;
        final sectionGap = isCompact ? _spacingMedium : _spacingLarge;

        if (_loading) return const Center(child: CircularProgressIndicator());
        if (_error != null || _plans.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(_error ?? 'Nenhum plano disponível.'),
                TextButton(onPressed: _load, child: const Text('Tentar novamente')),
              ],
            ),
          );
        }

        return SingleChildScrollView(
          padding: EdgeInsets.all(isCompact ? _spacingSmall : _spacingMedium),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),
              SizedBox(height: sectionGap),
              _buildCurrentPlanBanner(context),
              SizedBox(height: sectionGap),
              _buildPlanCards(context),
              SizedBox(height: sectionGap),
              _buildFaq(context),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Plano de Conta',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: _spacingMinimum),
        Text(
          'Escolha o plano ideal para seus estudos.',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: EducanoColors.textSecondary,
              ),
        ),
      ],
    );
  }

  Widget _buildCurrentPlanBanner(BuildContext context) {
    final plan = _plans.firstWhere((p) => p['name'] == _currentPlan);
    final color = plan['color'] as Color;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < AppBreakpoints.compact;

        return Container(
          padding: EdgeInsets.all(isCompact ? _spacingSmall : _spacingMedium),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(_radius),
            border: Border.all(color: color.withValues(alpha: 0.4)),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: isCompact ? 20 : 24,
                backgroundColor: color.withValues(alpha: 0.2),
                child: Icon(
                  plan['icon'] as IconData,
                  color: color,
                  size: isCompact ? 20 : 24,
                ),
              ),
              const SizedBox(width: _spacingSmall),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Plano Atual',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: EducanoColors.textSecondary,
                          ),
                    ),
                    Text(
                      _currentPlan,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: isCompact ? 16 : 18,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: _spacingMinimum),
              Text(
                plan['price'] as String,
                textAlign: TextAlign.right,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: isCompact ? 13 : null,
                  color: EducanoColors.textPrimary,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPlanCards(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Abaixo de 900px os três planos não cabem lado a lado sem espremer
        // a lista de benefícios, então empilham (frame mobile do Figma).
        final isNarrow = constraints.maxWidth < AppBreakpoints.medium;
        if (isNarrow) {
          return Column(
            children: _plans
                .map(
                  (plan) => Padding(
                    padding: const EdgeInsets.only(
                      top: _spacingSmall,
                      bottom: _spacingSmall,
                    ),
                    child: _buildPlanCard(context, plan),
                  ),
                )
                .toList(),
          );
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: _plans
              .map(
                (plan) => Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(
                      right: plan == _plans.last ? 0 : _spacingSmall,
                    ),
                    child: _buildPlanCard(context, plan),
                  ),
                ),
              )
              .toList(),
        );
      },
    );
  }

  Widget _buildPlanCard(BuildContext context, Map<String, dynamic> plan) {
    final isCurrent = plan['name'] == _currentPlan;
    final color = plan['color'] as Color;
    final hasBadge = plan.containsKey('badge');

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          padding: const EdgeInsets.all(_spacingMedium),
          decoration: BoxDecoration(
            color: EducanoColors.background,
            borderRadius: BorderRadius.circular(_radius),
            border: Border.all(
              color: isCurrent ? color : EducanoColors.border,
              width: isCurrent ? 2 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: isCurrent ? color.withValues(alpha: 0.15) : Colors.black12,
                blurRadius: isCurrent ? 12 : 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (hasBadge) const SizedBox(height: _spacingSmall),
              Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: color.withValues(alpha: 0.15),
                    child: Icon(
                      plan['icon'] as IconData,
                      color: color,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: _spacingMinimum),
                  Text(
                    plan['name'] as String,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: _spacingSmall),
              Text(
                plan['price'] as String,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: EducanoColors.textPrimary,
                ),
              ),
              const Divider(),
              ...(plan['features'] as List<dynamic>).map(
                (feature) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 3),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.check_rounded,
                        color: EducanoColors.successGreen,
                        size: 16,
                      ),
                      const SizedBox(width: _spacingMinimum),
                      Expanded(
                        child: Text(
                          feature as String,
                          style: const TextStyle(
                            color: EducanoColors.textPrimary,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              ...(plan['disabled'] as List<dynamic>).map(
                (feature) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 3),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.close_rounded,
                        color: EducanoColors.textSecondary,
                        size: 16,
                      ),
                      const SizedBox(width: _spacingMinimum),
                      Expanded(
                        child: Text(
                          feature as String,
                          style: const TextStyle(
                            color: EducanoColors.textSecondary,
                            fontSize: 13,
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: _spacingMedium),
              SizedBox(
                width: double.infinity,
                child: isCurrent
                    ? OutlinedButton(
                        onPressed: null,
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: color),
                        ),
                        child: Text(
                          'Plano Atual',
                          style: TextStyle(color: color),
                        ),
                      )
                    : ElevatedButton(
                        onPressed: () =>
                            _showChangePlanDialog(context, plan['name'] as String),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: color,
                        ),
                        child: Text(
                          _plans.indexWhere((p) => p['name'] == plan['name']) >
                                  _plans.indexWhere(
                                      (p) => p['name'] == _currentPlan)
                              ? 'Fazer Upgrade'
                              : 'Fazer Downgrade',
                        ),
                      ),
              ),
            ],
          ),
        ),
        if (hasBadge)
          Positioned(
            top: -12,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  plan['badge'] as String,
                  style: const TextStyle(
                    color: EducanoColors.textWhite,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildFaq(BuildContext context) {
    final faqs = [
      {
        'question': 'Posso cancelar meu plano a qualquer momento?',
        'answer':
            'Sim. Você pode cancelar ou fazer downgrade do seu plano quando quiser. O acesso permanece ativo até o fim do período pago.',
      },
      {
        'question': 'Como funciona o upgrade de plano?',
        'answer':
            'Ao fazer upgrade, o novo plano é ativado imediatamente. O valor é calculado proporcionalmente ao período restante do plano atual.',
      },
      {
        'question': 'Meus dados e progresso são mantidos ao mudar de plano?',
        'answer':
            'Sim. Todo o seu progresso, XP, moedas e histórico de atividades são mantidos independentemente do plano.',
      },
    ];

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: _spacingSmall,
        vertical: _spacingMedium,
      ),
      decoration: BoxDecoration(
        color: EducanoColors.background,
        borderRadius: BorderRadius.circular(_radius),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Perguntas Frequentes',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const Divider(),
          // Material próprio: o ExpansionTile usa ListTile, que precisa de um
          // Material mais próximo que o Container decorado desta seção.
          Material(
            type: MaterialType.transparency,
            child: Column(
              children: faqs
                  .map(
                    (faq) => ExpansionTile(
                      tilePadding: EdgeInsets.zero,
                      title: Text(
                        faq['question'] as String,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: EducanoColors.textPrimary,
                          fontSize: 14,
                        ),
                      ),
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(bottom: _spacingSmall),
                          child: Text(
                            faq['answer'] as String,
                            style: const TextStyle(
                              color: EducanoColors.textSecondary,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}
