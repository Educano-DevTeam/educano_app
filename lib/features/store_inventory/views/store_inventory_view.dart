import 'package:flutter/material.dart';

import '../../../core/constants/app_breakpoints.dart';
import 'dart:async';

import '../../../core/theme/theme.dart';
import '../../../services/api_client.dart';
import '../../../services/store_service.dart';

const double _spacingMinimum = 8;
const double _spacingSmall = 16;
const double _spacingMedium = 24;

const double _radius = 18;

// IBL24 – Compra e Armazenamento de Itens no Inventário
class StoreInventoryView extends StatefulWidget {
  const StoreInventoryView({super.key});

  @override
  State<StoreInventoryView> createState() => _StoreInventoryViewState();
}

class _StoreInventoryViewState extends State<StoreInventoryView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _playerCoins = 0;

  List<Map<String, dynamic>> _storeItems = [];
  List<Map<String, dynamic>> _inventoryItems = [];
  bool _loading = true;
  String? _error;
  Timer? _ticker;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _load();
    // Atualiza o tempo restante dos itens ativos e recarrega ao expirar.
    _ticker = Timer.periodic(const Duration(seconds: 30), (_) {
      if (!mounted) return;
      final expired = _inventoryItems.any((item) {
        final expiresAt = item['expiresAt'] as DateTime?;
        return item['active'] == true && expiresAt != null && expiresAt.isBefore(DateTime.now());
      });
      expired ? _load() : setState(() {});
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final results = await Future.wait([
        StoreService.instance.items(),
        StoreService.instance.inventory(),
      ]);
      if (!mounted) return;
      setState(() {
        _storeItems = results[0].items;
        _inventoryItems = results[1].items;
        _playerCoins = results[1].balance;
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

  void _snack(String message, {bool error = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: error ? EducanoColors.error : EducanoColors.successGreen,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _purchase(Map<String, dynamic> item) async {
    try {
      final balance = await StoreService.instance.purchase(item['id'] as String);
      if (!mounted) return;
      setState(() => _playerCoins = balance);
      _snack('${item['name']} adquirido!');
      await _load();
    } on ApiException catch (error) {
      _snack(error.message, error: true);
    }
  }

  Future<void> _activate(Map<String, dynamic> item) async {
    try {
      final snapshot = await StoreService.instance.activate(item['id'] as String);
      if (!mounted) return;
      setState(() {
        _inventoryItems = snapshot.items;
        _playerCoins = snapshot.balance;
      });
      _snack(item['effect'] == 'TEMPO_EXTRA'
          ? 'Tempo Extra pronto! Ele será aplicado no próximo simulado.'
          : '${item['name']} ativado!');
    } on ApiException catch (error) {
      _snack(error.message, error: true);
    }
  }

  /// Texto do estado do item no inventário (tempo restante, uso etc.).
  String? _statusLabel(Map<String, dynamic> item) {
    if (item['effect'] == 'DICA_EXTRA') return 'Use durante um simulado';
    if (item['active'] != true) return null;
    if (item['effect'] == 'TEMPO_EXTRA') return 'Aguardando o próximo simulado';
    final expiresAt = item['expiresAt'] as DateTime?;
    if (expiresAt == null) return 'Em uso';
    final left = expiresAt.difference(DateTime.now());
    if (left.isNegative) return 'Expirado';
    final hours = left.inHours;
    final minutes = left.inMinutes % 60;
    return hours > 0 ? 'Restam ${hours}h ${minutes}min' : 'Restam ${left.inMinutes + 1} min';
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
              _purchase(item);
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
    final status = _loadingOrError();
    if (status != null) return status;
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

  /// Indicador de carregamento ou erro, comum às duas abas.
  Widget? _loadingOrError() {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_error == null) return null;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(_error!, textAlign: TextAlign.center),
          TextButton(onPressed: _load, child: const Text('Tentar novamente')),
        ],
      ),
    );
  }

  Widget _buildInventoryTab() {
    final status = _loadingOrError();
    if (status != null) return status;
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
                if (_statusLabel(item) != null)
                  Text(
                    _statusLabel(item)!,
                    style: TextStyle(
                      color: isActive ? EducanoColors.successGreen : EducanoColors.textSecondary,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: _spacingMinimum),
          ElevatedButton(
            onPressed: isActive ||
                    item['effect'] == 'DICA_EXTRA' ||
                    (item['quantity'] as int) <= 0
                ? null
                : () => _activate(item),
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
