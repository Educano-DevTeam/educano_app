class AppRoutes {
  AppRoutes._();

  // Telas principais (todos os usuários)
  static const String home = '/';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String verifyAccount = '/verify-account';
  static const String forgotPassword = '/forgot-password';
  static const String flashcards = '/flashcards';
  static const String ranking = '/ranking';
  static const String storeInventory = '/loja_e_inventario';
  static const String profile = '/perfil';
  static const String settings = '/configuracoes';
  
  // SubTelas (precisa acessar dentro das principais)
  static const String accountPlan = '/perfil/planos';
  static const String courses = '/cursos';
  static const String course = '/curso';
  static const String material = '/curso/material';
  static const String lastExams = '/simulados';
  static const String examConfig = '/simulados/config';
  static const String exam = '/simulado'; 
  static const String activity = '/atividade';
  static const String examFinish = '/simulados/finalizar';
  static const String examResult = '/simulados/nota';
  
  // Telas de administração  
  static const String dashboard = '/dashboard';
  static const String dashboardUsers = '/dashboard/usuarios';
  static const String dashboardCourses = '/dashboard/cursos';
  static const String dashboardQuestions = '/dashboard/questoes';
  static const String dashboardItems = '/dashboard/itens';
}
