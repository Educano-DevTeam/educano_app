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
  static Map<String, dynamic> itemMap(Map<String, dynamic> api) =>
      ApiClient.parseResponse('/items.item', () {
        return {
          'id': api['id'],
          'name': api['nome'],
          'description': api['descricao'] ?? '',
          'price': api['preco'],
          'icon': ApiMappers.icon(
            api['icone'] as String?,
            fallback: Icons.star_rounded,
          ),
          'color': ApiMappers.color(api['cor'] as String?),
          'category': api['categoria'],
          'effect': api['efeito'],
          'effectValue': api['valorEfeito'] ?? 0,
          'durationMinutes': api['duracaoMinutos'],
          'active': api['ativo'] ?? true,
          'owned': api['quantidadeNoInventario'] ?? 0,
        };
      });

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
    final response = await _api.get(
      '/items',
      query: {if (includeInactive) 'todos': 'true'},
    );
    final data = ApiClient.responseMap(
      response,
      endpoint: '/items',
      optional: true,
    );
    return ApiClient.parseResponse(
      '/items',
      () => StoreSnapshot(
        balance: ApiClient.responseInt(data['saldo'], endpoint: '/items.saldo'),
        items: ApiClient.responseList(
          data['dados'],
          endpoint: '/items.dados',
        ).map(itemMap).toList(),
        categories: ApiClient.responseStringList(
          data['categorias'],
          endpoint: '/items.categorias',
        ),
      ),
    );
  }

  /// Compra o item e devolve o novo saldo.
  Future<int> purchase(String itemId) async {
    final response = await _api.post('/items/$itemId/purchase', {
      'quantidade': 1,
    });
    final data = ApiClient.responseMap(
      response,
      endpoint: '/items/$itemId/purchase',
    );
    return ApiClient.responseInt(
      data['saldo'],
      endpoint: '/items/$itemId/purchase.saldo',
      required: true,
    );
  }

  Future<StoreSnapshot> inventory() async {
    final response = await _api.get('/inventory');
    final data = ApiClient.responseMap(
      response,
      endpoint: '/inventory',
      optional: true,
    );
    return _inventorySnapshot(data);
  }

  Future<StoreSnapshot> activate(String itemId) async {
    final response = await _api.post('/inventory/$itemId/activate');
    final data = ApiClient.responseMap(
      response,
      endpoint: '/inventory/$itemId/activate',
    );
    return _inventorySnapshot(data);
  }

  StoreSnapshot _inventorySnapshot(Map<String, dynamic> data) =>
      ApiClient.parseResponse(
        '/inventory',
        () => StoreSnapshot(
          balance: ApiClient.responseInt(
            data['saldo'],
            endpoint: '/inventory.saldo',
          ),
          items: [
            for (final entry in ApiClient.responseList(
              data['dados'],
              endpoint: '/inventory.dados',
            ))
              {
                ...itemMap(
                  ApiClient.responseMap(
                    entry['item'],
                    endpoint: '/inventory.dados.item',
                  ),
                ),
                'quantity': ApiClient.responseInt(
                  entry['quantidade'],
                  endpoint: '/inventory.dados.quantidade',
                ),
                'active': entry['ativo'] == true,
                'expiresAt': ApiMappers.date(
                  (entry['ativacao'] as Map?)?['expiraEm'],
                ),
              },
          ],
        ),
      );

  Future<Map<String, dynamic>> create(Map<String, dynamic> item) async {
    final response = await _api.post('/items', itemPayload(item));
    final data = ApiClient.responseMap(response, endpoint: '/items');
    return itemMap(
      ApiClient.responseMap(data['item'], endpoint: '/items.item'),
    );
  }

  Future<Map<String, dynamic>> update(
    String id,
    Map<String, dynamic> item,
  ) async {
    final response = await _api.put('/items/$id', itemPayload(item));
    final data = ApiClient.responseMap(response, endpoint: '/items/$id');
    return itemMap(
      ApiClient.responseMap(data['item'], endpoint: '/items/$id.item'),
    );
  }

  Future<String> delete(String id) async {
    final response = await _api.delete('/items/$id');
    final data = ApiClient.responseMap(
      response,
      endpoint: '/items/$id',
      optional: true,
    );
    return ApiClient.responseString(
          data['message'],
          endpoint: '/items/$id.message',
        ) ??
        'Item removido.';
  }
}
