import 'package:flutter/material.dart';

import '../../../core/constants/app_breakpoints.dart';
import '../../../core/theme/theme.dart';

const double _spacingMinimum = 8;
const double _spacingSmall = 16;
const double _spacingMedium = 24;

const double _radius = 18;

// IBL24 – Compra e Armazenamento de Itens no Inventário
class StudentStoreView extends StatefulWidget {
  const StudentStoreView({super.key});

  @override
  State<StudentStoreView> createState() => _StudentStoreViewState();
}

class _StudentStoreViewState extends State<StudentStoreView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _playerCoins = 850;

  final List<Map<String, dynamic>> _storeItems = [
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
      'color': EducanoColors.softGreen,
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

  final List<Map<String, dynamic>> _inventoryItems = [
    {
      'name': 'Dica Extra',
      'description': 'Revela uma dica em qualquer questão.',
      'quantity': 3,
      'icon': Icons.lightbulb_rounded,
      'color': EducanoColors.successGreen,
      'active': false,
    },
    {
      'name': 'Escudo de Sequência',
      'description': 'Protege sua sequência por um dia.',
      'quantity': 1,
      'icon': Icons.shield_rounded,
      'color': EducanoColors.primaryBlue,
      'active': true,
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _buyItem(Map<String, dynamic> item) {
    final price = item['price'] as int;
    if (_playerCoins < price) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Moedas insuficientes!'),
          backgroundColor: EducanoColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_radius),
        ),
        title: const Text('Confirmar Compra'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: (item['color'] as Color).withValues(alpha: 0.15),
              child: Icon(
                item['icon'] as IconData,
                color: item['color'] as Color,
                size: 28,
              ),
            ),
            const SizedBox(height: _spacingSmall),
            Text(
              item['name'] as String,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: _spacingMinimum),
            Text(
              item['description'] as String,
              textAlign: TextAlign.center,
              style: const TextStyle(color: EducanoColors.textSecondary),
            ),
            const SizedBox(height: _spacingMedium),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.monetization_on_rounded,
                  color: EducanoColors.accentYellow,
                ),
                const SizedBox(width: 4),
                Text(
                  '${item['price']} moedas',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ],
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
              setState(() {
                _playerCoins -= price;
                final existingIndex = _inventoryItems.indexWhere(
                  (i) => i['name'] == item['name'],
                );
                if (existingIndex >= 0) {
                  _inventoryItems[existingIndex]['quantity'] =
                      (_inventoryItems[existingIndex]['quantity'] as int) + 1;
                } else {
                  _inventoryItems.add({
                    'name': item['name'],
                    'description': item['description'],
                    'quantity': 1,
                    'icon': item['icon'],
                    'color': item['color'],
                    'active': false,
                  });
                }
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${item['name']} adquirido!'),
                  backgroundColor: EducanoColors.successGreen,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: const Text('Comprar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isCompact =
        MediaQuery.sizeOf(context).width < AppBreakpoints.compact;

    return Column(
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(
            isCompact ? _spacingSmall : _spacingMedium,
            isCompact ? _spacingSmall : _spacingMedium,
            isCompact ? _spacingSmall : _spacingMedium,
            0,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),
              const SizedBox(height: _spacingMedium),
              _buildCoinBalance(),
              const SizedBox(height: _spacingMedium),
              TabBar(
                controller: _tabController,
                labelColor: EducanoColors.primaryBlue,
                unselectedLabelColor: EducanoColors.textSecondary,
                indicatorColor: EducanoColors.primaryBlue,
                tabs: const [
                  Tab(icon: Icon(Icons.store_rounded), text: 'Loja'),
                  Tab(
                    icon: Icon(Icons.inventory_2_rounded),
                    text: 'Inventário',
                  ),
                ],
              ),
            ],
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildStoreTab(),
              _buildInventoryTab(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Loja & Inventário',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: _spacingMinimum),
        Text(
          'Use suas moedas para comprar itens e potencializar seus estudos.',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: EducanoColors.textSecondary,
              ),
        ),
      ],
    );
  }

  Widget _buildCoinBalance() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < AppBreakpoints.compact;

        return Container(
          padding: EdgeInsets.symmetric(
            horizontal: isCompact ? _spacingSmall : _spacingMedium,
            vertical: _spacingSmall,
          ),
          decoration: BoxDecoration(
            gradient: EducanoColors.primaryGradient,
            borderRadius: BorderRadius.circular(_radius),
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 8,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Icon(
                Icons.account_balance_wallet_rounded,
                color: EducanoColors.textWhite,
                size: isCompact ? 26 : 32,
              ),
              const SizedBox(width: _spacingSmall),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Saldo de Moedas',
                      style: TextStyle(
                        color: EducanoColors.textWhite,
                        fontSize: 13,
                      ),
                    ),
                    Row(
                      children: [
                        const Icon(
                          Icons.monetization_on_rounded,
                          color: EducanoColors.accentYellow,
                          size: 20,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '$_playerCoins',
                          style: TextStyle(
                            color: EducanoColors.textWhite,
                            fontSize: isCompact ? 20 : 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // No mobile o texto de apoio sai para o saldo não quebrar.
              if (!isCompact)
                const Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Como ganhar mais?',
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          color: EducanoColors.textWhite,
                          fontSize: 11,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Complete cursos e atividades',
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          color: EducanoColors.textWhite,
                          fontSize: 11,
                          fontStyle: FontStyle.italic,
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
  }

  Widget _buildStoreTab() {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Mobile: itens em lista compacta (frame mobile do Figma).
        if (constraints.maxWidth < AppBreakpoints.compact) {
          return ListView.separated(
            padding: const EdgeInsets.all(_spacingSmall),
            itemCount: _storeItems.length,
            separatorBuilder: (context, index) =>
                const SizedBox(height: _spacingMinimum),
            itemBuilder: (context, index) =>
                _buildStoreItemRow(_storeItems[index]),
          );
        }

        final columns =
            constraints.maxWidth < AppBreakpoints.medium ? 2 : 3;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(_spacingMedium),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: columns,
              crossAxisSpacing: _spacingSmall,
              mainAxisSpacing: _spacingSmall,
              mainAxisExtent: 172,
            ),
            itemCount: _storeItems.length,
            itemBuilder: (context, index) =>
                _buildStoreItemCard(_storeItems[index]),
          ),
        );
      },
    );
  }

  /// Versão em linha do item da loja, usada no mobile.
  Widget _buildStoreItemRow(Map<String, dynamic> item) {
    final canAfford = _playerCoins >= (item['price'] as int);
    final color = item['color'] as Color;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: EducanoColors.background,
        borderRadius: BorderRadius.circular(_radius),
        border: Border.all(color: EducanoColors.border),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 3)),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: color.withValues(alpha: 0.15),
            child: Icon(item['icon'] as IconData, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  item['name'] as String,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: EducanoColors.textPrimary,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Icon(
                      Icons.monetization_on_rounded,
                      color: canAfford
                          ? EducanoColors.accentYellow
                          : EducanoColors.textSecondary,
                      size: 14,
                    ),
                    const SizedBox(width: 2),
                    Text(
                      '${item['price']}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: canAfford
                            ? EducanoColors.textPrimary
                            : EducanoColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: _spacingMinimum),
          ElevatedButton(
            onPressed: canAfford ? () => _buyItem(item) : null,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              canAfford ? 'Comprar' : 'Sem saldo',
              style: const TextStyle(fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStoreItemCard(Map<String, dynamic> item) {
    final canAfford = _playerCoins >= (item['price'] as int);
    final color = item['color'] as Color;

    return Container(
      padding: const EdgeInsets.all(_spacingSmall),
      decoration: BoxDecoration(
        color: EducanoColors.background,
        borderRadius: BorderRadius.circular(_radius),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 3)),
        ],
        border: Border.all(color: EducanoColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: color.withValues(alpha: 0.15),
                child: Icon(item['icon'] as IconData, color: color, size: 20),
              ),
              const SizedBox(width: _spacingMinimum),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item['name'] as String,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: EducanoColors.textPrimary,
                        fontSize: 13,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 1,
                      ),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        item['category'] as String,
                        style: TextStyle(
                          color: color,
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: _spacingMinimum),
          Text(
            item['description'] as String,
            style: const TextStyle(
              color: EducanoColors.textSecondary,
              fontSize: 12,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.monetization_on_rounded,
                    color: canAfford
                        ? EducanoColors.accentYellow
                        : EducanoColors.textSecondary,
                    size: 16,
                  ),
                  const SizedBox(width: 2),
                  Text(
                    '${item['price']}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: canAfford
                          ? EducanoColors.textPrimary
                          : EducanoColors.textSecondary,
                    ),
                  ),
                ],
              ),
              ElevatedButton(
                onPressed: canAfford ? () => _buyItem(item) : null,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: _spacingSmall,
                    vertical: 6,
                  ),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  canAfford ? 'Comprar' : 'Sem saldo',
                  style: const TextStyle(fontSize: 12),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInventoryTab() {
    if (_inventoryItems.isEmpty) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.inventory_2_outlined,
              size: 64,
              color: EducanoColors.textSecondary,
            ),
            SizedBox(height: _spacingSmall),
            Text(
              'Seu inventário está vazio.',
              style: TextStyle(color: EducanoColors.textSecondary),
            ),
            SizedBox(height: _spacingMinimum),
            Text(
              'Compre itens na loja para aparecerem aqui.',
              style: TextStyle(
                color: EducanoColors.textSecondary,
                fontSize: 13,
              ),
            ),
          ],
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < AppBreakpoints.compact;
        return SingleChildScrollView(
          padding: EdgeInsets.all(isCompact ? _spacingSmall : _spacingMedium),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: _inventoryItems
                .map((item) => _buildInventoryItemCard(item))
                .toList(),
          ),
        );
      },
    );
  }

  Widget _buildInventoryItemCard(Map<String, dynamic> item) {
    final color = item['color'] as Color;
    final isActive = item['active'] as bool;

    return Container(
      margin: const EdgeInsets.only(bottom: _spacingSmall),
      padding: const EdgeInsets.all(_spacingSmall),
      decoration: BoxDecoration(
        color: EducanoColors.background,
        borderRadius: BorderRadius.circular(_radius),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 3)),
        ],
        border: isActive
            ? Border.all(color: EducanoColors.successGreen, width: 1.5)
            : Border.all(color: EducanoColors.border),
      ),
      child: Row(
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: color.withValues(alpha: 0.15),
                child: Icon(item['icon'] as IconData, color: color, size: 24),
              ),
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  width: 18,
                  height: 18,
                  decoration: BoxDecoration(
                    color: EducanoColors.primaryBlue,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: EducanoColors.background,
                      width: 1.5,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      '${item['quantity']}',
                      style: const TextStyle(
                        color: EducanoColors.textWhite,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: _spacingSmall),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        item['name'] as String,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: EducanoColors.textPrimary,
                        ),
                      ),
                    ),
                    if (isActive) ...[
                      const SizedBox(width: _spacingMinimum),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: EducanoColors.successGreen.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'Ativo',
                          style: TextStyle(
                            color: EducanoColors.successGreen,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                Text(
                  item['description'] as String,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: EducanoColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: _spacingMinimum),
          ElevatedButton(
            onPressed: isActive
                ? null
                : () {
                    setState(() {
                      item['active'] = true;
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('${item['name']} ativado!'),
                        backgroundColor: EducanoColors.successGreen,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(
                horizontal: _spacingSmall,
                vertical: _spacingMinimum,
              ),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(isActive ? 'Usando' : 'Usar'),
          ),
        ],
      ),
    );
  }
}
