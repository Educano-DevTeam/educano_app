import 'package:educano_app/core/navigation/app_menu.dart';
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
      routes: {
        AppRoutes.home: (_) => const HomePage(),
        AppRoutes.flashcards: (_) => const FlashcardsPage(),
        AppRoutes.ranking: (_) => const RankingPage(),
        AppRoutes.store_inventory: (_) => const StoreInventoryPage(),
        AppRoutes.dashboard: (context) {
          final menu = ModalRoute.of(context)?.settings.arguments as AppMenu?;
          return DashboardPage(initialMenu: menu ?? AppMenu.dashboard);
        },
      },
    );
  }
}
