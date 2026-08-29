import 'package:flutter/material.dart';

import '../../theme/theme.dart';

class AppModal extends StatelessWidget {
  final Widget child;

  final String? title;

  final double maxWidth;

  const AppModal({
    super.key,
    required this.child,
    this.title,
    this.maxWidth = 600,
  });

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
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: EducanoColors.surface,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (title != null) ...[
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          title!,
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge,
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                    child,
                  ],
                ),
              ),

              Positioned(
                top: 0,
                right: 0,
                child: IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close_rounded),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}