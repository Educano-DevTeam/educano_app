import 'package:flutter/material.dart';

import '../../../core/layout/app_scaffold.dart';
import '../../../core/navigation/app_menu.dart';
import '../widgets/course_content.dart';

class CoursePage extends StatelessWidget {
  final String courseId;

  const CoursePage({super.key, required this.courseId});

  @override
  Widget build(BuildContext context) => AppScaffold(
    selectedMenu: AppMenu.home,
    child: CourseContent(courseId: courseId, selectedMenu: AppMenu.home),
  );
}
