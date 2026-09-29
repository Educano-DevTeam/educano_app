import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/app_theme.dart';
import '../core/breakpoints.dart';
import '../core/validators.dart';
import '../services/auth_service.dart';
import '../widgets/app_buttons.dart';
import '../widgets/app_logo.dart';
import '../widgets/auth_card.dart';
import 'login_screen.dart';

class VerifyAccountScreen extends StatefulWidget {
  static const routeName = '/verify-account';

  /// E-mail para o qual o código de verificação foi enviado.
  final String email;

  const VerifyAccountScreen({super.key, required this.email});

  @override
  State<VerifyAccountScreen> createState() => _VerifyAccountScreenState();
}

class _VerifyAccountScreenState extends State<VerifyAccountScreen> {
  static const int _codeLength = 6;
  static const int _resendCooldownSeconds = 30;

  final List<TextEditingController> _controllers =
      List.generate(_codeLength, (_) => TextEditingController());
  final List<FocusNode> _focusNodes =
      List.generate(_codeLength, (_) => FocusNode());

  bool _isVerifying = false;
  bool _isResending = false;
  bool _hasError = false;
  Timer? _cooldownTimer;
  int _cooldownSecondsLeft = 0;

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    _cooldownTimer?.cancel();
    super.dispose();
  }

  String get _code => _controllers.map((c) => c.text).join();

  void _onDigitChanged(String value, int index) {
    if (_hasError) setState(() => _hasError = false);

    if (value.isNotEmpty && index < _codeLength - 1) {
      _focusNodes[index + 1].requestFocus();
    }
    if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }

    // Verifica automaticamente quando todos os dígitos são preenchidos.
    if (_code.length == _codeLength &&
        !_controllers.any((c) => c.text.isEmpty)) {
      FocusScope.of(context).unfocus();
      _handleVerify();
    }
  }

  Future<void> _handleVerify() async {
    if (_code.length != _codeLength) {
      setState(() => _hasError = true);
      _showSnackBar('Digite o código completo de 6 dígitos.', isError: true);
      return;
    }

    setState(() {
      _isVerifying = true;
      _hasError = false;
    });

    final result = await AuthService.instance.verifyCode(
      email: widget.email,
      code: _code,
    );

    if (!mounted) return;
    setState(() => _isVerifying = false);

    if (result.success) {
      _showSnackBar(result.message ?? 'Conta verificada com sucesso!');
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    } else {
      setState(() => _hasError = true);
      _showSnackBar(result.message ?? 'Código inválido.', isError: true);
      _clearCode();
    }
  }

  void _clearCode() {
    for (final c in _controllers) {
      c.clear();
    }
    _focusNodes.first.requestFocus();
  }

  Future<void> _handleResend() async {
    if (_cooldownSecondsLeft > 0 || _isResending) return;

    setState(() => _isResending = true);
    final result = await AuthService.instance.resendCode(email: widget.email);
    if (!mounted) return;

    setState(() => _isResending = false);
    _showSnackBar(
      result.message ?? 'Código reenviado.',
      isError: !result.success,
    );
    _startCooldown();
  }

  void _startCooldown() {
    setState(() => _cooldownSecondsLeft = _resendCooldownSeconds);
    _cooldownTimer?.cancel();
    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        _cooldownSecondsLeft--;
        if (_cooldownSecondsLeft <= 0) timer.cancel();
      });
    });
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

  void _editEmail() {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWeb = constraints.maxWidth >= AppBreakpoints.web;

          if (isWeb) {
            // Nó "Card Verificação" do Figma: card branco de 560px centralizado.
            return Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(vertical: 40),
                child: AuthCard(
                  width: 560,
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        AppLogo(size: isWeb ? 72 : 64),
        SizedBox(height: isWeb ? 20 : 20),
        Text(
          'Verifique sua conta',
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(
            fontSize: isWeb ? 28 : 22,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          isWeb
              ? 'Enviamos um código de 6 dígitos para o e-mail ${Validators.maskEmail(widget.email)}. Digite o código abaixo para confirmar sua conta.'
              : 'Enviamos um código de 6 dígitos para ${Validators.maskEmail(widget.email)}.',
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(
            fontSize: isWeb ? 15 : 13,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(_codeLength, (index) {
            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                  right: index == _codeLength - 1 ? 0 : (isWeb ? 12 : 8),
                ),
                child: _OtpDigitBox(
                  controller: _controllers[index],
                  focusNode: _focusNodes[index],
                  hasError: _hasError,
                  height: isWeb ? 64 : 52,
                  fontSize: isWeb ? 24 : 20,
                  onChanged: (value) => _onDigitChanged(value, index),
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 20),
        PrimaryButton(
          label: 'Verificar conta',
          isLoading: _isVerifying,
          onPressed: _handleVerify,
        ),
        const SizedBox(height: 16),
        AppOutlineButton(
          label: _cooldownSecondsLeft > 0
              ? 'Reenviar código (${_cooldownSecondsLeft}s)'
              : 'Reenviar código',
          isLoading: _isResending,
          onPressed: _cooldownSecondsLeft > 0 ? null : _handleResend,
        ),
        const SizedBox(height: 16),
        InlineLinkRow(
          text: 'Endereço errado?',
          linkText: 'Editar e-mail',
          onTap: _editEmail,
        ),
      ],
    );
  }
}

class _OtpDigitBox extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool hasError;
  final double height;
  final double fontSize;
  final ValueChanged<String> onChanged;

  const _OtpDigitBox({
    required this.controller,
    required this.focusNode,
    required this.hasError,
    required this.height,
    required this.fontSize,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isFilled = controller.text.isNotEmpty;
    final borderColor = hasError
        ? AppColors.error
        : (isFilled || focusNode.hasFocus)
            ? AppColors.primary
            : AppColors.border;

    return SizedBox(
      height: height,
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        onChanged: onChanged,
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        maxLength: 1,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        style: GoogleFonts.inter(
          fontSize: fontSize,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        decoration: InputDecoration(
          counterText: '',
          contentPadding: EdgeInsets.zero,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: borderColor, width: 1.5),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: borderColor, width: 1.5),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
          ),
        ),
      ),
    );
  }
}
