import 'package:flutter/material.dart';
import 'core/app_theme.dart';
import 'screens/forgot_password_screen.dart';
import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';

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
      initialRoute: LoginScreen.routeName,
      routes: {
        LoginScreen.routeName: (context) => const LoginScreen(),
        SignupScreen.routeName: (context) => const SignupScreen(),
        ForgotPasswordScreen.routeName: (context) => const ForgotPasswordScreen(),
        // A tela de Verificação de Conta precisa do e-mail como parâmetro,
        // por isso é aberta via Navigator.push diretamente nas telas de
        // origem (ver signup_screen.dart), e não por rota nomeada aqui.
      },
    );
  }
}
