import 'package:educano_app/core/navigation/app_menu.dart';
import 'package:educano_app/core/navigation/app_navigation.dart';
import 'package:flutter/material.dart';
import '../../models/app_user.dart';
import '../../theme/theme.dart';

const String _logoAssetPath = 'lib/assets/Educano_Logo.jpeg';

class AppHeader extends StatelessWidget {
  final VoidCallback? onMenuPressed;

  final bool isMobile;
  final AppUser? user;

  /// Controller compartilhado com o DashboardPage.
  /// Tudo que o usuário digitar ficará armazenado aqui.
  final TextEditingController searchController;

  const AppHeader({
    super.key,
    required this.onMenuPressed,
    required this.isMobile,
    required this.searchController,
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Container do Header
        Container(
          height: 72,
          padding: const EdgeInsets.symmetric(horizontal: 24),
          decoration: const BoxDecoration(
            color: EducanoColors.primaryBlue,
            border: Border(
              bottom: BorderSide(
                color: EducanoColors.secondaryBlue,
                width: 1.5,
              ),
            ),
          ),

          child: Row(
            children: [
              // Menu Hamburguer (recolhe no web; abre drawer no mobile)
              IconButton(
                icon: const Icon(Icons.menu, color: EducanoColors.surface),
                tooltip: "Menu",
                onPressed: onMenuPressed,
              ),

              const SizedBox(width: 12),

              // Logo
              ClipOval(
                child: Image.asset(
                  _logoAssetPath,
                  width: 42,
                  height: 42,
                  fit: BoxFit.cover,
                ),
              ),

              const SizedBox(width: 12),

              Text(
                "Educano",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: isMobile ? 20 : 22,
                  color: EducanoColors.textWhite,
                ),
              ),

              SizedBox(width: isMobile ? 12 : 32),

              // Barra de pesquisa
              if (!isMobile)
                Expanded(
                  child: SizedBox(
                    height: 45,
                    child: TextField(
                      controller: searchController,
                      decoration: const InputDecoration(
                        hintText: "Pesquisar usuários, cursos, questões...",
                        prefixIcon: Icon(Icons.search),
                      ),
                    ),
                  ),
                ),

              if (isMobile) const Spacer() else const SizedBox(width: 30),

              if (isMobile)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircleAvatar(
                      radius: 22,
                      backgroundColor: EducanoColors.surface,
                      child: Icon(
                        Icons.person,
                        color: EducanoColors.secondaryBlue,
                      ),
                    ),
                    if (user != null &&
                        MediaQuery.sizeOf(context).width >= 430) ...[
                      const SizedBox(width: 8),
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 82),
                        child: Text(
                          user!.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: EducanoColors.textWhite,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ],
                )
              else
                Row(
                  children: [
                    // Icone de Perfil
                    IconButton(
                      onPressed: () {
                        AppNavigation.onMenuSelected(context, AppMenu.profile);
                      },
                      icon: const CircleAvatar(
                        radius: 22,
                        backgroundColor: EducanoColors.surface,
                        child: Icon(
                          Icons.person,
                          color: EducanoColors.secondaryBlue,
                        ),
                      ),
                    ),

                    const SizedBox(width: 12),

                    // Infos. da Conta logada
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user?.name ?? 'Conta Educano',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: EducanoColors.textWhite,
                          ),
                        ),
                        Text(
                          user?.role ?? 'Estudante',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: EducanoColors.secondaryBlue,
                                fontSize: 11,
                              ),
                        ),
                      ],
                    ),
                  ],
                ),
            ],
          ),
        ),

        // Linhas de decoração abaixo do Header
        Container(
          height: 1.5,
          width: double.infinity,
          decoration: BoxDecoration(color: EducanoColors.accentYellow),
        ),
      ],
    );
  }
}
