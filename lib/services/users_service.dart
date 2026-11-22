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
    final profile = ApiClient.responseMap(
      data['perfil'],
      endpoint: '/users/me/profile.perfil',
    );
    final photoFileId = _profilePhotoFileId(profile['urlFotoPerfil']);
    if (photoFileId == null) return profile;

    final fileResponse = await _api.get('/files/$photoFileId');
    final fileData = ApiClient.responseMap(
      fileResponse,
      endpoint: '/files/$photoFileId',
    );
    final file = ApiClient.responseMap(
      fileData['arquivo'],
      endpoint: '/files/$photoFileId.arquivo',
    );
    return {
      ...profile,
      'urlFotoPerfil': ApiClient.responseString(
        file['url'],
        endpoint: '/files/$photoFileId.arquivo.url',
        required: true,
      ),
    };
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
    final uploadResponse = await _api.upload(
      '/files',
      field: 'arquivo',
      bytes: bytes,
      fileName: fileName,
      fields: {'tipo': 'IMAGEM', 'finalidade': 'FOTO_PERFIL'},
    );
    final data = ApiClient.responseMap(uploadResponse, endpoint: '/files');
    final file = ApiClient.responseMap(
      data['arquivo'],
      endpoint: '/files.arquivo',
    );
    final fileId = ApiClient.responseString(
      file['id'],
      endpoint: '/files.arquivo.id',
      required: true,
    )!;
    final profileUrl = _profilePhotoUrl(fileId);
    final profile = await updateMyProfile({'urlFotoPerfil': profileUrl});
    return {
      ...profile,
      'urlFotoPerfil': ApiClient.responseString(
        file['url'],
        endpoint: '/files.arquivo.url',
        required: true,
      ),
    };
  }

  static String _profilePhotoUrl(String fileId) {
    final base = Uri.parse(apiBaseUrl);
    final basePath = base.path.replaceFirst(RegExp(r'/$'), '');
    return base.replace(path: '$basePath/files/$fileId').toString();
  }

  static String? _profilePhotoFileId(Object? value) {
    if (value is! String || value.isEmpty) return null;

    final photoUri = Uri.tryParse(value);
    final base = Uri.parse(apiBaseUrl);
    if (photoUri == null || photoUri.origin != base.origin) return null;

    final basePath = base.path.replaceFirst(RegExp(r'/$'), '');
    final prefix = '$basePath/files/';
    if (!photoUri.path.startsWith(prefix)) return null;

    final fileId = photoUri.path.substring(prefix.length);
    return fileId.isEmpty || fileId.contains('/') ? null : fileId;
  }

  /// Atualiza o nome e a sessão salva no aparelho.
  Future<AppUser> updateMyName(AppUser current, String name) async {
    await _api.patch('/users/me', {'nome': name.trim()});
    final updated = current.copyWith(name: name.trim());
    await StorageService.instance.saveCurrentUser(updated);
    return updated;
  }

  Future<void> deleteMyAccount() => _api.delete('/users/me');
}
