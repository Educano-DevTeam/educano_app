import 'package:flutter/material.dart';

import 'educano_colors.dart';

class EducanoTheme {
  EducanoTheme._();

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,

      // Cor principal do sistema
      colorScheme: ColorScheme.fromSeed(
        seedColor: EducanoColors.primaryBlue,
        brightness: Brightness.light,
      ),

      // Fundo padrão
      scaffoldBackgroundColor: EducanoColors.background,

      // Fonte padrão (temporário)
      fontFamily: 'Roboto',

      // Cards
      cardTheme: const CardThemeData(
        color: EducanoColors.surface,
        elevation: 2,
        margin: EdgeInsets.all(8),
      ),

      // Campo de texto
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: EducanoColors.searchBackground,

        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),

        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: EducanoColors.border,
          ),
        ),

        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: EducanoColors.secondaryBlue,
            width: 2,
          ),
        ),

        prefixIconColor: EducanoColors.primaryBlue,
      ),

      // Botões elevados
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: EducanoColors.primaryBlue,
          foregroundColor: EducanoColors.textWhite,

          padding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 14,
          ),

          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}