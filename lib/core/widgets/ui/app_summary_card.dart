import 'package:flutter/material.dart';

import '../../theme/educano_colors.dart';

class AppSummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final String variation;
  final String footer;
  final IconData icon;
  final Color color;
  final Color variationColor;

  const AppSummaryCard({
    super.key,
    required this.title,
    required this.value,
    required this.variation,
    required this.footer,
    required this.icon,
    required this.color,
    required this.variationColor,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final isMobile = width < 768;

    return Container(
      padding: EdgeInsets.all(isMobile ? 16 : 14),
      decoration: BoxDecoration(
        color: EducanoColors.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Color(0x12000000),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: EducanoColors.textPrimary,
                  ),
                ),
              ),
              Icon(
                icon,
                color: color,
                size: 20,
              ),
            ],
          ),

          const SizedBox(height: 16),

          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    value,
                    maxLines: 1,
                    style: TextStyle(
                      fontSize: isMobile ? 30 : 26,
                      fontWeight: FontWeight.bold,
                      color: EducanoColors.textPrimary,
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 8),

              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: variationColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    variation,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: variationColor,
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 4),

          Text(
            footer,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 12,
              color: EducanoColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}