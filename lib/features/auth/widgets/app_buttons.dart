import '../../../core/theme/educano_colors.dart';
import 'package:flutter/material.dart';

/// Botão primário cheio (Button/Primary no Figma), com estado de loading.
class PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;

  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(
              color: Color(0x40425BC2),
              blurRadius: 6,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          child: isLoading
              ? const SizedBox(
                  height: 22,
                  width: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : Text(label),
        ),
      ),
    );
  }
}

/// Botão outline (Button/Outline no Figma), ex.: "Reenviar código".
class AppOutlineButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;

  const AppOutlineButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: isLoading ? null : onPressed,
        child: isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(EducanoColors.primaryBlue),
                ),
              )
            : Text(label),
      ),
    );
  }
}

/// Linha "Texto + link", ex.: "Não tem conta? Criar conta".
class InlineLinkRow extends StatelessWidget {
  final String text;
  final String linkText;
  final VoidCallback onTap;

  const InlineLinkRow({
    super.key,
    required this.text,
    required this.linkText,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          text,
          style: const TextStyle(fontSize: 13, color: EducanoColors.textSecondary),
        ),
        const SizedBox(width: 4),
        GestureDetector(
          onTap: onTap,
          child: Text(
            linkText,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: EducanoColors.primaryBlue,
            ),
          ),
        ),
      ],
    );
  }
}

class AuthMessage extends StatelessWidget {
  final String message;
  final bool isError;

  const AuthMessage({super.key, required this.message, this.isError = false});

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: isError
          ? EducanoColors.error.withValues(alpha: 0.08)
          : EducanoColors.successGreen.withValues(alpha: 0.08),
      borderRadius: BorderRadius.circular(8),
    ),
    child: Text(
      message,
      style: TextStyle(
        color: isError ? EducanoColors.error : EducanoColors.successGreen,
        fontSize: 13,
      ),
    ),
  );
}
