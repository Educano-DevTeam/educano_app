import '../core/models/app_user.dart';
import '../core/navigation/app_routes.dart';
import '../core/navigation/navigation_service.dart';
import 'api_client.dart';
import 'storage_service.dart';

/// Resultado padrão de uma operação de autenticação.
class AuthResult {
  final bool success;
  final String? message;
  final AppUser? user;

  /// Código de erro da API (ex.: SENHA_EXPIRADA), quando houver.
  final String? code;

  const AuthResult({required this.success, this.message, this.user, this.code});

  factory AuthResult.ok([String? message, AppUser? user]) =>
      AuthResult(success: true, message: message, user: user);

  factory AuthResult.fail(String message, {String? code}) =>
      AuthResult(success: false, message: message, code: code);
}

/// Camada de serviço responsável pela autenticação na API do Educano.
///
/// A sessão é validada pela API; quando o token JWT expira, o usuário volta
/// ao login na próxima requisição autenticada.
class AuthService {
  AuthService._internal() {
    ApiClient.instance.onSessionExpired = _handleSessionExpired;
  }

  static final AuthService instance = AuthService._internal();

  bool _expiring = false;

  // Credenciais do cadastro em andamento, mantidas só em memória para
  // entrar automaticamente depois que o e-mail for validado.
  String? _pendingEmail;
  String? _pendingPassword;

  Future<AuthResult> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await ApiClient.instance.postPublic('/auth/login', {
        'email': email.trim(),
        'senha': password,
      });
      final data = ApiClient.responseMap(response, endpoint: '/auth/login');
      final user = ApiClient.parseResponse(
        '/auth/login',
        () => AppUser.fromApi(
          ApiClient.responseMap(data['usuario'], endpoint: '/auth/login'),
        ),
      );
      final token = ApiClient.responseString(
        data['token'],
        endpoint: '/auth/login',
      );
      if (token == null || token.isEmpty) {
        throw const ApiException(502, 'A API não retornou o token da sessão.');
      }
      await StorageService.instance.saveToken(token);
      await StorageService.instance.saveCurrentUser(user);
      _expiring = false;

      return AuthResult.ok(
        ApiClient.responseString(data['message'], endpoint: '/auth/login'),
        user,
      );
    } on ApiException catch (error) {
      return AuthResult.fail(error.message, code: error.code);
    }
  }

  Future<AuthResult> register({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final response = await ApiClient.instance.postPublic('/auth/register', {
        'nome': name.trim(),
        'email': email.trim(),
        'senha': password,
        'tipo': 'ALUNO',
      });
      final data = ApiClient.responseMap(response, endpoint: '/auth/register');

      _pendingEmail = email.trim().toLowerCase();
      _pendingPassword = password;

      return AuthResult.ok(
        ApiClient.responseString(data['message'], endpoint: '/auth/register'),
      );
    } on ApiException catch (error) {
      return AuthResult.fail(error.message, code: error.code);
    }
  }

  /// Cadastro feito pelo administrador no dashboard (qualquer tipo de conta).
  Future<AuthResult> registerByAdmin({
    required String name,
    required String email,
    required String password,
    required String type,
  }) async {
    try {
      final response = await ApiClient.instance.post('/auth/register', {
        'nome': name.trim(),
        'email': email.trim(),
        'senha': password,
        'tipo': type,
      });
      final data = ApiClient.responseMap(response, endpoint: '/auth/register');

      return AuthResult.ok(
        ApiClient.responseString(data['message'], endpoint: '/auth/register'),
        ApiClient.parseResponse(
          '/auth/register',
          () => AppUser.fromApi(
            ApiClient.responseMap(data['usuario'], endpoint: '/auth/register'),
          ),
        ),
      );
    } on ApiException catch (error) {
      return AuthResult.fail(error.message, code: error.code);
    }
  }

  Future<AuthResult> verifyCode({
    required String email,
    required String code,
  }) async {
    try {
      final response = await ApiClient.instance.postPublic(
        '/auth/verify-code',
        {'email': email.trim(), 'codigo': code.trim().toUpperCase()},
      );
      final data = ApiClient.responseMap(
        response,
        endpoint: '/auth/verify-code',
      );

      final message = ApiClient.responseString(
        data['message'],
        endpoint: '/auth/verify-code',
      );

      // Com a senha do cadastro em memória, já entra na conta.
      if (_pendingEmail == email.trim().toLowerCase() &&
          _pendingPassword != null) {
        final login = await this.login(
          email: email,
          password: _pendingPassword!,
        );
        _pendingEmail = null;
        _pendingPassword = null;
        if (login.success) return AuthResult.ok(message, login.user);
      }

      // Sem a senha (ex.: a página foi recarregada), o usuário faz login.
      return AuthResult.ok(message);
    } on ApiException catch (error) {
      return AuthResult.fail(error.message, code: error.code);
    }
  }

  Future<AuthResult> resendCode({required String email}) async {
    try {
      final response = await ApiClient.instance.postPublic(
        '/auth/resend-code',
        {'email': email.trim()},
      );
      final data = ApiClient.responseMap(
        response,
        endpoint: '/auth/resend-code',
      );
      return AuthResult.ok(
        ApiClient.responseString(
          data['message'],
          endpoint: '/auth/resend-code',
        ),
      );
    } on ApiException catch (error) {
      return AuthResult.fail(error.message, code: error.code);
    }
  }

  /// Envia um código de redefinição de senha para o e-mail.
  Future<AuthResult> sendPasswordResetCode({required String email}) async {
    try {
      final response = await ApiClient.instance.postPublic(
        '/auth/forgot-password',
        {'email': email.trim()},
      );
      final data = ApiClient.responseMap(
        response,
        endpoint: '/auth/forgot-password',
      );
      return AuthResult.ok(
        ApiClient.responseString(
          data['message'],
          endpoint: '/auth/forgot-password',
        ),
      );
    } on ApiException catch (error) {
      return AuthResult.fail(error.message, code: error.code);
    }
  }

  Future<AuthResult> resetPassword({
    required String email,
    required String code,
    required String newPassword,
  }) async {
    try {
      final response = await ApiClient.instance
          .postPublic('/auth/reset-password', {
            'email': email.trim(),
            'codigo': code.trim().toUpperCase(),
            'novaSenha': newPassword,
          });
      final data = ApiClient.responseMap(
        response,
        endpoint: '/auth/reset-password',
      );
      return AuthResult.ok(
        ApiClient.responseString(
          data['message'],
          endpoint: '/auth/reset-password',
        ),
      );
    } on ApiException catch (error) {
      return AuthResult.fail(error.message, code: error.code);
    }
  }

  /// Confere no servidor se a sessão salva ainda é válida.
  Future<AppUser?> restoreSession() async {
    final token = await StorageService.instance.loadToken();
    if (token == null) {
      await StorageService.instance.clearCurrentUser();
      return null;
    }

    try {
      final response = await ApiClient.instance.get('/auth/me');
      final me = ApiClient.responseMap(response, endpoint: '/auth/me');
      final user = ApiClient.parseResponse(
        '/auth/me',
        () => AppUser.fromApi(
          ApiClient.responseMap(me['usuario'], endpoint: '/auth/me'),
        ),
      );
      await StorageService.instance.saveCurrentUser(user);
      _expiring = false;
      return user;
    } on ApiException catch (error) {
      if (error.isNetworkError) rethrow;
      await StorageService.instance.clearCurrentUser();
      return null;
    }
  }

  Future<void> logout() async {
    await StorageService.instance.clearCurrentUser();
  }

  Future<void> _handleSessionExpired() async {
    if (_expiring) return;
    _expiring = true;
    await logout();
    NavigationService.pushNamedAndRemoveUntil(
      AppRoutes.login,
      (route) => false,
    );
  }
}
