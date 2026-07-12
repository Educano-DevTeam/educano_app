import 'package:flutter/material.dart';

import '../constants/app_breakpoints.dart';

class ResponsiveLayout extends StatelessWidget {
  final Widget mobileBody;
  final Widget tabletBody;
  final Widget webBody;

  const ResponsiveLayout({
    super.key, 
    required this.mobileBody,
    required this.tabletBody, 
    required this.webBody,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Se a tela for menor que 768px (largura padrão de tablets/celulares), mostra mobile
        if (constraints.maxWidth <= AppBreakpoints.mobile) {
          return mobileBody;
        } else if (constraints.maxWidth <= AppBreakpoints.tablet) {
          return tabletBody;
        }
        else {
          return webBody;
        }
      },
    );
  }
}