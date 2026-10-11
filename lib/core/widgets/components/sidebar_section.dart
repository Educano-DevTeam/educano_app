import 'package:flutter/material.dart';

class SidebarSection extends StatelessWidget {

  final String title;
  final bool expanded;
  final List<Widget> children;

  const SidebarSection({
    super.key,
    required this.title,
    required this.expanded,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 20),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          // Exibe o título apenas quando expandida.
          AnimatedOpacity(
            duration: const Duration(milliseconds: 180),

            opacity: expanded ? 1 : 0,

            child: expanded
              ? Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 6,
                  ),

                  child: Text(
                    title.toUpperCase(),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Colors.grey.shade600,
                      letterSpacing: 1.2,
                    ),
                  ),
                )
              : const SizedBox.shrink(),
            ),
          ...children,
        ],
      ),
    );
  }
}