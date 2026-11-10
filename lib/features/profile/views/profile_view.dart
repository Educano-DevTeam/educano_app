import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/educano_colors.dart';
import '../../../core/utils/api_mappers.dart';
import '../../../services/api_client.dart';
import '../../../services/progress_service.dart';
import '../../../services/users_service.dart';
import '../../../core/models/app_user.dart';
import '../../../core/models/profile_course.dart';
import '../../../core/widgets/charts/mini_bar_chart.dart';
import '../../../core/navigation/app_routes.dart';
import '../../../core/navigation/navigation_service.dart';
import '../../../services/storage_service.dart';

import '../../../core/widgets/ui/app_card.dart';

import '../../../core/widgets/ui/app_button.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  List<ProfileCourse> _courses = const [];
  List<ChartPoint> _chartData = const [];
  Map<String, dynamic>? _stats;
  Map<String, dynamic>? _profile;

  int? _selectedCourse;
  late final Future<AppUser?> _userFuture;

  @override
  void initState() {
    super.initState();
    _userFuture = StorageService.instance.loadCurrentUser();
    _load();
  }

  Future<void> _load() async {
    try {
      final results = await Future.wait([
        ProgressService.instance.me(),
        UsersService.instance.myProfile(),
      ]);
      final progress = results[0];
      final courses = ((progress['cursos'] as Map)['lista'] as List).cast<Map<String, dynamic>>();
      if (!mounted) return;
      setState(() {
        _stats = progress;
        _profile = results[1];
        _chartData = [
          for (final month in (progress['evolucao'] as List).cast<Map<String, dynamic>>())
            ChartPoint(
              month['mes'] as String,
              (month['atividades'] as num).toDouble(),
              (month['simulados'] as num).toDouble(),
            ),
        ];
        _courses = [
          for (final course in courses)
            ProfileCourse(
              id: course['id'] as String,
              initials: _initials(course['nome'] as String),
              color: ApiMappers.color(course['cor'] as String?),
              name: course['nome'] as String,
              progressLabel: '${course['sessoes']} ${course['sessoes'] == 1 ? 'trilha' : 'trilhas'} • '
                  '${((course['progresso'] as num) * 100).round()}% concluído',
            ),
        ];
      });
    } on ApiException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error.message)));
    }
  }

  static String _initials(String name) {
    final words = name.split(RegExp(r'\s+')).where((w) => w.length > 2).toList();
    if (words.isEmpty) return name.substring(0, 1).toUpperCase();
    return words.take(2).map((w) => w[0].toUpperCase()).join();
  }

  Future<void> _editProfile() async {
    final changed = await showDialog<bool>(
      context: context,
      builder: (_) => _EditProfileDialog(profile: _profile ?? const {}),
    );
    if (changed == true) await _load();
  }

  void _share() {
    final perfil = _stats?['perfil'] as Map<String, dynamic>?;
    final text = 'Estou no nível ${perfil?['nivel'] ?? 0} do Educano, com '
        '${perfil?['xp'] ?? 0} XP e ${perfil?['sequenciaDias'] ?? 0} dias de sequência!';
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Resumo do perfil copiado para compartilhar.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Meu Perfil',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: EducanoColors.legacyTextPrimary,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Gerencie suas informações e confira seu progresso.',
            style: TextStyle(
              fontSize: 13,
              color: EducanoColors.legacyTextSecondary,
            ),
          ),
          const SizedBox(height: 16),
          FutureBuilder<AppUser?>(
            future: _userFuture,
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return const _ProfileDataError();
              }
              return _ProfileHeaderCard(
                user: snapshot.data,
                photoUrl: _profile?['urlFotoPerfil'] as String?,
                stats: _stats,
                onEdit: _editProfile,
                onShare: _share,
              );
            },
          ),
          const SizedBox(height: 16),
          _PlanBanner(
            planName: ((_stats?['perfil'] as Map?)?['plano'] as Map?)?['nome'] as String?,
          ),
          const SizedBox(height: 20),
          AppSectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Text(
                      'Evolução das notas',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: EducanoColors.legacyTextPrimary,
                      ),
                    ),
                    Spacer(),
                    Text(
                      'Últimos 7 meses',
                      style: TextStyle(
                        fontSize: 11,
                        color: EducanoColors.legacyTextSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Row(
                  children: [
                    _LegendDot(
                      color: EducanoColors.legacyRed,
                      label: 'Atividades',
                    ),
                    SizedBox(width: 16),
                    _LegendDot(
                      color: EducanoColors.legacyPrimary,
                      label: 'Simulados',
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (_chartData.isEmpty)
                  const SizedBox(height: 120, child: Center(child: CircularProgressIndicator()))
                else
                  MiniBarChart(data: _chartData),
              ],
            ),
          ),
          const SizedBox(height: 20),
          AppSectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text(
                      'Meus Cursos',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: EducanoColors.legacyTextPrimary,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${_courses.length} em andamento',
                      style: const TextStyle(
                        fontSize: 11.5,
                        color: EducanoColors.legacyTextSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                for (int i = 0; i < _courses.length; i++)
                  _CourseRow(
                    course: _courses[i],
                    selected: _selectedCourse == i,
                    onTap: () {
                      setState(() => _selectedCourse = i);
                      NavigationService.pushNamed(AppRoutes.course, arguments: _courses[i].id);
                    },
                  ),
                if (_courses.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Text('Você ainda não está inscrito em cursos.'),
                  ),
                const SizedBox(height: 6),
                GestureDetector(
                  onTap: () => NavigationService.pushNamed(AppRoutes.courses),
                  child: const Text(
                    'Ver todos os cursos  ›',
                    style: TextStyle(
                      color: EducanoColors.legacyPrimary,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

class _ProfileHeaderCard extends StatelessWidget {
  final AppUser? user;
  final String? photoUrl;
  final Map<String, dynamic>? stats;
  final VoidCallback onEdit;
  final VoidCallback onShare;

  const _ProfileHeaderCard({
    required this.user,
    required this.photoUrl,
    required this.stats,
    required this.onEdit,
    required this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    return AppSectionCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                height: 92,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      EducanoColors.legacyGradientStart,
                      EducanoColors.legacyGradientEnd,
                    ],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                ),
              ),
              Positioned(
                left: 20,
                bottom: -30,
                child: Container(
                  width: 68,
                  height: 68,
                  padding: const EdgeInsets.all(3),
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                  ),
                  child: CircleAvatar(
                    backgroundColor: EducanoColors.legacyPrimary,
                    backgroundImage: (photoUrl?.isNotEmpty ?? false)
                        ? NetworkImage(photoUrl!)
                        : null,
                    child: (photoUrl?.isNotEmpty ?? false)
                        ? null
                        : const Icon(Icons.person, color: Colors.white, size: 30),
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 40, 20, 20),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final bool narrow = constraints.maxWidth < 460;

                final nameBlock = Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      user?.name ?? 'Conta Educano',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: EducanoColors.legacyTextPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      user?.email ?? '',
                      style: const TextStyle(
                        fontSize: 12.5,
                        color: EducanoColors.legacyTextSecondary,
                      ),
                    ),
                  ],
                );

                final Widget buttons = Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    HoverOutlineButton(
                      label: 'Editar Perfil',
                      leadingIcon: Icons.edit_outlined,
                      onPressed: onEdit,
                    ),
                    const SizedBox(width: 10),
                    HoverOutlineButton(
                      label: 'Compartilhar',
                      leadingIcon: Icons.ios_share,
                      onPressed: onShare,
                    ),
                  ],
                );

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    narrow
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              nameBlock,
                              const SizedBox(height: 12),
                              buttons,
                            ],
                          )
                        : Row(
                            children: [
                              Expanded(child: nameBlock),
                              buttons,
                            ],
                          ),
                    const SizedBox(height: 20),
                    _StatsRow(stats: stats),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _StatsRow extends StatelessWidget {
  final Map<String, dynamic>? stats;

  const _StatsRow({required this.stats});

  @override
  Widget build(BuildContext context) {
    final perfil = stats?['perfil'] as Map<String, dynamic>?;
    final cursos = stats?['cursos'] as Map<String, dynamic>?;
    final sequence = perfil?['sequenciaDias'] ?? 0;
    final List<List<String>> items = [
      ['${perfil?['nivel'] ?? '—'}', 'Nível'],
      ['${perfil?['xp'] ?? '—'}', 'XP'],
      ['$sequence ${sequence == 1 ? 'dia' : 'dias'}', 'Sequência'],
      ['${cursos?['concluidos'] ?? '—'}', 'Concluídos'],
    ];

    return Row(
      children: [
        for (int i = 0; i < items.length; i++) ...[
          if (i != 0)
            Container(
              width: 1,
              height: 30,
              color: EducanoColors.legacyCardBorder,
              margin: const EdgeInsets.symmetric(horizontal: 14),
            ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                items[i][0],
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: EducanoColors.legacyTextPrimary,
                ),
              ),
              Text(
                items[i][1],
                style: const TextStyle(
                  fontSize: 11,
                  color: EducanoColors.legacyTextSecondary,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

class _PlanBanner extends StatelessWidget {
  final String? planName;

  const _PlanBanner({this.planName});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: EducanoColors.legacyLavender,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.workspace_premium,
              color: EducanoColors.legacyPrimary,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Plano ${planName ?? 'Básico'}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13.5,
                    color: EducanoColors.legacyTextPrimary,
                  ),
                ),
                Text(
                  planName == null || planName == 'Básico'
                      ? 'Grátis - Tenha acesso a mais recursos disponíveis.'
                      : 'Obrigado por apoiar o Educano!',
                  style: const TextStyle(
                    fontSize: 11.5,
                    color: EducanoColors.legacyTextSecondary,
                  ),
                ),
              ],
            ),
          ),
          HoverButton(
            label: 'Ver planos',
            trailingIcon: Icons.chevron_right,
            onPressed: () {
              NavigationService.pushNamed(AppRoutes.accountPlan);
            },
          ),
        ],
      ),
    );
  }
}

class _ProfileDataError extends StatelessWidget {
  const _ProfileDataError();

  @override
  Widget build(BuildContext context) => const AppSectionCard(
    child: Text(
      'Não foi possível carregar as informações da conta.',
      style: TextStyle(color: EducanoColors.error),
    ),
  );
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11.5,
            color: EducanoColors.legacyTextSecondary,
          ),
        ),
      ],
    );
  }
}

class _CourseRow extends StatefulWidget {
  final ProfileCourse course;
  final bool selected;
  final VoidCallback onTap;

  const _CourseRow({
    required this.course,
    required this.selected,
    required this.onTap,
  });

  @override
  State<_CourseRow> createState() => _CourseRowState();
}

class _CourseRowState extends State<_CourseRow> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final course = widget.course;

    Color bg;
    if (widget.selected) {
      bg = EducanoColors.legacyPrimary.withValues(alpha: 0.12);
    } else if (_hovered) {
      bg = EducanoColors.legacyBackground;
    } else {
      bg = Colors.transparent;
    }

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeOut,
          margin: const EdgeInsets.symmetric(vertical: 2),
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: course.color,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  course.initials,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12.5,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      course.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13.5,
                        color: EducanoColors.legacyTextPrimary,
                      ),
                    ),
                    Text(
                      course.progressLabel,
                      style: const TextStyle(
                        fontSize: 11.5,
                        color: EducanoColors.legacyTextSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                size: 18,
                color: widget.selected
                    ? EducanoColors.legacyPrimary
                    : EducanoColors.legacyTextSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Edição do perfil: foto e visibilidade (perfil público ou privado).
class _EditProfileDialog extends StatefulWidget {
  final Map<String, dynamic> profile;

  const _EditProfileDialog({required this.profile});

  @override
  State<_EditProfileDialog> createState() => _EditProfileDialogState();
}

class _EditProfileDialogState extends State<_EditProfileDialog> {
  late bool _public = widget.profile['tipoPerfil'] == 'PUBLICO';
  late String _photoUrl = widget.profile['urlFotoPerfil'] as String? ?? '';
  bool _busy = false;
  bool _changed = false;

  void _error(String message) => ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(message), backgroundColor: EducanoColors.legacyRed),
  );

  Future<void> _pickPhoto() async {
    final files = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['jpg', 'jpeg', 'png', 'webp'],
    );
    if (!mounted || files.isEmpty) return;
    setState(() => _busy = true);
    try {
      final file = files.first;
      final profile = await UsersService.instance.uploadPhoto(
        await file.readAsBytes(),
        file.name,
      );
      if (!mounted) return;
      setState(() {
        _photoUrl = profile['urlFotoPerfil'] as String? ?? '';
        _changed = true;
      });
    } on ApiException catch (error) {
      if (mounted) _error(error.message);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _removePhoto() async {
    setState(() => _busy = true);
    try {
      await UsersService.instance.updateMyProfile({'urlFotoPerfil': ''});
      if (!mounted) return;
      setState(() {
        _photoUrl = '';
        _changed = true;
      });
    } on ApiException catch (error) {
      if (mounted) _error(error.message);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _save() async {
    setState(() => _busy = true);
    try {
      await UsersService.instance.updateMyProfile({
        'tipoPerfil': _public ? 'PUBLICO' : 'PRIVADO',
      });
      if (mounted) Navigator.pop(context, true);
    } on ApiException catch (error) {
      if (!mounted) return;
      setState(() => _busy = false);
      _error(error.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Editar perfil'),
      content: SizedBox(
        width: 380,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 42,
              backgroundColor: EducanoColors.legacyPrimary,
              backgroundImage: _photoUrl.isNotEmpty ? NetworkImage(_photoUrl) : null,
              child: _photoUrl.isEmpty
                  ? const Icon(Icons.person, color: Colors.white, size: 40)
                  : null,
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: [
                OutlinedButton.icon(
                  onPressed: _busy ? null : _pickPhoto,
                  icon: const Icon(Icons.photo_camera_outlined),
                  label: const Text('Trocar foto'),
                ),
                if (_photoUrl.isNotEmpty)
                  TextButton(
                    onPressed: _busy ? null : _removePhoto,
                    child: const Text('Remover'),
                  ),
              ],
            ),
            const Text(
              'JPG, PNG ou WEBP de até 5 MB.',
              style: TextStyle(fontSize: 11, color: EducanoColors.legacyTextSecondary),
            ),
            const SizedBox(height: 12),
            SwitchListTile(
              value: _public,
              onChanged: _busy ? null : (value) => setState(() => _public = value),
              title: const Text('Perfil público'),
              subtitle: Text(
                _public
                    ? 'Outros usuários podem ver seu nível, XP e foto.'
                    : 'Somente você vê os dados do seu perfil.',
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _busy ? null : () => Navigator.pop(context, _changed),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _busy ? null : _save,
          child: _busy
              ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
              : const Text('Salvar'),
        ),
      ],
    );
  }
}
