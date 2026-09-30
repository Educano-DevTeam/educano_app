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
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(20),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: maxWidth,
        ),
        child: Container(
          decoration: BoxDecoration(
            color: EducanoColors.surface,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontSize: 20,
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
                    child: child,
                  ),
                ),

                if (actions != null && actions!.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ...actions!.map(
                        (action) => Padding(
                          padding: const EdgeInsets.only(left: 8),
                          child: action,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}