import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/app_theme.dart';
import '../core/breakpoints.dart';
import '../core/validators.dart';
import '../services/auth_service.dart';
import '../widgets/app_buttons.dart';
import '../widgets/app_logo.dart';
import '../widgets/app_text_field.dart';
import '../widgets/auth_card.dart';

class ForgotPasswordScreen extends StatefulWidget {
  static const routeName = '/forgot-password';

  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  bool _isLoading = false;
  bool _linkSent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handleSendLink() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final result = await AuthService.instance.sendPasswordResetLink(
      email: _emailController.text,
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (result.success) {
      setState(() => _linkSent = true);
    } else {
      _showSnackBar(
        result.message ?? 'Não foi possível enviar o link.',
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

          if (isWeb) {
            // Nó "Card Recuperação" do Figma: card branco de 520px centralizado.
            return Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(vertical: 40),
                child: AuthCard(
                  width: 520,
                  child: _buildContent(isWeb: true),
                ),
              ),
            );
          }

          return SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 28, vertical: 40),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 480),
                  child: _buildContent(isWeb: false),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildContent({required bool isWeb}) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          AppLogo(size: isWeb ? 72 : 64),
          const SizedBox(height: 20),
          Text(
            _linkSent ? 'Verifique seu e-mail' : 'Esqueceu sua senha?',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: isWeb ? 28 : 22,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _linkSent
                ? 'Enviamos um link de recuperação para ${Validators.maskEmail(_emailController.text.trim())}. Verifique também a caixa de spam.'
                : isWeb
                    ? 'Sem problemas! Digite seu e-mail e enviaremos um link para você redefinir sua senha.'
                    : 'Digite seu e-mail e enviaremos um link para redefinir sua senha.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: isWeb ? 15 : 13,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 20),
          if (!_linkSent) ...[
            AppTextField(
              label: 'E-mail',
              hint: 'Digite seu e-mail cadastrado',
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.done,
              validator: Validators.email,
              onFieldSubmitted: (_) => _handleSendLink(),
            ),
            const SizedBox(height: 20),
            PrimaryButton(
              label: 'Enviar link de recuperação',
              isLoading: _isLoading,
              onPressed: _handleSendLink,
            ),
          ] else ...[
            AppOutlineButton(
              label: 'Reenviar link',
              isLoading: _isLoading,
              onPressed: _handleSendLink,
            ),
          ],
          const SizedBox(height: 16),
          InlineLinkRow(
            text: 'Lembrou sua senha?',
            linkText: 'Voltar para o login',
            onTap: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }
}
