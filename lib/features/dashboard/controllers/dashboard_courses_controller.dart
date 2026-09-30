import 'package:educano_app/core/models/dashboard_course.dart';

class DashboardCoursesRepository {
  DashboardCoursesRepository._();

  static final DashboardCoursesRepository instance =
      DashboardCoursesRepository._();

  final List<DashboardCourse> _courses = [
    DashboardCourse(
      name: 'Matemática',
      description: 'Curso completo de matemática.',
      category: 'Exatas',
      status: 'Ativo',
      createdAt: '01/07/2026',
      enrolled: 72,
      capacity: 100,
    ),
    DashboardCourse(
      name: 'Português',
      description: 'Curso de língua portuguesa.',
      category: 'Humanas',
      status: 'Ativo',
      createdAt: '05/07/2026',
      enrolled: 48,
      capacity: 80,
    ),
  ];

  List<DashboardCourse> getAll() {
    return List.unmodifiable(_courses);
  }

  void add(DashboardCourse course) {
    _courses.add(course);
  }

  void update(
    DashboardCourse oldCourse,
    DashboardCourse updatedCourse,
  ) {
    final index = _courses.indexOf(oldCourse);

    if (index == -1) return;

    _courses[index] = updatedCourse;
  }

  void delete(DashboardCourse course) {
    _courses.remove(course);
  }
}