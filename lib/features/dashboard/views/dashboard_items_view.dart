import 'package:educano_app/core/widgets/ui/app_small_button.dart';
import 'package:flutter/material.dart';

import '../../../core/theme/theme.dart';
import '../widgets/dashboard_list_components.dart';

const double _spacingMinimum = 8;
const double _spacingSmall = 16;
const double _spacingMedium = 24;
const double _spacingLarge = 32;

const double _radius = 18;

Future<void> showDashboardItemDialog(BuildContext context) async {
  final iconOptions = <Map<String, dynamic>>[
    {'label': 'Raio', 'icon': Icons.bolt_rounded},
    {'label': 'Escudo', 'icon': Icons.shield_rounded},
    {'label': 'Lâmpada', 'icon': Icons.lightbulb_rounded},
    {'label': 'Cronômetro', 'icon': Icons.timer_rounded},
    {'label': 'Reiniciar', 'icon': Icons.refresh_rounded},
    {'label': 'Avatar', 'icon': Icons.face_rounded},
    {'label': 'Estrela', 'icon': Icons.star_rounded},
  ];

  final colorOptions = <Map<String, dynamic>>[
    {'label': 'Amarelo', 'color': EducanoColors.accentYellow},
    {'label': 'Azul', 'color': EducanoColors.primaryBlue},
    {'label': 'Verde', 'color': EducanoColors.successGreen},
    {'label': 'Verde Escuro', 'color': EducanoColors.darkGreen},
    {'label': 'Vermelho', 'color': EducanoColors.error},
  ];

  final categories = ['Boosts', 'Proteção', 'Estudos', 'Personalização'];

  await showDialog<void>(
    context: context,
    builder: (_) => _DashboardItemEditorDialog(
      iconOptions: iconOptions,
      colorOptions: colorOptions,
      categories: categories,
    ),
  );
}

class _DashboardItemEditorDialog extends StatefulWidget {
  const _DashboardItemEditorDialog({
    required this.iconOptions,
    required this.colorOptions,
    required this.categories,
  });

  final List<Map<String, dynamic>> iconOptions;
  final List<Map<String, dynamic>> colorOptions;
  final List<String> categories;

  @override
  State<_DashboardItemEditorDialog> createState() =>
      _DashboardItemEditorDialogState();
}

class _DashboardItemEditorDialogState extends State<_DashboardItemEditorDialog> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _description = TextEditingController();
  final _price = TextEditingController();

  late String _category = widget.categories.first;
  late IconData _icon = widget.iconOptions.first['icon'] as IconData;
  late Color _color = widget.colorOptions.first['color'] as Color;

  @override
  void dispose() {
    _name.dispose();
    _description.dispose();
    _price.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(_radius),
      ),
      title: const Text('Novo Item'),
      content: SizedBox(
        width: 360,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _name,
                  decoration: const InputDecoration(labelText: 'Nome'),
                  validator: (value) =>
                      (value ?? '').trim().isEmpty ? 'Informe o nome' : null,
                ),
                const SizedBox(height: _spacingSmall),
                TextFormField(
                  controller: _description,
                  decoration: const InputDecoration(labelText: 'Descrição'),
                  maxLines: 2,
                ),
                const SizedBox(height: _spacingSmall),
                TextFormField(
                  controller: _price,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Preço (moedas)',
                    prefixIcon: Icon(Icons.monetization_on_rounded),
                  ),
                  validator: (value) =>
                      int.tryParse(value ?? '') == null ? 'Informe um preço válido' : null,
                ),
                const SizedBox(height: _spacingSmall),
                DropdownButtonFormField<String>(
                  initialValue: _category,
                  decoration: const InputDecoration(labelText: 'Categoria'),
                  items: widget.categories
                      .map((value) => DropdownMenuItem(value: value, child: Text(value)))
                      .toList(),
                  onChanged: (value) => setState(() => _category = value!),
                ),
                const SizedBox(height: _spacingSmall),
                DropdownButtonFormField<IconData>(
                  initialValue: _icon,
                  decoration: const InputDecoration(labelText: 'Ícone'),
                  items: widget.iconOptions
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
                  items: widget.colorOptions
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
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        ElevatedButton.icon(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              Navigator.pop(context);
            }
          },
          icon: const Icon(Icons.save_rounded),
          label: const Text('Salvar'),
        ),
      ],
    );
  }
}

/// Gestão administrativa dos itens vendidos na Loja do aluno.
/// Acessada pelo item "Itens da Loja" da barra lateral (admin/parceiro).
class DashboardItemsView extends StatefulWidget {
  const DashboardItemsView({super.key});

  @override
  State<DashboardItemsView> createState() => _DashboardItemsViewState();
}

class _DashboardItemsViewState extends State<DashboardItemsView> {
  final List<Map<String, dynamic>> _iconOptions = [
    {'label': 'Raio', 'icon': Icons.bolt_rounded},
    {'label': 'Escudo', 'icon': Icons.shield_rounded},
    {'label': 'LÃ¢mpada', 'icon': Icons.lightbulb_rounded},
    {'label': 'CronÃ´metro', 'icon': Icons.timer_rounded},
    {'label': 'Reiniciar', 'icon': Icons.refresh_rounded},
    {'label': 'Avatar', 'icon': Icons.face_rounded},
    {'label': 'Estrela', 'icon': Icons.star_rounded},
  ];

  final List<Map<String, dynamic>> _colorOptions = [
    {'label': 'Amarelo', 'color': EducanoColors.accentYellow},
    {'label': 'Azul', 'color': EducanoColors.primaryBlue},
    {'label': 'Verde', 'color': EducanoColors.successGreen},
    {'label': 'Verde Escuro', 'color': EducanoColors.darkGreen},
    {'label': 'Vermelho', 'color': EducanoColors.error},
  ];

  final List<String> _categories = [
    'Boosts',
    'ProteÃ§Ã£o',
    'Estudos',
    'PersonalizaÃ§Ã£o',
  ];

  final List<Map<String, dynamic>> _items = [
    {
      'name': 'Boost de XP',
      'description': 'Dobra o XP ganho por 24 horas.',
      'price': 200,
      'icon': Icons.bolt_rounded,
      'color': EducanoColors.accentYellow,
      'category': 'Boosts',
    },
    {
      'name': 'Escudo de SequÃªncia',
      'description': 'Protege sua sequÃªncia por um dia.',
      'price': 150,
      'icon': Icons.shield_rounded,
      'color': EducanoColors.primaryBlue,
      'category': 'ProteÃ§Ã£o',
    },
    {
      'name': 'Dica Extra',
      'description': 'Revela uma dica em qualquer questÃ£o.',
      'price': 80,
      'icon': Icons.lightbulb_rounded,
      'color': EducanoColors.successGreen,
      'category': 'Estudos',
    },
    {
      'name': 'Tempo Extra',
      'description': 'Adiciona 5 minutos em simulados.',
      'price': 120,
      'icon': Icons.timer_rounded,
      'color': EducanoColors.successGreen,
      'category': 'Estudos',
    },
    {
      'name': 'Reviver Tentativa',
      'description': 'Refaz uma questÃ£o errada.',
      'price': 100,
      'icon': Icons.refresh_rounded,
      'color': EducanoColors.error,
      'category': 'Estudos',
    },
    {
      'name': 'Avatar Especial',
      'description': 'Desbloqueie um avatar exclusivo.',
      'price': 500,
      'icon': Icons.face_rounded,
      'color': EducanoColors.darkGreen,
      'category': 'PersonalizaÃ§Ã£o',
    },
  ];

  void _showItemDialog({Map<String, dynamic>? item}) {
    final isEditing = item != null;
    final nameController = TextEditingController(text: item?['name'] as String? ?? '');
    final descriptionController =
        TextEditingController(text: item?['description'] as String? ?? '');
    final priceController =
        TextEditingController(text: item != null ? '${item['price']}' : '');
    String category = item?['category'] as String? ?? _categories.first;
    IconData icon = item?['icon'] as IconData? ?? _iconOptions.first['icon'] as IconData;
    Color color = item?['color'] as Color? ?? _colorOptions.first['color'] as Color;
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(_radius),
          ),
          title: Text(isEditing ? 'Editar Item' : 'Novo Item'),
          content: SizedBox(
            width: 360,
            child: Form(
              key: formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      controller: nameController,
                      decoration: const InputDecoration(labelText: 'Nome'),
                      validator: (v) =>
                          (v == null || v.trim().isEmpty) ? 'Informe o nome' : null,
                    ),
                    const SizedBox(height: _spacingSmall),
                    TextFormField(
                      controller: descriptionController,
                      decoration: const InputDecoration(labelText: 'DescriÃ§Ã£o'),
                      maxLines: 2,
                    ),
                    const SizedBox(height: _spacingSmall),
                    TextFormField(
                      controller: priceController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'PreÃ§o (moedas)',
                        prefixIcon: Icon(Icons.monetization_on_rounded),
                      ),
                      validator: (v) => (int.tryParse(v ?? '') == null)
                          ? 'Informe um preÃ§o vÃ¡lido'
                          : null,
                    ),
                    const SizedBox(height: _spacingSmall),
                    DropdownButtonFormField<String>(
                      initialValue: category,
                      decoration: const InputDecoration(labelText: 'Categoria'),
                      items: _categories
                          .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                          .toList(),
                      onChanged: (v) => setDialogState(() => category = v!),
                    ),
                    const SizedBox(height: _spacingSmall),
                    DropdownButtonFormField<IconData>(
                      initialValue: icon,
                      decoration: const InputDecoration(labelText: 'Ãcone'),
                      items: _iconOptions
                          .map(
                            (option) => DropdownMenuItem(
                              value: option['icon'] as IconData,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(option['icon'] as IconData, size: 18),
                                  const SizedBox(width: _spacingMinimum),
                                  Text(option['label'] as String),
                                ],
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: (v) => setDialogState(() => icon = v!),
                    ),
                    const SizedBox(height: _spacingSmall),
                    DropdownButtonFormField<Color>(
                      initialValue: color,
                      decoration: const InputDecoration(labelText: 'Cor'),
                      items: _colorOptions
                          .map(
                            (option) => DropdownMenuItem(
                              value: option['color'] as Color,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  CircleAvatar(
                                    radius: 8,
                                    backgroundColor: option['color'] as Color,
                                  ),
                                  const SizedBox(width: _spacingMinimum),
                                  Text(option['label'] as String),
                                ],
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: (v) => setDialogState(() => color = v!),
                    ),
                  ],
                ),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton.icon(
              onPressed: () {
                if (!formKey.currentState!.validate()) return;
                final newItem = {
                  'name': nameController.text,
                  'description': descriptionController.text,
                  'price': int.parse(priceController.text),
                  'icon': icon,
                  'color': color,
                  'category': category,
                };
                setState(() {
                  if (isEditing) {
                    final index = _items.indexOf(item);
                    _items[index] = newItem;
                  } else {
                    _items.add(newItem);
                  }
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(isEditing ? 'Item atualizado!' : 'Item criado!'),
                    backgroundColor: EducanoColors.successGreen,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              icon: const Icon(Icons.save_rounded),
              label: const Text('Salvar'),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(Map<String, dynamic> item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_radius),
        ),
        title: const Text('Remover Item'),
        content: Text('Tem certeza que deseja remover "${item['name']}" da loja?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() => _items.remove(item));
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: EducanoColors.error),
            child: const Text('Remover'),
          ),
        ],
      ),
    );
  }

  void _showItemDetails(Map<String, dynamic> item) {
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: Row(children: [
          Expanded(child: Text(item['name'] as String)),
          IconButton(onPressed: () { Navigator.pop(context); _showItemDialog(item: item); }, icon: const Icon(Icons.edit_rounded)),
          IconButton(onPressed: () { Navigator.pop(context); _confirmDelete(item); }, icon: const Icon(Icons.delete_outline_rounded, color: EducanoColors.error)),
        ]),
        content: SizedBox(width: 420, child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Tipo: ${item['category']}'),
          const SizedBox(height: 8),
          Text(item['description'] as String),
          const SizedBox(height: 8),
          Text('PreÃ§o: ${item['price']} moedas', style: const TextStyle(fontWeight: FontWeight.bold)),
        ])),
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
          _buildItemsList(context),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Itens da Loja',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: _spacingMinimum),
              Text(
                'Gerencie os itens disponÃ­veis na loja dos alunos.',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: EducanoColors.textSecondary,
                    ),
              ),
            ],
          ),
        ),
        AppSmallButton(
          onPressed: _showItemDialog,
          icon: Icons.add_rounded,
          label: 'Novo Item',
        ),
      ],
    );
  }

  Widget _buildLegacyStats() {
    final averagePrice = _items.isEmpty
        ? 0
        : _items.fold<int>(0, (sum, i) => sum + (i['price'] as int)) ~/
            _items.length;
    final stats = [
      {
        'label': 'Total de Itens',
        'value': _items.length.toString(),
        'icon': Icons.shopping_bag_rounded,
        'color': EducanoColors.primaryBlue,
      },
      {
        'label': 'Categorias',
        'value': _items.map((i) => i['category']).toSet().length.toString(),
        'icon': Icons.category_rounded,
        'color': EducanoColors.darkGreen,
      },
      {
        'label': 'PreÃ§o MÃ©dio',
        'value': '$averagePrice moedas',
        'icon': Icons.monetization_on_rounded,
        'color': EducanoColors.accentYellow,
      },
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth < 700 ? 1 : 3;
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            crossAxisSpacing: _spacingSmall,
            mainAxisSpacing: _spacingSmall,
            childAspectRatio: 2.6,
          ),
          itemCount: stats.length,
          itemBuilder: (context, index) {
            final stat = stats[index];
            return Container(
              padding: const EdgeInsets.symmetric(
                horizontal: _spacingSmall,
                vertical: _spacingSmall,
              ),
              decoration: BoxDecoration(
                color: EducanoColors.background,
                borderRadius: BorderRadius.circular(_radius),
                boxShadow: const [
                  BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 3)),
                ],
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: (stat['color'] as Color).withValues(alpha: 0.15),
                    child: Icon(stat['icon'] as IconData, color: stat['color'] as Color),
                  ),
                  const SizedBox(width: _spacingSmall),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          stat['label'] as String,
                          style: const TextStyle(
                            color: EducanoColors.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          stat['value'] as String,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: EducanoColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildItemsList(BuildContext context) {
    return DashboardListCard(title: 'Lista de Itens', count: _items.length, children: _items.map(_buildItemRow).toList());
  }

  Widget _buildStats() {
    final averagePrice = _items.isEmpty ? 0 : _items.fold<int>(0, (sum, item) => sum + (item['price'] as int)) ~/ _items.length;
    return DashboardSummaryGrid(items: [
      DashboardSummaryData(label: 'Total de Itens', value: '${_items.length}', icon: Icons.shopping_bag_rounded, color: EducanoColors.primaryBlue),
      DashboardSummaryData(label: 'Categorias', value: '${_items.map((i) => i['category']).toSet().length}', icon: Icons.category_rounded, color: EducanoColors.darkGreen),
      DashboardSummaryData(label: 'PreÃ§o MÃ©dio', value: '$averagePrice moedas', icon: Icons.monetization_on_rounded, color: EducanoColors.accentYellow),
    ]);
  }

  Widget _buildLegacyItemsList(BuildContext context) {
    return Container(
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
          Padding(
            padding: const EdgeInsets.all(_spacingMedium),
            child: Text(
              'Lista de Itens (${_items.length})',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          const Divider(height: 1),
          ..._items.map((item) => _buildItemRow(item)),
        ],
      ),
    );
  }

  Widget _buildItemRow(Map<String, dynamic> item) {
    final color = item['color'] as Color;

    return InkWell(
      onTap: () => _showItemDetails(item),
      borderRadius: BorderRadius.circular(12),
      child: Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: _spacingMedium,
            vertical: _spacingSmall,
          ),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: color.withValues(alpha: 0.15),
                child: Icon(item['icon'] as IconData, color: color),
              ),
              const SizedBox(width: _spacingSmall),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item['name'] as String,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: EducanoColors.textPrimary,
                      ),
                    ),
                    Text(
                      '${item['category']}  Â·  ${item['description']}',
                      style: const TextStyle(
                        color: EducanoColors.textSecondary,
                        fontSize: 12,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  const Icon(
                    Icons.monetization_on_rounded,
                    color: EducanoColors.accentYellow,
                    size: 16,
                  ),
                  const SizedBox(width: 2),
                  Text(
                    '${item['price']}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              IconButton(
                onPressed: () => _showItemDialog(item: item),
                icon: const Icon(Icons.edit_rounded, size: 20),
              ),
              IconButton(
                onPressed: () => _confirmDelete(item),
                icon: const Icon(Icons.delete_outline_rounded, size: 20),
                color: EducanoColors.error,
              ),
            ],
          ),
        ),
        const Divider(height: 1, indent: _spacingMedium),
      ],
      ),
    );
  }
}

