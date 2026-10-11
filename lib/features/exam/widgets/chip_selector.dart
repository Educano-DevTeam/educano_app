import '../../../core/theme/educano_colors.dart';
import 'package:flutter/material.dart';
import '../../../core/theme/theme.dart';

/// Chip selecionável usado na tela de "Configurar/Iniciar" simulado
/// (ex.: seleção de matéria, dificuldade, número de questões).
class SelectableChip extends StatelessWidget {
  const SelectableChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
    this.icon,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: selected ? EducanoColors.primaryBlue : EducanoColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? EducanoColors.primaryBlue : EducanoColors.border,
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 16,
                color: selected ? EducanoColors.surface : EducanoColors.textSecondary,
              ),
              const SizedBox(width: 8),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: selected ? EducanoColors.surface : EducanoColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Grupo de chips com título de seção (ex.: "Matéria", "Dificuldade").
class ChipSelectorGroup extends StatelessWidget {
  const ChipSelectorGroup({
    super.key,
    required this.title,
    required this.options,
    required this.selected,
    required this.onSelected,
  });

  final String title;
  final List<String> options;
  final Set<String> selected;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: EducanoColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final option in options)
              SelectableChip(
                label: option,
                selected: selected.contains(option),
                onTap: () => onSelected(option),
              ),
          ],
        ),
      ],
    );
  }
}
