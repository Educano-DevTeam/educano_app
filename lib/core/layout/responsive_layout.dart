import 'package:flutter/material.dart';

import '../constants/app_breakpoints.dart';

class ResponsiveLayout extends StatelessWidget {
  final Widget mobileBody;
  final Widget contentMaxWidht;

  const ResponsiveLayout({
    super.key, 
    required this.mobileBody, 
    required this.contentMaxWidht,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth  <= AppBreakpoints.mobile) {
          return mobileBody;
        } else {
          return contentMaxWidht;
        }
      },
    );
  }
}