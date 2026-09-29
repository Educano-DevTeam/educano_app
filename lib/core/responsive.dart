import 'package:flutter/widgets.dart';

/// Ponto de quebra único usado em todo o app para decidir entre o
/// layout Web (sidebar fixa + topbar) e o layout Mobile (drawer + bottom nav).
class Responsive {
  Responsive._();

  static const double mobileBreakpoint = 900;

  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < mobileBreakpoint;
  }
}
