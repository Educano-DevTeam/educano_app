import 'package:flutter/material.dart';

import '../../../core/layout/app_scaffold.dart';
import '../../../core/navigation/app_menu.dart';
import '../../../core/theme/educano_colors.dart';
import '../models/course_models.dart';
import '../repositories/course_local_repository.dart';
import '../widgets/course_editor_dialogs.dart';

import 'package:educano_app/core/navigation/app_routes.dart';
import 'package:educano_app/features/materials/models/material_route_args.dart';

const _green = Color(0xFF20D500);

class CoursePage extends StatefulWidget {
  final String courseId;

  const CoursePage({super.key, required this.courseId});

  @override
  State<CoursePage> createState() => _CoursePageState();
}

class _CoursePageState extends State<CoursePage> {
  final _repository = CourseLocalRepository.instance;
  Course? _course;
  int _selectedSession = 2;

  @override
  void initState() {
    super.initState();
    _loadCourse();
  }

  Future<void> _loadCourse() async {
    final course = await _repository.getCourse(widget.courseId);
    if (!mounted) return;
    setState(() {
      _course = course;
      if (course != null && course.sessions.isNotEmpty) {
        _selectedSession = _selectedSession
            .clamp(0, course.sessions.length - 1)
            .toInt();
      }
    });
  }

  Future<void> _addSession() async {
    final data = await showSessionEditor(context);
    if (data == null) return;

    await _repository.addSession(
      courseId: widget.courseId,
      title: data['title']!,
      subtitle: data['subtitle']!,
      description: data['description']!,
    );
    await _loadCourse();
    if (mounted && _course != null) {
      setState(() => _selectedSession = _course!.sessions.length - 1);
    }
  }

  Future<void> _addModule(CourseSession session) async {
    final data = await showModuleEditor(context);
    if (data == null) return;

    await _repository.addModule(
      courseId: widget.courseId,
      sessionId: session.id,
      title: data['title']!,
      description: data['description']!,
    );
    await _loadCourse();
  }

  Future<void> _addMaterial(CourseSession session, CourseModule module) async {
    final material = await showMaterialEditor(context);
    if (material == null) return;

    await _repository.addMaterial(
      courseId: widget.courseId,
      sessionId: session.id,
      moduleId: module.id,
      material: material,
    );
    await _loadCourse();
  }

  Future<void> _toggleModule(CourseSession session, CourseModule module) async {
    await _repository.toggleModule(
      courseId: widget.courseId,
      sessionId: session.id,
      moduleId: module.id,
    );
    await _loadCourse();
  }

  Future<void> _openMaterial(
    CourseSession session,
    CourseModule module,
    CourseMaterial material,
  ) async {
    final result = await Navigator.of(context).pushNamed(
      AppRoutes.material,
      arguments: MaterialRouteArgs(
        courseId: widget.courseId,
        sessionId: session.id,
        moduleId: module.id,
        materialId: material.id,
      ),
    );

    if (!mounted || result != true) return;

    final refreshed = await CourseLocalRepository.instance.getCourse(
      widget.courseId,
    );

    if (refreshed != null) {
      setState(() {
        _course = refreshed;
      });
    }
  }

  Future<void> _showFilePreview(CourseMaterial material) {
    return showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(material.title),
        content: SizedBox(
          width: 440,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                material.kind.icon,
                size: 54,
                color: EducanoColors.primaryBlue,
              ),
              const SizedBox(height: 14),
              Text(
                'Aqui será aberta a tela do ${material.kindLabel.toLowerCase()}.',
                textAlign: TextAlign.center,
              ),
              if (material.fileUrl != null) ...[
                const SizedBox(height: 12),
                SelectableText(material.fileUrl!),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }

  Future<void> _showActivityPreview(Activity activity) {
    return showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(activity.theme),
        content: Text(
          'Aqui será aberta a tela do simulado com '
          '${activity.questions.length} questões e ${activity.durationMinutes} min.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      selectedMenu: AppMenu.home,
      child: _course == null
          ? const Center(child: CircularProgressIndicator())
          : _buildCourse(context, _course!),
    );
  }

  Widget _buildCourse(BuildContext context, Course course) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final mobile = constraints.maxWidth < 700;
        return SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            mobile ? 12 : 44,
            32,
            mobile ? 12 : 44,
            40,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _CourseHero(course: course, mobile: mobile),
              SizedBox(height: mobile ? 10 : 0),
              _ProgressCard(course: course, mobile: mobile),
              const SizedBox(height: 10),
              _AboutCourse(course: course, mobile: mobile),
              const SizedBox(height: 12),
              Text(
                'Conteúdo',
                style: TextStyle(
                  fontSize: mobile ? 22 : 24,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF444444),
                ),
              ),
              const SizedBox(height: 12),
              _ContentCard(
                course: course,
                mobile: mobile,
                selectedSession: _selectedSession,
                onSessionChanged: (value) =>
                    setState(() => _selectedSession = value),
                onAddSession: _addSession,
                onAddModule: _addModule,
                onAddMaterial: _addMaterial,
                onToggleModule: _toggleModule,
                onOpenMaterial: _openMaterial,
              ),
            ],
          ),
        );
      },
    );
  }
}

class _CourseHero extends StatelessWidget {
  final Course course;
  final bool mobile;

  const _CourseHero({required this.course, required this.mobile});

  @override
  Widget build(BuildContext context) {
    final image = Image.asset(
      course.imageAsset,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => Container(
        color: EducanoColors.secondaryBlue,
        child: const Icon(
          Icons.menu_book_rounded,
          color: Colors.white,
          size: 72,
        ),
      ),
    );

    final details = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          course.title,
          style: TextStyle(
            color: Colors.white,
            fontSize: mobile ? 20 : 22,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 3),
        Text(course.category, style: const TextStyle(color: Colors.white70)),
        const SizedBox(height: 12),
        Wrap(
          spacing: 14,
          runSpacing: 8,
          children: [
            _HeroMetric(icon: Icons.star_rounded, label: '4.7/5'),
            _HeroMetric(icon: Icons.people_alt_rounded, label: '52.732'),
            _HeroMetric(
              icon: Icons.access_time_filled_rounded,
              label: course.duration,
            ),
            _HeroMetric(
              icon: Icons.menu_book_rounded,
              label: '${course.sessions.length} sessões',
            ),
          ],
        ),
        const SizedBox(height: 10),
        const Text(
          'Prepare-se para o vestibular com aulas focadas, material atualizado, '
          'simulados frequentes e suporte com professores experientes para '
          'garantir a sua aprovação na universidade dos sonhos.',
          style: TextStyle(color: Colors.white, fontSize: 12.5, height: 1.25),
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFF627CF0),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 15,
                backgroundColor: Colors.white,
                child: Icon(
                  Icons.school_rounded,
                  color: EducanoColors.primaryBlue,
                  size: 19,
                ),
              ),
              SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Educano',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    'Responsável pelo Curso',
                    style: TextStyle(color: Colors.white70, fontSize: 9),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );

    return Container(
      padding: EdgeInsets.all(mobile ? 12 : 24),
      decoration: BoxDecoration(
        color: EducanoColors.primaryBlue,
        borderRadius: BorderRadius.circular(mobile ? 12 : 14),
      ),
      child: mobile
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: AspectRatio(aspectRatio: 1.65, child: image),
                ),
                const SizedBox(height: 12),
                details,
              ],
            )
          : Row(
              children: [
                SizedBox(
                  width: 300,
                  height: 200,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: image,
                  ),
                ),
                const SizedBox(width: 18),
                Expanded(child: details),
              ],
            ),
    );
  }
}

class _HeroMetric extends StatelessWidget {
  final IconData icon;
  final String label;

  const _HeroMetric({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 18, color: Colors.white),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _ProgressCard extends StatelessWidget {
  final Course course;
  final bool mobile;

  const _ProgressCard({required this.course, required this.mobile});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: mobile ? 0 : 24),
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 9),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFD4D4D4), width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Seu progresso',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 5),
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(7),
                  child: LinearProgressIndicator(
                    value: course.progress,
                    minHeight: 18,
                    backgroundColor: const Color(0xFFD9D9D9),
                    valueColor: const AlwaysStoppedAnimation(Color(0xFF20D500)),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                '${(course.progress * 100).round()}%',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          Text(
            'Você concluiu ${course.completedMaterials} de ${course.totalMaterials} materiais dessa trilha',
            style: const TextStyle(fontSize: 10, color: Colors.black54),
          ),
        ],
      ),
    );
  }
}

class _AboutCourse extends StatelessWidget {
  final Course course;
  final bool mobile;

  const _AboutCourse({required this.course, required this.mobile});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: mobile ? 2 : 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Sobre o Curso',
            style: TextStyle(
              fontSize: mobile ? 20 : 21,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            course.description,
            style: const TextStyle(color: Colors.black54, height: 1.25),
          ),
          const SizedBox(height: 12),
          const Text(
            'O Que o Curso Oferece:',
            style: TextStyle(color: Colors.black54),
          ),
          const SizedBox(height: 5),
          const Text(
            '• Aulas focadas: explicações diretas e resolução de exercícios das matérias que mais caem nas provas.\n'
            '• Redação nota 1000: treinamento prático com regras e correções detalhadas para o seu texto.\n'
            '• Simulados reais: provas de teste no mesmo estilo e tempo dos exames oficiais.\n'
            '• Apoio para os estudos: plantões de dúvidas e orientação para organizar sua rotina.',
            style: TextStyle(color: Colors.black54, height: 1.22),
          ),
        ],
      ),
    );
  }
}

class _ContentCard extends StatelessWidget {
  final Course course;
  final bool mobile;
  final int selectedSession;
  final ValueChanged<int> onSessionChanged;
  final VoidCallback onAddSession;
  final Future<void> Function(CourseSession) onAddModule;
  final Future<void> Function(CourseSession, CourseModule) onAddMaterial;
  final Future<void> Function(CourseSession, CourseModule) onToggleModule;
  final Future<void> Function(CourseSession, CourseModule, CourseMaterial)
  onOpenMaterial;

  const _ContentCard({
    required this.course,
    required this.mobile,
    required this.selectedSession,
    required this.onSessionChanged,
    required this.onAddSession,
    required this.onAddModule,
    required this.onAddMaterial,
    required this.onToggleModule,
    required this.onOpenMaterial,
  });

  @override
  Widget build(BuildContext context) {
    if (course.sessions.isEmpty) {
      return _EmptyState(
        text: 'Este curso ainda não possui sessões cadastradas.',
        buttonText: 'Adicionar sessão',
        onPressed: onAddSession,
      );
    }

    final session = course
        .sessions[selectedSession.clamp(0, course.sessions.length - 1).toInt()];

    return Container(
      padding: EdgeInsets.all(mobile ? 10 : 18),
      decoration: BoxDecoration(
        color: const Color(0xFFFAFFFD),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFD4D4D4), width: 1.2),
      ),
      child: Column(
        children: [
          _SessionTimeline(
            sessions: course.sessions,
            selected: selectedSession
                .clamp(0, course.sessions.length - 1)
                .toInt(),
            mobile: mobile,
            onChanged: onSessionChanged,
          ),
          const SizedBox(height: 18),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  '${session.title}: ${session.subtitle}',
                  style: TextStyle(
                    fontSize: mobile ? 18 : 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              _AddButton(
                label: 'Adicionar módulo',
                onPressed: () => onAddModule(session),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              session.description,
              style: const TextStyle(color: Colors.black54, height: 1.2),
            ),
          ),
          const SizedBox(height: 14),
          if (session.modules.isEmpty)
            _EmptyState(
              compact: true,
              text: 'Nenhum módulo cadastrado nesta sessão.',
              buttonText: 'Adicionar módulo',
              onPressed: () => onAddModule(session),
            )
          else
            ...session.modules.map(
              (module) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _ModuleCard(
                  session: session,
                  module: module,
                  mobile: mobile,
                  onToggle: () => onToggleModule(session, module),
                  onAddMaterial: () => onAddMaterial(session, module),
                  onOpenMaterial: onOpenMaterial,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _SessionTimeline extends StatelessWidget {
  final List<CourseSession> sessions;
  final int selected;
  final bool mobile;
  final ValueChanged<int> onChanged;

  const _SessionTimeline({
    required this.sessions,
    required this.selected,
    required this.mobile,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: mobile ? 94 : 84,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: sessions.length,
        separatorBuilder: (_, __) => const SizedBox(width: 0),
        itemBuilder: (context, index) {
          final active = index == selected;
          return SizedBox(
            width: mobile ? 92 : 150,
            child: InkWell(
              onTap: () => onChanged(index),
              borderRadius: BorderRadius.circular(12),
              child: Column(
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        if (index > 0)
                          Expanded(
                            child: Container(
                              height: 4,
                              color: index <= selected
                                  ? _green
                                  : Colors.grey.shade500,
                            ),
                          )
                        else
                          const Expanded(child: SizedBox()),
                        CircleAvatar(
                          radius: mobile ? 17 : 20,
                          backgroundColor: active
                              ? Colors.white
                              : (index < selected ? _green : Colors.white),
                          foregroundColor: active
                              ? EducanoColors.primaryBlue
                              : (index < selected
                                    ? Colors.white
                                    : Colors.black54),
                          child: active
                              ? Text(
                                  '${index + 1}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                  ),
                                )
                              : (index < selected
                                    ? const Icon(Icons.check_rounded, size: 19)
                                    : Text('${index + 1}')),
                        ),
                        if (index < sessions.length - 1)
                          Expanded(
                            child: Container(
                              height: 4,
                              color: index < selected
                                  ? _green
                                  : Colors.grey.shade500,
                            ),
                          )
                        else
                          const Expanded(child: SizedBox()),
                      ],
                    ),
                  ),
                  Text(
                    sessions[index].title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: mobile ? 11 : 13,
                    ),
                  ),
                  Text(
                    sessions[index].subtitle,
                    maxLines: 2,
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: mobile ? 8 : 10,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ModuleCard extends StatelessWidget {
  final CourseSession session;
  final CourseModule module;
  final bool mobile;
  final VoidCallback onToggle;
  final VoidCallback onAddMaterial;
  final Future<void> Function(CourseSession, CourseModule, CourseMaterial)
  onOpenMaterial;

  const _ModuleCard({
    required this.session,
    required this.module,
    required this.mobile,
    required this.onToggle,
    required this.onAddMaterial,
    required this.onOpenMaterial,
  });

  @override
  Widget build(BuildContext context) {
    final progress = module.progress;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      decoration: BoxDecoration(
        color: module.expanded ? Colors.white : const Color(0xFF20D500),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: module.expanded ? const Color(0xFF777777) : Colors.transparent,
          width: 1.3,
        ),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: onToggle,
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: mobile ? 12 : 16,
                vertical: 11,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      module.title,
                      style: TextStyle(
                        color: module.expanded ? Colors.black54 : Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: mobile ? 12 : 14,
                      ),
                    ),
                  ),
                  Icon(
                    module.expanded
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    color: module.expanded ? Colors.black54 : Colors.white,
                  ),
                ],
              ),
            ),
          ),
          if (module.expanded)
            Padding(
              padding: EdgeInsets.fromLTRB(
                mobile ? 12 : 18,
                0,
                mobile ? 12 : 18,
                14,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    module.description,
                    style: const TextStyle(
                      color: Colors.black54,
                      fontSize: 12,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: LinearProgressIndicator(
                            value: progress,
                            minHeight: 12,
                            backgroundColor: const Color(0xFFD9D9D9),
                            valueColor: const AlwaysStoppedAnimation(_green),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${(progress * 100).round()}%',
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  if (module.materials.isEmpty)
                    _EmptyState(
                      compact: true,
                      text: 'Nenhum material cadastrado.',
                      buttonText: 'Adicionar material',
                      onPressed: onAddMaterial,
                    )
                  else
                    ...module.materials.map(
                      (material) => _MaterialRow(
                        material: material,
                        mobile: mobile,
                        onTap: () => onOpenMaterial(session, module, material),
                      ),
                    ),
                  const SizedBox(height: 6),
                  _AddButton(
                    label: 'Adicionar material',
                    onPressed: onAddMaterial,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _MaterialRow extends StatelessWidget {
  final CourseMaterial material;
  final bool mobile;
  final VoidCallback onTap;

  const _MaterialRow({
    required this.material,
    required this.mobile,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 7),
        child: Row(
          children: [
            CircleAvatar(
              radius: mobile ? 15 : 17,
              backgroundColor: material.completed
                  ? _green.withValues(alpha: .15)
                  : Colors.grey.shade100,
              child: Icon(
                material.kind.icon,
                size: 18,
                color: material.completed ? _green : Colors.grey.shade600,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    material.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                  Text(
                    material.kindLabel,
                    style: const TextStyle(fontSize: 10, color: Colors.black45),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              material.metadataLabel,
              style: const TextStyle(fontSize: 10, color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }
}

class _AddButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const _AddButton({required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: const Icon(Icons.add_rounded, size: 17),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        foregroundColor: EducanoColors.primaryBlue,
        side: const BorderSide(color: EducanoColors.primaryBlue),
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 9),
        visualDensity: VisualDensity.compact,
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String text;
  final String buttonText;
  final VoidCallback onPressed;
  final bool compact;

  const _EmptyState({
    required this.text,
    required this.buttonText,
    required this.onPressed,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(compact ? 12 : 22),
      decoration: BoxDecoration(
        color: const Color(0xFFF7FAFF),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFD4D4D4)),
      ),
      child: compact
          ? Row(
              children: [
                const Expanded(
                  child: Text(
                    'Nenhum conteúdo cadastrado ainda.',
                    style: TextStyle(color: Colors.black54),
                  ),
                ),
                _AddButton(label: buttonText, onPressed: onPressed),
              ],
            )
          : Column(
              children: [
                const Icon(
                  Icons.layers_clear_rounded,
                  size: 38,
                  color: EducanoColors.primaryBlue,
                ),
                const SizedBox(height: 8),
                Text(
                  text,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.black54),
                ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: onPressed,
                  icon: const Icon(Icons.add_rounded),
                  label: Text(buttonText),
                ),
              ],
            ),
    );
  }

  
}
