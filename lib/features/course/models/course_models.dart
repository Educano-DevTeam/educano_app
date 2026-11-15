import 'dart:typed_data';

import 'package:flutter/material.dart';

enum MaterialKind { video, audio, pdf, activity }

enum ActivityQuestionDifficulty { easy, medium, hard }

class Course {
  final String id;
  final String title;
  final String category;
  final String duration;
  final String description;
  final String imageAsset;
  final double progress;
  final int completedMaterials;
  final int totalMaterials;
  final List<CourseSession> sessions;

  // Dados vindos da API.
  final String? imageUrl;
  final bool canEdit;
  final bool enrolled;
  final int enrolledCount;
  final String? creatorName;
  final String status;

  const Course({
    required this.id,
    required this.title,
    required this.category,
    required this.duration,
    required this.description,
    required this.imageAsset,
    required this.progress,
    required this.completedMaterials,
    required this.totalMaterials,
    required this.sessions,
    this.imageUrl,
    this.canEdit = false,
    this.enrolled = false,
    this.enrolledCount = 0,
    this.creatorName,
    this.status = 'ATIVO',
  });

  Course copyWith({
    String? title,
    String? category,
    String? duration,
    String? description,
    String? imageAsset,
    double? progress,
    int? completedMaterials,
    int? totalMaterials,
    List<CourseSession>? sessions,
    bool? canEdit,
  }) => Course(
    id: id,
    title: title ?? this.title,
    category: category ?? this.category,
    duration: duration ?? this.duration,
    description: description ?? this.description,
    imageAsset: imageAsset ?? this.imageAsset,
    progress: progress ?? this.progress,
    completedMaterials: completedMaterials ?? this.completedMaterials,
    totalMaterials: totalMaterials ?? this.totalMaterials,
    sessions: sessions ?? this.sessions,
    imageUrl: imageUrl,
    canEdit: canEdit ?? this.canEdit,
    enrolled: enrolled,
    enrolledCount: enrolledCount,
    creatorName: creatorName,
    status: status,
  );
}

class CourseSession {
  final String id;
  final String title;
  final String subtitle;
  final String description;
  final List<CourseModule> modules;

  const CourseSession({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.modules,
  });

  CourseSession copyWith({
    String? title,
    String? subtitle,
    String? description,
    List<CourseModule>? modules,
  }) => CourseSession(
    id: id,
    title: title ?? this.title,
    subtitle: subtitle ?? this.subtitle,
    description: description ?? this.description,
    modules: modules ?? this.modules,
  );
}

class CourseModule {
  final String id;
  final String title;
  final String description;
  final List<CourseMaterial> materials;
  final bool expanded;

  const CourseModule({
    required this.id,
    required this.title,
    required this.description,
    required this.materials,
    this.expanded = false,
  });

  double get progress {
    if (materials.isEmpty) return 0;
    return materials.where((m) => m.completed).length / materials.length;
  }

  CourseModule copyWith({
    String? title,
    String? description,
    List<CourseMaterial>? materials,
    bool? expanded,
  }) => CourseModule(
    id: id,
    title: title ?? this.title,
    description: description ?? this.description,
    materials: materials ?? this.materials,
    expanded: expanded ?? this.expanded,
  );
}

class CourseMaterial {
  final String id;
  final MaterialKind kind;
  final String title;
  final String description;
  final String? fileName;
  final String? fileUrl;
  final Uint8List? fileBytes;
  final String? filePath;
  final int? fileSizeBytes;
  final int? pageCount;
  final int? durationSeconds;
  final Activity? activity;
  final bool completed;

  const CourseMaterial({
    required this.id,
    required this.kind,
    required this.title,
    required this.description,
    this.fileName,
    this.fileUrl,
    this.fileBytes,
    this.filePath,
    this.fileSizeBytes,
    this.pageCount,
    this.durationSeconds,
    this.activity,
    this.completed = false,
  });

  String get kindLabel => switch (kind) {
    MaterialKind.video => 'Vídeo',
    MaterialKind.audio => 'Áudio',
    MaterialKind.pdf => 'PDF',
    MaterialKind.activity => 'Atividade',
  };

  String get metadataLabel {
    if (kind == MaterialKind.activity && activity != null) {
      return '${activity!.totalQuestions} questões';
    }
    if (durationSeconds != null) {
      final m = durationSeconds! ~/ 60;
      final s = durationSeconds! % 60;
      return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')} min';
    }
    if (pageCount != null) return '$pageCount páginas';
    if (fileSizeBytes != null) {
      final kb = fileSizeBytes! / 1024;
      return kb < 1024
          ? '${kb.round()} KB'
          : '${(kb / 1024).toStringAsFixed(1)} MB';
    }
    return kindLabel;
  }

  CourseMaterial copyWith({bool? completed}) => CourseMaterial(
    id: id,
    kind: kind,
    title: title,
    description: description,
    fileName: fileName,
    fileUrl: fileUrl,
    fileBytes: fileBytes,
    filePath: filePath,
    fileSizeBytes: fileSizeBytes,
    pageCount: pageCount,
    durationSeconds: durationSeconds,
    activity: activity,
    completed: completed ?? this.completed,
  );
}

class Activity {
  final String theme;
  final int durationMinutes;
  final List<ActivityQuestion> questions;

  /// Total de questões quando elas não vêm junto (detalhe do curso na API).
  final int? questionCount;

  /// IDs das questões do banco vinculadas (usado na edição).
  final List<String> questionIds;

  const Activity({
    required this.theme,
    required this.durationMinutes,
    required this.questions,
    this.questionCount,
    this.questionIds = const [],
  });

  int get totalQuestions => questionCount ?? questions.length;
}

class ActivityQuestion {
  final String id;
  final String title;
  final String statement;
  final ActivityQuestionDifficulty difficulty;
  final List<String> options;

  /// Índice da alternativa correta; -1 enquanto o gabarito não é revelado.
  final int correctOptionIndex;

  // Dados do banco de questões da API.
  final String subject;
  final String topic;
  final String explanation;
  final List<String> optionIds;
  final String? authorId;
  final String? authorName;

  const ActivityQuestion({
    required this.id,
    required this.title,
    required this.statement,
    required this.difficulty,
    required this.options,
    required this.correctOptionIndex,
    this.subject = '',
    this.topic = '',
    this.explanation = '',
    this.optionIds = const [],
    this.authorId,
    this.authorName,
  });
}

extension MaterialKindIcon on MaterialKind {
  IconData get icon => switch (this) {
    MaterialKind.video => Icons.play_circle_outline_rounded,
    MaterialKind.audio => Icons.headphones_rounded,
    MaterialKind.pdf => Icons.picture_as_pdf_outlined,
    MaterialKind.activity => Icons.assignment_rounded,
  };
}

extension ActivityDifficultyLabel on ActivityQuestionDifficulty {
  String get label => switch (this) {
    ActivityQuestionDifficulty.easy => 'Fácil',
    ActivityQuestionDifficulty.medium => 'Médio',
    ActivityQuestionDifficulty.hard => 'Difícil',
  };
}
