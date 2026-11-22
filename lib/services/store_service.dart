import 'package:flutter/material.dart';

import '../core/utils/api_mappers.dart';
import 'api_client.dart';
import 'users_service.dart';

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
        final icon = switch (api['icone'] as String?) {
          'RAIO' => Icons.bolt_rounded,
          'ESCUDO' => Icons.shield_rounded,
          'LAMPADA' => Icons.lightbulb_rounded,
          'CRONOMETRO' => Icons.timer_rounded,
          'REINICIAR' => Icons.refresh_rounded,
          'AVATAR' => Icons.face_rounded,
          _ => Icons.star_rounded,
        };
        return {
          'id': api['id'],
          'name': api['nome'],
          'description': api['descricao'] ?? '',
          'price': api['preco'],
          'icon': icon,
          'color': ApiMappers.color(api['cor'] as String?),
          'category': 'Boosts',
          'effect': 'BOOST_XP',
          'effectValue': api['boost'] ?? 2,
          'durationMinutes': api['tempoUso'] ?? 1440,
          'active': api['status'] == null || api['status'] == 'ATIVO',
          'owned': 0,
        };
      });

  static Map<String, dynamic> itemPayload(Map<String, dynamic> item) {
    final iconKey = switch (ApiMappers.iconKey(item['icon'] as IconData?)) {
      'bolt' => 'RAIO',
      'shield' => 'ESCUDO',
      'lightbulb' => 'LAMPADA',
      'timer' => 'CRONOMETRO',
      'refresh' => 'REINICIAR',
      'face' => 'AVATAR',
      _ => 'ESTRELA',
    };
    return {
    'nome': item['name'],
    'descricao': item['description'] ?? '',
    'preco': item['price'],
    'icone': iconKey,
    'cor': ApiMappers.hex(item['color'] as Color),
    'categoria': 'BOOST',
    'boost': ((item['effectValue'] as num?)?.toDouble() ?? 2).clamp(1.01, 100),
    'tempoUso': item['durationMinutes'] ?? 1440,
  };
  }

  Future<StoreSnapshot> shop() async {
    final data = ApiClient.responseMap(
      await _api.get('/items/loja'),
      endpoint: '/items/loja',
    );
    return StoreSnapshot(
      balance: 0,
      items: ApiClient.responseList(data['dados'], endpoint: '/items/loja.dados')
          .map(itemMap).toList(),
    );
  }

  Future<StoreSnapshot> items({bool includeInactive = false}) async {
    final first = ApiClient.responseMap(
      await _api.get('/items', query: {'pagina': 1}),
      endpoint: '/items',
    );
    final items = ApiClient.responseList(first['dados'], endpoint: '/items.dados');
    final pagination = ApiClient.responseMap(first['paginacao'], endpoint: '/items.paginacao', optional: true);
    final totalPages = ApiClient.responseInt(pagination['totalPaginas'], endpoint: '/items.paginacao.totalPaginas');
    for (var page = 2; page <= totalPages; page++) {
      final data = ApiClient.responseMap(
        await _api.get('/items', query: {'pagina': page}),
        endpoint: '/items',
      );
      items.addAll(ApiClient.responseList(data['dados'], endpoint: '/items.dados'));
    }
    return ApiClient.parseResponse(
      '/items',
      () => StoreSnapshot(
        balance: 0,
        items: items.map(itemMap).toList(),
        categories: ApiClient.responseStringList(
          const [],
          endpoint: '/items.categorias',
        ),
      ),
    );
  }

  /// Compra o item e devolve o novo saldo.
  Future<int> purchase(String itemId) async {
    await _api.post('/items/$itemId/comprar');
    final profile = await UsersService.instance.myProfile();
    return ApiClient.responseInt(
      profile['moedas'],
      endpoint: '/users/me/profile.perfil.moedas',
    );
  }

  Future<StoreSnapshot> inventory() async {
    final response = await _api.get('/items/inventario');
    final data = ApiClient.responseMap(
      response,
      endpoint: '/items/inventario',
      optional: true,
    );
    final profile = await UsersService.instance.myProfile();
    return _inventorySnapshot(
      data,
      balance: ApiClient.responseInt(
        profile['moedas'],
        endpoint: '/users/me/profile.perfil.moedas',
      ),
    );
  }

  Future<StoreSnapshot> activate(String inventoryId) async {
    await _api.patch('/items/inventario/$inventoryId/ativar');
    return inventory();
  }

  StoreSnapshot _inventorySnapshot(Map<String, dynamic> data, {required int balance}) =>
      ApiClient.parseResponse(
        '/items/inventario',
        () => StoreSnapshot(
          balance: balance,
          items: [
            for (final entry in ApiClient.responseList(
              data['dados'],
              endpoint: '/items/inventario.dados',
            ))
              {
                ...itemMap(
                  ApiClient.responseMap(
                    entry['item'],
                    endpoint: '/items/inventario.dados.item',
                  ),
                ),
                'id': (entry['item'] as Map)['id'],
                'inventoryId': entry['id'],
                'quantity': 1,
                'active': entry['status'] == 'ATIVO',
                'expiresAt': ApiMappers.date(entry['expiraEm']),
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
    final payload = itemPayload(item)
      ..['status'] = item['active'] == false ? 'INATIVO' : 'ATIVO';
    final response = await _api.patch('/items/$id', payload);
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
