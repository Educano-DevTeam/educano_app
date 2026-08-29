import 'package:flutter/material.dart';

import '../../theme/theme.dart';

class AppListItem extends StatelessWidget {
  final Map<String, dynamic> data;
  final List<String> columns;

  final IconData? icon;
  final bool showIcon;

  final Widget? trailing;

  const AppListItem({
    super.key,
    required this.data,
    required this.columns,
    this.icon,
    this.showIcon = true,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 12,
      ),
      decoration: const BoxDecoration(
        color: EducanoColors.surface,
        border: Border(
          bottom: BorderSide(
            color: EducanoColors.divider,
          ),
        ),
      ),
      child: Row(
        children: [
          if (showIcon) ...[
            SizedBox(
              width: 40,
              child: Icon(
                icon ?? Icons.circle_outlined,
                size: 20,
                color: EducanoColors.textSecondary,
              ),
            ),
            const SizedBox(width: 12),
          ],

          ...columns.map(
            (column) {
              return Expanded(
                child: Text(
                  data[column]?.toString() ?? "-",
                  overflow: TextOverflow.ellipsis,
                ),
              );
            },
          ),

          if (trailing != null) ...[
            const SizedBox(width: 12),
            trailing!,
          ],
        ],
      ),
    );
  }
}