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
import 'verify_account_screen.dart';

class SignupScreen extends StatefulWidget {
  static const routeName = '/signup';

  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _acceptedTerms = false;
  bool _isLoading = false;
  bool _termsError = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleSignup() async {
    FocusScope.of(context).unfocus();
    final isFormValid = _formKey.currentState!.validate();

    setState(() => _termsError = !_acceptedTerms);

    if (!isFormValid || !_acceptedTerms) return;

    setState(() => _isLoading = true);

    final result = await AuthService.instance.register(
      name: _nameController.text,
      email: _emailController.text,
      password: _passwordController.text,
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (result.success) {
      _showSnackBar(result.message ?? 'Conta criada com sucesso!');
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) =>
              VerifyAccountScreen(email: _emailController.text.trim()),
        ),
      );
    } else {
      _showSnackBar(
        result.message ?? 'Não foi possível criar a conta.',
        isError: true,
      );
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

  // Layout WEB — nó "Tela Cadastro (WEB)": painel de marca 600px + form 420px.
  Widget _buildWebLayout() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const BrandPanel(
          tagline:
              'Crie sua conta gratuita e comece a estudar com trilhas personalizadas, flashcards e simulados.',
        ),
        Expanded(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 40),
              child: SizedBox(
                width: 420,
                child: _buildForm(isWeb: true),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Layout MOBILE — nó "Tela Cadastro (MOBILE)": header azul + formulário.
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
                  padding: const EdgeInsets.symmetric(vertical: 32),
                  child: Column(
                    children: [
                      const AppLogo(size: 56),
                      const SizedBox(height: 10),
                      Text(
                        'Educano',
                        style: GoogleFonts.inter(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 28, 24, 32),
                  child: _buildForm(isWeb: false),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildForm({required bool isWeb}) {
    final gap = isWeb ? 20.0 : 16.0;

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Crie sua conta',
            style: GoogleFonts.inter(
              fontSize: isWeb ? 32 : 22,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: isWeb ? 12 : 6),
          Text(
            isWeb
                ? 'Preencha os dados abaixo para começar a estudar.'
                : 'Comece a estudar com trilhas personalizadas.',
            style: GoogleFonts.inter(
              fontSize: isWeb ? 16 : 13,
              color: AppColors.textSecondary,
            ),
          ),
          SizedBox(height: gap),
          AppTextField(
            label: 'Nome completo',
            hint: 'Digite seu nome completo',
            controller: _nameController,
            keyboardType: TextInputType.name,
            validator: Validators.name,
          ),
          SizedBox(height: gap),
          AppTextField(
            label: 'E-mail',
            hint: 'Digite seu e-mail',
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            validator: Validators.email,
          ),
          SizedBox(height: gap),
          AppTextField(
            label: 'Senha',
            hint: 'Digite sua senha',
            controller: _passwordController,
            obscureText: _obscurePassword,
            validator: Validators.password,
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
          SizedBox(height: gap),
          AppTextField(
            label: 'Confirmar senha',
            hint: 'Digite sua senha novamente',
            controller: _confirmPasswordController,
            obscureText: _obscureConfirmPassword,
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => _handleSignup(),
            validator: (value) => Validators.confirmPassword(
              value,
              _passwordController.text,
            ),
            suffixIcon: IconButton(
              icon: Icon(
                _obscureConfirmPassword
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
                color: AppColors.textSecondary,
              ),
              onPressed: () {
                setState(() {
                  _obscureConfirmPassword = !_obscureConfirmPassword;
                });
              },
            ),
          ),
          SizedBox(height: gap),
          _buildTermsCheckbox(isWeb: isWeb),
          SizedBox(height: gap),
          PrimaryButton(
            label: 'Criar conta',
            isLoading: _isLoading,
            onPressed: _handleSignup,
          ),
          SizedBox(height: gap),
          InlineLinkRow(
            text: 'Já tem uma conta?',
            linkText: 'Entrar',
            onTap: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  Widget _buildTermsCheckbox({required bool isWeb}) {
    return InkWell(
      onTap: () {
        setState(() {
          _acceptedTerms = !_acceptedTerms;
          if (_acceptedTerms) _termsError = false;
        });
      },
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 20,
            height: 20,
            child: Checkbox(
              value: _acceptedTerms,
              activeColor: AppColors.primary,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              side: BorderSide(
                color: _termsError ? AppColors.error : AppColors.border,
                width: 1.5,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5),
              ),
              onChanged: (value) {
                setState(() {
                  _acceptedTerms = value ?? false;
                  if (_acceptedTerms) _termsError = false;
                });
              },
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
                children: [
                  const TextSpan(text: 'Eu concordo com os '),
                  TextSpan(
                    text: 'Termos de Uso',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                  const TextSpan(text: ' e '),
                  TextSpan(
                    text: 'Política de Privacidade',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
