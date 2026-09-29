/// Funções de validação usadas nos formulários de autenticação.
class Validators {
  Validators._();

  static final RegExp _emailRegex = RegExp(
    r"^[a-zA-Z0-9.a-zA-Z0-9!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)+$",
  );

  static String? name(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'Digite seu nome completo';
    if (v.length < 3) return 'Digite um nome válido';
    if (!v.contains(' ')) return 'Digite nome e sobrenome';
    return null;
  }

  static String? email(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'Digite seu e-mail';
    if (!_emailRegex.hasMatch(v)) return 'Digite um e-mail válido';
    return null;
  }

  static String? password(String? value, {int minLength = 6}) {
    final v = value ?? '';
    if (v.isEmpty) return 'Digite sua senha';
    if (v.length < minLength) {
      return 'A senha deve ter no mínimo $minLength caracteres';
    }
    return null;
  }

  static String? loginPassword(String? value) {
    if ((value ?? '').isEmpty) return 'Digite sua senha';
    return null;
  }

  static String? confirmPassword(String? value, String original) {
    final v = value ?? '';
    if (v.isEmpty) return 'Confirme sua senha';
    if (v != original) return 'As senhas não coincidem';
    return null;
  }

  /// Mascara um e-mail para exibição, ex: "daniel@email.com" -> "da••••@email.com".
  static String maskEmail(String email) {
    final parts = email.split('@');
    if (parts.length != 2) return email;
    final user = parts[0];
    final domain = parts[1];
    if (user.length <= 2) {
      return '${user[0]}${'•' * 4}@$domain';
    }
    final visible = user.substring(0, 2);
    return '$visible${'•' * 4}@$domain';
  }
}
