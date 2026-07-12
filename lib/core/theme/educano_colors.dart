import 'package:flutter/material.dart';

class EducanoColors {
  EducanoColors._();

  // CORES PRINCIPAIS
  static const Color primaryBlue = Color(0xFF425BC2);
  static const Color secondaryBlue = Color(0xFF86C5FF);
  static const Color lightBlue = Color(0xFF9FBEED);

  // CORES DE DESTAQUE
  static const Color accentYellow = Color(0xFFFFA62B);
  static const Color successGreen = Color(0xFF79B425);
  static const Color darkGreen = Color(0xFF1D6517);
  static const Color softGreen = Color(0xFF7DAB9E);


  // FUNDOS
  static const Color background = Color(0xFFFAFFFD);
  static const Color surface = Colors.white;
  static const Color searchBackground = Color(0xFFF4F9FF);

  // TEXTO
  static const Color textPrimary = Color(0xFF2D3748);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textWhite = Colors.white;

  // BORDAS
  static const Color border = Color(0xFFE5E7EB);

  static const Color divider = Color(0xFFEDF2F7);

  // STATUS
  static const Color success = successGreen;
  static const Color warning = accentYellow;
  static const Color info = secondaryBlue;
  static const Color error = Color(0xFFE53935);

  // GRADIENTE OFICIAL
  static const LinearGradient primaryGradient =
    LinearGradient(
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
      colors: [
        primaryBlue,
        secondaryBlue,
        accentYellow,
      ],
    );
}