import 'package:flutter/material.dart';

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
      home: const DashboardPage(),
    );
  }
}