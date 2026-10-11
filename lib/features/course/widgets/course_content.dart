import 'package:flutter/material.dart';

import '../../../core/navigation/app_menu.dart';
import '../views/course_view.dart';

class CourseContent extends StatelessWidget {
  final String courseId;
  final AppMenu selectedMenu;

  const CourseContent({
    super.key,
    required this.courseId,
    required this.selectedMenu,
  });

  @override
  Widget build(BuildContext context) {
    if (selectedMenu != AppMenu.home) return const SizedBox.shrink();
    return CourseView(courseId: courseId);
  }
}
