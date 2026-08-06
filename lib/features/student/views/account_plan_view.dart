import 'package:flutter/material.dart';

import '../../../core/theme/theme.dart';

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

  final List<Map<String, dynamic>> _plans = [
    {
      'name': 'Básico',
      'price': 'Grátis',
      'priceValue': 0.0,
      'color': EducanoColors.softGreen,
      'icon': Icons.school_rounded,
      'features': [
        'Acesso a cursos gratuitos',
        'Até 3 simulados por mês',
        'Ranking global',
        'Suporte por e-mail',
      ],
      'disabled': [
        'Cursos premium',
        'Simulados ilimitados',
        'Relatórios avançados',
        'Suporte prioritário',
      ],
    },
    {
      'name': 'Pro',
      'price': 'R\$ 29,90/mês',
      'priceValue': 29.90,
      'color': EducanoColors.primaryBlue,
      'icon': Icons.workspace_premium_rounded,
      'badge': 'Mais Popular',
      'features': [
        'Todos os cursos disponíveis',
        'Simulados ilimitados',
        'Ranking global',
        'Relatórios de desempenho',
        'Suporte prioritário',
        'Certificados digitais',
      ],
      'disabled': [
        'Mentoria individual',
        'Conteúdo exclusivo',
      ],
    },
    {
      'name': 'Premium',
      'price': 'R\$ 59,90/mês',
      'priceValue': 59.90,
      'color': EducanoColors.accentYellow,
      'icon': Icons.diamond_rounded,
      'features': [
        'Tudo do plano Pro',
        'Mentoria individual mensal',
        'Conteúdo exclusivo',
        'Acesso antecipado a novidades',
        'Badge exclusivo no perfil',
        'Desconto em eventos parceiros',
      ],
      'disabled': [],
    },
  ];

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
              setState(() => _currentPlan = newPlan);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Plano alterado para $newPlan!'),
                  backgroundColor: EducanoColors.successGreen,
                  behavior: SnackBarBehavior.floating,
                ),
              );
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
    return SingleChildScrollView(
      padding: const EdgeInsets.all(_spacingMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context),
          const SizedBox(height: _spacingLarge),
          _buildCurrentPlanBanner(context),
          const SizedBox(height: _spacingLarge),
          _buildPlanCards(context),
          const SizedBox(height: _spacingLarge),
          _buildFaq(context),
        ],
      ),
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

    return Container(
      padding: const EdgeInsets.all(_spacingMedium),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(_radius),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: color.withValues(alpha: 0.2),
            child: Icon(
              plan['icon'] as IconData,
              color: color,
              size: 24,
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
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
          Text(
            plan['price'] as String,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: EducanoColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlanCards(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 700;
        if (isNarrow) {
          return Column(
            children: _plans
                .map(
                  (plan) => Padding(
                    padding: const EdgeInsets.only(bottom: _spacingSmall),
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
      padding: const EdgeInsets.all(_spacingMedium),
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
          ...faqs.map(
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
          ),
        ],
      ),
    );
  }
}
