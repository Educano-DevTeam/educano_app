import 'dart:typed_data';

import '../core/utils/api_mappers.dart';
import '../features/course/models/course_models.dart';
import '../features/dashboard/views/material_editor_view.dart' as editor;
import 'api_client.dart';
import 'storage_service.dart';

class CourseListResult {
  final List<Map<String, dynamic>> courses;
  final List<String> categories;
  final Map<String, int> stats;

  const CourseListResult({
    required this.courses,
    required this.categories,
    required this.stats,
  });
}

/// Link temporário para abrir o arquivo de um material.
class MaterialAccess {
  final String url;
  final String downloadUrl;
  final String fileName;
  final String mimeType;

  const MaterialAccess({
    required this.url,
    required this.downloadUrl,
    required this.fileName,
    required this.mimeType,
  });
}

/// Cursos, sessões, módulos, aulas, atividades e inscrições na API.
class CoursesService {
  CoursesService._();

  static final CoursesService instance = CoursesService._();

  final _api = ApiClient.instance;

  static final _uuid = RegExp(
    r'^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$',
    caseSensitive: false,
  );

  static bool _isApiId(Object? id) => id is String && _uuid.hasMatch(id);

  // ---------------------------------------------------------------------------
  // Listagem e detalhe
  // ---------------------------------------------------------------------------

  /// Lista os cursos visíveis ao usuário (a API pagina de 20 em 20).
  Future<CourseListResult> list({
    String? search,
    String? category,
    String? status,
  }) async {
    final courses = <Map<String, dynamic>>[];
    Map<String, dynamic> stats = const {};
    int? page = 1;

    while (page != null) {
      final data = await _api.get('/courses', query: {
        'pagina': page,
        'nome': search,
        'categoria': category,
        'status': status,
      }) as Map<String, dynamic>;

      courses.addAll(
        (data['dados'] as List).cast<Map<String, dynamic>>().map(listMap),
      );
      stats = data['estatisticas'] as Map<String, dynamic>;
      page = (data['paginacao'] as Map<String, dynamic>)['proximaPagina'] as int?;
    }

    return CourseListResult(
      courses: courses,
      categories: ApiMappers.courseCategories.values.toList(),
      stats: stats.map((key, value) => MapEntry(key, (value as num).toInt())),
    );
  }

  /// Formato usado pelas listagens de cursos (dashboard e catálogo).
  static Map<String, dynamic> listMap(Map<String, dynamic> api) {
    final content = api['conteudo'] as Map<String, dynamic>? ?? const {};
    final price = ApiMappers.number(api['preco']) ?? 0;
    final turma = api['turma'] ?? (api['inscricao'] as Map?)?['turma'];

    return {
      'id': api['id'],
      'name': api['nome'],
      'category': ApiMappers.categoryLabel(api['categoria'] as String?),
      'description': api['descricao'] ?? '',
      'enrolled': api['inscritos'] ?? 0,
      // Sem limite de vagas a API devolve null.
      'capacity': api['vagas'] as int?,
      'status': ApiMappers.courseStatusLabel(api['status'] as String?),
      'createdAt': ApiMappers.formatDate(api['criadoEm']),
      'icon': ApiMappers.coverIcon(api['iconeCapa'] as String?),
      'color': ApiMappers.color(api['cor'] as String?),
      'idCapa': api['idCapa'],
      'imageUrl': ApiMappers.mediaUrl(api['idCapa'] as String?) ?? '',
      'price': price,
      'premium': price > 0,
      'isEnrolled': api['inscrito'] == true,
      'turma': ApiMappers.turmas[turma],
      'canEdit': api['podeEditar'] == true,
      'contentSummary': {
        'trilhas': content['sessoes'] ?? 0,
        'modulos': content['modulos'] ?? 0,
        'materiais': content['aulas'] ?? 0,
      },
    };
  }

  /// Curso com sessões, módulos, conteúdos e o progresso do usuário.
  Future<Map<String, dynamic>> detail(String id) async =>
      await _api.get('/courses/$id/estrutura') as Map<String, dynamic>;

  /// Detalhe do curso no modelo usado pela página do curso.
  Future<Course> course(String id) async => courseFromApi(await detail(id));

  static String _workload(int minutes) {
    if (minutes <= 0) return 'Carga horária livre';
    if (minutes < 60) return '$minutes min';
    final hours = (minutes / 60).round();
    return hours == 1 ? '1 hora' : '$hours horas';
  }

  static Course courseFromApi(Map<String, dynamic> data) {
    final api = data['curso'] as Map<String, dynamic>;
    final progress = api['progresso'] as Map<String, dynamic>;
    final creator = api['responsavel'] as Map<String, dynamic>?;

    return Course(
      id: api['id'] as String,
      title: api['nome'] as String,
      category: ApiMappers.categoryLabel(api['categoria'] as String?),
      duration: _workload(api['cargaHorariaMinutos'] as int? ?? 0),
      description: api['descricao'] as String? ?? '',
      imageAsset: 'lib/assets/courses/vestibular_course_image.jpg',
      imageUrl: ApiMappers.mediaUrl(api['idCapa'] as String?),
      progress: (progress['percentual'] as num).toDouble(),
      completedMaterials: progress['concluidos'] as int,
      totalMaterials: progress['totalConteudos'] as int,
      canEdit: api['podeEditar'] == true,
      enrolled: api['inscrito'] == true,
      enrolledCount: api['inscritos'] as int? ?? 0,
      creatorName: creator?['nome'] as String?,
      status: api['status'] as String? ?? 'ATIVO',
      sessions: [
        for (final sessao in (data['sessoes'] as List).cast<Map<String, dynamic>>())
          CourseSession(
            id: sessao['id'] as String,
            title: sessao['titulo'] as String,
            subtitle: sessao['subtitulo'] as String? ?? '',
            description: sessao['descricao'] as String? ?? '',
            modules: [
              for (final modulo in (sessao['modulos'] as List).cast<Map<String, dynamic>>())
                CourseModule(
                  id: modulo['id'] as String,
                  title: modulo['titulo'] as String,
                  description: modulo['descricao'] as String? ?? '',
                  materials: [
                    for (final conteudo in (modulo['conteudos'] as List).cast<Map<String, dynamic>>())
                      _materialFromApi(conteudo),
                  ],
                ),
            ],
          ),
      ],
    );
  }

  static CourseMaterial _materialFromApi(Map<String, dynamic> api) {
    final kind = ApiMappers.materialKind(api['tipo'] as String?);
    final file = api['arquivo'] as Map<String, dynamic>?;
    final minutes = api['duracaoMinutos'] as int?;

    return CourseMaterial(
      id: api['id'] as String,
      kind: kind,
      title: api['titulo'] as String,
      description: api['descricao'] as String? ?? '',
      fileName: file?['nomeOriginal'] as String?,
      fileSizeBytes: ApiMappers.number(file?['tamanhoBytes'])?.toInt(),
      durationSeconds: minutes == null || minutes == 0 ? null : minutes * 60,
      completed: api['concluido'] == true,
      activity: kind == MaterialKind.activity
          ? Activity(
              theme: api['titulo'] as String,
              durationMinutes: api['tempoMinutos'] as int? ?? 0,
              questions: const [],
              questionCount: api['totalQuestoes'] as int? ?? 0,
              questionIds: (api['idsQuestoes'] as List? ?? const []).cast<String>(),
            )
          : null,
    );
  }

  // ---------------------------------------------------------------------------
  // Editor do dashboard
  // ---------------------------------------------------------------------------

  static editor.MaterialKind? _editorKind(String? tipo) => switch (tipo) {
    'PDF' || 'DOCUMENTO' => editor.MaterialKind.pdf,
    'VIDEO' => editor.MaterialKind.video,
    'AUDIO' => editor.MaterialKind.audio,
    _ => null,
  };

  static String _editorType(editor.MaterialKind kind) => switch (kind) {
    editor.MaterialKind.pdf => 'PDF',
    editor.MaterialKind.video => 'VIDEO',
    editor.MaterialKind.audio => 'AUDIO',
  };

  /// Converte a estrutura do curso no mapa usado pelo editor do dashboard.
  static Map<String, dynamic> editorMap(Map<String, dynamic> data) => {
    ...listMap(data['curso'] as Map<String, dynamic>),
    'iconKey': (data['curso'] as Map<String, dynamic>)['iconeCapa'],
    'trilhas': [
      for (final sessao in (data['sessoes'] as List).cast<Map<String, dynamic>>())
        <String, dynamic>{
          'id': sessao['id'],
          'title': sessao['titulo'],
          'subtitle': sessao['subtitulo'] ?? '',
          'description': sessao['descricao'] ?? '',
          'modulos': <Map<String, dynamic>>[
            for (final modulo in (sessao['modulos'] as List).cast<Map<String, dynamic>>())
              <String, dynamic>{
                'id': modulo['id'],
                'title': modulo['titulo'],
                'description': modulo['descricao'] ?? '',
                'licao': <String, dynamic>{
                  'title': modulo['licaoTitulo'] ?? '',
                  'xp': modulo['xp'] ?? 0,
                },
                'materiais': <Map<String, dynamic>>[
                  for (final conteudo in (modulo['conteudos'] as List).cast<Map<String, dynamic>>())
                    _editorMaterial(conteudo),
                ],
              },
          ],
        },
    ],
  };

  static Map<String, dynamic> _editorMaterial(Map<String, dynamic> api) {
    final file = api['arquivo'] as Map<String, dynamic>?;
    final kind = _editorKind(api['tipo'] as String?);
    final minutes = api['duracaoMinutos'] as int?;

    return <String, dynamic>{
      'id': api['id'],
      'tipo': api['tipo'],
      'name': api['titulo'],
      'description': api['descricao'] ?? '',
      'type': ?kind,
      if (kind != null) 'icon': kind.icon,
      if (file != null) 'idArquivo': file['id'],
      if (file != null) 'fileName': file['nomeOriginal'],
      if (file != null) 'fileSize': ApiMappers.fileSize(ApiMappers.number(file['tamanhoBytes'])),
      if (minutes != null && minutes > 0) 'duration': ApiMappers.duration(minutes * 60),
      if (api['quantidadePaginas'] != null) 'quantidadePaginas': api['quantidadePaginas'],
      // Atividades são preservadas como estão ao salvar pelo dashboard.
      if (api['tipo'] == 'ATIVIDADE') ...{
        'tempoMinutos': api['tempoMinutos'],
        'idsQuestoes': api['idsQuestoes'] ?? const <String>[],
        'totalQuestoes': api['totalQuestoes'] ?? 0,
      },
    };
  }

  /// Dados do curso (sem a estrutura) a partir do mapa do editor.
  static Map<String, dynamic> coursePayload(Map<String, dynamic> map) {
    final keepImage = map['idCapa'] != null && map['iconChanged'] != true;

    return {
      'nome': map['name'],
      'descricao': map['description'] ?? '',
      'categoria': ApiMappers.categoryValue(map['category'] as String),
      'vagas': map['capacity'],
      'cor': ApiMappers.hex(map['color']),
      // Sem trocar o ícone, a imagem de capa já enviada é mantida.
      if (!keepImage) 'capa': ApiMappers.coverIconKey(map['icon']),
    };
  }

  /// Sessões, módulos e conteúdos no formato de PUT /courses/:id/estrutura.
  static Map<String, dynamic> structurePayload(Map<String, dynamic> map) {
    String? id(Object? value) => _isApiId(value) ? value as String : null;

    return {
      'sessoes': [
        for (final trilha in (map['trilhas'] as List? ?? const []).cast<Map<String, dynamic>>())
          {
            if (id(trilha['id']) != null) 'id': id(trilha['id']),
            'titulo': trilha['title'],
            'subtitulo': trilha['subtitle'] ?? '',
            'descricao': trilha['description'] ?? '',
            'modulos': [
              for (final modulo in (trilha['modulos'] as List).cast<Map<String, dynamic>>())
                {
                  if (id(modulo['id']) != null) 'id': id(modulo['id']),
                  'titulo': modulo['title'],
                  'descricao': modulo['description'] ?? '',
                  'licaoTitulo': (modulo['licao'] as Map?)?['title'] ?? '',
                  'xp': (modulo['licao'] as Map?)?['xp'] ?? 0,
                  'conteudos': [
                    for (final material in (modulo['materiais'] as List).cast<Map<String, dynamic>>())
                      _contentPayload(material, id(material['id'])),
                  ],
                },
            ],
          },
      ],
    };
  }

  static Map<String, dynamic> _contentPayload(
    Map<String, dynamic> material,
    String? id,
  ) {
    if (material['tipo'] == 'ATIVIDADE') {
      return {
        'id': ?id,
        'tipo': 'ATIVIDADE',
        'titulo': material['name'],
        if (material['tempoMinutos'] != null) 'tempoMinutos': material['tempoMinutos'],
        'idsQuestoes': material['idsQuestoes'] ?? const <String>[],
      };
    }

    final kind = material['type'] as editor.MaterialKind? ?? editor.MaterialKind.pdf;
    final seconds = ApiMappers.parseDuration(material['duration'] as String?);
    // Documentos já cadastrados continuam com o tipo original.
    final type = material['tipo'] == 'DOCUMENTO' && kind == editor.MaterialKind.pdf
        ? 'DOCUMENTO'
        : _editorType(kind);

    return {
      'id': ?id,
      'tipo': type,
      'titulo': material['name'],
      'descricao': material['description'] ?? '',
      if (material['idArquivo'] != null) 'idArquivo': material['idArquivo'],
      if (seconds != null) 'duracaoMinutos': (seconds / 60).ceil(),
      if (material['quantidadePaginas'] != null) 'quantidadePaginas': material['quantidadePaginas'],
    };
  }

  /// Salva o curso do editor (cria quando não há id) e devolve o mapa salvo.
  Future<Map<String, dynamic>> saveFromEditor(Map<String, dynamic> map) async {
    final user = await StorageService.instance.loadCurrentUser();
    final isAdmin = user?.isAdmin ?? false;
    final status = ApiMappers.courseStatusValue(map['status'] as String? ?? 'Rascunho');
    final payload = coursePayload(map);

    Map<String, dynamic> saved;
    if (_isApiId(map['id'])) {
      final changedStatus = status != ApiMappers.courseStatusValue(
        map['originalStatus'] as String? ?? 'Rascunho',
      );
      saved = (await _api.patch('/courses/${map['id']}', {
        ...payload,
        // Somente administradores alteram o status do curso.
        if (isAdmin && changedStatus) 'status': status,
      }) as Map<String, dynamic>)['curso'] as Map<String, dynamic>;
    } else {
      saved = (await _api.post('/courses', payload) as Map<String, dynamic>)['curso']
          as Map<String, dynamic>;
      // O curso nasce como rascunho ou inativo; a ativação vem em seguida.
      if (isAdmin && saved['status'] != status) {
        await _api.patch('/courses/${saved['id']}', {'status': status});
      }
    }

    final data = await _api.put(
      '/courses/${saved['id']}/estrutura',
      structurePayload(map),
    ) as Map<String, dynamic>;
    return editorMap(data);
  }

  Future<void> delete(String id) => _api.delete('/courses/$id');

  // ---------------------------------------------------------------------------
  // Estrutura item a item (página do curso)
  // ---------------------------------------------------------------------------

  Future<void> addSession(
    String courseId, {
    required String title,
    required String subtitle,
    required String description,
  }) => _api.post('/sessions', {
    'idCurso': courseId,
    'titulo': title,
    'subtitulo': subtitle,
    'descricao': description,
  });

  Future<void> addModule(
    String courseId,
    String sessionId, {
    required String title,
    required String description,
  }) => _api.post('/modules', {
    'idSessao': sessionId,
    'titulo': title,
    'descricao': description,
  });

  /// Cadastra uma aula (o arquivo é enviado antes ao storage) ou atividade.
  Future<void> addMaterial(
    String courseId,
    String moduleId,
    CourseMaterial material,
  ) async {
    final activity = material.activity;

    if (material.kind == MaterialKind.activity && activity != null) {
      await _api.post('/tests', {
        'idModulo': moduleId,
        'titulo': activity.theme.isNotEmpty ? activity.theme : material.title,
        if (activity.durationMinutes > 0) 'tempoMinutos': activity.durationMinutes,
        'idsQuestoes': activity.questionIds.isNotEmpty
            ? activity.questionIds
            : activity.questions.map((q) => q.id).toList(),
      });
      return;
    }

    final bytes = material.fileBytes;
    if (bytes == null) {
      throw const ApiException(400, 'Selecione o arquivo do material.');
    }

    final type = ApiMappers.materialType(material.kind);
    final fileId = await uploadFile(type, bytes, material.fileName ?? 'arquivo');
    final seconds = material.durationSeconds;

    await _api.post('/lessons', {
      'idModulo': moduleId,
      'tipo': type,
      'titulo': material.title,
      'descricao': material.description,
      'idArquivo': fileId,
      if (seconds != null) 'duracaoMinutos': (seconds / 60).ceil(),
    });
  }

  /// Envia o arquivo de uma aula (PDF, VIDEO ou AUDIO) e devolve o id.
  Future<String> uploadFile(String type, Uint8List bytes, String fileName) async {
    final data = await _api.upload(
      '/files',
      field: 'arquivo',
      bytes: bytes,
      fileName: fileName,
      fields: {'tipo': type, 'finalidade': 'MATERIAL_AULA'},
    ) as Map<String, dynamic>;
    return (data['arquivo'] as Map<String, dynamic>)['id'] as String;
  }

  // ---------------------------------------------------------------------------
  // Inscrições
  // ---------------------------------------------------------------------------

  Future<String> enroll(String courseId, {String turma = 'EAD'}) async {
    final data = await _api.post('/enrollments', {
      'idCurso': courseId,
      'turma': ApiMappers.turmaValue(turma),
    }) as Map<String, dynamic>;
    return data['message'] as String? ?? 'Inscrição realizada.';
  }

  Future<void> cancelEnrollment(String courseId) =>
      _api.delete('/enrollments/$courseId');

  Future<String> enrollUser(
    String courseId, {
    required String email,
    required String turma,
  }) async {
    final data = await _api.post('/enrollments/curso/$courseId', {
      'email': email.trim(),
      'turma': ApiMappers.turmaValue(turma),
    }) as Map<String, dynamic>;
    final inscricao = data['inscricao'] as Map<String, dynamic>;
    final usuario = inscricao['usuario'] as Map<String, dynamic>;
    return usuario['nome'] as String;
  }

  /// Cursos em que o usuário está inscrito, com o progresso.
  Future<List<Map<String, dynamic>>> myCourses() async {
    final data = await _api.get('/enrollments/me') as Map<String, dynamic>;
    return (data['dados'] as List).cast<Map<String, dynamic>>();
  }

  // ---------------------------------------------------------------------------
  // Aulas
  // ---------------------------------------------------------------------------

  Future<MaterialAccess> materialAccess(String materialId) async {
    final data = await _api.get('/lessons/$materialId/access') as Map<String, dynamic>;
    final url = data['url'] as String;
    return MaterialAccess(
      url: url,
      downloadUrl: url,
      fileName: data['nomeArquivo'] as String,
      mimeType: data['contentType'] as String,
    );
  }

  /// Marca a aula como concluída e devolve as recompensas recebidas.
  Future<Map<String, dynamic>> completeMaterial(String materialId) async =>
      await _api.post('/lessons/$materialId/complete') as Map<String, dynamic>;
}
