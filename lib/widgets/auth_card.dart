import 'package:flutter/material.dart';
import '../core/app_theme.dart';

/// Card branco centralizado do layout WEB (nós "Card Verificação" e
/// "Card Recuperação" no Figma): borda 2px #E5E7EB, raio 24, padding 56
/// e sombra suave.
class AuthCard extends StatelessWidget {
  final Widget child;
  final double width;

  const AuthCard({
    super.key,
    required this.child,
    this.width = 560,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      padding: const EdgeInsets.all(56),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border, width: 2),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F000000),
            blurRadius: 24,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }
}
