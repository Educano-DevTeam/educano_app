import '../../course/models/course_models.dart';

class MaterialRouteArgs {
  final String courseId;
  final String sessionId;
  final String moduleId;
  final String materialId;
  final String? materialUrl;
  final MaterialKind? materialKind;
  final String? title;
  final String? description;
  final bool completed;

  const MaterialRouteArgs({
    required this.courseId,
    required this.sessionId,
    required this.moduleId,
    required this.materialId,
    this.materialUrl,
    this.materialKind,
    this.title,
    this.description,
    this.completed = false,
  });
}
