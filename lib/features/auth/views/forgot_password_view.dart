import '../../../core/theme/educano_colors.dart';
import 'package:flutter/material.dart';
import '../widgets/validators.dart';
import '../../../core/constants/app_breakpoints.dart';
import '../../../services/auth_service.dart';
import '../widgets/app_buttons.dart';
import '../widgets/app_logo.dart';
import '../widgets/app_text_field.dart';
import '../widgets/auth_card.dart';
import '../../../core/navigation/app_routes.dart';

class ForgotPasswordView extends StatefulWidget {
  const ForgotPasswordView({super.key});

  @override
  State<ForgotPasswordView> createState() => _ForgotPasswordViewState();
}

class _ForgotPasswordViewState extends State<ForgotPasswordView> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _codeController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  bool _isLoading = false;
  bool _codeSent = false;
  bool _obscurePassword = true;
  String? _errorMessage;
  String? _infoMessage;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // O login envia o e-mail quando a senha expirou.
    final email = ModalRoute.of(context)?.settings.arguments;
    if (email is String && _emailController.text.isEmpty) {
      _emailController.text = email;
      _infoMessage =
          'Sua senha expirou (validade de 90 dias). Redefina para continuar.';
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _codeController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _handleSendCode() async {
    FocusScope.of(context).unfocus();
    if (!_codeSent && !_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final result = await AuthService.instance.sendPasswordResetCode(
      email: _emailController.text,
    );

    if (!mounted) return;
    setState(() {
      _isLoading = false;
      if (result.success) {
        _codeSent = true;
        _infoMessage = null;
      } else {
        _errorMessage = result.message ?? 'Não foi possível enviar o código.';
      }
    });
  }

  Future<void> _handleReset() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final result = await AuthService.instance.resetPassword(
      email: _emailController.text,
      code: _codeController.text,
      newPassword: _passwordController.text,
    );

    if (!mounted) return;
    if (result.success) {
      await showDialog<void>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('Senha redefinida'),
          content: Text(
            result.message ?? 'Sua senha foi redefinida. Você já pode entrar.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Ir para o login'),
            ),
          ],
        ),
      );
      if (!mounted) return;
      Navigator.of(
        context,
      ).pushNamedAndRemoveUntil(AppRoutes.login, (route) => false);
    } else {
      setState(() {
        _isLoading = false;
        _errorMessage = result.message ?? 'Não foi possível redefinir a senha.';
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
            _codeSent ? 'Redefina sua senha' : 'Esqueceu sua senha?',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: isWeb ? 28 : 22,
              fontWeight: FontWeight.w600,
              color: EducanoColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _codeSent
                ? 'Se o e-mail ${Validators.maskEmail(_emailController.text.trim())} estiver cadastrado, você receberá um código de 6 caracteres. Verifique também a caixa de spam.'
                : isWeb
                ? 'Sem problemas! Digite seu e-mail e enviaremos um código para você redefinir sua senha.'
                : 'Digite seu e-mail e enviaremos um código para redefinir sua senha.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: isWeb ? 15 : 13,
              color: EducanoColors.textSecondary,
            ),
          ),
          if (_infoMessage != null) ...[
            const SizedBox(height: 16),
            AuthMessage(message: _infoMessage!, isError: false),
          ],
          if (_errorMessage != null) ...[
            const SizedBox(height: 16),
            AuthMessage(message: _errorMessage!, isError: true),
          ],
          const SizedBox(height: 20),
          if (!_codeSent) ...[
            AppTextField(
              label: 'E-mail',
              hint: 'Digite seu e-mail cadastrado',
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.done,
              validator: Validators.email,
              onFieldSubmitted: (_) => _handleSendCode(),
            ),
            const SizedBox(height: 20),
            PrimaryButton(
              label: 'Enviar código',
              isLoading: _isLoading,
              onPressed: _handleSendCode,
            ),
          ] else ...[
            AppTextField(
              label: 'Código',
              hint: 'Código recebido por e-mail',
              controller: _codeController,
              validator: (value) =>
                  RegExp(r'^[A-Za-z0-9]{6}$').hasMatch(value?.trim() ?? '')
                  ? null
                  : 'Digite o código de 6 caracteres',
            ),
            const SizedBox(height: 16),
            AppTextField(
              label: 'Nova senha',
              hint: 'Digite a nova senha',
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
                onPressed: () =>
                    setState(() => _obscurePassword = !_obscurePassword),
              ),
            ),
            const SizedBox(height: 16),
            AppTextField(
              label: 'Confirmar nova senha',
              hint: 'Digite a nova senha novamente',
              controller: _confirmController,
              obscureText: _obscurePassword,
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (_) => _handleReset(),
              validator: (value) =>
                  Validators.confirmPassword(value, _passwordController.text),
            ),
            const SizedBox(height: 20),
            PrimaryButton(
              label: 'Redefinir senha',
              isLoading: _isLoading,
              onPressed: _handleReset,
            ),
            const SizedBox(height: 12),
            AppOutlineButton(
              label: 'Reenviar código',
              isLoading: false,
              onPressed: _isLoading ? null : _handleSendCode,
            ),
          ],
          const SizedBox(height: 16),
          InlineLinkRow(
            text: 'Lembrou sua senha?',
            linkText: 'Voltar para o login',
            onTap: () => Navigator.of(
              context,
            ).pushNamedAndRemoveUntil(AppRoutes.login, (route) => false),
          ),
        ],
      ),
    );
  }
}
