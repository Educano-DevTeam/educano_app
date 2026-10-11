import '../../../core/theme/educano_colors.dart';
import 'package:flutter/material.dart';
import '../../../core/theme/theme.dart';

enum SimuladoStatus { concluido, emAndamento }

/// Badge de status ("Concluído" / "Em andamento") usado nos cartões de
/// "Últimos Simulados".
class StatusBadge extends StatelessWidget {
  const StatusBadge({super.key, required this.status});

  final SimuladoStatus status;

  @override
  Widget build(BuildContext context) {
    final isDone = status == SimuladoStatus.concluido;
    final bg = isDone ? EducanoColors.successLight : EducanoColors.warningLight;
    final fg = isDone ? EducanoColors.successDark : EducanoColors.accentYellow;
    final label = isDone ? 'Concluído' : 'Em andamento';
    final icon = isDone ? Icons.check_circle_rounded : Icons.access_time_rounded;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: fg),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: fg,
            ),
          ),
        ],
      ),
    );
  }
}
