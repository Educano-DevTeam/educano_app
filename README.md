# Educano - Ranking, Perfil e Configurações (Flutter)

Implementação em Flutter/Dart das 6 telas do protótipo Figma "Educano - Web e Mobile":

- Ranking (Web e Mobile)
- Perfil (Web e Mobile)
- Configurações (Web e Mobile)

Em vez de criar 6 arquivos separados, cada tela foi construída como **um único
widget responsivo**: o mesmo código Dart se adapta ao layout Web (sidebar fixa
+ topbar) ou Mobile (drawer + bottom navigation) de acordo com a largura da
tela, seguindo fielmente as cores, textos e componentes das imagens enviadas.

## Como rodar

```bash
flutter pub get
flutter run -d chrome      # para testar a versão Web
flutter run                # para rodar num emulador/dispositivo mobile
```

O breakpoint entre Web e Mobile é 900px de largura (veja `lib/core/responsive.dart`).
Redimensione a janela do Chrome para ver o layout alternar em tempo real.

## Estrutura do projeto

```
lib/
├── main.dart                     # rotas: /ranking, /perfil, /configuracoes
├── core/
│   ├── app_colors.dart           # paleta extraída do protótipo
│   ├── app_theme.dart            # ThemeData global (botões, inputs, etc)
│   └── responsive.dart           # breakpoint Web/Mobile
├── models/
│   ├── ranking_entry.dart
│   └── course.dart
├── widgets/
│   ├── app_shell.dart            # casca responsiva (sidebar/drawer + topbar)
│   ├── top_bar.dart              # barra superior (logo, sino, avatar)
│   ├── sidebar_menu.dart         # menu lateral (Principal/Dashboard/Outras opções)
│   ├── bottom_nav_bar.dart       # navegação inferior (mobile)
│   ├── section_card.dart         # cartão branco padrão
│   ├── stat_card.dart            # cartão de estatística (ranking)
│   └── mini_bar_chart.dart       # gráfico de barras (evolução das notas)
└── screens/
    ├── ranking_screen.dart
    ├── perfil_screen.dart
    └── configuracoes_screen.dart
```

## Detalhes de fidelidade ao protótipo

- **Ranking**: busca, 3 cards de estatística (posição, XP semanal, XP para o
  3º lugar), lista com pódio destacado (ouro/prata/bronze) e linha do usuário
  atual destacada em lavanda.
- **Perfil**: banner com gradiente azul→laranja, avatar sobreposto, botões
  "Editar Perfil"/"Compartilhar" (que colapsam para baixo do nome no mobile),
  estatísticas (Nível, XP, Sequência, Concluídos), card do plano, gráfico de
  barras "Evolução das notas" (Atividades x Simulados) e lista "Meus Cursos"
  com badges coloridos.
- **Configurações**: em telas largas usa duas colunas (Dados da
  conta/Notificações/Segurança à esquerda; Plano/Preferências/Encerrar conta
  à direita); no mobile as mesmas seções são empilhadas na ordem exata do
  protótipo. Switches, campos de texto e botão "Excluir conta" em vermelho
  seguem o mockup.

## Observações

- Os dados (nomes, XP, cursos etc.) são estáticos/mock, prontos para serem
  substituídos por uma API real.
- Os toggles de Notificações e Preferências já são funcionais em memória
  (usando `StatefulWidget` + `setState`).
- Nenhuma dependência externa além do Flutter SDK foi usada (o gráfico de
  barras é feito "na mão" com `Container`s, sem pacotes de terceiros), para
  minimizar problemas de instalação.
- Os itens do menu lateral que não fazem parte deste escopo (Home,
  Flashcards, Painel, Usuários, Cursos, Questões, Loja, Logout) mostram um
  aviso ("não faz parte deste protótipo") ao serem clicados — a navegação
  entre Ranking, Perfil e Configurações está 100% funcional.
