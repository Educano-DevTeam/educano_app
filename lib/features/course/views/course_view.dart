import 'package:flutter/material.dart';

import '../../../core/theme/educano_colors.dart';
import '../../../services/api_client.dart';
import '../../../services/courses_service.dart';
import '../../../services/exams_service.dart';
import '../models/course_models.dart';
import '../widgets/course_editor_dialogs.dart';

import 'package:educano_app/core/navigation/app_routes.dart';
import 'package:educano_app/features/materials/models/material_route_args.dart';

const _green = Color(0xFF20D500);

bool _isSessionCompleted(CourseSession session) =>
    session.modules.isNotEmpty &&
    session.modules.every(
      (module) =>
          module.materials.isNotEmpty &&
          module.materials.every((material) => material.completed),
    );

class _RewardItem extends StatelessWidget {
  const _RewardItem({required this.emoji, required this.amount});
  final String emoji;
  final String amount;

  @override
  Widget build(BuildContext context) => Expanded(
    child: Column(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 44)),
        const SizedBox(height: 8),
        Text(
          amount,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        ),
      ],
    ),
  );
}

class CourseView extends StatefulWidget {
  final String courseId;

  const CourseView({super.key, required this.courseId});

  @override
  State<CourseView> createState() => _CourseViewState();
}

class _CourseViewState extends State<CourseView> {
  final _service = CoursesService.instance;
  Course? _course;
  String? _error;
  int _selectedSession = 0;
  bool _sessionChosen = false;
  bool _mutationBusy = false;
  String? _busySessionId;
  String? _busyModuleId;

  // Módulos abertos na tela (estado só visual).
  final Set<String> _expandedModules = {};

  @override
  void initState() {
    super.initState();
    _loadCourse();
  }

  Future<void> _loadCourse() async {
    try {
      final course = await _service.course(widget.courseId);
      if (!mounted) return;
      setState(() {
        _error = null;
        _course = _withExpanded(course);
        if (!_sessionChosen) _selectedSession = _firstPendingSession(course);
        if (course.sessions.isNotEmpty) {
          _selectedSession = _selectedSession
              .clamp(0, course.sessions.length - 1)
              .toInt();
        }
      });
    } on ApiException catch (error) {
      if (!mounted) return;
      setState(() => _error = error.message);
    }
  }

  /// Abre a sessão do primeiro material ainda não concluído.
  int _firstPendingSession(Course course) {
    for (var i = 0; i < course.sessions.length; i++) {
      final pending = course.sessions[i].modules.any(
        (m) => m.materials.any((material) => !material.completed),
      );
      if (pending) return i;
    }
    return 0;
  }

  Course _withExpanded(Course course) => course.copyWith(
    sessions: [
      for (final session in course.sessions)
        session.copyWith(
          modules: [
            for (final module in session.modules)
              module.copyWith(expanded: _expandedModules.contains(module.id)),
          ],
        ),
    ],
  );

  void _showMessage(String message, {bool error = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: error
            ? EducanoColors.error
            : EducanoColors.successGreen,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// Executa uma alteração na API e recarrega o curso.
  Future<void> _run(
    Future<void> Function() action,
    String success, {
    String? sessionId,
    String? moduleId,
  }) async {
    if (_mutationBusy) return;
    setState(() {
      _mutationBusy = true;
      _busySessionId = sessionId;
      _busyModuleId = moduleId;
    });
    try {
      await action();
      await _loadCourse();
      if (mounted) _showMessage(success);
    } on ApiException catch (error) {
      if (mounted) _showMessage(error.message, error: true);
    } finally {
      if (mounted) {
        setState(() {
          _mutationBusy = false;
          _busySessionId = null;
          _busyModuleId = null;
        });
      }
    }
  }

  Future<void> _runInSession(
    CourseSession session,
    Future<void> Function() action,
    String success,
  ) => _run(action, success, sessionId: session.id);

  Future<void> _runInModule(
    CourseSession session,
    CourseModule module,
    Future<void> Function() action,
    String success,
  ) => _run(action, success, sessionId: session.id, moduleId: module.id);

  Future<void> _enroll() async {
    await _run(
      () => _service.enroll(widget.courseId),
      'Inscrição realizada! Bons estudos.',
    );
  }

  Future<void> _addSession() async {
    final data = await showSessionEditor(context);
    if (data == null) return;

    await _run(
      () => _service.addSession(
        widget.courseId,
        title: data['title']!,
        subtitle: data['subtitle']!,
        description: data['description']!,
      ),
      'Trilha cadastrada.',
    );
    if (mounted && _course != null) {
      setState(() {
        _sessionChosen = true;
        _selectedSession = _course!.sessions.length - 1;
      });
    }
  }

  Future<void> _addModule(CourseSession session) async {
    final data = await showModuleEditor(context);
    if (data == null) return;

    await _runInSession(
      session,
      () => _service.addModule(
        widget.courseId,
        session.id,
        title: data['title']!,
        description: data['description']!,
      ),
      'Módulo cadastrado.',
    );
  }

  Future<void> _editSession(CourseSession session) async {
    final data = await showSessionEditor(context, session: session);
    if (data == null) return;
    await _runInSession(
      session,
      () => _service.updateSession(session.id, data),
      'Trilha atualizada.',
    );
  }

  Future<void> _deleteSession(CourseSession session) async {
    if (!await _confirmDelete(
      'Excluir trilha?',
      'Os módulos e materiais desta trilha também serão excluídos.',
    ))
      return;
    await _runInSession(
      session,
      () => _service.deleteSession(session.id),
      'Trilha excluída.',
    );
  }

  Future<void> _editModule(CourseSession session, CourseModule module) async {
    final data = await showModuleEditor(context, module: module);
    if (data == null) return;
    await _runInModule(
      session,
      module,
      () => _service.updateModule(module.id, data),
      'Módulo atualizado.',
    );
  }

  Future<void> _deleteModule(CourseSession session, CourseModule module) async {
    if (!await _confirmDelete(
      'Excluir módulo?',
      'As aulas e atividades deste módulo também serão excluídas.',
    ))
      return;
    await _runInModule(
      session,
      module,
      () => _service.deleteModule(module.id),
      'Módulo excluído.',
    );
  }

  Future<CourseMaterial> _loadActivityForEdit(
    CourseSession session,
    CourseModule module,
    CourseMaterial material,
  ) async {
    setState(() {
      _mutationBusy = true;
      _busySessionId = session.id;
      _busyModuleId = module.id;
    });
    try {
      return await _service.activityForEdit(material);
    } finally {
      if (mounted) {
        setState(() {
          _mutationBusy = false;
          _busySessionId = null;
          _busyModuleId = null;
        });
      }
    }
  }

  Future<void> _editMaterial(
    CourseSession session,
    CourseModule module,
    CourseMaterial material,
  ) async {
    try {
      final existing = material.kind == MaterialKind.activity
          ? await _loadActivityForEdit(session, module, material)
          : material;
      if (!mounted) return;
      final updated = await showMaterialEditor(context, material: existing);
      if (updated == null) return;
      if (material.kind == MaterialKind.activity) {
        await _runInModule(
          session,
          module,
          () => _service.updateActivity(material.id, updated),
          'Atividade atualizada.',
        );
      } else {
        await _runInModule(
          session,
          module,
          () => _service.updateLesson(material.id, updated),
          'Aula atualizada.',
        );
      }
    } on ApiException catch (error) {
      if (mounted) _showMessage(error.message, error: true);
    }
  }

  Future<void> _deleteMaterial(
    CourseSession session,
    CourseModule module,
    CourseMaterial material,
  ) async {
    if (!await _confirmDelete(
      'Excluir material?',
      'Esta ação não pode ser desfeita.',
    ))
      return;
    await _runInModule(
      session,
      module,
      () => material.kind == MaterialKind.activity
          ? _service.deleteActivity(material.id)
          : _service.deleteLesson(material.id),
      'Material excluído.',
    );
  }

  Future<bool> _confirmDelete(String title, String message) async =>
      await showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Excluir'),
            ),
          ],
        ),
      ) ==
      true;

  Future<void> _addMaterial(CourseSession session, CourseModule module) async {
    final material = await showMaterialEditor(context);
    if (material == null) return;

    _expandedModules.add(module.id);
    await _runInModule(
      session,
      module,
      () => _service.addMaterial(widget.courseId, module.id, material),
      'Material cadastrado.',
    );
  }

  void _toggleModule(CourseSession session, CourseModule module) {
    if (!_canAccessModule(session, module)) {
      _showMessage(
        'Conclua as aulas e atividades dos módulos anteriores para continuar.',
      );
      return;
    }
    setState(() {
      if (!_expandedModules.remove(module.id)) _expandedModules.add(module.id);
      _course = _withExpanded(_course!);
    });
  }

  bool _canAccessModule(CourseSession session, CourseModule module) {
    final course = _course;
    if (course == null || course.canEdit) return true;

    var foundTarget = false;
    for (final previousSession in course.sessions) {
      for (final previousModule in previousSession.modules) {
        if (previousSession.id == session.id &&
            previousModule.id == module.id) {
          foundTarget = true;
          break;
        }
        if (previousModule.materials.isNotEmpty &&
            previousModule.materials.any((material) => !material.completed)) {
          return false;
        }
      }
      if (foundTarget) break;
    }
    return foundTarget;
  }

  Future<void> _openMaterial(
    CourseSession session,
    CourseModule module,
    CourseMaterial material,
  ) async {
    if (!_canAccessModule(session, module)) {
      _showMessage(
        'Conclua as aulas e atividades dos módulos anteriores para continuar.',
      );
      return;
    }
    if (material.kind == MaterialKind.activity) {
      try {
        final exam = await ExamsService.instance.startActivity(material.id);
        if (!mounted) return;
        await Navigator.of(
          context,
        ).pushNamed(AppRoutes.activity, arguments: exam);
        await _loadCourse();
      } on ApiException catch (error) {
        if (mounted) _showMessage(error.message, error: true);
      }
      return;
    }
    final result = await Navigator.of(context).pushNamed(
      AppRoutes.material,
      arguments: MaterialRouteArgs(
        courseId: widget.courseId,
        sessionId: session.id,
        moduleId: module.id,
        materialId: material.id,
        materialUrl: material.fileUrl,
        materialKind: material.kind,
        title: material.title,
        description: material.description,
        completed: material.completed,
      ),
    );

    if (!mounted) return;
    if (result is Map<String, dynamic> &&
        ((result['xp'] as int? ?? 0) > 0 ||
            (result['moedas'] as int? ?? 0) > 0)) {
      await _showReward(result);
    }
    if (result == true || result is Map<String, dynamic>) await _loadCourse();
  }

  Future<void> _showReward(Map<String, dynamic> reward) async {
    final xp = reward['xp'] as int? ?? 0;
    final coins = reward['moedas'] as int? ?? 0;
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 360),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.celebration_rounded,
                  size: 42,
                  color: Color(0xFFFFC107),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Recompensas recebidas!',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    _RewardItem(emoji: '⚡', amount: '+$xp XP'),
                    const SizedBox(width: 12),
                    _RewardItem(emoji: '🪙', amount: '+$coins moedas'),
                  ],
                ),
                const SizedBox(height: 22),
                FilledButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('Continuar'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null && _course == null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_error!, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: _loadCourse,
              child: const Text('Tentar novamente'),
            ),
          ],
        ),
      );
    }
    return _course == null
        ? const Center(child: CircularProgressIndicator())
        : _buildCourse(context, _course!);
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
              if (!course.enrolled && !course.canEdit)
                _EnrollCard(mobile: mobile, onEnroll: _enroll)
              else
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
              IgnorePointer(
                ignoring: _mutationBusy,
                child: Stack(
                  children: [
                    _ContentCard(
                      course: course,
                      mobile: mobile,
                      selectedSession: _selectedSession,
                      busySessionId: _busySessionId,
                      busyModuleId: _busyModuleId,
                      onSessionChanged: (value) => setState(() {
                        _sessionChosen = true;
                        _selectedSession = value;
                      }),
                      // Só quem gerencia o curso vê as ações de cadastro.
                      onAddSession: course.canEdit ? _addSession : null,
                      onEditSession: course.canEdit ? _editSession : null,
                      onDeleteSession: course.canEdit ? _deleteSession : null,
                      onAddModule: course.canEdit ? _addModule : null,
                      onAddMaterial: course.canEdit ? _addMaterial : null,
                      onEditModule: course.canEdit ? _editModule : null,
                      onDeleteModule: course.canEdit ? _deleteModule : null,
                      onEditMaterial: course.canEdit ? _editMaterial : null,
                      onDeleteMaterial: course.canEdit ? _deleteMaterial : null,
                      onToggleModule: _toggleModule,
                      onOpenMaterial: _openMaterial,
                    ),
                    if (_mutationBusy &&
                        (_busySessionId == null ||
                            !course.sessions.any(
                              (session) => session.id == _busySessionId,
                            )) &&
                        _busyModuleId == null)
                      const Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        child: LinearProgressIndicator(),
                      ),
                  ],
                ),
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
    const foregroundColor = Colors.white;
    const secondaryForegroundColor = Colors.white;
    final coverIconBackground = Color.alphaBlend(
      course.color.withValues(alpha: 0.15),
      Colors.white,
    );
    final fallback = Container(
      color: coverIconBackground,
      alignment: Alignment.center,
      child: Icon(course.icon, color: course.color, size: 72),
    );
    final image = course.imageUrl == null
        ? fallback
        : Image.network(
            course.imageUrl!,
            fit: BoxFit.cover,
            webHtmlElementStrategy: WebHtmlElementStrategy.fallback,
            errorBuilder: (_, __, ___) => Container(
              color: coverIconBackground,
              alignment: Alignment.center,
              child: Icon(course.icon, color: course.color, size: 72),
            ),
          );
    Widget coverFrame(Widget child) => Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: course.color,
        borderRadius: BorderRadius.circular(10),
      ),
      child: ClipRRect(borderRadius: BorderRadius.circular(6), child: child),
    );

    final details = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          course.title,
          style: TextStyle(
            color: foregroundColor,
            fontSize: mobile ? 20 : 22,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          course.category,
          style: TextStyle(color: secondaryForegroundColor),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 14,
          runSpacing: 8,
          children: [
            _HeroMetric(
              icon: Icons.people_alt_rounded,
              label: '${course.enrolledCount} inscritos',
              foregroundColor: foregroundColor,
            ),
            _HeroMetric(
              icon: Icons.access_time_filled_rounded,
              label: course.duration,
              foregroundColor: foregroundColor,
            ),
            _HeroMetric(
              icon: Icons.menu_book_rounded,
              label: '${course.sessions.length} trilhas',
              foregroundColor: foregroundColor,
            ),
          ],
        ),
        const SizedBox(height: 10),
        Text(
          course.description,
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: secondaryForegroundColor,
            fontSize: 12.5,
            height: 1.25,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: coverIconBackground,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircleAvatar(
                radius: 15,
                backgroundColor: Colors.white,
                child: Icon(
                  Icons.school_rounded,
                  color: EducanoColors.primaryBlue,
                  size: 19,
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    course.creatorName ?? 'Educano',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Text(
                    'Responsável pelo Curso',
                    style: TextStyle(color: Colors.white, fontSize: 9),
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
        color: course.color,
        borderRadius: BorderRadius.circular(mobile ? 12 : 14),
      ),
      child: mobile
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                coverFrame(AspectRatio(aspectRatio: 1.65, child: image)),
                const SizedBox(height: 12),
                details,
              ],
            )
          : Row(
              children: [
                coverFrame(SizedBox(width: 300, height: 200, child: image)),
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
  final Color foregroundColor;

  const _HeroMetric({
    required this.icon,
    required this.label,
    required this.foregroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 18, color: foregroundColor),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(color: foregroundColor, fontWeight: FontWeight.w600),
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
        ],
      ),
    );
  }
}

class _ContentCard extends StatelessWidget {
  final Course course;
  final bool mobile;
  final int selectedSession;
  final String? busySessionId;
  final String? busyModuleId;
  final ValueChanged<int> onSessionChanged;
  final VoidCallback? onAddSession;
  final Future<void> Function(CourseSession)? onAddModule;
  final Future<void> Function(CourseSession)? onEditSession;
  final Future<void> Function(CourseSession)? onDeleteSession;
  final Future<void> Function(CourseSession, CourseModule)? onEditModule;
  final Future<void> Function(CourseSession, CourseModule)? onDeleteModule;
  final Future<void> Function(CourseSession, CourseModule, CourseMaterial)?
  onEditMaterial;
  final Future<void> Function(CourseSession, CourseModule, CourseMaterial)?
  onDeleteMaterial;
  final Future<void> Function(CourseSession, CourseModule)? onAddMaterial;
  final void Function(CourseSession, CourseModule) onToggleModule;
  final Future<void> Function(CourseSession, CourseModule, CourseMaterial)
  onOpenMaterial;

  const _ContentCard({
    required this.course,
    required this.mobile,
    required this.selectedSession,
    required this.busySessionId,
    required this.busyModuleId,
    required this.onSessionChanged,
    this.onAddSession,
    this.onAddModule,
    this.onEditSession,
    this.onDeleteSession,
    this.onEditModule,
    this.onDeleteModule,
    this.onEditMaterial,
    this.onDeleteMaterial,
    this.onAddMaterial,
    required this.onToggleModule,
    required this.onOpenMaterial,
  });

  @override
  Widget build(BuildContext context) {
    if (course.sessions.isEmpty) {
      return _EmptyState(
        text: 'Este curso ainda não possui trilhas cadastradas.',
        buttonText: 'Adicionar trilha',
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
            onAddSession: onAddSession,
          ),
          if (busySessionId == session.id &&
              (busyModuleId == null ||
                  !session.modules.any(
                    (module) => module.id == busyModuleId,
                  ))) ...[
            const SizedBox(height: 8),
            const LinearProgressIndicator(),
          ],
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
              if (onEditSession != null)
                IconButton(
                  tooltip: 'Editar trilha',
                  onPressed: () => onEditSession!(session),
                  icon: const Icon(Icons.edit_outlined),
                ),
              if (onDeleteSession != null)
                IconButton(
                  tooltip: 'Excluir trilha',
                  onPressed: () => onDeleteSession!(session),
                  icon: const Icon(
                    Icons.delete_outline,
                    color: Colors.redAccent,
                  ),
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
              text: 'Nenhum módulo cadastrado nesta trilha.',
              buttonText: 'Adicionar módulo',
              onPressed: onAddModule == null
                  ? null
                  : () => onAddModule!(session),
            )
          else
            ...session.modules.map(
              (module) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _ModuleCard(
                  session: session,
                  module: module,
                  mobile: mobile,
                  isLoading: busyModuleId == module.id,
                  onToggle: () => onToggleModule(session, module),
                  onAddMaterial: onAddMaterial == null
                      ? null
                      : () => onAddMaterial!(session, module),
                  onEditModule: onEditModule == null
                      ? null
                      : () => onEditModule!(session, module),
                  onDeleteModule: onDeleteModule == null
                      ? null
                      : () => onDeleteModule!(session, module),
                  onOpenMaterial: onOpenMaterial,
                  onEditMaterial: onEditMaterial == null
                      ? null
                      : (material) =>
                            onEditMaterial!(session, module, material),
                  onDeleteMaterial: onDeleteMaterial == null
                      ? null
                      : (material) =>
                            onDeleteMaterial!(session, module, material),
                ),
              ),
            ),
          if (session.modules.isNotEmpty)
            Align(
              alignment: Alignment.centerRight,
              child: _AddButton(
                label: 'Adicionar módulo',
                onPressed: onAddModule == null
                    ? null
                    : () => onAddModule!(session),
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
  final VoidCallback? onAddSession;

  const _SessionTimeline({
    required this.sessions,
    required this.selected,
    required this.mobile,
    required this.onChanged,
    required this.onAddSession,
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
          final completed = _isSessionCompleted(sessions[index]);
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
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: active
                                ? Border.all(
                                    color: EducanoColors.primaryBlue,
                                    width: 2,
                                  )
                                : null,
                          ),
                          padding: active ? const EdgeInsets.all(2) : null,
                          child: CircleAvatar(
                            radius: mobile ? 17 : 20,
                            backgroundColor: completed ? _green : Colors.white,
                            foregroundColor: completed
                                ? Colors.white
                                : Colors.black,
                            child: Text(
                              '${index + 1}',
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                        if (active && onAddSession != null) ...[
                          const SizedBox(width: 4),
                          InkWell(
                            onTap: onAddSession,
                            customBorder: const CircleBorder(),
                            child: CircleAvatar(
                              radius: mobile ? 14 : 16,
                              backgroundColor: Colors.white,
                              child: const Icon(
                                Icons.add_rounded,
                                size: 19,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ],
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
  final bool isLoading;
  final VoidCallback onToggle;
  final VoidCallback? onAddMaterial;
  final VoidCallback? onEditModule;
  final VoidCallback? onDeleteModule;
  final ValueChanged<CourseMaterial>? onEditMaterial;
  final ValueChanged<CourseMaterial>? onDeleteMaterial;
  final Future<void> Function(CourseSession, CourseModule, CourseMaterial)
  onOpenMaterial;

  const _ModuleCard({
    required this.session,
    required this.module,
    required this.mobile,
    required this.isLoading,
    required this.onToggle,
    this.onAddMaterial,
    this.onEditModule,
    this.onDeleteModule,
    this.onEditMaterial,
    this.onDeleteMaterial,
    required this.onOpenMaterial,
  });

  @override
  Widget build(BuildContext context) {
    final progress = module.progress;
    final completed = module.materials.isNotEmpty && progress >= 1;
    final foreground = completed ? Colors.white : Colors.black;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      decoration: BoxDecoration(
        color: completed ? _green : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFD4D4D4), width: 1.3),
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
                        color: foreground,
                        fontWeight: FontWeight.w700,
                        fontSize: mobile ? 12 : 14,
                      ),
                    ),
                  ),
                  if (onEditModule != null)
                    IconButton(
                      tooltip: 'Editar módulo',
                      onPressed: onEditModule,
                      icon: Icon(
                        Icons.edit_outlined,
                        size: 18,
                        color: foreground,
                      ),
                    ),
                  if (onDeleteModule != null)
                    IconButton(
                      tooltip: 'Excluir módulo',
                      onPressed: onDeleteModule,
                      icon: Icon(
                        Icons.delete_outline,
                        size: 18,
                        color: completed ? Colors.white : Colors.redAccent,
                      ),
                    ),
                  Icon(
                    module.expanded
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    color: foreground,
                  ),
                ],
              ),
            ),
          ),
          if (isLoading)
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 0, 16, 10),
              child: LinearProgressIndicator(),
            ),
          if (module.expanded)
            Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(12),
                ),
              ),
              child: Padding(
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
                    else ...[
                      ...module.materials.map(
                        (material) => _MaterialRow(
                          material: material,
                          mobile: mobile,
                          onTap: () =>
                              onOpenMaterial(session, module, material),
                          onEdit: onEditMaterial == null
                              ? null
                              : () => onEditMaterial!(material),
                          onDelete: onDeleteMaterial == null
                              ? null
                              : () => onDeleteMaterial!(material),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Align(
                        alignment: Alignment.centerRight,
                        child: _AddButton(
                          label: 'Adicionar material',
                          onPressed: onAddMaterial,
                        ),
                      ),
                    ],
                  ],
                ),
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
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const _MaterialRow({
    required this.material,
    required this.mobile,
    required this.onTap,
    this.onEdit,
    this.onDelete,
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
            if (onEdit != null)
              IconButton(
                tooltip: 'Editar material',
                visualDensity: VisualDensity.compact,
                onPressed: onEdit,
                icon: const Icon(Icons.edit_outlined, size: 17),
              ),
            if (onDelete != null)
              IconButton(
                tooltip: 'Excluir material',
                visualDensity: VisualDensity.compact,
                onPressed: onDelete,
                icon: const Icon(
                  Icons.delete_outline,
                  size: 17,
                  color: Colors.redAccent,
                ),
              ),
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
  final VoidCallback? onPressed;

  const _AddButton({required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    // Sem ação (usuário sem permissão de edição), o botão não aparece.
    if (onPressed == null) return const SizedBox.shrink();
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
  final VoidCallback? onPressed;
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
                Expanded(
                  child: Text(
                    text,
                    style: const TextStyle(color: Colors.black54),
                  ),
                ),
                if (buttonText.isNotEmpty)
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
                if (onPressed != null) ...[
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: onPressed,
                    icon: const Icon(Icons.add_rounded),
                    label: Text(buttonText),
                  ),
                ],
              ],
            ),
    );
  }
}

/// Convite para alunos que ainda não estão inscritos no curso.
class _EnrollCard extends StatelessWidget {
  final bool mobile;
  final VoidCallback onEnroll;

  const _EnrollCard({required this.mobile, required this.onEnroll});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: mobile ? 0 : 24),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFD4D4D4), width: 1.2),
      ),
      child: Row(
        children: [
          const Expanded(
            child: Text(
              'Inscreva-se para acessar os materiais e registrar seu progresso.',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(width: 12),
          ElevatedButton.icon(
            onPressed: onEnroll,
            icon: const Icon(Icons.how_to_reg_rounded),
            label: const Text('Inscrever-se'),
          ),
        ],
      ),
    );
  }
}
