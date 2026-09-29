/// Resultado padrão de uma operação de autenticação.
class AuthResult {
  final bool success;
  final String? message;

  const AuthResult({required this.success, this.message});

  factory AuthResult.ok([String? message]) =>
      AuthResult(success: true, message: message);

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

  // Simula uma pequena "base de dados" de usuários já cadastrados.
  final Set<String> _registeredEmails = {'teste@educano.com'};

  // Guarda o último código de verificação "enviado" por e-mail, só para
  // simular o fluxo. Numa API real isso vive inteiramente no backend.
  final Map<String, String> _pendingCodes = {};

  Future<AuthResult> login({
    required String email,
    required String password,
  }) async {
    await Future.delayed(const Duration(milliseconds: 900));

    // TODO: substituir pela chamada real à API de autenticação.
    if (!_registeredEmails.contains(email.trim().toLowerCase())) {
      return AuthResult.fail('E-mail ou senha inválidos.');
    }
    if (password.length < 6) {
      return AuthResult.fail('E-mail ou senha inválidos.');
    }

    return AuthResult.ok('Login realizado com sucesso!');
  }

  Future<AuthResult> register({
    required String name,
    required String email,
    required String password,
  }) async {
    await Future.delayed(const Duration(milliseconds: 1100));

    final normalizedEmail = email.trim().toLowerCase();

    // TODO: substituir pela chamada real à API de cadastro.
    if (_registeredEmails.contains(normalizedEmail)) {
      return AuthResult.fail('Este e-mail já está cadastrado.');
    }

    _registeredEmails.add(normalizedEmail);
    final code = _generateCode();
    _pendingCodes[normalizedEmail] = code;

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
    final expected = _pendingCodes[normalizedEmail];

    // TODO: substituir pela validação real do código no backend.
    // Para fins de demonstração, qualquer código de 6 dígitos "123456"
    // ou o código gerado no mock são aceitos.
    if (code == expected || code == '123456') {
      _pendingCodes.remove(normalizedEmail);
      return AuthResult.ok('Conta verificada com sucesso!');
    }

    return AuthResult.fail('Código inválido. Tente novamente.');
  }

  Future<AuthResult> resendCode({required String email}) async {
    await Future.delayed(const Duration(milliseconds: 700));

    final normalizedEmail = email.trim().toLowerCase();
    final code = _generateCode();
    _pendingCodes[normalizedEmail] = code;

    // ignore: avoid_print
    print('[MOCK] Novo código de verificação para $normalizedEmail: $code');

    return AuthResult.ok('Um novo código foi enviado para o seu e-mail.');
  }

  Future<AuthResult> sendPasswordResetLink({required String email}) async {
    await Future.delayed(const Duration(milliseconds: 900));

    final normalizedEmail = email.trim().toLowerCase();

    // TODO: substituir pela chamada real à API de recuperação de senha.
    if (!_registeredEmails.contains(normalizedEmail)) {
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
