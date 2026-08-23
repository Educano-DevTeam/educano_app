import 'package:flutter/material.dart';
import '../theme/theme.dart';

class AppHeader extends StatelessWidget {
  final VoidCallback? onMenuPressed;

  final bool isMobile;
  /// Controller compartilhado com o DashboardPage.
  /// Tudo que o usuário digitar ficará armazenado aqui.
  final TextEditingController searchController;

  const AppHeader({
    super.key,
    required this.onMenuPressed,
    required this.isMobile,
    required this.searchController,
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
            border: Border(bottom: BorderSide(color: EducanoColors.secondaryBlue, width: 1.5,)),
          ),

          child: Row(
            children: [
              // Menu Hamburguer (recolhe no web; abre drawer no mobile)
              IconButton(
                icon: const Icon(Icons.menu, color: EducanoColors.surface),
                tooltip: "Menu",
                onPressed: onMenuPressed,
              ),

              // Logo
              const Icon(Icons.school_rounded, color: EducanoColors.textWhite, size: 32),
              const SizedBox(width: 12),

              const Text(
                "Educano",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22, color: EducanoColors.textWhite),
              ),

              const SizedBox(width: 32),

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

              if (isMobile)
                const Spacer()
              else
                const SizedBox(width: 30),

              // Notificações (presente em todos os frames do Figma)
              IconButton(
                icon: const Icon(
                  Icons.notifications_none_rounded,
                  color: EducanoColors.surface,
                ),
                tooltip: "Notificações",
                onPressed: () {},
              ),

              const SizedBox(width: 4),

              if (isMobile)
                const CircleAvatar(
                  radius: 22,
                  backgroundColor: EducanoColors.surface,
                  child: Icon(Icons.person, color: EducanoColors.secondaryBlue),
                )

              else
                Row(
                  children: [
                    // Ícone dePerfil
                    const CircleAvatar(
                      radius: 22,
                      backgroundColor: EducanoColors.surface,
                      child: Icon(Icons.person, color: EducanoColors.secondaryBlue),
                    ),

                    const SizedBox(width: 12),

                    // Infos. da Conta logada
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Miguel Soares",
                          style: TextStyle(fontWeight: FontWeight.bold, color: EducanoColors.textWhite),
                        ),
                        Text(
                          "Administrador",
                          style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(
                              color: EducanoColors.secondaryBlue,
                              fontSize: 11,
                            ),
                        ),
                      ],
                    ),
                  ],
                ),
            ]
          ),
        ),

        // Linhas de decoração abaixo do Header
        Container(
          height: 1.5,
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: EducanoColors.primaryGradient,
          ),
        )
      ],
    );
  }
}