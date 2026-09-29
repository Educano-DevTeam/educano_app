import 'package:flutter/material.dart';
import '../core/app_theme.dart';

/// Logo circular do Educano.
///
/// Tenta carregar `assets/images/logo.png` (exportado do Figma, node
/// "Tela Login (MOBILE)" > "Header" > "Frame"). Caso o arquivo ainda não
/// tenha sido adicionado ao projeto, cai num ícone de fallback para que o
/// app nunca quebre por causa de um asset ausente.
class AppLogo extends StatelessWidget {
  final double size;
  final bool onDarkBackground;

  const AppLogo({super.key, this.size = 64, this.onDarkBackground = false});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(size / 2),
      child: Container(
        width: size,
        height: size,
        color: Colors.white,
        child: Image.asset(
          'assets/images/logo.png',
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Icon(
              Icons.school_rounded,
              size: size * 0.55,
              color: AppColors.primary,
            );
          },
        ),
      ),
    );
  }
}
