import 'package:flutter/material.dart';

import '../../../core/layout/app_scaffold.dart';
import '../../../core/navigation/app_menu.dart';
import '../models/material_route_args.dart';
import '../widgets/material_content.dart';

class CourseMaterialPage extends StatelessWidget {
  final MaterialRouteArgs arguments;

  const CourseMaterialPage({super.key, required this.arguments});

  @override
  Widget build(BuildContext context) => AppScaffold(
        selectedMenu: AppMenu.home,
        child: MaterialContent(
          selectedMenu: AppMenu.home,
          arguments: arguments,
        ),
      );
}
