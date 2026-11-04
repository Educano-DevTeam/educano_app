import 'package:flutter/material.dart';
import '../../../core/theme/educano_colors.dart';
import '../../../core/constants/app_breakpoints.dart';

import '../../../core/widgets/ui/app_card.dart';
import '../../../core/widgets/ui/app_button.dart';
import '../../../core/models/app_user.dart';
import '../../../core/navigation/app_routes.dart';
import '../../../services/api_client.dart';
import '../../../services/auth_service.dart';
import '../../../services/progress_service.dart';
import '../../../services/storage_service.dart';
import '../../../services/users_service.dart';
import '../../auth/widgets/validators.dart';

class SettingsView extends StatefulWidget {
  const SettingsView({super.key});

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  bool _novidadesPlataforma = true;
  bool _lembretesEstudo = true;
  bool _respostasForum = false;
  bool _modoEscuro = false;
  bool _efeitosSonoros = true;

  Future<void> _confirmarEncerramento() async {
    final bool? confirmar = await showDialog<bool>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.4),
      builder: (ctx) => Dialog(
        backgroundColor: Colors.white,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 440),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: EducanoColors.legacyRed.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.warning_amber_rounded, color: EducanoColors.legacyRed, size: 22),
                    ),
                    const SizedBox(width: 14),
                    const Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(top: 8),
                        child: Text(
                          'Deseja encerrar sua conta?',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: EducanoColors.legacyTextPrimary,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Text(
                  'Essa ação é permanente. Todo o seu progresso, XP, conquistas e histórico de estudos serão removidos e não poderão ser recuperados.',
                  style: TextStyle(fontSize: 13, color: EducanoColors.legacyTextSecondary, height: 1.5),
                ),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: EducanoColors.legacyRed.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: EducanoColors.legacyRed.withValues(alpha: 0.2)),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.info_outline, size: 16, color: EducanoColors.legacyRed),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Recomendamos exportar seus dados antes de continuar.',
                          style: TextStyle(fontSize: 12, color: EducanoColors.legacyRed),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 22),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(ctx).pop(false),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: EducanoColors.legacyTextPrimary,
                          side: const BorderSide(color: EducanoColors.legacyCardBorder),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        child: const Text('Cancelar'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => Navigator.of(ctx).pop(true),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: EducanoColors.legacyRed,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        child: const Text('Encerrar conta'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );

    if (confirmar == true && mounted) {
      try {
        await UsersService.instance.deleteMyAccount();
        await AuthService.instance.logout();
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Sua conta foi encerrada.')),
        );
        Navigator.of(context).pushNamedAndRemoveUntil(AppRoutes.login, (route) => false);
      } on ApiException catch (error) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error.message), backgroundColor: EducanoColors.legacyRed),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                IconButton(
                  onPressed: () => Navigator.of(context).maybePop(),
                  icon: const Icon(Icons.arrow_back, color: EducanoColors.legacyTextPrimary),
                ),
                const Text(
                  'Configurações',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: EducanoColors.legacyTextPrimary),
                ),
              ],
            ),
            const Padding(
              padding: EdgeInsets.only(left: 48),
              child: Text(
                'Gerencie sua conta, notificações e preferências.',
                style: TextStyle(fontSize: 13, color: EducanoColors.legacyTextSecondary),
              ),
            ),
            const SizedBox(height: 20),
            _buildContent(context),
            const SizedBox(height: 20),
          ],
        ),
    );
  }

  Widget _buildContent(BuildContext context) {
    final bool mobile = (MediaQuery.sizeOf(context).width < AppBreakpoints.medium);

    const Widget dadosConta = _DadosContaCard();
    final Widget notificacoes = _NotificacoesCard(
      novidades: _novidadesPlataforma,
      lembretes: _lembretesEstudo,
      forum: _respostasForum,
      onNovidades: (v) => setState(() => _novidadesPlataforma = v),
      onLembretes: (v) => setState(() => _lembretesEstudo = v),
      onForum: (v) => setState(() => _respostasForum = v),
    );
    const Widget seguranca = _SegurancaCard();
    const Widget planoAtual = _PlanoAtualCard();
    final Widget preferencias = _PreferenciasCard(
      modoEscuro: _modoEscuro,
      efeitosSonoros: _efeitosSonoros,
      onModoEscuro: (v) => setState(() => _modoEscuro = v),
      onEfeitosSonoros: (v) => setState(() => _efeitosSonoros = v),
    );
    final Widget encerrarConta = _EncerrarContaCard(onDelete: _confirmarEncerramento);

    if (mobile) {
      return Column(
        children: [
          dadosConta,
          const SizedBox(height: 20),
          notificacoes,
          const SizedBox(height: 20),
          planoAtual,
          const SizedBox(height: 20),
          preferencias,
          const SizedBox(height: 20),
          seguranca,
          const SizedBox(height: 20),
          encerrarConta,
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 3,
          child: Column(
            children: [
              dadosConta,
              const SizedBox(height: 20),
              notificacoes,
              const SizedBox(height: 20),
              seguranca,
            ],
          ),
        ),
        const SizedBox(width: 20),
        Expanded(
          flex: 2,
          child: Column(
            children: [
              planoAtual,
              const SizedBox(height: 20),
              preferencias,
              const SizedBox(height: 20),
              encerrarConta,
            ],
          ),
        ),
      ],
    );
  }
}

// ----------------------------------------------------------------------
// Dados da conta
// ----------------------------------------------------------------------

class _DadosContaCard extends StatefulWidget {
  const _DadosContaCard();

  @override
  State<_DadosContaCard> createState() => _DadosContaCardState();
}

class _DadosContaCardState extends State<_DadosContaCard> {
  final _name = TextEditingController();
  AppUser? _user;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    StorageService.instance.loadCurrentUser().then((user) {
      if (!mounted || user == null) return;
      setState(() {
        _user = user;
        _name.text = user.name;
      });
    });
  }

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final user = _user;
    if (user == null) return;
    if (_name.text.trim().length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Informe um nome válido.')),
      );
      return;
    }
    setState(() => _saving = true);
    try {
      final updated = await UsersService.instance.updateMyName(user, _name.text);
      if (!mounted) return;
      setState(() => _user = updated);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Dados atualizados.'), backgroundColor: EducanoColors.successGreen),
      );
    } on ApiException catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error.message), backgroundColor: EducanoColors.legacyRed),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Dados da conta',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.5, color: EducanoColors.legacyTextPrimary)),
          const SizedBox(height: 16),
          _ControlledFieldsRow(
            fields: [
              _ControlledField('Nome Completo', _name),
              _ControlledField('E-mail', TextEditingController(text: _user?.email ?? ''), readOnly: true),
            ],
          ),
          const SizedBox(height: 14),
          _ControlledFieldsRow(
            fields: [
              _ControlledField('Perfil de acesso', TextEditingController(text: _user?.role ?? ''), readOnly: true),
            ],
          ),
          const SizedBox(height: 18),
          HoverButton(
            label: _saving ? 'Salvando...' : 'Salvar alterações',
            onPressed: _saving ? () {} : _save,
            padding: const EdgeInsets.symmetric(vertical: 14),
            fontSize: 13.5,
            borderRadius: 8,
          ),
        ],
      ),
    );
  }
}

/// Campo com controller, usado nos cards que salvam dados na API.
class _ControlledField {
  final String label;
  final TextEditingController controller;
  final bool obscure;
  final bool readOnly;
  const _ControlledField(this.label, this.controller, {this.obscure = false, this.readOnly = false});
}

class _ControlledFieldsRow extends StatelessWidget {
  final List<_ControlledField> fields;
  const _ControlledFieldsRow({required this.fields});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final narrow = constraints.maxWidth < 380;
        final widgets = [
          for (final f in fields)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(f.label, style: const TextStyle(fontSize: 11.5, color: EducanoColors.legacyTextSecondary)),
                const SizedBox(height: 6),
                TextField(
                  controller: f.controller,
                  obscureText: f.obscure,
                  readOnly: f.readOnly,
                  style: TextStyle(
                    fontSize: 13,
                    color: f.readOnly ? EducanoColors.legacyTextSecondary : null,
                  ),
                  decoration: const InputDecoration(isDense: true),
                ),
              ],
            ),
        ];
        if (narrow) {
          return Column(
            children: [
              for (int i = 0; i < widgets.length; i++) ...[
                widgets[i],
                if (i != widgets.length - 1) const SizedBox(height: 14),
              ],
            ],
          );
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (int i = 0; i < widgets.length; i++) ...[
              Expanded(child: widgets[i]),
              if (i != widgets.length - 1) const SizedBox(width: 14),
            ],
          ],
        );
      },
    );
  }
}

// ----------------------------------------------------------------------
// Notificações
// ----------------------------------------------------------------------

class _NotificacoesCard extends StatelessWidget {
  final bool novidades;
  final bool lembretes;
  final bool forum;
  final ValueChanged<bool> onNovidades;
  final ValueChanged<bool> onLembretes;
  final ValueChanged<bool> onForum;

  const _NotificacoesCard({
    required this.novidades,
    required this.lembretes,
    required this.forum,
    required this.onNovidades,
    required this.onLembretes,
    required this.onForum,
  });

  @override
  Widget build(BuildContext context) {
    return AppSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Notificações',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.5, color: EducanoColors.legacyTextPrimary)),
          const Text('Escolha o que você quer receber por e-mail ou push.',
              style: TextStyle(fontSize: 11.5, color: EducanoColors.legacyTextSecondary)),
          const SizedBox(height: 12),
          _ToggleRow(
            title: 'Novidades da plataforma',
            subtitle: 'Lançamento de cursos e recursos',
            value: novidades,
            onChanged: onNovidades,
          ),
          const Divider(height: 26),
          _ToggleRow(
            title: 'Lembretes de estudo',
            subtitle: 'Alertas diários para manter sua sequência',
            value: lembretes,
            onChanged: onLembretes,
          ),
          const Divider(height: 26),
          _ToggleRow(
            title: 'Respostas do fórum',
            subtitle: 'Quando alguém responder sua dúvida',
            value: forum,
            onChanged: onForum,
          ),
        ],
      ),
    );
  }
}

class _ToggleRow extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _ToggleRow({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: const TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 13, color: EducanoColors.legacyTextPrimary)),
              const SizedBox(height: 2),
              Text(subtitle, style: const TextStyle(fontSize: 11.5, color: EducanoColors.legacyTextSecondary)),
            ],
          ),
        ),
        Switch(value: value, onChanged: onChanged, activeThumbColor: EducanoColors.legacyPrimary),
      ],
    );
  }
}

// ----------------------------------------------------------------------
// Segurança
// ----------------------------------------------------------------------

class _SegurancaCard extends StatefulWidget {
  const _SegurancaCard();

  @override
  State<_SegurancaCard> createState() => _SegurancaCardState();
}

class _SegurancaCardState extends State<_SegurancaCard> {
  final _current = TextEditingController();
  final _next = TextEditingController();
  bool _saving = false;

  @override
  void dispose() {
    _current.dispose();
    _next.dispose();
    super.dispose();
  }

  void _message(String text, {bool error = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(text),
        backgroundColor: error ? EducanoColors.legacyRed : EducanoColors.successGreen,
      ),
    );
  }

  Future<void> _save() async {
    final problem = _current.text.isEmpty
        ? 'Digite sua senha atual'
        : Validators.password(_next.text);
    if (problem != null) {
      _message(problem, error: true);
      return;
    }
    setState(() => _saving = true);
    try {
      final message = await UsersService.instance.changePassword(_current.text, _next.text);
      if (!mounted) return;
      _current.clear();
      _next.clear();
      _message(message);
    } on ApiException catch (error) {
      if (mounted) _message(error.message, error: true);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Segurança',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.5, color: EducanoColors.legacyTextPrimary)),
          const SizedBox(height: 16),
          _ControlledFieldsRow(
            fields: [
              _ControlledField('Senha atual', _current, obscure: true),
              _ControlledField('Nova senha', _next, obscure: true),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            'A nova senha precisa ter 8+ caracteres, letra maiúscula, número e símbolo. '
            'Senhas valem por 90 dias.',
            style: TextStyle(fontSize: 11, color: EducanoColors.legacyTextSecondary),
          ),
          const SizedBox(height: 18),
          HoverButton(
            label: _saving ? 'Alterando...' : 'Alterar Senha',
            onPressed: _saving ? () {} : _save,
            padding: const EdgeInsets.symmetric(vertical: 14),
            fontSize: 13.5,
            borderRadius: 8,
          ),
        ],
      ),
    );
  }
}

// ----------------------------------------------------------------------
// Plano atual
// ----------------------------------------------------------------------

class _PlanoAtualCard extends StatefulWidget {
  const _PlanoAtualCard();

  @override
  State<_PlanoAtualCard> createState() => _PlanoAtualCardState();
}

class _PlanoAtualCardState extends State<_PlanoAtualCard> {
  String _name = 'Básico';
  String _price = 'Grátis';

  @override
  void initState() {
    super.initState();
    ProgressService.instance.plans().then((data) {
      final current = (data['dados'] as List)
          .cast<Map<String, dynamic>>()
          .where((p) => p['atual'] == true)
          .firstOrNull;
      if (!mounted || current == null) return;
      final cents = current['precoCentavos'] as int;
      setState(() {
        _name = current['nome'] as String;
        _price = cents == 0
            ? 'Grátis'
            : 'R\$ ${(cents / 100).toStringAsFixed(2).replaceAll('.', ',')}/mês';
      });
    }).catchError((_) {});
  }

  @override
  Widget build(BuildContext context) {
    return AppSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Plano atual',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.5, color: EducanoColors.legacyTextPrimary)),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(14),
            decoration:
                BoxDecoration(color: EducanoColors.legacyLavender, borderRadius: BorderRadius.circular(10)),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(_name,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 14, color: EducanoColors.legacyTextPrimary)),
                      Text(_price, style: const TextStyle(fontSize: 11.5, color: EducanoColors.legacyTextSecondary)),
                    ],
                  ),
                ),
                HoverButton(
                  label: _name == 'Premium' ? 'Ver planos' : 'Fazer Upgrade',
                  onPressed: () => Navigator.of(context).pushNamed(AppRoutes.accountPlan),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          const Text.rich(
            TextSpan(
              style: TextStyle(fontSize: 11.5, color: EducanoColors.legacyTextSecondary),
              children: [
                TextSpan(text: 'Veja todos os planos em '),
                TextSpan(
                    text: 'Perfil > Planos.',
                    style: TextStyle(color: EducanoColors.legacyPrimary, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ----------------------------------------------------------------------
// Preferências
// ----------------------------------------------------------------------

class _PreferenciasCard extends StatelessWidget {
  final bool modoEscuro;
  final bool efeitosSonoros;
  final ValueChanged<bool> onModoEscuro;
  final ValueChanged<bool> onEfeitosSonoros;

  const _PreferenciasCard({
    required this.modoEscuro,
    required this.efeitosSonoros,
    required this.onModoEscuro,
    required this.onEfeitosSonoros,
  });

  @override
  Widget build(BuildContext context) {
    return AppSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Preferências',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.5, color: EducanoColors.legacyTextPrimary)),
          const SizedBox(height: 12),
          _ToggleRow(
            title: 'Modo escuro',
            subtitle: 'Altera o fundo das telas da plataforma.',
            value: modoEscuro,
            onChanged: onModoEscuro,
          ),
          const Divider(height: 26),
          _ToggleRow(
            title: 'Efeitos sonoros',
            subtitle: 'Efeitos sonoros para conquistas, acertos e recompensas.',
            value: efeitosSonoros,
            onChanged: onEfeitosSonoros,
          ),
        ],
      ),
    );
  }
}

// ----------------------------------------------------------------------
// Encerrar conta
// ----------------------------------------------------------------------

class _EncerrarContaCard extends StatefulWidget {
  final VoidCallback onDelete;
  const _EncerrarContaCard({required this.onDelete});

  @override
  State<_EncerrarContaCard> createState() => _EncerrarContaCardState();
}

class _EncerrarContaCardState extends State<_EncerrarContaCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _hovered
                ? EducanoColors.legacyRed.withValues(alpha: 0.5)
                : EducanoColors.legacyRedSoft,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Encerrar sua conta',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: EducanoColors.legacyRed)),
            const SizedBox(height: 6),
            const Text(
              'Encerrar sua conta remove todo o seu progresso permanentemente.',
              style: TextStyle(fontSize: 11.5, color: EducanoColors.legacyTextSecondary),
            ),
            const SizedBox(height: 14),
            OutlinedButton(
              onPressed: widget.onDelete,
              style: OutlinedButton.styleFrom(
                foregroundColor: EducanoColors.legacyRed,
                side: const BorderSide(color: EducanoColors.legacyRed),
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              ),
              child: const Text('Excluir conta'),
            ),
          ],
        ),
      ),
    );
  }
}
