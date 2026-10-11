import 'package:flutter/material.dart';

import '../../../core/theme/educano_colors.dart';

export '../../../core/widgets/ui/app_card.dart' show AppCard;

class AppProgressBar extends StatelessWidget {
  const AppProgressBar({super.key, required this.progress, this.color = EducanoColors.primaryBlue, this.height = 8});
  final double progress;
  final Color color;
  final double height;

  @override
  Widget build(BuildContext context) => ClipRRect(
        borderRadius: BorderRadius.circular(height),
        child: LinearProgressIndicator(
          value: progress.clamp(0.0, 1.0),
          minHeight: height,
          backgroundColor: EducanoColors.divider,
          valueColor: AlwaysStoppedAnimation<Color>(color),
        ),
      );
}
