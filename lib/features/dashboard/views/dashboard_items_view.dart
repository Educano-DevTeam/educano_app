import 'package:flutter/material.dart';
import '../../../core/constants/app_breakpoints.dart';
import '../../../core/data/dashboard_events.dart';
import '../../../core/theme/theme.dart';
import '../../../services/api_client.dart';
import '../../../services/store_service.dart';
import '../widgets/dashboard_list_components.dart';

const double _spacingMinimum = 8;
const double _spacingSmall = 16;
const double _spacingMedium = 24;
const double _spacingLarge = 32;

const double _radius = 18;

const _iconOptions = <Map<String, dynamic>>[
  {'label': 'Raio', 'icon': Icons.bolt_rounded},
  {'label': 'Escudo', 'icon': Icons.shield_rounded},
  {'label': 'Lâmpada', 'icon': Icons.lightbulb_rounded},
  {'label': 'Cronômetro', 'icon': Icons.timer_rounded},
  {'label': 'Reiniciar', 'icon': Icons.refresh_rounded},
  {'label': 'Avatar', 'icon': Icons.face_rounded},
  {'label': 'Estrela', 'icon': Icons.star_rounded},
];

const _colorOptions = <Map<String, dynamic>>[
  {'label': 'Amarelo', 'color': EducanoColors.accentYellow},
  {'label': 'Azul', 'color': EducanoColors.primaryBlue},
  {'label': 'Verde', 'color': EducanoColors.successGreen},
  {'label': 'Verde Escuro', 'color': EducanoColors.darkGreen},
  {'label': 'Vermelho', 'color': EducanoColors.error},
];

const _categories = ['Boosts'];

/// Cadastro ou edição de item da loja (somente administradores).
/// Retorna true quando o item foi salvo na API.
Future<bool> showDashboardItemDialog(
  BuildContext context, {
  Map<String, dynamic>? item,
}) async {
  final saved = await showDialog<bool>(
    context: context,
    builder: (_) => _DashboardItemEditorDialog(item: item),
  );
  if (saved == true) DashboardEvents.notifyChanged();
  return saved == true;
}

class _DashboardItemEditorDialog extends StatefulWidget {
  const _DashboardItemEditorDialog({this.item});

  final Map<String, dynamic>? item;

  @override
  State<_DashboardItemEditorDialog> createState() =>
      _DashboardItemEditorDialogState();
}

class _DashboardItemEditorDialogState
    extends State<_DashboardItemEditorDialog> {
  final _formKey = GlobalKey<FormState>();
  late final _name = TextEditingController(
    text: widget.item?['name'] as String?,
  );
  late final _description = TextEditingController(
    text: widget.item?['description'] as String?,
  );
  late final _price = TextEditingController(
    text: widget.item?['price']?.toString(),
  );
  late final _effectValue = TextEditingController(
    text: '${widget.item?['effectValue'] ?? 2}',
  );
  late final _duration = TextEditingController(
    text: widget.item?['durationMinutes']?.toString() ?? '1440',
  );
  late String _category = _categories.contains(widget.item?['category'])
      ? widget.item!['category'] as String
      : _categories.first;
  late IconData _icon = _iconOptions
      .map((o) => o['icon'] as IconData)
      .firstWhere(
        (i) => i == widget.item?['icon'],
        orElse: () => _iconOptions.first['icon'] as IconData,
      );
  late Color _color = _colorOptions
      .map((o) => o['color'] as Color)
      .firstWhere(
        (c) => c.toARGB32() == (widget.item?['color'] as Color?)?.toARGB32(),
        orElse: () => _colorOptions.first['color'] as Color,
      );
  late String _effect = widget.item?['effect'] as String? ?? 'BOOST_XP';
  late bool _active = widget.item?['active'] as bool? ?? true;
  bool _saving = false;
  String? _error;

  bool get _usesValue => _effect == 'BOOST_XP' || _effect == 'TEMPO_EXTRA';
  bool get _usesDuration =>
      _effect == 'BOOST_XP' || _effect == 'ESCUDO_SEQUENCIA';

  @override
  void dispose() {
    _name.dispose();
    _description.dispose();
    _price.dispose();
    _effectValue.dispose();
    _duration.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _saving = true;
      _error = null;
    });

    final data = {
      'name': _name.text.trim(),
      'description': _description.text.trim(),
      'price': int.parse(_price.text.trim()),
      'icon': _icon,
      'color': _color,
      'category': _category,
      'effect': _effect,
      'effectValue': _usesValue ? double.parse(_effectValue.text.trim()) : 2,
      'durationMinutes': _usesDuration
          ? int.parse(_duration.text.trim())
          : null,
      'active': _active,
    };

    try {
      final id = widget.item?['id'] as String?;
      if (id == null) {
        await StoreService.instance.create(data);
      } else {
        await StoreService.instance.update(id, data);
      }
      if (mounted) Navigator.pop(context, true);
    } on ApiException catch (error) {
      if (!mounted) return;
      setState(() {
        _saving = false;
        _error = error.message;
      });
    }
  }

  String? _positiveNumber(String? value) {
    final number = int.tryParse((value ?? '').trim());
    return number == null || number <= 0 ? 'Informe um número válido' : null;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(_radius),
      ),
      title: Text(widget.item == null ? 'Novo Item' : 'Editar Item'),
      content: SizedBox(
        width: 380,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_error != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: _spacingMinimum),
                    child: Text(
                      _error!,
                      style: const TextStyle(color: EducanoColors.error),
                    ),
                  ),
                TextFormField(
                  controller: _name,
                  decoration: const InputDecoration(labelText: 'Nome'),
                  validator: (value) =>
                      (value ?? '').trim().length < 2 ? 'Informe o nome' : null,
                ),
                const SizedBox(height: _spacingSmall),
                TextFormField(
                  controller: _description,
                  decoration: const InputDecoration(labelText: 'Descrição'),
                  maxLines: 2,
                  validator: (value) => (value ?? '').trim().isEmpty
                      ? 'Informe a descrição'
                      : null,
                ),
                const SizedBox(height: _spacingSmall),
                TextFormField(
                  controller: _price,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Preço (moedas)',
                    prefixIcon: Icon(Icons.monetization_on_rounded),
                  ),
                  validator: _positiveNumber,
                ),
                const SizedBox(height: _spacingSmall),
                DropdownButtonFormField<String>(
                  initialValue: 'BOOST_XP',
                  decoration: const InputDecoration(
                    labelText: 'Efeito do item',
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: 'BOOST_XP',
                      child: Text('Boost de XP'),
                    ),
                  ],
                  onChanged: (value) => setState(() => _effect = value!),
                ),
                if (_usesValue) ...[
                  const SizedBox(height: _spacingSmall),
                  TextFormField(
                    controller: _effectValue,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: _effect == 'BOOST_XP'
                          ? 'Multiplicador de XP (ex.: 2 = dobro)'
                          : 'Minutos extras no simulado',
                    ),
                    validator: (value) {
                      final parsed = num.tryParse((value ?? '').trim());
                      return parsed == null || parsed <= 1 || parsed > 100
                          ? 'Use um multiplicador entre 1 e 100'
                          : null;
                    },
                  ),
                ],
                if (_usesDuration) ...[
                  const SizedBox(height: _spacingSmall),
                  TextFormField(
                    controller: _duration,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Duração após ativar (minutos)',
                      helperText: '1440 = 24 horas',
                    ),
                    validator: _positiveNumber,
                  ),
                ],
                const SizedBox(height: _spacingSmall),
                DropdownButtonFormField<String>(
                  initialValue: _category,
                  decoration: const InputDecoration(labelText: 'Categoria'),
                  items: _categories
                      .map(
                        (value) =>
                            DropdownMenuItem(value: value, child: Text(value)),
                      )
                      .toList(),
                  onChanged: (value) => setState(() => _category = value!),
                ),
                const SizedBox(height: _spacingSmall),
                DropdownButtonFormField<IconData>(
                  initialValue: _icon,
                  decoration: const InputDecoration(labelText: 'Ícone'),
                  items: _iconOptions
                      .map(
                        (option) => DropdownMenuItem(
                          value: option['icon'] as IconData,
                          child: Row(
                            children: [
                              Icon(option['icon'] as IconData, size: 18),
                              const SizedBox(width: 8),
                              Text(option['label'] as String),
                            ],
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (value) => setState(() => _icon = value!),
                ),
                const SizedBox(height: _spacingSmall),
                DropdownButtonFormField<Color>(
                  initialValue: _color,
                  decoration: const InputDecoration(labelText: 'Cor'),
                  items: _colorOptions
                      .map(
                        (option) => DropdownMenuItem(
                          value: option['color'] as Color,
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 8,
                                backgroundColor: option['color'] as Color,
                              ),
                              const SizedBox(width: 8),
                              Text(option['label'] as String),
                            ],
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (value) => setState(() => _color = value!),
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  value: _active,
                  onChanged: (value) => setState(() => _active = value),
                  title: const Text('Disponível na loja'),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _saving ? null : () => Navigator.pop(context, false),
          child: const Text('Cancelar'),
        ),
        ElevatedButton.icon(
          onPressed: _saving ? null : _save,
          icon: _saving
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.check_rounded),
          label: const Text('Salvar'),
        ),
      ],
    );
  }
}

// IBL22/IBL23 – Cadastro e listagem de itens da loja.
class DashboardItemsView extends StatefulWidget {
  const DashboardItemsView({super.key});

  @override
  State<DashboardItemsView> createState() => _DashboardItemsViewState();
}

class _DashboardItemsViewState extends State<DashboardItemsView> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedStatus = 'Todos';
  String _selectedCategory = 'Todas';
  List<Map<String, dynamic>> _items = [];
  bool _loading = true;
  String? _error;

  List<String> get _categoryOptions {
    final categories =
        _items.map((item) => item['category'] as String).toSet().toList()
          ..sort();
    return ['Todas', ...categories];
  }

  List<Map<String, dynamic>> get _filteredItems {
    final query = _searchQuery.trim().toLowerCase();
    return _items.where((item) {
      final matchesSearch =
          query.isEmpty ||
          (item['name'] as String).toLowerCase().contains(query) ||
          (item['description'] as String).toLowerCase().contains(query) ||
          (item['category'] as String).toLowerCase().contains(query);
      final matchesStatus =
          _selectedStatus == 'Todos' ||
          (_selectedStatus == 'Na loja'
              ? item['active'] == true
              : item['active'] != true);
      final matchesCategory =
          _selectedCategory == 'Todas' || item['category'] == _selectedCategory;
      return matchesSearch && matchesStatus && matchesCategory;
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    DashboardEvents.changes.addListener(_load);
    _load();
  }

  @override
  void dispose() {
    DashboardEvents.changes.removeListener(_load);
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final snapshot = await StoreService.instance.items(includeInactive: true);
      if (!mounted) return;
      setState(() {
        _items = snapshot.items;
        if (!_categoryOptions.contains(_selectedCategory)) {
          _selectedCategory = 'Todas';
        }
        _loading = false;
      });
    } on ApiException catch (error) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = error.message;
      });
    }
  }

  void _snack(String message, {bool error = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: error
            ? EducanoColors.error
            : EducanoColors.successGreen,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // A listagem recarrega pelo DashboardEvents disparado após salvar.
  Future<void> _showItemDialog({Map<String, dynamic>? item}) async {
    if (await showDashboardItemDialog(context, item: item) && mounted) {
      _snack(item == null ? 'Item cadastrado!' : 'Item atualizado!');
    }
  }

  void _confirmDelete(Map<String, dynamic> item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_radius),
        ),
        title: const Text('Excluir Item'),
        content: Text(
          'Excluir "${item['name']}"? Se alguém já comprou o item, ele apenas '
          'deixa de aparecer na loja.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: EducanoColors.error,
            ),
            onPressed: () async {
              Navigator.pop(context);
              try {
                final message = await StoreService.instance.delete(
                  item['id'] as String,
                );
                if (!mounted) return;
                _snack(message);
                await _load();
              } on ApiException catch (error) {
                _snack(error.message, error: true);
              }
            },
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
  }

  String _effectLabel(Map<String, dynamic> item) {
    final effect = StoreService.effects[item['effect']] ?? '—';
    final duration = item['durationMinutes'] as int?;
    if (item['effect'] == 'BOOST_XP') {
      return '$effect ${item['effectValue']}x por ${_formatMinutes(duration)}';
    }
    if (item['effect'] == 'TEMPO_EXTRA')
      return '$effect +${item['effectValue']} min';
    if (duration != null) return '$effect por ${_formatMinutes(duration)}';
    return effect;
  }

  String _formatMinutes(int? minutes) {
    if (minutes == null) return '—';
    if (minutes % 1440 == 0) return '${minutes ~/ 1440} dia(s)';
    if (minutes % 60 == 0) return '${minutes ~/ 60} h';
    return '$minutes min';
  }

  void _showItemDetails(Map<String, dynamic> item) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: (item['color'] as Color).withValues(alpha: .15),
              child: Icon(
                item['icon'] as IconData,
                color: item['color'] as Color,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(item['name'] as String)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(item['description'] as String),
            const SizedBox(height: 12),
            Text('Preço: ${item['price']} moedas'),
            Text('Categoria: ${item['category']}'),
            Text('Efeito: ${_effectLabel(item)}'),
            Text(
              'Situação: ${item['active'] == true ? 'Disponível na loja' : 'Fora da loja'}',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fechar'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              _showItemDialog(item: item);
            },
            icon: const Icon(Icons.edit_rounded),
            label: const Text('Editar'),
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
          _buildStats(),
          const SizedBox(height: _spacingLarge),
          _buildActions(),
          const SizedBox(height: _spacingSmall),
          _buildSearchAndFilters(),
          const SizedBox(height: _spacingMedium),
          _buildItemsList(context),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Itens da Loja',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: _spacingMinimum),
        Text(
          'Gerencie os itens disponíveis na loja dos alunos.',
          style: Theme.of(
            context,
          ).textTheme.bodyLarge?.copyWith(color: EducanoColors.textSecondary),
        ),
      ],
    );
  }

  Widget _buildActions() {
    return ElevatedButton.icon(
      onPressed: () => _showItemDialog(),
      icon: const Icon(Icons.add_rounded),
      label: const Text('Novo Item'),
    );
  }

  Widget _buildSearchAndFilters() {
    Widget statusFilter() => DropdownButtonFormField<String>(
      isExpanded: true,
      initialValue: _selectedStatus,
      decoration: const InputDecoration(labelText: 'Status'),
      items: const ['Todos', 'Na loja', 'Fora da loja']
          .map((value) => DropdownMenuItem(value: value, child: Text(value)))
          .toList(),
      onChanged: (value) {
        if (value != null) setState(() => _selectedStatus = value);
      },
    );
    Widget categoryFilter() => DropdownButtonFormField<String>(
      isExpanded: true,
      initialValue: _selectedCategory,
      decoration: const InputDecoration(labelText: 'Categoria'),
      items: _categoryOptions
          .map((value) => DropdownMenuItem(value: value, child: Text(value)))
          .toList(),
      onChanged: (value) {
        if (value != null) setState(() => _selectedCategory = value);
      },
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final searchField = TextField(
          controller: _searchController,
          onChanged: (value) => setState(() => _searchQuery = value),
          decoration: const InputDecoration(
            hintText: 'Buscar por nome, descrição ou categoria...',
            prefixIcon: Icon(Icons.search_rounded),
          ),
        );
        if (constraints.maxWidth < AppBreakpoints.medium) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              searchField,
              const SizedBox(height: _spacingSmall),
              Row(
                children: [
                  Expanded(child: statusFilter()),
                  const SizedBox(width: _spacingSmall),
                  Expanded(child: categoryFilter()),
                ],
              ),
            ],
          );
        }
        return Row(
          children: [
            Expanded(child: searchField),
            const SizedBox(width: _spacingSmall),
            SizedBox(width: 170, child: statusFilter()),
            const SizedBox(width: _spacingSmall),
            SizedBox(width: 170, child: categoryFilter()),
          ],
        );
      },
    );
  }

  Widget _buildStats() {
    final active = _items.where((i) => i['active'] == true).toList();
    final averagePrice = active.isEmpty
        ? 0
        : active.fold<int>(0, (sum, i) => sum + (i['price'] as int)) ~/
              active.length;
    final categories = _items.map((i) => i['category']).toSet().length;

    return DashboardSummaryGrid(
      items: [
        DashboardSummaryData(
          label: 'Itens na loja',
          value: '${active.length}',
          icon: Icons.store_rounded,
          color: EducanoColors.primaryBlue,
        ),
        DashboardSummaryData(
          label: 'Fora da loja',
          value: '${_items.length - active.length}',
          icon: Icons.visibility_off_rounded,
          color: EducanoColors.error,
        ),
        DashboardSummaryData(
          label: 'Preço médio',
          value: '$averagePrice',
          icon: Icons.monetization_on_rounded,
          color: EducanoColors.accentYellow,
        ),
        DashboardSummaryData(
          label: 'Categorias',
          value: '$categories',
          icon: Icons.category_rounded,
          color: EducanoColors.successGreen,
        ),
      ],
    );
  }

  Widget _buildItemsList(BuildContext context) {
    if (_loading) {
      return const DashboardListCard(
        title: 'Lista de Itens',
        children: [
          Padding(
            padding: EdgeInsets.all(_spacingLarge),
            child: Center(child: CircularProgressIndicator()),
          ),
        ],
      );
    }
    if (_error != null) {
      return DashboardListCard(
        title: 'Lista de Itens',
        children: [
          Padding(
            padding: const EdgeInsets.all(_spacingLarge),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    _error!,
                    style: const TextStyle(color: EducanoColors.error),
                  ),
                ),
                TextButton(
                  onPressed: _load,
                  child: const Text('Tentar novamente'),
                ),
              ],
            ),
          ),
        ],
      );
    }
    final items = _filteredItems;
    return DashboardListCard(
      title: 'Lista de Itens',
      count: items.length,
      children: items.isEmpty
          ? [
              Padding(
                padding: const EdgeInsets.all(_spacingLarge),
                child: Center(
                  child: Text(
                    _items.isEmpty
                        ? 'Nenhum item cadastrado.'
                        : 'Nenhum item encontrado.',
                  ),
                ),
              ),
            ]
          : items
                .map(
                  (item) => DashboardListRow(
                    onTap: () => _showItemDetails(item),
                    leading: CircleAvatar(
                      backgroundColor: (item['color'] as Color).withValues(
                        alpha: .15,
                      ),
                      child: Icon(
                        item['icon'] as IconData,
                        color: item['color'] as Color,
                      ),
                    ),
                    title: item['active'] == true
                        ? item['name'] as String
                        : '${item['name']} (fora da loja)',
                    subtitle:
                        '${item['category']}  •  ${item['price']} moedas  •  ${_effectLabel(item)}',
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          onPressed: () => _showItemDialog(item: item),
                          icon: const Icon(Icons.edit_rounded),
                        ),
                        IconButton(
                          onPressed: () => _confirmDelete(item),
                          icon: const Icon(
                            Icons.delete_outline_rounded,
                            color: Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
                .toList(),
    );
  }
}
