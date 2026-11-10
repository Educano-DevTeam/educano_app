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
    final data = await _api.get('/users', query: {
      'page': page,
      'busca': search,
      'tipo': type,
      'status': status,
    }) as Map<String, dynamic>;

    final pagination = data['paginacao'] as Map<String, dynamic>;
    return UserPage(
      users: (data['dados'] as List).cast<Map<String, dynamic>>(),
      page: pagination['pagina'] as int,
      totalPages: pagination['totalPaginas'] as int,
      total: pagination['total'] as int,
    );
  }

  Future<Map<String, dynamic>> setStatus(String id, bool active) async {
    final data = await _api.patch('/users/$id/status', {
      'status': active ? 'ATIVO' : 'INATIVO',
    }) as Map<String, dynamic>;
    return data['usuario'] as Map<String, dynamic>;
  }

  Future<void> delete(String id) => _api.delete('/users/$id');

  Future<Map<String, dynamic>?> profileOf(String id) async {
    try {
      final data = await _api.get('/users/$id/profile') as Map<String, dynamic>;
      return (data['perfil'] ?? data['dados']) as Map<String, dynamic>?;
    } on ApiException catch (error) {
      if (error.statusCode == 404) return null;
      rethrow;
    }
  }

  Future<Map<String, dynamic>> myProfile() async {
    final data = await _api.get('/users/me/profile') as Map<String, dynamic>;
    return data['perfil'] as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> updateMyProfile(Map<String, dynamic> changes) async {
    final data = await _api.patch('/users/me/profile', changes) as Map<String, dynamic>;
    return data['perfil'] as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> uploadPhoto(Uint8List bytes, String fileName) async {
    final data = await _api.upload(
      '/users/me/profile/photo',
      field: 'foto',
      bytes: bytes,
      fileName: fileName,
    ) as Map<String, dynamic>;
    return data['perfil'] as Map<String, dynamic>;
  }

  /// Atualiza o nome e a sessão salva no aparelho.
  Future<AppUser> updateMyName(AppUser current, String name) async {
    await _api.patch('/users/me', {'nome': name.trim()});
    final updated = current.copyWith(name: name.trim());
    await StorageService.instance.saveCurrentUser(updated);
    return updated;
  }

  Future<String> changePassword(String current, String next) async {
    final data = await _api.patch('/users/me/password', {
      'senhaAtual': current,
      'novaSenha': next,
    }) as Map<String, dynamic>;
    return data['message'] as String? ?? 'Senha alterada.';
  }

  Future<void> deleteMyAccount() => _api.delete('/users/me');
}
