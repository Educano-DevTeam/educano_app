import 'package:flutter/material.dart';

import '../../../core/layout/app_scaffold.dart';
import '../../../core/models/level_progress.dart';
import '../../../core/models/app_user.dart';
import '../../../core/navigation/app_menu.dart';
import '../../../core/theme/educano_colors.dart';
import '../../../core/utils/api_mappers.dart';
import '../../../core/widgets/ui/app_card.dart';
import '../../../core/widgets/ui/profile_avatar.dart';
import '../../../core/widgets/ui/stat_card.dart';

class PublicProfilePage extends StatelessWidget {
  final Map<String, dynamic> profile;

  const PublicProfilePage({super.key, required this.profile});

  @override
  Widget build(BuildContext context) => AppScaffold(
    selectedMenu: AppMenu.profile,
    child: _PublicProfileView(profile: profile),
  );
}

class _PublicProfileView extends StatelessWidget {
  final Map<String, dynamic> profile;

  const _PublicProfileView({required this.profile});

  @override
  Widget build(BuildContext context) {
    final name = profile['nome'] as String? ?? 'Usuário Educano';
    final type = profile['tipo'] as String? ?? 'ALUNO';
    final color = ApiMappers.color(profile['cor'] as String?);
    final photoUrl = profile['urlFotoPerfil'] as String?;
    final xp = _number(profile['xp']);
    final level = LevelProgress.fromTotalXp(xp).level;
    final coins = _number(profile['moedas']);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Perfil do usuário',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: EducanoColors.legacyTextPrimary,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Informações públicas deste perfil.',
            style: TextStyle(
              fontSize: 13,
              color: EducanoColors.legacyTextSecondary,
            ),
          ),
          const SizedBox(height: 16),
          AppSectionCard(
            child: Row(
              children: [
                ProfileAvatar(
                  imageUrl: photoUrl,
                  radius: 36,
                  backgroundColor: color,
                  placeholder: const Icon(
                    Icons.person,
                    color: Colors.white,
                    size: 34,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: EducanoColors.legacyTextPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        AppUser.roleLabel(type),
                        style: const TextStyle(
                          fontSize: 13,
                          color: EducanoColors.legacyTextSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, constraints) {
              final cards = [
                StatCard(label: 'Nível', value: '$level'),
                StatCard(label: 'XP total', value: '$xp XP'),
                StatCard(label: 'Moedas', value: '$coins'),
              ];
              if (constraints.maxWidth < 520) {
                return Column(
                  children: [
                    for (var index = 0; index < cards.length; index++) ...[
                      SizedBox(width: double.infinity, child: cards[index]),
                      if (index != cards.length - 1) const SizedBox(height: 12),
                    ],
                  ],
                );
              }
              return Row(
                children: [
                  for (var index = 0; index < cards.length; index++) ...[
                    Expanded(child: cards[index]),
                    if (index != cards.length - 1) const SizedBox(width: 12),
                  ],
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  static int _number(Object? value) =>
      value is num ? value.toInt() : int.tryParse('$value') ?? 0;
}
