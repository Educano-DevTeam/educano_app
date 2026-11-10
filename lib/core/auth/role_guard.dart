import 'package:flutter/material.dart';

import '../models/app_user.dart';
import '../navigation/app_routes.dart';
import '../theme/educano_colors.dart';
import '../../services/storage_service.dart';

/// Restringe uma página pelo tipo da conta logada.
///
/// A API também valida cada requisição; aqui só evitamos mostrar telas que
/// o usuário não pode usar.
class RoleGuard extends StatefulWidget {
  final Widget child;
  final bool Function(AppUser user) allow;

  const RoleGuard({super.key, required this.child, required this.allow});

  /// Telas do dashboard abertas à equipe (admin, professor e parceiro).
  factory RoleGuard.staff(Widget child) =>
      RoleGuard(allow: (user) => user.isStaff, child: child);

  /// Telas exclusivas do administrador.
  factory RoleGuard.admin(Widget child) =>
      RoleGuard(allow: (user) => user.isAdmin, child: child);

  @override
  State<RoleGuard> createState() => _RoleGuardState();
}

class _RoleGuardState extends State<RoleGuard> {
  late final Future<AppUser?> _user = StorageService.instance.loadCurrentUser();

  @override
  Widget build(BuildContext context) => FutureBuilder<AppUser?>(
    future: _user,
    builder: (context, snapshot) {
      if (snapshot.connectionState != ConnectionState.done) {
        return const ColoredBox(
          color: EducanoColors.background,
          child: Center(child: CircularProgressIndicator()),
        );
      }

      final user = snapshot.data;
      if (user != null && widget.allow(user)) return widget.child;

      return Material(
        color: EducanoColors.background,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.lock_outline_rounded, size: 48, color: EducanoColors.textSecondary),
              const SizedBox(height: 12),
              const Text(
                'Acesso restrito',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 6),
              const Text('Sua conta não tem permissão para acessar esta área.'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pushNamedAndRemoveUntil(
                  user == null ? AppRoutes.login : AppRoutes.home,
                  (route) => false,
                ),
                child: Text(user == null ? 'Ir para o login' : 'Voltar ao início'),
              ),
            ],
          ),
        ),
      );
    },
  );
}
