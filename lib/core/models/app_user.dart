class AppUser {
  final String id;
  final String name;
  final String email;
  final String role;

  /// Tipo da conta na API: ALUNO, PROFESSOR, PARCEIRO ou ADMIN.
  final String type;

  const AppUser({
    required this.id,
    required this.name,
    required this.email,
    this.role = 'Estudante',
    this.type = 'ALUNO',
  });

  bool get isAdmin => type == 'ADMIN';

  /// Equipe que produz conteúdo (cursos, materiais e questões).
  bool get isStaff => type == 'ADMIN' || type == 'PROFESSOR' || type == 'PARCEIRO';

  static String roleLabel(String type) => switch (type) {
    'ADMIN' => 'Administrador',
    'PROFESSOR' => 'Professor',
    'PARCEIRO' => 'Parceiro',
    _ => 'Estudante',
  };

  /// Converte o objeto `usuario` retornado pela API.
  factory AppUser.fromApi(Map<String, dynamic> json) {
    final type = json['tipo'] as String? ?? 'ALUNO';
    return AppUser(
      id: json['id'] as String,
      name: json['nome'] as String,
      email: json['email'] as String,
      role: roleLabel(type),
      type: type,
    );
  }

  AppUser copyWith({String? name}) => AppUser(
    id: id,
    name: name ?? this.name,
    email: email,
    role: role,
    type: type,
  );

  Map<String, Object> toJson() => {
    'id': id,
    'name': name,
    'email': email,
    'role': role,
    'type': type,
  };

  factory AppUser.fromJson(Map<String, dynamic> json) {
    final id = json['id'];
    final name = json['name'];
    final email = json['email'];
    final role = json['role'];
    final type = json['type'];
    if (id is! String ||
        name is! String ||
        email is! String ||
        (role != null && role is! String) ||
        (type != null && type is! String)) {
      throw const FormatException('Dados locais da conta inválidos.');
    }
    return AppUser(
      id: id,
      name: name,
      email: email,
      role: role is String ? role : 'Estudante',
      type: type is String ? type : 'ALUNO',
    );
  }
}
