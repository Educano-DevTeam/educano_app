import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/app_theme.dart';
import 'app_logo.dart';

/// Painel azul lateral do layout WEB (nó "Painel Marca" no Figma).
///
/// Largura fixa de 600px, logo 96px, título 40px e um texto de apoio
/// em azul claro (#86C5FF) com 400px de largura.
class BrandPanel extends StatelessWidget {
  final String tagline;
  final double width;

  const BrandPanel({
    super.key,
    required this.tagline,
    this.width = 600,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: double.infinity,
      color: AppColors.primary,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const AppLogo(size: 96),
          const SizedBox(height: 32),
          Text(
            'Educano',
            style: GoogleFonts.inter(
              fontSize: 40,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: 400,
            child: Text(
              tagline,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 18,
                color: AppColors.brandTagline,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
