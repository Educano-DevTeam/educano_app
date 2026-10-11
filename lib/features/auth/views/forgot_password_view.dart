import '../../../core/theme/educano_colors.dart';
import 'package:flutter/material.dart';
import '../widgets/validators.dart';
import '../../../core/constants/app_breakpoints.dart';
import '../../../services/auth_service.dart';
import '../widgets/app_buttons.dart';
import '../widgets/app_logo.dart';
import '../widgets/app_text_field.dart';
import '../widgets/auth_card.dart';

class ForgotPasswordView extends StatefulWidget {
  const ForgotPasswordView({super.key});

  @override
  State<ForgotPasswordView> createState() => _ForgotPasswordViewState();
}

class _ForgotPasswordViewState extends State<ForgotPasswordView> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  bool _isLoading = false;
  bool _linkSent = false;
  String? _errorMessage;

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
      setState(() {
        _errorMessage = result.message ?? 'Não foi possível enviar o link.';
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

          if (isWeb) {
            // Nó "Card Recuperação" do Figma: card branco de 520px centralizado.
            return Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(vertical: 40),
                child: AuthCard(width: 520, child: _buildContent(isWeb: true)),
              ),
            );
          }

          return SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 28,
                  vertical: 40,
                ),
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
            style: TextStyle(
              fontSize: isWeb ? 28 : 22,
              fontWeight: FontWeight.w600,
              color: EducanoColors.textPrimary,
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
            style: TextStyle(
              fontSize: isWeb ? 15 : 13,
              color: EducanoColors.textSecondary,
            ),
          ),
          if (_errorMessage != null) ...[
            const SizedBox(height: 16),
            AuthMessage(message: _errorMessage!, isError: true),
          ],
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
