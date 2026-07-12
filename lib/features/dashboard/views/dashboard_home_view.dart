import 'package:flutter/material.dart';

import '../../../core/theme/theme.dart';

class DashboardHomeView extends StatelessWidget {
  const DashboardHomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(
        horizontal:24,
        vertical:20,
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Título
          Text(
            "Painel de Controle",
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: EducanoColors.textPrimary,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            "Bem-vindo de volta! Aqui está um resumo da plataforma.",
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: EducanoColors.textSecondary,
            ),
          ),

          const SizedBox(height: 32),

          // Cards (temporariamente vazios)
          LayoutBuilder(
            builder: (context, constraints) {
              final double width =
                constraints.maxWidth;

              final double cardWidth =
                width < 700
                  ? width
                  : 270;

              return Wrap(
                spacing: 20,
                runSpacing: 20,

                children: List.generate(
                  4,
                  (_) => Container(
                    width: cardWidth,
                    height: 120,

                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: EducanoColors.border,
                      ),
                    ),
                  ),
                ),
              );
            }
          ),
          
          const SizedBox(height: 40),

          // Atividade recente
          Text(
            "Atividade recente",
            style: Theme.of(context).textTheme.titleLarge,
          ),

          const SizedBox(height: 16),

          Container(
            height: 300,

            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: EducanoColors.border,
              ),
            ),
          ),
        ],
      ),
    );
  }
}