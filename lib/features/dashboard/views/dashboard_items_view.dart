import 'package:flutter/material.dart';

import '../../../core/theme/theme.dart';

const double _spacingMinimum = 8;
const double _spacingSmall = 16;
const double _spacingMedium = 24;
const double _spacingLarge = 32;

const double _radius = 18;

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
    {'label': 'Lâmpada', 'icon': Icons.lightbulb_rounded},
    {'label': 'Cronômetro', 'icon': Icons.timer_rounded},
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
    'Proteção',
    'Estudos',
    'Personalização',
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
      'name': 'Escudo de Sequência',
      'description': 'Protege sua sequência por um dia.',
      'price': 150,
      'icon': Icons.shield_rounded,
      'color': EducanoColors.primaryBlue,
      'category': 'Proteção',
    },
    {
      'name': 'Dica Extra',
      'description': 'Revela uma dica em qualquer questão.',
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
      'description': 'Refaz uma questão errada.',
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
      'category': 'Personalização',
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
                      decoration: const InputDecoration(labelText: 'Descrição'),
                      maxLines: 2,
                    ),
                    const SizedBox(height: _spacingSmall),
                    TextFormField(
                      controller: priceController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Preço (moedas)',
                        prefixIcon: Icon(Icons.monetization_on_rounded),
                      ),
                      validator: (v) => (int.tryParse(v ?? '') == null)
                          ? 'Informe um preço válido'
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
                      decoration: const InputDecoration(labelText: 'Ícone'),
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
                'Gerencie os itens disponíveis na loja dos alunos.',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: EducanoColors.textSecondary,
                    ),
              ),
            ],
          ),
        ),
        ElevatedButton.icon(
          onPressed: () => _showItemDialog(),
          icon: const Icon(Icons.add_rounded),
          label: const Text('Novo Item'),
        ),
      ],
    );
  }

  Widget _buildStats() {
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
        'label': 'Preço Médio',
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

    return Column(
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
                      '${item['category']}  ·  ${item['description']}',
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
    );
  }
}
