import '../core/models/app_user.dart';

/// Resultado padrão de uma operação de autenticação.
class AuthResult {
  final bool success;
  final String? message;
  final AppUser? user;

  const AuthResult({required this.success, this.message, this.user});

  factory AuthResult.ok([String? message, AppUser? user]) =>
      AuthResult(success: true, message: message, user: user);

  factory AuthResult.fail(String message) =>
      AuthResult(success: false, message: message);
}

/// Camada de serviço responsável por toda a lógica de autenticação.
///
/// Está mockada (usa `Future.delayed` para simular latência de rede) para
/// que as telas fiquem 100% funcionais sem backend. Basta trocar a
/// implementação de cada método por chamadas HTTP reais (ex.: usando
/// `http` ou `dio`) mantendo a mesma assinatura.
class AuthService {
  AuthService._internal();
  static final AuthService instance = AuthService._internal();

  final Map<String, _RegisteredUser> _registeredUsers = {
    'teste@educano.com': _RegisteredUser(
      user: const AppUser(
        id: 'demo-user',
        name: 'Miguel Soares',
        email: 'teste@educano.com',
        role: 'Administrador',
      ),
    ),
  };
  final Map<String, _PendingRegistration> _pendingRegistrations = {};

  Future<AuthResult> login({
    required String email,
    required String password,
  }) async {
    await Future.delayed(const Duration(milliseconds: 900));

    // TODO: substituir pela chamada real à API de autenticação.
    final normalizedEmail = email.trim().toLowerCase();
    final registered = _registeredUsers[normalizedEmail];
    if (password.length < 6 ||
        registered == null ||
        (registered.password != null && registered.password != password)) {
      return AuthResult.fail('E-mail ou senha inválidos.');
    }

    return AuthResult.ok('Login realizado com sucesso!', registered.user);
  }

  Future<AuthResult> register({
    required String name,
    required String email,
    required String password,
  }) async {
    await Future.delayed(const Duration(milliseconds: 1100));

    final normalizedEmail = email.trim().toLowerCase();

    // TODO: substituir pela chamada real à API de cadastro.
    if (_registeredUsers.containsKey(normalizedEmail) ||
        _pendingRegistrations.containsKey(normalizedEmail)) {
      return AuthResult.fail('Este e-mail já está cadastrado.');
    }

    final code = _generateCode();
    final user = AppUser(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      name: name.trim(),
      email: normalizedEmail,
    );
    _pendingRegistrations[normalizedEmail] = _PendingRegistration(
      user: user,
      password: password,
      code: code,
    );

    // Em produção o backend envia o e-mail; aqui só simulamos o log.
    // ignore: avoid_print
    print('[MOCK] Código de verificação para $normalizedEmail: $code');

    return AuthResult.ok('Conta criada! Enviamos um código de verificação.');
  }

  Future<AuthResult> verifyCode({
    required String email,
    required String code,
  }) async {
    await Future.delayed(const Duration(milliseconds: 800));

    final normalizedEmail = email.trim().toLowerCase();
    final pending = _pendingRegistrations[normalizedEmail];

    // TODO: substituir pela validação real do código no backend.
    // Para fins de demonstração, qualquer código de 6 dígitos "123456"
    // ou o código gerado no mock são aceitos.
    if (pending != null && (code == pending.code || code == '123456')) {
      _pendingRegistrations.remove(normalizedEmail);
      _registeredUsers[normalizedEmail] = _RegisteredUser(
        user: pending.user,
        password: pending.password,
      );
      return AuthResult.ok('Conta verificada com sucesso!', pending.user);
    }

    return AuthResult.fail('Código inválido. Tente novamente.');
  }

  Future<AuthResult> resendCode({required String email}) async {
    await Future.delayed(const Duration(milliseconds: 700));

    final normalizedEmail = email.trim().toLowerCase();
    final pending = _pendingRegistrations[normalizedEmail];
    if (pending == null) {
      return AuthResult.fail('Não há uma verificação pendente para este e-mail.');
    }
    final code = _generateCode();
    pending.code = code;

    // ignore: avoid_print
    print('[MOCK] Novo código de verificação para $normalizedEmail: $code');

    return AuthResult.ok('Um novo código foi enviado para o seu e-mail.');
  }

  Future<AuthResult> sendPasswordResetLink({required String email}) async {
    await Future.delayed(const Duration(milliseconds: 900));

    final normalizedEmail = email.trim().toLowerCase();

    // TODO: substituir pela chamada real à API de recuperação de senha.
    if (!_registeredUsers.containsKey(normalizedEmail)) {
      // Por segurança, muitos apps não revelam se o e-mail existe ou não.
      // Aqui mantemos a mensagem genérica de sucesso.
      return AuthResult.ok(
        'Se o e-mail estiver cadastrado, você receberá um link de recuperação.',
      );
    }

    return AuthResult.ok('Link de recuperação enviado para o seu e-mail.');
  }

  String _generateCode() {
    final now = DateTime.now().millisecondsSinceEpoch;
    return (now % 900000 + 100000).toString();
  }
}

class _RegisteredUser {
  final AppUser user;
  final String? password;

  const _RegisteredUser({required this.user, this.password});
}

class _PendingRegistration {
  final AppUser user;
  final String password;
  String code;

  _PendingRegistration({
    required this.user,
    required this.password,
    required this.code,
  });
}
