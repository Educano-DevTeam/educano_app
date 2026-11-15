import 'package:flutter/material.dart';

import '../../features/course/models/course_models.dart';
import '../../services/api_client.dart';

/// Conversões entre os valores da API e os usados nas telas.
class ApiMappers {
  ApiMappers._();

  // Ícones são salvos na API pelo nome (ex.: "calculate").
  static const Map<String, IconData> _icons = {
    'menu_book': Icons.menu_book_rounded,
    'calculate': Icons.calculate_rounded,
    'biotech': Icons.biotech_rounded,
    'science': Icons.science_rounded,
    'museum': Icons.museum_rounded,
    'public': Icons.public_rounded,
    'translate': Icons.translate_rounded,
    'palette': Icons.palette_rounded,
    'school': Icons.school_rounded,
    'workspace_premium': Icons.workspace_premium_rounded,
    'diamond': Icons.diamond_rounded,
    'bolt': Icons.bolt_rounded,
    'shield': Icons.shield_rounded,
    'lightbulb': Icons.lightbulb_rounded,
    'timer': Icons.timer_rounded,
    'refresh': Icons.refresh_rounded,
    'face': Icons.face_rounded,
    'star': Icons.star_rounded,
  };

  static IconData icon(
    String? key, {
    IconData fallback = Icons.menu_book_rounded,
  }) => _icons[key] ?? fallback;

  static String iconKey(IconData? icon, {String fallback = 'menu_book'}) {
    for (final entry in _icons.entries) {
      if (entry.value == icon) return entry.key;
    }
    return fallback;
  }

  // Ícones de capa aceitos pela API de cursos (campo "capa"/"iconeCapa").
  static const Map<String, IconData> _coverIcons = {
    'livro': Icons.menu_book_rounded,
    'matematica': Icons.calculate_rounded,
    'biologia': Icons.biotech_rounded,
    'ciencias': Icons.science_rounded,
    'historia': Icons.museum_rounded,
    'geografia': Icons.public_rounded,
    'idiomas': Icons.translate_rounded,
    'artes': Icons.palette_rounded,
  };

  static IconData coverIcon(String? key) =>
      _coverIcons[key] ?? Icons.menu_book_rounded;

  static String coverIconKey(IconData? icon) {
    for (final entry in _coverIcons.entries) {
      if (entry.value == icon) return entry.key;
    }
    return 'livro';
  }

  /// Endereço público da imagem (capa ou foto) guardada no storage.
  static String? mediaUrl(String? idArquivo) =>
      idArquivo == null || idArquivo.isEmpty
      ? null
      : '$apiBaseUrl/media/$idArquivo';

  // Categorias de curso: valor da API <-> texto das telas.
  static const Map<String, String> courseCategories = {
    'LINGUAGENS': 'Linguagens',
    'EXATAS': 'Exatas',
    'CIENCIAS_HUMANAS': 'Ciências Humanas',
    'CIENCIAS_NATURAIS': 'Ciências da Natureza',
    'REDACAO': 'Redação',
    'VESTIBULAR': 'Vestibular',
    'TECNOLOGIA': 'Tecnologia',
    'INTELIGENCIA_ARTIFICIAL': 'Inteligência Artificial',
    'DESIGN': 'Design',
    'FINANCAS': 'Finanças',
  };

  static String categoryLabel(String? value) =>
      courseCategories[value] ?? value ?? '';

  static String categoryValue(String label) => courseCategories.entries
      .firstWhere(
        (e) => e.value == label,
        orElse: () => courseCategories.entries.first,
      )
      .key;

  // Matérias das questões e simulados usam as mesmas áreas das categorias.
  static const Map<String, String> subjects = {
    'EXATAS': 'Matemática',
    'LINGUAGENS': 'Linguagens',
    'CIENCIAS_NATURAIS': 'Ciências da Natureza',
    'CIENCIAS_HUMANAS': 'Ciências Humanas',
    'REDACAO': 'Redação',
    'VESTIBULAR': 'Vestibular',
    'TECNOLOGIA': 'Tecnologia',
    'INTELIGENCIA_ARTIFICIAL': 'Inteligência Artificial',
    'DESIGN': 'Design',
    'FINANCAS': 'Finanças',
  };

  static String subjectLabel(String? value) => subjects[value] ?? value ?? '';

  static String? subjectValue(String label) {
    for (final entry in subjects.entries) {
      if (entry.value == label) return entry.key;
    }
    return null;
  }

  /// Números que a API pode devolver como texto (BigInt e Decimal).
  static num? number(Object? value) =>
      value is num ? value : (value is String ? num.tryParse(value) : null);

  static Color color(String? hex, {Color fallback = const Color(0xFF425BC2)}) {
    final value = hex?.replaceFirst('#', '');
    if (value == null || value.length != 6) return fallback;
    final parsed = int.tryParse(value, radix: 16);
    return parsed == null ? fallback : Color(0xFF000000 | parsed);
  }

  static String hex(Color color) {
    final rgb = color.toARGB32() & 0xFFFFFF;
    return '#${rgb.toRadixString(16).padLeft(6, '0').toUpperCase()}';
  }

  static DateTime? date(Object? iso) =>
      iso is String ? DateTime.tryParse(iso)?.toLocal() : null;

  /// Data no formato dd/MM/yyyy.
  static String formatDate(Object? iso) {
    final value = date(iso);
    if (value == null) return '—';
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(value.day)}/${two(value.month)}/${value.year}';
  }

  static String formatDateTime(Object? iso) {
    final value = date(iso);
    if (value == null) return '—';
    String two(int n) => n.toString().padLeft(2, '0');
    return '${formatDate(iso)} ${two(value.hour)}:${two(value.minute)}';
  }

  // Status de curso: ATIVO/INATIVO/RASCUNHO <-> Ativo/Inativo/Rascunho.
  static String courseStatusLabel(String? status) => switch (status) {
    'ATIVO' => 'Ativo',
    'INATIVO' => 'Inativo',
    _ => 'Rascunho',
  };

  static String courseStatusValue(String label) => switch (label) {
    'Ativo' => 'ATIVO',
    'Inativo' => 'INATIVO',
    _ => 'RASCUNHO',
  };

  static const turmas = {
    'MANHA': 'Manhã',
    'TARDE': 'Tarde',
    'NOITE': 'Noite',
    'EAD': 'EAD',
  };

  static String turmaValue(String label) => turmas.entries
      .firstWhere((e) => e.value == label, orElse: () => turmas.entries.last)
      .key;

  static ActivityQuestionDifficulty difficulty(String? value) =>
      switch (value) {
        'FACIL' => ActivityQuestionDifficulty.easy,
        'DIFICIL' => ActivityQuestionDifficulty.hard,
        _ => ActivityQuestionDifficulty.medium,
      };

  static String difficultyValue(ActivityQuestionDifficulty difficulty) =>
      switch (difficulty) {
        ActivityQuestionDifficulty.easy => 'FACIL',
        ActivityQuestionDifficulty.medium => 'MEDIO',
        ActivityQuestionDifficulty.hard => 'DIFICIL',
      };

  static String difficultyFromLabel(String label) => switch (label) {
    'Fácil' => 'FACIL',
    'Difícil' => 'DIFICIL',
    _ => 'MEDIO',
  };

  static MaterialKind materialKind(String? tipo) => switch (tipo) {
    'VIDEO' => MaterialKind.video,
    'AUDIO' => MaterialKind.audio,
    'PDF' || 'DOCUMENTO' => MaterialKind.pdf,
    _ => MaterialKind.activity,
  };

  static String materialType(MaterialKind kind) => switch (kind) {
    MaterialKind.video => 'VIDEO',
    MaterialKind.audio => 'AUDIO',
    MaterialKind.pdf => 'PDF',
    MaterialKind.activity => 'ATIVIDADE',
  };

  static String fileSize(num? bytes) {
    if (bytes == null) return '';
    final kb = bytes / 1024;
    if (kb < 1024) return '${kb.round()} KB';
    return '${(kb / 1024).toStringAsFixed(1).replaceAll('.', ',')} MB';
  }

  static String duration(int? seconds) {
    if (seconds == null) return '';
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  /// Converte "mm:ss" (ou "hh:mm:ss") em segundos.
  static int? parseDuration(String? text) {
    if (text == null || text.trim().isEmpty) return null;
    final parts = text.trim().split(':').map(int.tryParse).toList();
    if (parts.any((p) => p == null)) return null;
    return parts.fold<int>(0, (total, part) => total * 60 + part!);
  }

  /// Converte uma questão da API para o modelo das telas.
  static ActivityQuestion question(Map<String, dynamic> json) {
    final alternatives = (json['alternativas'] as List? ?? const [])
        .cast<Map<String, dynamic>>();
    final professor = json['professor'] as Map<String, dynamic>?;
    final correctAlternativeId = json['idAlternativaCorreta'];
    return ActivityQuestion(
      id: json['id'] as String,
      title: json['titulo'] as String? ?? '',
      statement: json['enunciado'] as String? ?? '',
      difficulty: difficulty(json['dificuldade'] as String?),
      options: alternatives.map((a) => a['texto'] as String).toList(),
      optionIds: alternatives.map((a) => a['id'] as String).toList(),
      correctOptionIndex: alternatives.indexWhere(
        (a) =>
            a['correta'] == true ||
            (correctAlternativeId != null && a['id'] == correctAlternativeId),
      ),
      subject: subjectLabel(json['materia'] as String?),
      topic: json['tema'] as String? ?? '',
      explanation: json['explicacao'] as String? ?? '',
      authorId: professor?['id'] as String?,
      authorName: professor?['nome'] as String?,
    );
  }

  /// Corpo de cadastro/edição de uma questão na API.
  static Map<String, dynamic> questionPayload(ActivityQuestion question) => {
    'titulo': question.title,
    'enunciado': question.statement,
    'dificuldade': difficultyValue(question.difficulty),
    'alternativas': [
      for (var i = 0; i < question.options.length; i++)
        {'letra': String.fromCharCode(65 + i), 'texto': question.options[i]},
    ],
    'letraCorreta': String.fromCharCode(65 + question.correctOptionIndex),
  };
}
