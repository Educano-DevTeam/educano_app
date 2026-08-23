class AppBreakpoints {
  AppBreakpoints._();

  /// Abaixo disso o app troca para o shell mobile (drawer + bottom nav).
  static const mobile = 500.0;

  // Breakpoints de conteúdo — usados dentro das views para decidir o número
  // de colunas e o empilhamento dos blocos, seguindo os frames do Figma.

  /// Celular: tudo em coluna única / versão compacta dos blocos.
  static const compact = 600.0;

  /// Tablet e janelas estreitas: 2 colunas.
  static const medium = 900.0;

  /// Desktop: layout completo (3+ colunas, blocos lado a lado).
  static const expanded = 1200.0;

  static const contentMaxWidth = 1440.0;
}
