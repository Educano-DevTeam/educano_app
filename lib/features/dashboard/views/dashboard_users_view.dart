import 'dart:async';

import 'package:flutter/material.dart';
import '../../../core/data/dashboard_events.dart';
import '../../../core/theme/theme.dart';
import '../../../core/utils/api_mappers.dart';
import '../../../services/api_client.dart';
import '../../../services/auth_service.dart';
import '../../../services/storage_service.dart';
import '../../../services/users_service.dart';
import '../../auth/widgets/validators.dart';
import '../widgets/dashboard_list_components.dart';

// IBL03/IBL04 – Cadastro e listagem de usuários (somente administradores).
class DashboardUsersView extends StatefulWidget { const DashboardUsersView({super.key}); @override State<DashboardUsersView> createState() => _DashboardUsersViewState(); }
class _DashboardUsersViewState extends State<DashboardUsersView> {
  final _service = UsersService.instance;
  final _search = TextEditingController(); String _type = 'Todos', _status = 'Todos';
  final List<Map<String, dynamic>> _users = []; int _page = 1, _totalPages = 1, _total = 0; bool _loading = true; String? _error, _myId; Timer? _debounce;
  @override void initState() { super.initState(); DashboardEvents.changes.addListener(_reload); StorageService.instance.loadCurrentUser().then((u) => _myId = u?.id); _reload(); }
  @override void dispose() { DashboardEvents.changes.removeListener(_reload); _debounce?.cancel(); _search.dispose(); super.dispose(); }
  String? get _statusFilter => switch (_status) { 'Ativos' => 'ATIVO', 'Inativos' => 'INATIVO', 'Pendentes' => 'PENDENTE', _ => null };
  void _reload() => _load(reset: true);
  Future<void> _load({bool reset = false}) async {
    setState(() { _loading = true; _error = null; });
    try {
      final page = await _service.list(page: reset ? 1 : _page + 1, search: _search.text.trim(), type: UsersService.typeValue(_type), status: _statusFilter);
      if (!mounted) return;
      setState(() { if (reset) _users.clear(); _users.addAll(page.users); _page = page.page; _totalPages = page.totalPages; _total = page.total; _loading = false; });
    } on ApiException catch (e) { if (mounted) setState(() { _loading = false; _error = e.message; }); }
  }
  void _onSearch(String _) { _debounce?.cancel(); _debounce = Timer(const Duration(milliseconds: 400), _reload); }
  void _snack(String message, {bool error = false}) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), backgroundColor: error ? EducanoColors.error : EducanoColors.successGreen, behavior: SnackBarBehavior.floating));
  // A listagem recarrega pelo DashboardEvents disparado após o cadastro.
  Future<void> _addUser() => showDashboardUserDialog(context);
  Future<void> _toggle(Map<String, dynamic> u, bool active) async {
    try { final updated = await _service.setStatus(u['id'] as String, active); if (!mounted) return; setState(() => u['status'] = updated['status']); _snack(active ? '${u['nome']} reativado(a).' : '${u['nome']} desativado(a).'); }
    on ApiException catch (e) { _snack(e.message, error: true); }
  }
  Future<void> _delete(Map<String, dynamic> u) async {
    final ok = await showDialog<bool>(context: context, builder: (_) => AlertDialog(title: const Text('Excluir usuário'), content: Text('Excluir definitivamente a conta de ${u['nome']}? Perfil, inscrições e histórico também serão removidos.'), actions: [TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')), ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: EducanoColors.error), onPressed: () => Navigator.pop(context, true), child: const Text('Excluir'))]));
    if (ok != true) return;
    try { await _service.delete(u['id'] as String); if (!mounted) return; setState(() { _users.remove(u); _total--; }); _snack('Usuário excluído.'); } on ApiException catch (e) { _snack(e.message, error: true); }
  }
  Future<void> _details(Map<String, dynamic> u) async {
    final profile = (u['perfil'] as Map<String, dynamic>?);
    await showDialog<void>(context: context, builder: (_) => AlertDialog(title: Row(children: [CircleAvatar(backgroundColor: EducanoColors.primaryBlue.withValues(alpha: .12), child: const Icon(Icons.person, color: EducanoColors.primaryBlue)), const SizedBox(width: 12), Expanded(child: Text(u['nome'] as String))]), content: SizedBox(width: 420, child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
      _info('E-mail', u['email'] as String), _info('Tipo', UsersService.typeLabels[u['tipo']] ?? '—'), _info('Status', UsersService.statusLabels[u['status']] ?? '—'), _info('Criado em', ApiMappers.formatDateTime(u['criadoEm'])), _info('Atualizado em', ApiMappers.formatDateTime(u['atualizadoEm'])),
      const Divider(height: 24),
      if (profile == null) const Text('Este usuário não possui perfil.') else ...[_info('Nível', '${profile['nivel']}'), _info('XP', '${profile['xp']}'), _info('Moedas', '${profile['moedas']}'), _info('Perfil', profile['tipoPerfil'] == 'PUBLICO' ? 'Público' : 'Privado')],
    ])), actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Fechar'))]));
  }
  Widget _info(String label, String value) => Padding(padding: const EdgeInsets.symmetric(vertical: 3), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [SizedBox(width: 110, child: Text(label, style: const TextStyle(color: EducanoColors.textSecondary, fontSize: 12))), Expanded(child: Text(value, style: const TextStyle(fontWeight: FontWeight.w500)))]));
  Color _statusColor(String? status) => switch (status) { 'ATIVO' => EducanoColors.successGreen, 'INATIVO' => EducanoColors.error, _ => EducanoColors.accentYellow };
  Widget _filters() => LayoutBuilder(builder: (context, constraints) { final search = TextField(controller: _search, onChanged: _onSearch, decoration: const InputDecoration(hintText: 'Buscar por nome ou email...', prefixIcon: Icon(Icons.search_rounded))); final type = DropdownButtonFormField<String>(initialValue: _type, decoration: const InputDecoration(labelText: 'Tipo'), items: ['Todos', ...UsersService.typeLabels.values].map((v) => DropdownMenuItem(value: v, child: Text(v))).toList(), onChanged: (v) { setState(() => _type = v!); _reload(); }); final status = DropdownButtonFormField<String>(initialValue: _status, decoration: const InputDecoration(labelText: 'Status'), items: ['Todos', 'Ativos', 'Inativos', 'Pendentes'].map((v) => DropdownMenuItem(value: v, child: Text(v))).toList(), onChanged: (v) { setState(() => _status = v!); _reload(); }); if (constraints.maxWidth < 700) return Column(children: [search, const SizedBox(height: 16), Row(children: [Expanded(child: type), const SizedBox(width: 16), Expanded(child: status)])]); return Row(children: [Expanded(child: search), const SizedBox(width: 16), SizedBox(width: 170, child: type), const SizedBox(width: 16), SizedBox(width: 170, child: status)]); });
  Widget _row(Map<String, dynamic> u) {
    final status = u['status'] as String?; final isMe = u['id'] == _myId;
    return DashboardListRow(onTap: () => _details(u), leading: CircleAvatar(backgroundColor: EducanoColors.primaryBlue.withValues(alpha: .12), child: const Icon(Icons.person, color: EducanoColors.primaryBlue)), title: u['nome'] as String, subtitle: '${u['email']}  •  ${UsersService.typeLabels[u['tipo']]}  •  Criado em ${ApiMappers.formatDate(u['criadoEm'])}  •  ${UsersService.statusLabels[status]}',
      trailing: Row(mainAxisSize: MainAxisSize.min, children: [
        Tooltip(message: status == 'PENDENTE' ? 'Aguardando validação do e-mail' : isMe ? 'Você não pode desativar sua conta' : (status == 'ATIVO' ? 'Desativar' : 'Reativar'), child: Switch(value: status == 'ATIVO', activeThumbColor: _statusColor(status), onChanged: status == 'PENDENTE' || isMe ? null : (v) => _toggle(u, v))),
        PopupMenuButton<String>(onSelected: (action) => action == 'details' ? _details(u) : _delete(u), itemBuilder: (_) => [const PopupMenuItem(value: 'details', child: Text('Ver detalhes')), if (!isMe) const PopupMenuItem(value: 'delete', child: Text('Excluir', style: TextStyle(color: EducanoColors.error)))]),
      ]));
  }
  @override Widget build(BuildContext context) => SingleChildScrollView(padding: const EdgeInsets.all(24), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Usuarios', style: Theme.of(context).textTheme.headlineMedium), const SizedBox(height: 8), Text('Gerencie as contas dos usuarios.', style: Theme.of(context).textTheme.bodyLarge), const SizedBox(height: 24), ElevatedButton.icon(onPressed: _addUser, icon: const Icon(Icons.add_rounded), label: const Text('Novo Usuario')), const SizedBox(height: 16), _filters(), const SizedBox(height: 24),
    DashboardListCard(title: 'Lista de Usuarios', count: _total, children: [
      if (_error != null) Padding(padding: const EdgeInsets.all(24), child: Row(children: [Expanded(child: Text(_error!, style: const TextStyle(color: EducanoColors.error))), TextButton(onPressed: _reload, child: const Text('Tentar novamente'))])),
      if (!_loading && _error == null && _users.isEmpty) const Padding(padding: EdgeInsets.all(24), child: Text('Nenhum usuário encontrado.')),
      ..._users.map(_row),
      if (_loading) const Padding(padding: EdgeInsets.all(24), child: Center(child: CircularProgressIndicator())),
      if (!_loading && _page < _totalPages) Padding(padding: const EdgeInsets.all(16), child: Center(child: OutlinedButton(onPressed: _load, child: const Text('Carregar mais')))),
    ])]));
}

class _UserDialog extends StatefulWidget { const _UserDialog(); @override State<_UserDialog> createState() => _UserDialogState(); }
class _UserDialogState extends State<_UserDialog> {
  final _form = GlobalKey<FormState>(); final _name = TextEditingController(), _email = TextEditingController(), _password = TextEditingController(); String _type = 'Aluno'; bool _saving = false; String? _error;
  @override void dispose() { _name.dispose(); _email.dispose(); _password.dispose(); super.dispose(); }
  Future<void> _submit() async {
    if (!_form.currentState!.validate()) return;
    setState(() { _saving = true; _error = null; });
    final result = await AuthService.instance.registerByAdmin(name: _name.text, email: _email.text, password: _password.text, type: UsersService.typeValue(_type) ?? 'ALUNO');
    if (!mounted) return;
    if (result.success) { Navigator.pop(context, true); } else { setState(() { _saving = false; _error = result.message; }); }
  }
  @override Widget build(BuildContext context) => AlertDialog(title: const Text('Cadastrar usuario'), content: SizedBox(width: 420, child: Form(key: _form, child: Column(mainAxisSize: MainAxisSize.min, children: [
    if (_error != null) Padding(padding: const EdgeInsets.only(bottom: 8), child: Text(_error!, style: const TextStyle(color: EducanoColors.error))),
    TextFormField(controller: _name, decoration: const InputDecoration(labelText: 'Nome'), validator: (v) => (v ?? '').trim().length < 2 ? 'Informe o nome' : null),
    TextFormField(controller: _email, decoration: const InputDecoration(labelText: 'Email'), validator: Validators.email),
    TextFormField(controller: _password, obscureText: true, decoration: const InputDecoration(labelText: 'Senha', helperText: '8+ caracteres, com maiúscula, número e símbolo'), validator: Validators.password),
    DropdownButtonFormField<String>(initialValue: _type, decoration: const InputDecoration(labelText: 'Tipo'), items: UsersService.typeLabels.values.map((v) => DropdownMenuItem(value: v, child: Text(v))).toList(), onChanged: (v) => setState(() => _type = v!)),
    const SizedBox(height: 12),
    const Text('A conta fica pendente até o usuário validar o código enviado para o e-mail.', style: TextStyle(fontSize: 12, color: EducanoColors.textSecondary)),
  ]))), actions: [TextButton(onPressed: _saving ? null : () => Navigator.pop(context, false), child: const Text('Cancelar')), ElevatedButton(onPressed: _saving ? null : _submit, child: _saving ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('Cadastrar'))]);
}

/// Abre o cadastro de usuário; retorna true quando a conta foi criada.
Future<bool> showDashboardUserDialog(BuildContext context) async {
  final created = await showDialog<bool>(context: context, builder: (_) => const _UserDialog());
  if (created == true && context.mounted) {
    DashboardEvents.notifyChanged();
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Usuário cadastrado. Enviamos um código de validação para o e-mail informado.'), backgroundColor: EducanoColors.successGreen, behavior: SnackBarBehavior.floating));
  }
  return created == true;
}
