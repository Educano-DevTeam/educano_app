import 'package:flutter/material.dart';

import '../../../core/navigation/app_menu.dart';
import '../models/material_route_args.dart';
import '../views/material_view.dart';

class MaterialContent extends StatelessWidget {
  final AppMenu selectedMenu;
  final MaterialRouteArgs arguments;

  const MaterialContent({
    super.key,
    required this.selectedMenu,
    required this.arguments,
  });

  @override
  Widget build(BuildContext context) {
    if (selectedMenu != AppMenu.home) return const SizedBox.shrink();

    return MaterialView(
      courseId: arguments.courseId,
      sessionId: arguments.sessionId,
      moduleId: arguments.moduleId,
      materialId: arguments.materialId,
    );
  }
}
