import 'package:flutter/material.dart';

import '../core/utils/api_mappers.dart';
import 'api_client.dart';

class StoreSnapshot {
  final int balance;
  final List<Map<String, dynamic>> items;
  final List<String> categories;

  const StoreSnapshot({
    required this.balance,
    required this.items,
    this.categories = const [],
  });
}

/// Loja, inventário e cadastro de itens.
class StoreService {
  StoreService._();

  static final StoreService instance = StoreService._();

  final _api = ApiClient.instance;

  static const effects = {
    'BOOST_XP': 'Boost de XP',
    'ESCUDO_SEQUENCIA': 'Escudo de sequência',
    'DICA_EXTRA': 'Dica extra (simulado)',
    'TEMPO_EXTRA': 'Tempo extra (simulado)',
    'REVIVER_TENTATIVA': 'Reviver tentativa',
    'COSMETICO': 'Personalização',
  };

  /// Item no formato das telas da loja e do dashboard.
  static Map<String, dynamic> itemMap(Map<String, dynamic> api) => {
    'id': api['id'],
    'name': api['nome'],
    'description': api['descricao'] ?? '',
    'price': api['preco'],
    'icon': ApiMappers.icon(api['icone'] as String?, fallback: Icons.star_rounded),
    'color': ApiMappers.color(api['cor'] as String?),
    'category': api['categoria'],
    'effect': api['efeito'],
    'effectValue': api['valorEfeito'] ?? 0,
    'durationMinutes': api['duracaoMinutos'],
    'active': api['ativo'] ?? true,
    'owned': api['quantidadeNoInventario'] ?? 0,
  };

  static Map<String, dynamic> itemPayload(Map<String, dynamic> item) => {
    'nome': item['name'],
    'descricao': item['description'] ?? '',
    'preco': item['price'],
    'icone': ApiMappers.iconKey(item['icon'], fallback: 'star'),
    'cor': ApiMappers.hex(item['color'] as Color),
    'categoria': item['category'],
    'efeito': item['effect'] ?? 'COSMETICO',
    'valorEfeito': item['effectValue'] ?? 0,
    'duracaoMinutos': item['durationMinutes'],
    'ativo': item['active'] ?? true,
  };

  Future<StoreSnapshot> items({bool includeInactive = false}) async {
    final data = await _api.get('/items', query: {
      if (includeInactive) 'todos': 'true',
    }) as Map<String, dynamic>;
    return StoreSnapshot(
      balance: data['saldo'] as int,
      items: (data['dados'] as List).cast<Map<String, dynamic>>().map(itemMap).toList(),
      categories: (data['categorias'] as List).cast<String>(),
    );
  }

  /// Compra o item e devolve o novo saldo.
  Future<int> purchase(String itemId) async {
    final data = await _api.post('/items/$itemId/purchase', {'quantidade': 1})
        as Map<String, dynamic>;
    return data['saldo'] as int;
  }

  Future<StoreSnapshot> inventory() async {
    final data = await _api.get('/inventory') as Map<String, dynamic>;
    return _inventorySnapshot(data);
  }

  Future<StoreSnapshot> activate(String itemId) async {
    final data = await _api.post('/inventory/$itemId/activate') as Map<String, dynamic>;
    return _inventorySnapshot(data);
  }

  StoreSnapshot _inventorySnapshot(Map<String, dynamic> data) => StoreSnapshot(
    balance: data['saldo'] as int,
    items: [
      for (final entry in (data['dados'] as List).cast<Map<String, dynamic>>())
        {
          ...itemMap(entry['item'] as Map<String, dynamic>),
          'quantity': entry['quantidade'],
          'active': entry['ativo'] == true,
          'expiresAt': ApiMappers.date((entry['ativacao'] as Map?)?['expiraEm']),
        },
    ],
  );

  Future<Map<String, dynamic>> create(Map<String, dynamic> item) async {
    final data = await _api.post('/items', itemPayload(item)) as Map<String, dynamic>;
    return itemMap(data['item'] as Map<String, dynamic>);
  }

  Future<Map<String, dynamic>> update(String id, Map<String, dynamic> item) async {
    final data = await _api.put('/items/$id', itemPayload(item)) as Map<String, dynamic>;
    return itemMap(data['item'] as Map<String, dynamic>);
  }

  Future<String> delete(String id) async {
    final data = await _api.delete('/items/$id') as Map<String, dynamic>;
    return data['message'] as String? ?? 'Item removido.';
  }
}
