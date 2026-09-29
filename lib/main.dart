import 'package:flutter/material.dart';
import 'core/app_theme.dart';
import 'screens/ranking_screen.dart';
import 'screens/perfil_screen.dart';
import 'screens/configuracoes_screen.dart';

void main() {
  runApp(const EducanoApp());
}

class EducanoApp extends StatelessWidget {
  const EducanoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Educano',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      initialRoute: '/ranking',
      routes: {
        '/ranking': (context) => const RankingScreen(),
        '/perfil': (context) => const PerfilScreen(),
        '/configuracoes': (context) => const ConfiguracoesScreen(),
      },
    );
  }
}
