import 'dart:typed_data';

import '../core/models/app_user.dart';
import 'api_client.dart';
import 'storage_service.dart';

class UserPage {
  final List<Map<String, dynamic>> users;
  final int page;
  final int totalPages;
  final int total;

  const UserPage({
    required this.users,
    required this.page,
    required this.totalPages,
    required this.total,
  });
}

/// Conta do usuário logado e gestão de usuários (administrador).
class UsersService {
  UsersService._();

  static final UsersService instance = UsersService._();

  final _api = ApiClient.instance;

  static const typeLabels = {
    'ALUNO': 'Aluno',
    'PROFESSOR': 'Professor',
    'PARCEIRO': 'Parceiro',
    'ADMIN': 'Administrador',
  };

  static const statusLabels = {
    'ATIVO': 'Ativo',
    'INATIVO': 'Inativo',
    'PENDENTE': 'Pendente',
  };

  static String? typeValue(String label) => typeLabels.entries
      .where((e) => e.value == label)
      .map((e) => e.key)
      .firstOrNull;

  Future<UserPage> list({
    int page = 1,
    String? search,
    String? type,
    String? status,
  }) async {
    final response = await _api.get(
      '/users',
      query: {'page': page, 'busca': search, 'tipo': type, 'status': status},
    );
    final data = ApiClient.responseMap(
      response,
      endpoint: '/users',
      optional: true,
    );

    final pagination = ApiClient.responseMap(
      data['paginacao'],
      endpoint: '/users.paginacao',
      optional: true,
    );
    return UserPage(
      users: ApiClient.responseList(data['dados'], endpoint: '/users.dados'),
      page: ApiClient.responseInt(
        pagination['pagina'],
        endpoint: '/users.paginacao.pagina',
        fallback: page,
      ),
      totalPages: ApiClient.responseInt(
        pagination['totalPaginas'],
        endpoint: '/users.paginacao.totalPaginas',
      ),
      total: ApiClient.responseInt(
        pagination['total'],
        endpoint: '/users.paginacao.total',
      ),
    );
  }

  Future<Map<String, dynamic>> setStatus(String id, bool active) async {
    final response = await _api.patch('/users/$id/status', {
      'status': active ? 'ATIVO' : 'INATIVO',
    });
    final data = ApiClient.responseMap(response, endpoint: '/users/$id/status');
    return ApiClient.responseMap(
      data['usuario'],
      endpoint: '/users/$id/status.usuario',
    );
  }

  Future<void> delete(String id) => _api.delete('/users/$id');

  Future<Map<String, dynamic>?> profileOf(String id) async {
    try {
      final response = await _api.get('/users/$id/profile');
      final data = ApiClient.responseMap(
        response,
        endpoint: '/users/$id/profile',
        optional: true,
      );
      final profile = data['perfil'] ?? data['dados'];
      return profile == null
          ? null
          : ApiClient.responseMap(
              profile,
              endpoint: '/users/$id/profile.perfil',
            );
    } on ApiException catch (error) {
      if (error.statusCode == 404) return null;
      rethrow;
    }
  }

  Future<Map<String, dynamic>> myProfile() async {
    final response = await _api.get('/users/me/profile');
    final data = ApiClient.responseMap(response, endpoint: '/users/me/profile');
    return ApiClient.responseMap(
      data['perfil'],
      endpoint: '/users/me/profile.perfil',
    );
  }

  Future<Map<String, dynamic>> updateMyProfile(
    Map<String, dynamic> changes,
  ) async {
    final response = await _api.patch('/users/me/profile', changes);
    final data = ApiClient.responseMap(response, endpoint: '/users/me/profile');
    return ApiClient.responseMap(
      data['perfil'],
      endpoint: '/users/me/profile.perfil',
    );
  }

  Future<Map<String, dynamic>> uploadPhoto(
    Uint8List bytes,
    String fileName,
  ) async {
    final response = await _api.upload(
      '/users/me/profile/photo',
      field: 'foto',
      bytes: bytes,
      fileName: fileName,
    );
    final data = ApiClient.responseMap(
      response,
      endpoint: '/users/me/profile/photo',
    );
    return ApiClient.responseMap(
      data['perfil'],
      endpoint: '/users/me/profile/photo.perfil',
    );
  }

  /// Atualiza o nome e a sessão salva no aparelho.
  Future<AppUser> updateMyName(AppUser current, String name) async {
    await _api.patch('/users/me', {'nome': name.trim()});
    final updated = current.copyWith(name: name.trim());
    await StorageService.instance.saveCurrentUser(updated);
    return updated;
  }

  Future<String> changePassword(String current, String next) async {
    final response = await _api.patch('/users/me/password', {
      'senhaAtual': current,
      'novaSenha': next,
    });
    final data = ApiClient.responseMap(
      response,
      endpoint: '/users/me/password',
    );
    return ApiClient.responseString(
          data['message'],
          endpoint: '/users/me/password.message',
        ) ??
        'Senha alterada.';
  }

  Future<void> deleteMyAccount() => _api.delete('/users/me');
}
