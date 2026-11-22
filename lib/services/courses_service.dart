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

  static String? courseCoverUrl(Map<String, dynamic> api) {
    String? urlFrom(Object? value) {
      if (value is String) {
        final candidate = value.trim();
        if (candidate.isEmpty) return null;
        final uri = Uri.tryParse(candidate);
        if (uri == null) return null;
        if (uri.hasScheme && uri.host.isNotEmpty) {
          return uri.scheme == 'http' || uri.scheme == 'https'
              ? candidate
              : null;
        }
        if (candidate.startsWith('/')) {
          final base = Uri.parse('$apiBaseUrl/');
          return base
              .resolve(candidate.replaceFirst(RegExp(r'^/+'), ''))
              .toString();
        }
        return null;
      }
      if (value is Map) {
        for (final key in const ['url', 'arquivo', 'media', 'capa']) {
          final url = urlFrom(value[key]);
          if (url != null) return url;
        }
      }
      return null;
    }

    for (final key in const ['capa', 'arquivoCapa']) {
      final url = urlFrom(api[key]);
      if (url != null) return url;
    }

    return null;
  }

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
      final response = await _api.get(
        '/courses',
        query: {
          'pagina': page,
          'nome': search,
          'categoria': category,
          'status': status,
        },
      );
      final data = ApiClient.responseMap(
        response,
        endpoint: '/courses',
        optional: true,
      );

      courses.addAll(
        ApiClient.parseResponse(
          '/courses',
          () => ApiClient.responseList(
            data['dados'],
            endpoint: '/courses.dados',
          ).map(listMap).toList(),
        ),
      );
      stats = ApiClient.responseMap(
        data['estatisticas'],
        endpoint: '/courses.estatisticas',
        optional: true,
      );
      final pagination = ApiClient.responseMap(
        data['paginacao'],
        endpoint: '/courses.paginacao',
        optional: true,
      );
      final nextPage = pagination['proximaPagina'];
      page = nextPage == null
          ? null
          : ApiClient.responseInt(
              nextPage,
              endpoint: '/courses.paginacao.proximaPagina',
              required: true,
            );
    }

    return CourseListResult(
      courses: courses,
      categories: ApiMappers.courseCategories.values.toList(),
      stats: ApiClient.parseResponse(
        '/courses.estatisticas',
        () => stats.map(
          (key, value) => MapEntry(
            key,
            value is num
                ? value.toInt()
                : throw const FormatException('Estatística inválida.'),
          ),
        ),
      ),
    );
  }

  /// Formato usado pelas listagens de cursos (dashboard e catálogo).
  static Map<String, dynamic> listMap(Map<String, dynamic> api) =>
      ApiClient.parseResponse('/courses.dados', () {
        final content = api['conteudo'] as Map<String, dynamic>? ?? const {};
        final price = ApiMappers.number(api['preco']) ?? 0;
        final turma = api['turma'] ?? (api['inscricao'] as Map?)?['turma'];
        return {
          'id': api['id'],
          'name': api['nome'],
          'category': ApiMappers.categoryLabel(api['categoria'] as String?),
          'description': api['descricao'] ?? '',
          'workload': api['cargaHoraria'] ?? 0,
          'enrolled': api['inscritos'] ?? 0,
          // Sem limite de vagas a API devolve null.
          'capacity': api['vagas'] as int?,
          'status': ApiMappers.courseStatusLabel(api['status'] as String?),
          'createdAt': ApiMappers.formatDate(api['criadoEm']),
          'icon': ApiMappers.coverIcon(api['iconeCapa'] as String?),
          'color': ApiMappers.color(api['cor'] as String?),
          'idCapa': api['idCapa'],
          'imageUrl': courseCoverUrl(api) ?? '',
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
      });

  /// Curso com sessões, módulos, conteúdos e o progresso do usuário.
  Future<Map<String, dynamic>> detail(String id) async => ApiClient.responseMap(
    await _api.get('/courses/$id/conteudo'),
    endpoint: '/courses/$id/conteudo',
  );

  /// Detalhe do curso no modelo usado pela página do curso.
  Future<Course> course(String id) async {
    final data = await detail(id);
    final course = courseFromApi(data);
    final enrolled = await isEnrolled(id);
    final user = await StorageService.instance.loadCurrentUser();
    final apiCourse = data['curso'] is Map<String, dynamic>
        ? data['curso'] as Map<String, dynamic>
        : data;
    final owner = apiCourse['responsavel'] as Map<String, dynamic>?;
    final teachers = (apiCourse['professores'] as List? ?? const [])
        .whereType<Map>()
        .map((entry) => entry['id'] as String?)
        .whereType<String>()
        .toSet();
    return course.copyWith(
      enrolled: enrolled,
      canEdit:
          user != null &&
          (owner?['id'] == user.id ||
              (user.type == 'PROFESSOR' && teachers.contains(user.id))),
    );
  }

  static String _workload(int hours) {
    if (hours <= 0) return 'Carga horária livre';
    return hours == 1 ? '1 hora' : '$hours horas';
  }

  static Course courseFromApi(Map<String, dynamic> data) {
    return ApiClient.parseResponse('/courses/estrutura', () {
      final api = ApiClient.responseMap(
        data['curso'] ?? data,
        endpoint: '/courses/conteudo.curso',
      );
      final progress = ApiClient.responseMap(
        api['progresso'],
        endpoint: '/courses/estrutura.curso.progresso',
      );
      final creator = ApiClient.responseMap(
        api['responsavel'],
        endpoint: '/courses/estrutura.curso.responsavel',
        optional: true,
      );

      return Course(
        id: api['id'] as String,
        title: api['nome'] as String,
        category: ApiMappers.categoryLabel(api['categoria'] as String?),
        duration: _workload(
          ApiClient.responseInt(
            api['cargaHoraria'],
            endpoint: '/courses/conteudo.curso.cargaHoraria',
          ),
        ),
        description: api['descricao'] as String? ?? '',
        imageAsset: 'lib/assets/courses/vestibular_course_image.jpg',
        imageUrl: courseCoverUrl(api),
        icon: ApiMappers.coverIcon(api['iconeCapa'] as String?),
        color: ApiMappers.color(api['cor'] as String?),
        progress: ((progress['percentual'] as num?) ?? 0).toDouble() / 100,
        completedMaterials: ApiClient.responseInt(
          progress['concluidos'],
          endpoint: '/courses/estrutura.curso.progresso.concluidos',
        ),
        totalMaterials: ApiClient.responseInt(
          progress['total'] ?? progress['totalConteudos'],
          endpoint: '/courses/estrutura.curso.progresso.totalConteudos',
        ),
        canEdit: api['podeEditar'] == true,
        enrolled: api['inscrito'] == true,
        enrolledCount: ApiClient.responseInt(
          api['quantidadeAlunosInscritos'] ?? api['inscritos'],
          endpoint: '/courses/estrutura.curso.inscritos',
        ),
        creatorName: creator['nome'] as String?,
        status: api['status'] as String? ?? 'ATIVO',
        sessions: [
          for (final sessao in ApiClient.responseList(
            api['sessoes'] ?? data['sessoes'],
            endpoint: '/courses/estrutura.sessoes',
          ))
            CourseSession(
              id: sessao['id'] as String,
              title: sessao['titulo'] as String,
              subtitle: sessao['subtitulo'] as String? ?? '',
              description: sessao['descricao'] as String? ?? '',
              modules: [
                for (final modulo in ApiClient.responseList(
                  sessao['modulos'],
                  endpoint: '/courses/estrutura.sessoes.modulos',
                ))
                  CourseModule(
                    id: modulo['id'] as String,
                    title: modulo['titulo'] as String,
                    description: modulo['descricao'] as String? ?? '',
                    materials: [
                      for (final conteudo in [
                        ...ApiClient.responseList(
                          modulo['aulas'],
                          endpoint: '/courses/conteudo.modulos.aulas',
                        ),
                        ...ApiClient.responseList(
                          modulo['atividades'] ?? modulo['testes'],
                          endpoint: '/courses/conteudo.modulos.atividades',
                        ),
                      ])
                        _materialFromApi(conteudo),
                    ],
                  ),
              ],
            ),
        ],
      );
    });
  }

  static CourseMaterial _materialFromApi(Map<String, dynamic> api) =>
      ApiClient.parseResponse('/courses/estrutura.conteudos', () {
        final kind = ApiMappers.materialKind(api['tipo'] as String?);
        final file = api['arquivo'] as Map<String, dynamic>?;
        final minutes = api['duracaoMinutos'] as int?;
        final title =
            api['titulo'] as String? ?? api['tema'] as String? ?? 'Conteúdo';

        return CourseMaterial(
          id: api['id'] as String,
          kind: kind,
          title: title,
          description: api['descricao'] as String? ?? '',
          fileName: file?['nomeOriginal'] as String?,
          fileUrl: file?['url'] as String?,
          fileSizeBytes: ApiMappers.number(file?['tamanhoBytes'])?.toInt(),
          pageCount: api['quantidadePaginas'] as int?,
          durationSeconds: minutes == null || minutes == 0
              ? null
              : minutes * 60,
          completed: api['concluida'] == true || api['concluido'] == true,
          activity: kind == MaterialKind.activity
              ? Activity(
                  theme: title,
                  durationMinutes: api['tempoMinutos'] as int? ?? 0,
                  questions: const [],
                  questionCount:
                      api['quantidadeQuestoes'] as int? ??
                      api['totalQuestoes'] as int? ??
                      0,
                  questionIds: (api['idsQuestoes'] as List? ?? const [])
                      .cast<String>(),
                )
              : null,
        );
      });

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
  static Map<String, dynamic> editorMap(Map<String, dynamic> data) =>
      ApiClient.parseResponse('/courses/conteudo', () {
        final course = ApiClient.responseMap(
          data['curso'] ?? data,
          endpoint: '/courses/conteudo.curso',
        );
        return {
          ...listMap(course),
          'iconKey': course['iconeCapa'],
          'workload': course['cargaHoraria'] ?? 0,
          'price': ApiMappers.number(course['preco']) ?? 0,
          'professores': course['professores'] ?? const [],
          'ownerId': (course['responsavel'] as Map?)?['id'] as String?,
          'trilhas': [
            for (final sessao in ApiClient.responseList(
              course['sessoes'] ?? data['sessoes'],
              endpoint: '/courses/conteudo.sessoes',
            ))
              <String, dynamic>{
                'id': sessao['id'],
                'title': sessao['titulo'],
                'subtitle': sessao['subtitulo'] ?? '',
                'description': sessao['descricao'] ?? '',
                'modulos': <Map<String, dynamic>>[
                  for (final modulo in ApiClient.responseList(
                    sessao['modulos'],
                    endpoint: '/courses/estrutura.sessoes.modulos',
                  ))
                    <String, dynamic>{
                      'id': modulo['id'],
                      'title': modulo['titulo'],
                      'description': modulo['descricao'] ?? '',
                      'materiais': <Map<String, dynamic>>[
                        for (final conteudo in [
                          ...ApiClient.responseList(
                            modulo['aulas'],
                            endpoint: '/courses/conteudo.modulos.aulas',
                          ),
                          ...ApiClient.responseList(
                            modulo['atividades'],
                            endpoint: '/courses/conteudo.modulos.atividades',
                          ),
                        ])
                          _editorMaterial(conteudo),
                      ],
                    },
                ],
              },
          ],
        };
      });

  static Map<String, dynamic> _editorMaterial(Map<String, dynamic> api) {
    final file = api['arquivo'] as Map<String, dynamic>?;
    final kind = _editorKind(api['tipo'] as String?);
    final minutes = api['duracaoMinutos'] as int?;
    final activity = api['tipo'] == 'ATIVIDADE';
    final rawQuestions =
        api['questaoIds'] ?? api['idsQuestoes'] ?? api['questoes'];
    final questionIds = rawQuestions is List
        ? rawQuestions
              .map((item) {
                if (item is String) return item;
                if (item is Map) {
                  final question = item['questao'];
                  if (question is Map && question['id'] is String) {
                    return question['id'] as String;
                  }
                  final id = item['idQuestao'] ?? item['id'];
                  if (id is String) return id;
                }
                return null;
              })
              .whereType<String>()
              .toList()
        : const <String>[];

    return <String, dynamic>{
      'id': api['id'],
      'tipo': api['tipo'],
      'name': api['titulo'] ?? api['tema'],
      'description': api['descricao'] ?? '',
      if (kind != null) 'type': kind,
      if (kind != null) 'icon': kind.icon,
      if (file != null) 'idArquivo': file['id'],
      if (file != null) 'fileName': file['nomeOriginal'],
      if (file != null) 'fileUrl': file['url'],
      if (file != null)
        'fileSize': ApiMappers.fileSize(
          ApiMappers.number(file['tamanhoBytes']),
        ),
      if (minutes != null && minutes > 0)
        'duration': ApiMappers.duration(minutes * 60),
      if (api['quantidadePaginas'] != null)
        'quantidadePaginas': api['quantidadePaginas'],
      // Atividades são preservadas como estão ao salvar pelo dashboard.
      if (activity) ...{
        'tempoMinutos': api['tempoMinutos'],
        'idsQuestoes': questionIds,
        'totalQuestoes': api['quantidadeQuestoes'] ?? api['totalQuestoes'] ?? 0,
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
      'cargaHoraria': map['workload'],
      'vagas': map['capacity'],
      'preco': map['price'] ?? 0,
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
        for (final trilha
            in (map['trilhas'] as List? ?? const [])
                .cast<Map<String, dynamic>>())
          {
            if (id(trilha['id']) != null) 'id': id(trilha['id']),
            'titulo': trilha['title'],
            'subtitulo': trilha['subtitle'] ?? '',
            'descricao': trilha['description'] ?? '',
            'modulos': [
              for (final modulo
                  in (trilha['modulos'] as List).cast<Map<String, dynamic>>())
                {
                  if (id(modulo['id']) != null) 'id': id(modulo['id']),
                  'titulo': modulo['title'],
                  'descricao': modulo['description'] ?? '',
                  'conteudos': [
                    for (final material
                        in (modulo['materiais'] as List)
                            .cast<Map<String, dynamic>>())
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
        if (id != null) 'id': id,
        'tipo': 'ATIVIDADE',
        'titulo': material['name'],
        if (material['tempoMinutos'] != null)
          'tempoMinutos': material['tempoMinutos'],
        'questaoIds':
            material['questaoIds'] ??
            material['idsQuestoes'] ??
            const <String>[],
      };
    }

    final kind =
        material['type'] as editor.MaterialKind? ?? editor.MaterialKind.pdf;
    final seconds = ApiMappers.parseDuration(material['duration'] as String?);
    // Documentos já cadastrados continuam com o tipo original.
    final type =
        material['tipo'] == 'DOCUMENTO' && kind == editor.MaterialKind.pdf
        ? 'DOCUMENTO'
        : _editorType(kind);

    return {
      if (id != null) 'id': id,
      'tipo': type,
      'titulo': material['name'],
      'descricao': material['description'] ?? '',
      if (material['idArquivo'] != null) 'idArquivo': material['idArquivo'],
      if (seconds != null) 'duracaoMinutos': (seconds / 60).ceil(),
      if (material['quantidadePaginas'] != null)
        'quantidadePaginas': material['quantidadePaginas'],
    };
  }

  /// Salva o curso do editor (cria quando não há id) e devolve o mapa salvo.
  Future<Map<String, dynamic>> saveFromEditor(Map<String, dynamic> map) async {
    final user = await StorageService.instance.loadCurrentUser();
    final isAdmin = user?.isAdmin ?? false;
    final status = ApiMappers.courseStatusValue(
      map['status'] as String? ?? 'Rascunho',
    );
    final payload = coursePayload(map);

    Map<String, dynamic> saved;
    final coverBytes = map['coverBytes'] as Uint8List?;
    final fields = <String, String>{
      for (final entry in payload.entries)
        if (entry.key != 'capa' || coverBytes == null)
          entry.key: '${entry.value ?? 'null'}',
      if (isAdmin &&
          status !=
              ApiMappers.courseStatusValue(
                map['originalStatus'] as String? ?? 'Rascunho',
              ))
        'status': status,
    };
    if (_isApiId(map['id'])) {
      final response = coverBytes == null
          ? await _api.patch(
              '/courses/${map['id']}',
              fields.map(
                (key, value) => MapEntry(key, value == 'null' ? null : value),
              ),
            )
          : await _api.multipart(
              'PATCH',
              '/courses/${map['id']}',
              fields: fields..remove('capa'),
              file: (
                field: 'arquivo',
                bytes: coverBytes,
                fileName: map['coverFileName'] as String? ?? 'capa.png',
              ),
            );
      final data = ApiClient.responseMap(
        response,
        endpoint: '/courses/${map['id']}',
      );
      saved = ApiClient.responseMap(
        data['curso'],
        endpoint: '/courses/${map['id']}.curso',
      );
    } else {
      final response = coverBytes == null
          ? await _api.post('/courses', payload)
          : await _api.upload(
              '/courses',
              field: 'arquivo',
              bytes: coverBytes,
              fileName: map['coverFileName'] as String? ?? 'capa.png',
              fields: fields..remove('capa'),
            );
      final data = ApiClient.responseMap(response, endpoint: '/courses');
      saved = ApiClient.responseMap(data['curso'], endpoint: '/courses.curso');
      // O curso nasce como rascunho ou inativo; a ativação vem em seguida.
      if (isAdmin && saved['status'] != status) {
        await _api.patch('/courses/${saved['id']}', {'status': status});
      }
    }

    await _saveStructure(saved['id'] as String, map);
    return {...map, 'id': saved['id'], 'idCapa': saved['idCapa']};
  }

  Future<void> _saveStructure(String courseId, Map<String, dynamic> map) async {
    final original = (map['originalTrilhas'] as List? ?? const [])
        .whereType<Map<String, dynamic>>()
        .toList();
    final sessions = (map['trilhas'] as List? ?? const [])
        .whereType<Map<String, dynamic>>()
        .toList();
    final keepSessionIds = <String>{};
    for (final session in sessions) {
      final sessionId = _isApiId(session['id'])
          ? session['id'] as String
          : null;
      final body = {
        'titulo': session['title'],
        'subtitulo': session['subtitle'] ?? '',
        'descricao': session['description'] ?? '',
      };
      String savedSessionId;
      if (sessionId == null) {
        final response = await _api.post('/sessions', {
          'idCurso': courseId,
          ...body,
        });
        final data = ApiClient.responseMap(response, endpoint: '/sessions');
        savedSessionId =
            ApiClient.responseMap(
                  data['sessao'],
                  endpoint: '/sessions.sessao',
                )['id']
                as String;
        session['id'] = savedSessionId;
      } else {
        savedSessionId = sessionId;
        await _api.patch('/sessions/$savedSessionId', body);
      }
      keepSessionIds.add(savedSessionId);
      final oldSession = original
          .where((item) => item['id'] == savedSessionId)
          .firstOrNull;
      final oldModules = (oldSession?['modulos'] as List? ?? const [])
          .whereType<Map<String, dynamic>>()
          .toList();
      final modules = (session['modulos'] as List? ?? const [])
          .whereType<Map<String, dynamic>>()
          .toList();
      final keepModuleIds = <String>{};
      for (final module in modules) {
        final moduleId = _isApiId(module['id']) ? module['id'] as String : null;
        final moduleBody = {
          'titulo': module['title'],
          'descricao': module['description'] ?? '',
        };
        String savedModuleId;
        if (moduleId == null) {
          final response = await _api.post('/course-modules', {
            'idSessao': savedSessionId,
            ...moduleBody,
          });
          final data = ApiClient.responseMap(
            response,
            endpoint: '/course-modules',
          );
          savedModuleId =
              ApiClient.responseMap(
                    data['modulo'],
                    endpoint: '/course-modules.modulo',
                  )['id']
                  as String;
          module['id'] = savedModuleId;
        } else {
          savedModuleId = moduleId;
          await _api.patch('/course-modules/$savedModuleId', moduleBody);
        }
        keepModuleIds.add(savedModuleId);
        final oldModule = oldModules
            .where((item) => item['id'] == savedModuleId)
            .firstOrNull;
        final oldMaterials = (oldModule?['materiais'] as List? ?? const [])
            .whereType<Map<String, dynamic>>()
            .toList();
        final materials = (module['materiais'] as List? ?? const [])
            .whereType<Map<String, dynamic>>()
            .toList();
        final keepMaterialIds = <String>{};
        for (final material in materials) {
          final materialId = _isApiId(material['id'])
              ? material['id'] as String
              : null;
          final isActivity =
              material['tipo'] == 'ATIVIDADE' ||
              material['kind'] == MaterialKind.activity;
          if (isActivity) {
            final activity = material['activity'] as Activity?;
            final ids =
                (material['idsQuestoes'] as List? ??
                        activity?.questionIds ??
                        const [])
                    .cast<String>();
            final body = {
              'tema': activity?.theme ?? material['name'],
              'tempoMinutos':
                  activity?.durationMinutes ?? material['tempoMinutos'] ?? 5,
              'questaoIds': ids,
            };
            if (materialId == null) {
              final response = await _api.post('/tests/activities', {
                'idModulo': savedModuleId,
                ...body,
              });
              final data = ApiClient.responseMap(
                response,
                endpoint: '/tests/activities',
              );
              material['id'] = ApiClient.responseMap(
                data['atividade'],
                endpoint: '/tests/activities.atividade',
              )['id'];
            } else if (activity != null || ids.isNotEmpty) {
              await _api.patch('/tests/$materialId', body);
            }
          } else if (materialId == null) {
            final bytes = material['fileBytes'] as Uint8List?;
            if (bytes == null)
              throw const ApiException(
                400,
                'Selecione o arquivo de cada aula antes de salvar o curso.',
              );
            final kind =
                material['type'] as editor.MaterialKind? ??
                editor.MaterialKind.pdf;
            final duration = ApiMappers.parseDuration(
              material['duration'] as String?,
            );
            final created = await _api.upload(
              '/lessons',
              field: 'arquivo',
              bytes: bytes,
              fileName: material['fileName'] as String? ?? 'material.pdf',
              fields: {
                'idModulo': savedModuleId,
                'tipo': _editorType(kind),
                'titulo': material['name'] as String,
                'descricao': material['description'] as String? ?? '',
                if (duration != null)
                  'duracaoMinutos': '${(duration / 60).ceil()}',
                if (material['quantidadePaginas'] != null)
                  'quantidadePaginas': '${material['quantidadePaginas']}',
              },
            );
            final createdData = ApiClient.responseMap(
              created,
              endpoint: '/lessons',
            );
            material['id'] = ApiClient.responseMap(
              createdData['aula'],
              endpoint: '/lessons.aula',
            )['id'];
          } else {
            await _api.patch('/lessons/$materialId', {
              'titulo': material['name'],
              'descricao': material['description'] ?? '',
            });
          }
          if (_isApiId(material['id']))
            keepMaterialIds.add(material['id'] as String);
        }
        for (final removed in oldMaterials.where(
          (item) =>
              _isApiId(item['id']) && !keepMaterialIds.contains(item['id']),
        )) {
          await _api.delete(
            removed['tipo'] == 'ATIVIDADE'
                ? '/tests/${removed['id']}'
                : '/lessons/${removed['id']}',
          );
        }
      }
      for (final removed in oldModules.where(
        (item) => _isApiId(item['id']) && !keepModuleIds.contains(item['id']),
      )) {
        await _api.delete('/course-modules/${removed['id']}');
      }
    }
    for (final removed in original.where(
      (item) => _isApiId(item['id']) && !keepSessionIds.contains(item['id']),
    )) {
      await _api.delete('/sessions/${removed['id']}');
    }
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
  }) => _api.post('/course-modules', {
    'idSessao': sessionId,
    'titulo': title,
    'descricao': description,
  });

  Future<void> updateSession(String id, Map<String, dynamic> data) async {
    await _api.patch('/sessions/$id', {
      'titulo': data['title'],
      'subtitulo': data['subtitle'],
      'descricao': data['description'],
    });
  }

  Future<void> updateModule(String id, Map<String, dynamic> data) async {
    await _api.patch('/course-modules/$id', {
      'titulo': data['title'],
      'descricao': data['description'],
    });
  }

  Future<void> updateLesson(String id, CourseMaterial material) async {
    await _api.patch('/lessons/$id', {
      'titulo': material.title,
      'descricao': material.description,
    });
  }

  Future<void> updateActivity(String id, CourseMaterial material) async {
    final activity = material.activity!;
    await _api.patch('/tests/$id', {
      'tema': activity.theme,
      'tempoMinutos': activity.durationMinutes,
      'questaoIds': activity.questionIds,
    });
  }

  Future<CourseMaterial> activityForEdit(CourseMaterial current) async {
    final response = await _api.get('/tests/${current.id}');
    final data = ApiClient.responseMap(
      response,
      endpoint: '/tests/${current.id}',
    );
    final test = ApiClient.responseMap(
      data['teste'],
      endpoint: '/tests/${current.id}.teste',
    );
    final questions = <ActivityQuestion>[];
    final questionIds = <String>[];
    for (final link in ApiClient.responseList(
      test['questoes'],
      endpoint: '/tests/${current.id}.teste.questoes',
    )) {
      final question = ApiClient.responseMap(
        link['questao'],
        endpoint: '/tests/${current.id}.questoes.questao',
      );
      questionIds.add(question['id'] as String);
      final alternatives = ApiClient.responseList(
        question['alternativas'],
        endpoint: '/tests/${current.id}.questoes.alternativas',
      );
      questions.add(
        ActivityQuestion(
          id: question['id'] as String,
          title: question['titulo'] as String? ?? '',
          statement: question['enunciado'] as String? ?? '',
          difficulty: ApiMappers.difficulty(question['dificuldade'] as String?),
          options: alternatives.map((item) => item['texto'] as String).toList(),
          optionIds: alternatives.map((item) => item['id'] as String).toList(),
          correctOptionIndex: -1,
        ),
      );
    }
    return CourseMaterial(
      id: current.id,
      kind: MaterialKind.activity,
      title: test['tema'] as String? ?? current.title,
      description: current.description,
      activity: Activity(
        theme: test['tema'] as String? ?? current.title,
        durationMinutes: ApiClient.responseInt(
          test['tempoMinutos'],
          endpoint: '/tests/${current.id}.tempoMinutos',
        ),
        questions: questions,
        questionCount: questions.length,
        questionIds: questionIds,
      ),
      completed: current.completed,
    );
  }

  Future<void> deleteSession(String id) async => _api.delete('/sessions/$id');
  Future<void> deleteModule(String id) async =>
      _api.delete('/course-modules/$id');
  Future<void> deleteLesson(String id) async => _api.delete('/lessons/$id');
  Future<void> deleteActivity(String id) async => _api.delete('/tests/$id');

  Future<List<Map<String, dynamic>>> linkedTeachers(String courseId) async {
    final response = await _api.get('/courses/$courseId/professores');
    final data = ApiClient.responseMap(
      response,
      endpoint: '/courses/$courseId/professores',
    );
    return ApiClient.responseList(
      data['dados'],
      endpoint: '/courses/$courseId/professores.dados',
    );
  }

  Future<List<Map<String, dynamic>>> availableTeachers(String courseId) async {
    final result = <Map<String, dynamic>>[];
    var page = 1;
    while (true) {
      final response = await _api.get(
        '/courses/$courseId/professores/disponiveis',
        query: {'pagina': page},
      );
      final data = ApiClient.responseMap(
        response,
        endpoint: '/courses/$courseId/professores/disponiveis',
      );
      result.addAll(
        ApiClient.responseList(
          data['dados'],
          endpoint: '/courses/$courseId/professores/disponiveis.dados',
        ),
      );
      final pagination = ApiClient.responseMap(
        data['paginacao'],
        endpoint: '/courses/$courseId/professores/disponiveis.paginacao',
        optional: true,
      );
      final totalPages = ApiClient.responseInt(
        pagination['totalPaginas'],
        endpoint: '/courses/$courseId/professores/disponiveis.totalPaginas',
        fallback: page,
      );
      if (page >= totalPages) break;
      page++;
    }
    return result;
  }

  Future<void> linkTeacher(String courseId, String teacherId) async =>
      _api.post('/courses/$courseId/professores', {'idProfessor': teacherId});

  Future<void> unlinkTeacher(String courseId, String teacherId) async =>
      _api.delete('/courses/$courseId/professores/$teacherId');

  /// Cadastra uma aula (o arquivo é enviado antes ao storage) ou atividade.
  Future<void> addMaterial(
    String courseId,
    String moduleId,
    CourseMaterial material,
  ) async {
    final activity = material.activity;

    if (material.kind == MaterialKind.activity) {
      if (activity == null) {
        throw const ApiException(400, 'Informe os dados da atividade.');
      }
      if (activity.durationMinutes < 1 || activity.durationMinutes > 600) {
        throw const ApiException(
          400,
          'A duração da atividade deve ser de 1 a 600 minutos.',
        );
      }
      final questionIds = activity.questionIds.isNotEmpty
          ? activity.questionIds
          : activity.questions.map((question) => question.id).toList();
      if (questionIds.isEmpty) {
        throw const ApiException(
          400,
          'Selecione pelo menos uma questão para a atividade.',
        );
      }
      await _api.post('/tests/activities', {
        'idModulo': moduleId,
        'tema': activity.theme.isNotEmpty ? activity.theme : material.title,
        'tempoMinutos': activity.durationMinutes,
        'questaoIds': questionIds,
      });
      return;
    }

    final bytes = material.fileBytes;
    if (bytes == null) {
      throw const ApiException(400, 'Selecione o arquivo do material.');
    }

    if (material.kind == MaterialKind.pdf &&
        (material.pageCount == null || material.pageCount! < 1)) {
      throw const ApiException(400, 'Informe a quantidade de páginas do PDF.');
    }
    if (material.kind != MaterialKind.pdf &&
        (material.durationSeconds == null || material.durationSeconds! < 1)) {
      throw const ApiException(
        400,
        'Informe a duração do vídeo ou áudio em minutos.',
      );
    }

    final type = ApiMappers.materialType(material.kind);
    final seconds = material.durationSeconds;

    await _api.upload(
      '/lessons',
      field: 'arquivo',
      bytes: bytes,
      fileName: material.fileName ?? 'material.pdf',
      fields: {
        'idModulo': moduleId,
        'tipo': type,
        'titulo': material.title,
        'descricao': material.description,
        if (seconds != null) 'duracaoMinutos': '${(seconds / 60).ceil()}',
        if (material.pageCount != null)
          'quantidadePaginas': '${material.pageCount}',
      },
    );
  }

  /// Envia o arquivo de uma aula (PDF, VIDEO ou AUDIO) e devolve o id.
  Future<String> uploadFile(
    String type,
    Uint8List bytes,
    String fileName,
  ) async {
    final response = await _api.upload(
      '/files',
      field: 'arquivo',
      bytes: bytes,
      fileName: fileName,
      fields: {'tipo': type, 'finalidade': 'MATERIAL_AULA'},
    );
    final data = ApiClient.responseMap(response, endpoint: '/files');
    final file = ApiClient.responseMap(
      data['arquivo'],
      endpoint: '/files.arquivo',
    );
    return ApiClient.responseString(
      file['id'],
      endpoint: '/files.arquivo.id',
      required: true,
    )!;
  }

  // ---------------------------------------------------------------------------
  // Inscrições
  // ---------------------------------------------------------------------------

  Future<String> enroll(String courseId, {String turma = 'EAD'}) async {
    final response = await _api.post('/courses/$courseId/inscricoes');
    final data = ApiClient.responseMap(
      response,
      endpoint: '/courses/$courseId/inscricoes',
    );
    return ApiClient.responseString(
          data['message'],
          endpoint: '/courses/$courseId/inscricoes.message',
        ) ??
        'Inscrição realizada.';
  }

  Future<bool> isEnrolled(String courseId) async {
    final endpoint = '/courses/$courseId/inscricoes/me';
    final response = ApiClient.responseMap(
      await _api.get(endpoint),
      endpoint: endpoint,
    );
    return ApiClient.parseResponse(endpoint, () {
      final enrolled = response['inscrito'];
      if (enrolled is bool) return enrolled;
      throw const FormatException('Estado da inscrição inválido.');
    });
  }

  Future<void> cancelEnrollment(String courseId) =>
      _api.delete('/courses/$courseId/inscricoes/me');

  Future<String> enrollUser(
    String courseId, {
    required String email,
    required String turma,
  }) async {
    final response = await _api.post('/enrollments/curso/$courseId', {
      'email': email.trim(),
      'turma': ApiMappers.turmaValue(turma),
    });
    final data = ApiClient.responseMap(
      response,
      endpoint: '/enrollments/curso/$courseId',
    );
    final inscricao = ApiClient.responseMap(
      data['inscricao'],
      endpoint: '/enrollments/curso/$courseId.inscricao',
    );
    final usuario = ApiClient.responseMap(
      inscricao['usuario'],
      endpoint: '/enrollments/curso/$courseId.inscricao.usuario',
    );
    return ApiClient.responseString(
      usuario['nome'],
      endpoint: '/enrollments/curso/$courseId.inscricao.usuario.nome',
      required: true,
    )!;
  }

  /// Cursos em que o usuário está inscrito, com o progresso.
  Future<List<Map<String, dynamic>>> myCourses() async {
    final response = await _api.get('/courses/minhas-inscricoes');
    final data = ApiClient.responseMap(
      response,
      endpoint: '/courses/minhas-inscricoes',
      optional: true,
    );
    final courses = ApiClient.responseList(
      data['cursos'] ?? data['dados'],
      endpoint: '/courses/minhas-inscricoes.cursos',
    );
    return Future.wait(
      courses.map((course) async {
        try {
          final detail = ApiClient.responseMap(
            await _api.get('/courses/${course['id']}'),
            endpoint: '/courses/${course['id']}',
          );
          final basic = ApiClient.responseMap(
            detail['curso'],
            endpoint: '/courses/${course['id']}.curso',
          );
          final detailCover = basic['capa'];
          final courseCover = course['capa'];
          final detailCoverUrl = detailCover is String
              ? detailCover
              : detailCover is Map
              ? detailCover['url'] as String?
              : null;
          final cover = detailCoverUrl != null && detailCoverUrl.isNotEmpty
              ? detailCover
              : courseCover;
          final coverData = cover == null
              ? const <String, dynamic>{}
              : {'capa': cover};
          return {...course, ...basic, ...coverData};
        } on ApiException {
          return course;
        }
      }),
    );
  }

  // ---------------------------------------------------------------------------
  // Aulas
  // ---------------------------------------------------------------------------

  Future<MaterialAccess> materialAccess(String materialId) async {
    final response = await _api.get('/lessons/$materialId');
    final data = ApiClient.responseMap(
      response,
      endpoint: '/lessons/$materialId',
    );
    final aula = ApiClient.responseMap(
      data['aula'],
      endpoint: '/lessons/$materialId.aula',
    );
    final arquivo = ApiClient.responseMap(
      aula['arquivo'],
      endpoint: '/lessons/$materialId.aula.arquivo',
    );
    final url = ApiClient.responseString(
      arquivo['url'],
      endpoint: '/lessons/$materialId.aula.arquivo.url',
      required: true,
    )!;
    return MaterialAccess(
      url: url,
      downloadUrl:
          ApiClient.responseString(
            arquivo['url'],
            endpoint: '/lessons/$materialId.aula.arquivo.url',
            fallback: url,
          ) ??
          url,
      fileName: ApiClient.responseString(
        arquivo['nomeOriginal'],
        endpoint: '/lessons/$materialId.aula.arquivo.nomeOriginal',
        required: true,
      )!,
      mimeType: ApiClient.responseString(
        arquivo['contentType'],
        endpoint: '/lessons/$materialId.aula.arquivo.contentType',
        required: true,
      )!,
    );
  }

  Future<Uint8List> materialPdfBytes(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null || (uri.scheme != 'http' && uri.scheme != 'https')) {
      throw const ApiException(502, 'O endereço do PDF recebido é inválido.');
    }
    final bytes = await _api.getBytes(uri);
    if (!_hasPdfSignature(bytes)) {
      throw const ApiException(
        502,
        'O endereço do material não retornou um arquivo PDF válido.',
      );
    }
    return bytes;
  }

  static bool _hasPdfSignature(Uint8List bytes) {
    const signature = [0x25, 0x50, 0x44, 0x46, 0x2d];
    final end = bytes.length < 1024 ? bytes.length : 1024;
    for (var start = 0; start <= end - signature.length; start++) {
      var matches = true;
      for (var index = 0; index < signature.length; index++) {
        if (bytes[start + index] != signature[index]) {
          matches = false;
          break;
        }
      }
      if (matches) return true;
    }
    return false;
  }

  /// Marca a aula como concluída e devolve as recompensas recebidas.
  Future<Map<String, dynamic>> completeMaterial(String materialId) async =>
      ApiClient.responseMap(
        await _api.post('/lessons/$materialId/progresso'),
        endpoint: '/lessons/$materialId/progresso',
      );
}
