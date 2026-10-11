import 'package:flutter/material.dart';

import '../../../core/layout/app_scaffold.dart';
import '../../../core/navigation/app_menu.dart';
import '../../../core/theme/educano_colors.dart';

/// Adds the exam screen heading inside the shared application scaffold.
class DashboardScaffold extends StatelessWidget {
  const DashboardScaffold({
    super.key,
    required this.title,
    required this.child,
    this.actions,
    this.showBackButton = false,
    this.onBack,
    this.activeNavIndex = 0,
    this.maxContentWidth = 1040,
  });

  final String title;
  final Widget child;
  final List<Widget>? actions;
  final bool showBackButton;
  final VoidCallback? onBack;
  final int activeNavIndex;
  final double maxContentWidth;

  @override
  Widget build(BuildContext context) => AppScaffold(
        selectedMenu: AppMenu.lastExams,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final mobile = constraints.maxWidth < 700;
            return SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(mobile ? 16 : 32, mobile ? 16 : 28, mobile ? 16 : 32, 32),
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: maxContentWidth),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(children: [
                        if (showBackButton) ...[
                          IconButton(onPressed: onBack ?? () => Navigator.of(context).maybePop(), icon: const Icon(Icons.arrow_back)),
                          const SizedBox(width: 4),
                        ],
                        Expanded(child: Text(title, style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: EducanoColors.textPrimary, fontWeight: FontWeight.w700))),
                        if (actions != null) ...actions!,
                      ]),
                      const SizedBox(height: 20),
                      child,
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      );
}
