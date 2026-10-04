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

  // Cores complementares usadas nos protótipos de perfil, ranking e configurações.
  static const Color legacyPrimary = Color(0xFF4C5FD5);
  static const Color legacyBackground = Color(0xFFF4F5FA);
  static const Color legacyTextSecondary = Color(0xFF8A8DA6);
  static const Color legacyTextPrimary = Color(0xFF1F2340);
  static const Color legacyCardBorder = Color(0xFFE7E8F0);
  static const Color legacyCardBackground = Colors.white;
  static const Color legacyGold = Color(0xFFF2B90E);
  static const Color legacySilver = Color(0xFF6B7280);
  static const Color legacyBronze = Color(0xFFB4713A);
  static const Color legacyTopThreeBackground = Color(0xFFFDF1D6);
  static const Color legacyAmber = Color(0xFFF2A70E);
  static const Color legacyGradientStart = Color(0xFF4C63D2);
  static const Color legacyGradientEnd = Color(0xFFE8964E);
  static const Color legacyNavy = Color(0xFF3B5BA9);
  static const Color legacyGreen = Color(0xFF4CAF6D);
  static const Color legacyOrange = Color(0xFFF5A623);
  static const Color legacyRed = Color(0xFFD9534F);
  static const Color legacyRedSoft = Color(0xFFF3D5D3);
  static const Color legacyLavender = Color(0xFFEEF0FF);

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
