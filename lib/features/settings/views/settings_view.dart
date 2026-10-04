import 'package:flutter/material.dart';
import '../../../core/theme/educano_colors.dart';
import '../../../core/constants/app_breakpoints.dart';

import '../../../core/widgets/ui/app_card.dart';
import '../../../core/widgets/ui/app_button.dart';

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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Conta encerrada (simulação).')),
      );
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

class _DadosContaCard extends StatelessWidget {
  const _DadosContaCard();

  @override
  Widget build(BuildContext context) {
    return AppSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Dados da conta',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.5, color: EducanoColors.legacyTextPrimary)),
          const SizedBox(height: 16),
          const _FieldsRow(
            fields: [
              _FieldData('Nome Completo', 'Daniel Lima'),
              _FieldData('E-mail', 'daniel.lima@gmail.com'),
            ],
          ),
          const SizedBox(height: 14),
          const _FieldsRow(
            fields: [
              _FieldData('Telefone', '(11) 99999-9999'),
              _FieldData('Perfil de acesso', 'Administrador'),
            ],
          ),
          const SizedBox(height: 18),
          HoverButton(
            label: 'Salvar alterações',
            onPressed: () {},
            padding: const EdgeInsets.symmetric(vertical: 14),
            fontSize: 13.5,
            borderRadius: 8,
          ),
        ],
      ),
    );
  }
}

class _FieldData {
  final String label;
  final String value;
  final bool obscure;
  const _FieldData(this.label, this.value, {this.obscure = false});
}

class _FieldsRow extends StatelessWidget {
  final List<_FieldData> fields;
  const _FieldsRow({required this.fields});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool narrow = constraints.maxWidth < 380;
        final List<Widget> widgets =
            fields.map((f) => _LabeledField(label: f.label, value: f.value, obscureText: f.obscure)).toList();

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

class _LabeledField extends StatelessWidget {
  final String label;
  final String value;
  final bool obscureText;
  const _LabeledField({required this.label, required this.value, this.obscureText = false});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 11.5, color: EducanoColors.legacyTextSecondary)),
        const SizedBox(height: 6),
        TextFormField(
          initialValue: value,
          obscureText: obscureText,
          style: const TextStyle(fontSize: 13),
          decoration: const InputDecoration(isDense: true),
        ),
      ],
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

class _SegurancaCard extends StatelessWidget {
  const _SegurancaCard();

  @override
  Widget build(BuildContext context) {
    return AppSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Segurança',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.5, color: EducanoColors.legacyTextPrimary)),
          const SizedBox(height: 16),
          const _FieldsRow(
            fields: [
              _FieldData('Senha atual', 'senha123456', obscure: true),
              _FieldData('Nova senha', '', obscure: true),
            ],
          ),
          const SizedBox(height: 18),
          HoverButton(
            label: 'Alterar Senha',
            onPressed: () {},
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

class _PlanoAtualCard extends StatelessWidget {
  const _PlanoAtualCard();

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
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Básico',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 14, color: EducanoColors.legacyTextPrimary)),
                      Text('Grátis', style: TextStyle(fontSize: 11.5, color: EducanoColors.legacyTextSecondary)),
                    ],
                  ),
                ),
                HoverButton(
                  label: 'Fazer Upgrade',
                  onPressed: () {},
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
                    text: 'Loja > Planos.',
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
