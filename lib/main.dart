import 'package:educano_app/core/navigation/app_menu.dart';
import 'package:educano_app/features/dashboard/pages/dashboard_items_page.dart';
import 'package:educano_app/features/dashboard/pages/dashcoard_courses_page.dart';
import 'package:educano_app/features/dashboard/widgets/dashboard_courses_content.dart';
import 'package:educano_app/features/dashboard/widgets/dashcoard_items_content.dart';
import 'package:educano_app/features/flashcards/pages/flashcards_page.dart';
import 'package:educano_app/features/home/pages/home_page.dart';
import 'package:educano_app/features/ranking/pages/ranking_page.dart';
import 'package:educano_app/features/store_inventory/pages/store_inventory_page.dart';
import 'package:flutter/material.dart';

import 'core/navigation/app_routes.dart';
import 'core/navigation/navigation_service.dart';
import 'core/theme/educano_theme.dart';

import 'features/dashboard/pages/dashboard_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const EducanoApp());
}

class EducanoApp extends StatelessWidget {
  const EducanoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Educano',
      debugShowCheckedModeBanner: false,
      theme: EducanoTheme.lightTheme,
      navigatorKey: NavigationService.navigatorKey,
      initialRoute: AppRoutes.home,
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case AppRoutes.home:
            return _buildRoute(const HomePage(), settings);

          case AppRoutes.flashcards:
            return _buildRoute(const FlashcardsPage(), settings);

          case AppRoutes.ranking:
            return _buildRoute(const RankingPage(), settings);

          case AppRoutes.storeInventory:
            return _buildRoute(const StoreInventoryPage(), settings);

          case AppRoutes.dashboard:
            return _buildRoute(DashboardPage(), settings);

          case AppRoutes.dashboardCourses:
            return _buildRoute(DashboardCoursesPage(), settings);

          case AppRoutes.dashboardItems:
            return _buildRoute(DashboardItemsPage(), settings);

          default:
            return _buildRoute(const HomePage(), settings);
        }
      },
    );
  }

  Route<dynamic> _buildRoute(Widget page, RouteSettings settings) {
    return PageRouteBuilder(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) {
        return page;
      },
      transitionDuration: Duration.zero,
      reverseTransitionDuration: Duration.zero,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return child;
      },
    );
  }
}
