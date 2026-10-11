import '../../../core/theme/educano_colors.dart';
import 'package:flutter/material.dart';
import '../widgets/validators.dart';
import '../../../core/constants/app_breakpoints.dart';
import '../../../core/navigation/app_routes.dart';
import '../../../core/navigation/navigation_service.dart';
import '../../../services/auth_service.dart';
import '../widgets/app_buttons.dart';
import '../widgets/app_logo.dart';
import '../widgets/app_text_field.dart';
import '../widgets/brand_panel.dart';

class SignupView extends StatefulWidget {
  const SignupView({super.key});

  @override
  State<SignupView> createState() => _SignupViewState();
}

class _SignupViewState extends State<SignupView> {
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
  String? _errorMessage;

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
    if (result.success) {
      NavigationService.pushReplacementNamed(
        AppRoutes.verifyAccount,
        arguments: _emailController.text.trim(),
      );
    } else {
      setState(() {
        _isLoading = false;
        _errorMessage = result.message ?? 'Não foi possível criar a conta.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: EducanoColors.background,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isWeb = constraints.maxWidth >= AppBreakpoints.expanded;
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
                  color: EducanoColors.primaryBlue,
                  padding: const EdgeInsets.symmetric(vertical: 32),
                  child: Column(
                    children: [
                      const AppLogo(size: 56),
                      const SizedBox(height: 10),
                      Text(
                        'Educano',
                        style: const TextStyle(
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
            style: TextStyle(
              fontSize: isWeb ? 32 : 22,
              fontWeight: FontWeight.w600,
              color: EducanoColors.textPrimary,
            ),
          ),
          SizedBox(height: isWeb ? 12 : 6),
          Text(
            isWeb
                ? 'Preencha os dados abaixo para começar a estudar.'
                : 'Comece a estudar com trilhas personalizadas.',
            style: TextStyle(
              fontSize: isWeb ? 16 : 13,
              color: EducanoColors.textSecondary,
            ),
          ),
          if (_errorMessage != null) ...[
            const SizedBox(height: 16),
            AuthMessage(message: _errorMessage!, isError: true),
          ],
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
                color: EducanoColors.textSecondary,
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
                color: EducanoColors.textSecondary,
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
              activeColor: EducanoColors.primaryBlue,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              side: BorderSide(
                color: _termsError ? EducanoColors.error : EducanoColors.border,
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
                style: const TextStyle(
                  fontSize: 13,
                  color: EducanoColors.textSecondary,
                ),
                children: [
                  const TextSpan(text: 'Eu concordo com os '),
                  TextSpan(
                    text: 'Termos de Uso',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: EducanoColors.primaryBlue,
                    ),
                  ),
                  const TextSpan(text: ' e '),
                  TextSpan(
                    text: 'Política de Privacidade',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: EducanoColors.primaryBlue,
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
