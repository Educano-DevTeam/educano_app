import '../models/course_models.dart';

class CourseLocalRepository {
  CourseLocalRepository._();
  static final CourseLocalRepository instance = CourseLocalRepository._();

  final Map<String, Course> _courses = {'vestibular-2026': _seedCourse()};

  Future<Course?> getCourse(String id) async => _courses[id];

  Future<void> saveCourse(Course course) async => _courses[course.id] = course;

  Future<Course?> addSession({
    required String courseId,
    required String title,
    required String subtitle,
    required String description,
  }) async {
    final course = _courses[courseId];
    if (course == null) return null;
    final session = CourseSession(
      id: 'session-${DateTime.now().microsecondsSinceEpoch}',
      title: title,
      subtitle: subtitle,
      description: description,
      modules: const [],
    );
    final updated = course.copyWith(sessions: [...course.sessions, session]);
    await saveCourse(updated);
    return updated;
  }

  Future<Course?> addModule({
    required String courseId,
    required String sessionId,
    required String title,
    required String description,
  }) async {
    final course = _courses[courseId];
    if (course == null) return null;
    final sessions = course.sessions.map((session) {
      if (session.id != sessionId) return session;
      final module = CourseModule(
        id: 'module-${DateTime.now().microsecondsSinceEpoch}',
        title: title,
        description: description,
        materials: const [],
      );
      return session.copyWith(modules: [...session.modules, module]);
    }).toList();
    final updated = course.copyWith(sessions: sessions);
    await saveCourse(updated);
    return updated;
  }

  Future<Course?> toggleModule({
    required String courseId,
    required String sessionId,
    required String moduleId,
  }) async {
    final course = _courses[courseId];
    if (course == null) return null;
    final sessions = course.sessions.map((session) {
      if (session.id != sessionId) return session;
      return session.copyWith(
        modules: session.modules.map((module) {
          if (module.id != moduleId) return module;
          return module.copyWith(expanded: !module.expanded);
        }).toList(),
      );
    }).toList();
    final updated = course.copyWith(sessions: sessions);
    await saveCourse(updated);
    return updated;
  }

  Future<Course?> addMaterial({
    required String courseId,
    required String sessionId,
    required String moduleId,
    required CourseMaterial material,
  }) async {
    final course = _courses[courseId];
    if (course == null) return null;
    final sessions = course.sessions.map((session) {
      if (session.id != sessionId) return session;
      return session.copyWith(
        modules: session.modules.map((module) {
          if (module.id != moduleId) return module;
          return module.copyWith(
            materials: [...module.materials, material],
            expanded: true,
          );
        }).toList(),
      );
    }).toList();
    final updated = course.copyWith(sessions: sessions);
    await saveCourse(updated);
    return updated;
  }

  Future<Course?> markMaterialCompleted({
    required String courseId,
    required String sessionId,
    required String moduleId,
    required String materialId,
  }) async {
    final course = _courses[courseId];
    if (course == null) return null;

    final sessions = course.sessions.map((session) {
      if (session.id != sessionId) return session;

      return session.copyWith(
        modules: session.modules.map((module) {
          if (module.id != moduleId) return module;

          return module.copyWith(
            materials: module.materials.map((material) {
              if (material.id != materialId) return material;
              return material.copyWith(completed: true);
            }).toList(),
          );
        }).toList(),
      );
    }).toList();

    final allMaterials = [
      for (final session in sessions)
        for (final module in session.modules)
          ...module.materials,
    ];
    final completed = allMaterials.where((m) => m.completed).length;
    final total = allMaterials.length;

    final updated = course.copyWith(
      sessions: sessions,
      completedMaterials: completed,
      totalMaterials: total,
      progress: total == 0 ? 0 : completed / total,
    );

    await saveCourse(updated);
    return updated;
  }
}

Course _seedCourse() {
  return Course(
    id: 'vestibular-2026',
    title: 'Vestibular 2026 - Curso Preparatório',
    category: 'Multidisciplinar',
    duration: '75 horas',
    description:
        'Este curso preparatório completo para o vestibular oferece aulas diárias, '
        'material didático atualizado, simulados semanais e suporte para organizar a rotina.',
    imageAsset: 'assets/home/course_vestibular.png',
    progress: .72,
    completedMaterials: 42,
    totalMaterials: 50,
    sessions: [
      CourseSession(
        id: 'session-1',
        title: 'Linguagens',
        subtitle: 'Do Português Básico ao Inglês Avançado',
        description: 'Fundamentos de linguagem, interpretação, gramática e produção textual.',
        modules: [
          CourseModule(
            id: 'module-1-1',
            title: 'Módulo 1: Interpretação de Texto',
            description: 'Leitura, contexto e identificação de ideias principais.',
            materials: [
              CourseMaterial(
                id: 'material-1-1-1',
                kind: MaterialKind.video,
                title: 'Introdução: interpretação',
                description: 'Aula introdutória em vídeo.',
                durationSeconds: 24 * 60 + 18,
              ),
            ],
          ),
        ],
      ),
      CourseSession(
        id: 'session-2',
        title: 'Exatas',
        subtitle: 'Matemática na Prática',
        description: 'Matemática aplicada às questões mais recorrentes dos vestibulares.',
        modules: [
          CourseModule(
            id: 'module-2-1',
            title: 'Módulo 1: Fundamentos',
            description: 'Operações, proporções e resolução de problemas.',
            materials: const [],
          ),
        ],
      ),
      CourseSession(
        id: 'session-3',
        title: 'C. Humanas',
        subtitle: '500 anos de História',
        description:
            'O módulo de ciências humanas integra História, Geografia, Sociologia e Filosofia.',
        modules: [
          CourseModule(
            id: 'module-3-1',
            title: 'Módulo 1: O Tratado de Tordesilhas',
            description: 'Conteúdo e atividades sobre O Tratado de Tordesilhas.',
            materials: const [],
          ),
          CourseModule(
            id: 'module-3-2',
            title: 'Módulo 2: Primeiras fundações',
            description: 'Conteúdo e atividades sobre as primeiras fundações.',
            materials: const [],
          ),
          CourseModule(
            id: 'module-3-3',
            title: 'Módulo 3: Brasil Colônia',
            description: 'Conteúdo e atividades sobre o Brasil Colônia.',
            materials: const [],
          ),
          CourseModule(
            id: 'module-3-4',
            title: 'Módulo 4: Pequeno Gigante',
            description: 'Conteúdo e atividades sobre o Pequeno Gigante.',
            materials: const [],
          ),
          CourseModule(
            id: 'module-3-5',
            title: 'Módulo 5: Independência ou Morte!',
            description: 'Conteúdo e atividades sobre a Independência.',
            materials: const [],
          ),
          CourseModule(
            id: 'module-3-6',
            title: 'Módulo 6: Ordem e Progresso',
            description: 'Conteúdo e atividades sobre a República.',
            materials: const [],
          ),
          CourseModule(
            id: 'module-3-7',
            title: 'Módulo 7: Ditadura Militar',
            description: 'Período autoritário brasileiro e seus principais acontecimentos.',
            expanded: true,
            materials: [
              CourseMaterial(
                id: 'm-3-7-1',
                kind: MaterialKind.video,
                title: 'Introdução: Jango',
                description: 'Aula em vídeo.',
                durationSeconds: 35 * 60 + 17,
                completed: true,
              ),
              CourseMaterial(
                id: 'm-3-7-2',
                kind: MaterialKind.pdf,
                title: 'O Golpe de 1º de Abril',
                description: 'Material em PDF.',
                fileName: 'golpe-1-abril.pdf',
                fileSizeBytes: 4 * 1024 * 1024,
              ),
              CourseMaterial(
                id: 'm-3-7-3',
                kind: MaterialKind.audio,
                title: 'Atos Institucionais (AI)',
                description: 'Áudio complementar.',
                durationSeconds: 21 * 60 + 12,
              ),
              CourseMaterial(
                id: 'm-3-7-4',
                kind: MaterialKind.activity,
                title: 'Questões de Prática',
                description: 'Atividade com questões do módulo.',
                activity: Activity(
                  theme: 'Ditadura Militar',
                  durationMinutes: 15,
                  questions: const [],
                ),
              ),
            ],
          ),
        ],
      ),
      CourseSession(
        id: 'session-4',
        title: 'C. Naturais',
        subtitle: 'Elementos, Cálculo e Animais',
        description: 'Biologia, Química e Física com foco nos assuntos mais cobrados.',
        modules: const [],
      ),
    ],
  );
}
