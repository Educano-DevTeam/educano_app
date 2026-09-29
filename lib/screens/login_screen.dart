import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/app_theme.dart';
import '../core/breakpoints.dart';
import '../core/validators.dart';
import '../services/auth_service.dart';
import '../widgets/app_buttons.dart';
import '../widgets/app_logo.dart';
import '../widgets/app_text_field.dart';
import '../widgets/brand_panel.dart';
import 'forgot_password_screen.dart';
import 'signup_screen.dart';

class LoginScreen extends StatefulWidget {
  static const routeName = '/login';

  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final result = await AuthService.instance.login(
      email: _emailController.text,
      password: _passwordController.text,
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (result.success) {
      _showSnackBar(result.message ?? 'Login realizado com sucesso!');
      // TODO: navegar para a tela Home real do app.
    } else {
      _showSnackBar(result.message ?? 'Não foi possível entrar.', isError: true);
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: isError ? AppColors.error : AppColors.success,
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  void _goToSignup() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const SignupScreen()),
    );
  }

  void _goToForgotPassword() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const ForgotPasswordScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWeb = constraints.maxWidth >= AppBreakpoints.web;
          return isWeb ? _buildWebLayout() : _buildMobileLayout();
        },
      ),
    );
  }

  // ---------------------------------------------------------------------
  // Layout WEB — nó "Tela Login (WEB)" do Figma.
  // Painel de marca azul de 600px à esquerda + formulário de 400px à direita.
  // ---------------------------------------------------------------------
  Widget _buildWebLayout() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const BrandPanel(
          tagline:
              'Aprenda no seu ritmo. Evolua todos os dias com trilhas, flashcards e simulados feitos para o seu crescimento.',
        ),
        Expanded(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 40),
              child: SizedBox(
                width: 400,
                child: _buildForm(isWeb: true),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------
  // Layout MOBILE — nó "Tela Login (MOBILE)" do Figma.
  // Header azul no topo + formulário abaixo.
  // ---------------------------------------------------------------------
  Widget _buildMobileLayout() {
    return SafeArea(
      child: SingleChildScrollView(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  width: double.infinity,
                  color: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 40),
                  child: Column(
                    children: [
                      const AppLogo(size: 64),
                      const SizedBox(height: 12),
                      Text(
                        'Educano',
                        style: GoogleFonts.inter(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: _buildForm(isWeb: false),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Formulário compartilhado pelos dois layouts — só os tamanhos de fonte
  /// e espaçamentos mudam entre mobile e web.
  Widget _buildForm({required bool isWeb}) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Bem-vindo de volta!',
            style: GoogleFonts.inter(
              fontSize: isWeb ? 32 : 24,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: isWeb ? 12 : 6),
          Text(
            isWeb
                ? 'Entre com sua conta para continuar seus estudos.'
                : 'Entre com sua conta para continuar.',
            style: GoogleFonts.inter(
              fontSize: isWeb ? 16 : 14,
              color: AppColors.textSecondary,
            ),
          ),
          SizedBox(height: isWeb ? 24 : 20),
          AppTextField(
            label: 'E-mail',
            hint: 'Digite seu e-mail',
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            validator: Validators.email,
          ),
          SizedBox(height: isWeb ? 24 : 20),
          AppTextField(
            label: 'Senha',
            hint: 'Digite sua senha',
            controller: _passwordController,
            obscureText: _obscurePassword,
            validator: Validators.loginPassword,
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => _handleLogin(),
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
                color: AppColors.textSecondary,
              ),
              onPressed: () {
                setState(() => _obscurePassword = !_obscurePassword);
              },
            ),
          ),
          SizedBox(height: isWeb ? 16 : 8),
          Align(
            alignment: Alignment.centerRight,
            child: GestureDetector(
              onTap: _goToForgotPassword,
              child: Text(
                'Esqueci minha senha',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
          SizedBox(height: isWeb ? 24 : 20),
          PrimaryButton(
            label: 'Entrar',
            isLoading: _isLoading,
            onPressed: _handleLogin,
          ),
          SizedBox(height: isWeb ? 24 : 20),
          InlineLinkRow(
            text: 'Não tem uma conta?',
            linkText: 'Criar conta',
            onTap: _goToSignup,
          ),
        ],
      ),
    );
  }
}
