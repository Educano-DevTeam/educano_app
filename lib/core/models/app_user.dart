class AppUser {
  final String id;
  final String name;
  final String email;
  final String role;

  const AppUser({
    required this.id,
    required this.name,
    required this.email,
    this.role = 'Estudante',
  });

  Map<String, Object> toJson() => {
    'id': id,
    'name': name,
    'email': email,
    'role': role,
  };

  factory AppUser.fromJson(Map<String, dynamic> json) {
    final id = json['id'];
    final name = json['name'];
    final email = json['email'];
    final role = json['role'];
    if (id is! String ||
        name is! String ||
        email is! String ||
        (role != null && role is! String)) {
      throw const FormatException('Dados locais da conta inválidos.');
    }
    return AppUser(
      id: id,
      name: name,
      email: email,
      role: role is String ? role : 'Estudante',
    );
  }
}
