/// Breakpoints de largura usados para alternar entre o layout mobile
/// (telas MOBILE do Figma) e o layout web (telas WEB do Figma, com painel
/// de marca lateral / card centralizado).
class AppBreakpoints {
  AppBreakpoints._();

  /// Abaixo disso, usa o layout mobile (mesmo em navegador/tablet estreito).
  static const double web = 900;
}
