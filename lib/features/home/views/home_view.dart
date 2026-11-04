import 'package:educano_app/core/constants/app_breakpoints.dart';
import 'package:flutter/material.dart';

import '../../../core/navigation/app_routes.dart';
import '../../../core/theme/theme.dart';
import '../../../core/utils/api_mappers.dart';
import '../../../services/api_client.dart';
import '../../../services/progress_service.dart';

const double _spacingSmall = 16;
const double _spacingMedium = 24;
const double _spacingLarge = 32;

const double _radius = 18;

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  List<_CourseData> _courses = const [];
  _LevelData? _level;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final progress = await ProgressService.instance.me();
      final perfil = progress['perfil'] as Map<String, dynamic>;
      final cursos = (progress['cursos'] as Map<String, dynamic>)['lista'] as List;
      if (!mounted) return;
      setState(() {
        _level = _LevelData.fromApi(perfil);
        _courses = cursos.cast<Map<String, dynamic>>().map(_CourseData.fromApi).toList();
        _loading = false;
        _error = null;
      });
    } on ApiException catch (error) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = error.message;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;

        final bool isMobile = width < AppBreakpoints.mobile;
        final bool isTablet =
            width >= AppBreakpoints.mobile && width < AppBreakpoints.expanded;

        return SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: isMobile
                ? 16
                : isTablet
                ? 20
                : 29,
            vertical: isMobile ? 16 : 32,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (_error != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: _spacingMedium),
                  child: Row(
                    children: [
                      Expanded(child: Text(_error!, style: const TextStyle(color: EducanoColors.error))),
                      TextButton(onPressed: _load, child: const Text('Tentar novamente')),
                    ],
                  ),
                ),

              _OverviewCard(isMobile: isMobile, level: _level),

              const SizedBox(height: _spacingMedium),

              _CoursesCard(courses: _courses, isMobile: isMobile, loading: _loading),
            ],
          ),
        );
      },
    );
  }
}

// -----------------------------------------------------------------------------
// VISÃO GERAL
// -----------------------------------------------------------------------------

class _OverviewCard extends StatelessWidget {
  final bool isMobile;
  final _LevelData? level;

  const _OverviewCard({required this.isMobile, this.level});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 16 : 28),
      decoration: BoxDecoration(
        color: EducanoColors.surface,
        borderRadius: BorderRadius.circular(_radius),
        border: Border.all(color: const Color(0xFFD4D4D4), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Visão Geral',
            style: TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.w700,
              color: Color(0xFF404040),
            ),
          ),

          const SizedBox(height: 14),

          _LevelCard(isMobile: isMobile, level: level ?? const _LevelData.empty()),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// LEVEL
// -----------------------------------------------------------------------------

class _LevelCard extends StatelessWidget {
  final bool isMobile;
  final _LevelData level;

  const _LevelCard({required this.isMobile, required this.level});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 16 : 18,
        vertical: isMobile ? 14 : 12,
      ),
      decoration: BoxDecoration(
        color: EducanoColors.primaryBlue,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: const Color(0xFFD4D4D4), width: 1.5),
      ),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: isMobile ? 12 : 14,
          vertical: 10,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
        ),
        child: isMobile ? _buildMobileLevel() : _buildDesktopLevel(),
      ),
    );
  }

  Widget _buildDesktopLevel() {
    return Row(
      children: [
        const SizedBox(
          width: 60,
          child: Icon(
            Icons.emoji_events_rounded,
            size: 56,
            color: EducanoColors.accentYellow,
          ),
        ),

        const SizedBox(width: 18),

        SizedBox(
          width: 145,
          child: Text(
            'LEVEL ${level.level}',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: EducanoColors.primaryBlue,
            ),
          ),
        ),

        Expanded(
          child: _ProgressArea(
            progress: level.progress,
            label: level.label,
          ),
        ),

        const SizedBox(width: 14),

        Text(
          level.percentLabel,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: EducanoColors.primaryBlue,
          ),
        ),
      ],
    );
  }

  Widget _buildMobileLevel() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(
              Icons.emoji_events_rounded,
              size: 48,
              color: EducanoColors.accentYellow,
            ),
            const SizedBox(width: 14),
            Text(
              'LEVEL ${level.level}',
              style: const TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w700,
                color: EducanoColors.primaryBlue,
              ),
            ),
            const Spacer(),
            Text(
              level.percentLabel,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: EducanoColors.primaryBlue,
              ),
            ),
          ],
        ),

        const SizedBox(height: 10),

        _ProgressArea(progress: level.progress, label: level.label),
      ],
    );
  }
}

class _ProgressArea extends StatelessWidget {
  final double progress;
  final String label;

  const _ProgressArea({required this.progress, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(7),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 19,
            backgroundColor: const Color(0xFFD7D7D7),
            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF20D500)),
          ),
        ),

        const SizedBox(height: 4),

        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: EducanoColors.primaryBlue,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

// -----------------------------------------------------------------------------
// MEUS CURSOS
// -----------------------------------------------------------------------------

class _CoursesCard extends StatelessWidget {
  final List<_CourseData> courses;
  final bool isMobile;
  final bool loading;

  const _CoursesCard({
    required this.courses,
    required this.isMobile,
    this.loading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 16 : 28),
      decoration: BoxDecoration(
        color: EducanoColors.surface,
        borderRadius: BorderRadius.circular(_radius),
        border: Border.all(color: const Color(0xFFD4D4D4), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Meus Cursos',
            style: TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.w700,
              color: Color(0xFF404040),
            ),
          ),

          const SizedBox(height: 14),

          if (loading)
            const Padding(
              padding: EdgeInsets.all(24),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (courses.isEmpty)
            const Padding(
              padding: EdgeInsets.only(bottom: 14),
              child: Text(
                'Você ainda não está inscrito em nenhum curso. '
                'Toque em "Novo Curso" para conhecer o catálogo.',
                style: TextStyle(color: Color(0xFF777777)),
              ),
            ),

          ...courses.map(
            (course) => Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: _CourseCard(course: course, isMobile: isMobile),
            ),
          ),

          _SimuladosCard(isMobile: isMobile),
          const SizedBox(height: 14),
          _NewCourseButton(),
        ],
      ),
    );
  }
}

class _NewCourseButton extends StatelessWidget {
  const _NewCourseButton();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 58,
      child: OutlinedButton.icon(
        onPressed: () => Navigator.of(context).pushNamed(
          AppRoutes.courses,
        ),
        icon: const Icon(Icons.add_rounded, size: 28),
        label: const Text('Novo Curso'),
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFF777777),
          side: const BorderSide(color: Color(0xFFD4D4D4), width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(17),
          ),
          textStyle: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// CARD DE CURSO
// -----------------------------------------------------------------------------

class _CourseCard extends StatelessWidget {
  final _CourseData course;
  final bool isMobile;

  const _CourseCard({required this.course, required this.isMobile});

  @override
  Widget build(BuildContext context) {
    if (isMobile) {
      return _buildMobile(context);
    }

    return _buildDesktop(context);
  }

  Widget _buildDesktop(BuildContext context) {
    return Material(
      color: Colors.white,
      child: InkWell(
        borderRadius: BorderRadius.circular(17),
        onTap: () {
          Navigator.of(
            context,
          ).pushNamed(AppRoutes.course, arguments: course.id);
        },
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(17),
            border: Border.all(color: const Color(0xFFD4D4D4), width: 1.5),
          ),
          clipBehavior: Clip.antiAlias,
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  width: 315,
                  child: _CourseImage(course: course),
                ),

                const SizedBox(width: 18),

                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(
                      top: 10,
                      right: 16,
                      bottom: 10,
                    ),
                    child: _CourseInformation(course: course),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMobile(BuildContext context) {
    return Material(
      color: Colors.white,
      child: InkWell(
        borderRadius: BorderRadius.circular(17),
        onTap: () {
          Navigator.of(
            context,
          ).pushNamed(AppRoutes.course, arguments: course.id);
        },
        child: Container(
          height: 123,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(17),
            border: Border.all(color: const Color(0xFFD4D4D4), width: 1.5),
          ),
          clipBehavior: Clip.antiAlias,
          child: Row(
            children: [
              SizedBox(
                width: 112,
                height: double.infinity,
                child: _CourseImage(course: course),
              ),

              const SizedBox(width: 8),

              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 7, right: 8, bottom: 7),
                  child: _CourseInformation(course: course, isMobile: true),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// INFORMAÇÕES DO CURSO
// -----------------------------------------------------------------------------

class _CourseInformation extends StatelessWidget {
  final _CourseData course;
  final bool isMobile;

  const _CourseInformation({required this.course, this.isMobile = false});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                course.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF454545),
                ),
              ),
            ),

            const SizedBox(width: 12),

            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.access_time_rounded,
                  size: 20,
                  color: EducanoColors.primaryBlue,
                ),
                const SizedBox(width: 5),
                Text(
                  course.hours,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF7A7A7A),
                  ),
                ),
              ],
            ),
          ],
        ),

        Text(
          course.category,
          style: const TextStyle(fontSize: 13, color: Color(0xFF555555)),
        ),

        const SizedBox(height: 7),

        Expanded(
          child: Text(
            course.description,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 15,
              height: 1.25,
              color: Color(0xFF4D4D4D),
            ),
          ),
        ),

        const Divider(height: 8, thickness: 1, color: Color(0xFFD5D5D5)),

        Row(
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(7),
                child: LinearProgressIndicator(
                  value: course.progress,
                  minHeight: 20,
                  backgroundColor: const Color(0xFFD7D7D7),
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    Color(0xFF20D500),
                  ),
                ),
              ),
            ),

            const SizedBox(width: 12),

            Text(
              course.progressLabel,
              style: const TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w700,
                color: Color(0xFF494949),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// -----------------------------------------------------------------------------
// SIMULADOS
// -----------------------------------------------------------------------------

class _SimuladosCard extends StatelessWidget {
  final bool isMobile;

  const _SimuladosCard({required this.isMobile});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      child: InkWell(
        borderRadius: BorderRadius.circular(17),
        onTap: () => Navigator.of(context).pushNamed(AppRoutes.lastExams),
        child: Container(
          height: isMobile ? 123 : 138,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(17),
            border: Border.all(color: const Color(0xFFD4D4D4), width: 1.5),
          ),
          clipBehavior: Clip.antiAlias,
          child: Row(
            children: [
              SizedBox(
                width: isMobile ? 112 : 315,
                height: double.infinity,
                child: Image.asset(
                  'lib/assets/courses/exam_image.jpg',
                  fit: BoxFit.cover,
                ),
              ),

              const SizedBox(width: 18),

              const Expanded(
                child: Text(
                  'Simulados',
                  style: TextStyle(
                    fontSize: 27,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF454545),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// MODELO
// -----------------------------------------------------------------------------

class _CourseData {
  final String id;
  final String title;
  final String category;
  final String hours;
  final String description;
  final double progress;
  final String progressLabel;
  final String image;
  final IconData icon;
  final Color color;

  const _CourseData({
    required this.id,
    required this.title,
    required this.category,
    required this.hours,
    required this.description,
    required this.progress,
    required this.progressLabel,
    required this.image,
    required this.icon,
    required this.color,
  });

  /// Curso inscrito retornado em /progress/me.
  factory _CourseData.fromApi(Map<String, dynamic> json) {
    final progress = (json['progresso'] as num).toDouble();
    final minutes = json['cargaHorariaMinutos'] as int? ?? 0;
    final hours = (minutes / 60).round();
    return _CourseData(
      id: json['id'] as String,
      title: json['nome'] as String,
      category: ApiMappers.categoryLabel(json['categoria'] as String?),
      hours: minutes <= 0
          ? '${json['totalConteudos']} ${json['totalConteudos'] == 1 ? 'conteúdo' : 'conteúdos'}'
          : (hours > 0 ? '$hours ${hours == 1 ? 'Hora' : 'Horas'}' : '$minutes min'),
      description: json['descricao'] as String? ?? '',
      progress: progress,
      progressLabel: progress >= 1 ? 'Concluído' : '${(progress * 100).round()}%',
      image: ApiMappers.mediaUrl(json['idCapa'] as String?) ?? '',
      icon: ApiMappers.coverIcon(json['iconeCapa'] as String?),
      color: ApiMappers.color(json['cor'] as String?),
    );
  }
}

class _LevelData {
  final int level;
  final int xpInLevel;
  final int xpPerLevel;
  final int totalXp;

  const _LevelData({
    required this.level,
    required this.xpInLevel,
    required this.xpPerLevel,
    required this.totalXp,
  });

  const _LevelData.empty() : level = 0, xpInLevel = 0, xpPerLevel = 250, totalXp = 0;

  factory _LevelData.fromApi(Map<String, dynamic> perfil) => _LevelData(
    level: perfil['nivel'] as int,
    xpInLevel: perfil['xpNoNivel'] as int,
    xpPerLevel: perfil['xpParaProximoNivel'] as int,
    totalXp: perfil['xp'] as int,
  );

  double get progress => xpPerLevel == 0 ? 0 : xpInLevel / xpPerLevel;
  String get percentLabel => '${(progress * 100).round()}%';
  String get label =>
      '$xpInLevel/$xpPerLevel XP para o Level ${level + 1} · $totalXp XP no total';
}

/// Imagem do curso (URL da API) ou o ícone e a cor dele.
class _CourseImage extends StatelessWidget {
  final _CourseData course;

  const _CourseImage({required this.course});

  @override
  Widget build(BuildContext context) {
    final fallback = Container(
      color: course.color.withValues(alpha: .15),
      child: Icon(course.icon, color: course.color, size: 48),
    );
    if (course.image.isEmpty) return fallback;
    return Image.network(
      course.image,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => fallback,
    );
  }
}
