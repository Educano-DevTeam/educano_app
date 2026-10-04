class AppRoutes {
  AppRoutes._();

  // Telas principais (todos os usuários)
  static const String home = '/';
  static const String flashcards = '/flashcards';
  static const String ranking = '/ranking';
  static const String storeInventory = '/loja_e_inventario';
  static const String profile = '/perfil';
  static const String settings = '/configuracoes';

  // Telas de administração  
  static const String dashboard = '/dashboard';
  static const String dashboardUsers = '/dashboard/usuarios';
  static const String dashboardCourses = '/dashboard/cursos';
  static const String dashboardQuestions = '/dashboard/questoes';
  static const String dashboardItems = '/dashboard/itens';

  // SubTelas (precisa acessar dentro das principais)
  static const String course = '/curso';
  static const String material = '/curso/material';
}
