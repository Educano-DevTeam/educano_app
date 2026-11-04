import 'dart:async';

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

  const AuthResult({
    required this.success,
    this.message,
    this.user,
    this.code,
  });

  factory AuthResult.ok([String? message, AppUser? user]) =>
      AuthResult(success: true, message: message, user: user);

  factory AuthResult.fail(String message, {String? code}) =>
      AuthResult(success: false, message: message, code: code);
}

/// Camada de serviço responsável pela autenticação na API do Educano.
///
/// O token JWT expira em 15 minutos; enquanto o app estiver aberto ele é
/// renovado a cada 10 minutos. Se a sessão expirar, o usuário volta ao login.
class AuthService {
  AuthService._internal() {
    ApiClient.instance.onSessionExpired = _handleSessionExpired;
  }

  static final AuthService instance = AuthService._internal();

  static const _refreshInterval = Duration(minutes: 10);

  Timer? _refreshTimer;
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
      final data = await ApiClient.instance.post('/auth/login', {
        'email': email.trim(),
        'senha': password,
      });

      final user = AppUser.fromApi(data['usuario'] as Map<String, dynamic>);
      await StorageService.instance.saveToken(data['token'] as String);
      await StorageService.instance.saveCurrentUser(user);
      _startRefresh();

      return AuthResult.ok(data['message'] as String?, user);
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
      final data = await ApiClient.instance.post('/auth/register', {
        'nome': name.trim(),
        'email': email.trim(),
        'senha': password,
      });

      _pendingEmail = email.trim().toLowerCase();
      _pendingPassword = password;

      return AuthResult.ok(data['message'] as String?);
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
      final data = await ApiClient.instance.post('/auth/register', {
        'nome': name.trim(),
        'email': email.trim(),
        'senha': password,
        'tipo': type,
      });

      return AuthResult.ok(
        data['message'] as String?,
        AppUser.fromApi(data['usuario'] as Map<String, dynamic>),
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
      final data = await ApiClient.instance.post('/auth/verify-code', {
        'email': email.trim(),
        'codigo': code.trim().toUpperCase(),
      });

      final message = data['message'] as String?;

      // Com a senha do cadastro em memória, já entra na conta.
      if (_pendingEmail == email.trim().toLowerCase() &&
          _pendingPassword != null) {
        final login = await this.login(email: email, password: _pendingPassword!);
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
      final data = await ApiClient.instance.post('/auth/resend-code', {
        'email': email.trim(),
      });
      return AuthResult.ok(data['message'] as String?);
    } on ApiException catch (error) {
      return AuthResult.fail(error.message, code: error.code);
    }
  }

  /// Envia um código de redefinição de senha para o e-mail.
  Future<AuthResult> sendPasswordResetCode({required String email}) async {
    try {
      final data = await ApiClient.instance.post('/auth/forgot-password', {
        'email': email.trim(),
      });
      return AuthResult.ok(data['message'] as String?);
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
      final data = await ApiClient.instance.post('/auth/reset-password', {
        'email': email.trim(),
        'codigo': code.trim().toUpperCase(),
        'novaSenha': newPassword,
      });
      return AuthResult.ok(data['message'] as String?);
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
      final data = await ApiClient.instance.post('/auth/refresh');
      await StorageService.instance.saveToken(data['token'] as String);

      final me = await ApiClient.instance.get('/auth/me');
      final user = AppUser.fromApi(me['usuario'] as Map<String, dynamic>);
      await StorageService.instance.saveCurrentUser(user);
      _startRefresh();
      return user;
    } on ApiException catch (error) {
      if (error.isNetworkError) rethrow;
      await StorageService.instance.clearCurrentUser();
      return null;
    }
  }

  Future<void> logout() async {
    _refreshTimer?.cancel();
    _refreshTimer = null;
    await StorageService.instance.clearCurrentUser();
  }

  void _startRefresh() {
    _expiring = false;
    _refreshTimer?.cancel();
    _refreshTimer = Timer.periodic(_refreshInterval, (_) async {
      try {
        final data = await ApiClient.instance.post('/auth/refresh');
        await StorageService.instance.saveToken(data['token'] as String);
      } on ApiException catch (error) {
        // Falhas de rede são ignoradas; a próxima tentativa renova o token.
        if (!error.isNetworkError) _refreshTimer?.cancel();
      }
    });
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
