import '../../../core/theme/educano_colors.dart';
import 'package:flutter/material.dart';
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
      color: EducanoColors.primaryBlue,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const AppLogo(size: 96),
          const SizedBox(height: 32),
          Text(
            'Educano',
            style: const TextStyle(
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
              style: const TextStyle(
                fontSize: 18,
                color: EducanoColors.secondaryBlue,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
