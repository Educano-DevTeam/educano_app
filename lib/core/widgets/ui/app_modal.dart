import 'package:flutter/material.dart';

import '../../theme/educano_colors.dart';

class AppModal extends StatelessWidget {
  final String title;
  final Widget child;
  final List<Widget>? actions;
  final double maxWidth;

  const AppModal({
    super.key,
    required this.title,
    required this.child,
    this.actions,
    this.maxWidth = 520,
  });

  static Future<T?> show<T>({
    required BuildContext context,
    required String title,
    required Widget child,
    List<Widget>? actions,
    double maxWidth = 520,
  }) {
    return showDialog<T>(
      context: context,
      builder: (_) {
        return AppModal(
          title: title,
          maxWidth: maxWidth,
          actions: actions,
          child: child,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.sizeOf(context);
    final isCompact = screenSize.width < 600;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(
        horizontal: isCompact ? 12 : 24,
        vertical: isCompact ? 16 : 24,
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: maxWidth,
          maxHeight: screenSize.height - (isCompact ? 32 : 48),
        ),
        child: Container(
          decoration: BoxDecoration(
            color: EducanoColors.surface,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: EdgeInsets.all(isCompact ? 16 : 24),
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: TextStyle(
                              fontSize: isCompact ? 18 : 20,
                              fontWeight: FontWeight.w600,
                              color: EducanoColors.textPrimary,
                            ),
                          ),
                        ),
                        IconButton(
                          tooltip: 'Fechar',
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.close),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Flexible(
                      child: SingleChildScrollView(
                        padding: EdgeInsets.zero,
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            minWidth: constraints.maxWidth,
                          ),
                          child: child,
                        ),
                      ),
                    ),
                    if (actions != null && actions!.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: OverflowBar(
                          alignment: MainAxisAlignment.end,
                          spacing: 8,
                          overflowSpacing: 8,
                          overflowAlignment: OverflowBarAlignment.end,
                          overflowDirection: VerticalDirection.up,
                          children: actions!,
                        ),
                      ),
                    ],
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
