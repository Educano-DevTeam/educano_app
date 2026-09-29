# Educano – Telas de Autenticação (Flutter)

Implementação em Flutter das 4 telas de autenticação do design no Figma
(*Educano - Web e Mobile*, versões MOBILE):

- **Login** — `lib/screens/login_screen.dart`
- **Cadastro** — `lib/screens/signup_screen.dart`
- **Verificação de Conta (OTP)** — `lib/screens/verify_account_screen.dart`
- **Recuperação de Senha** — `lib/screens/forgot_password_screen.dart`

## Como rodar

```bash
flutter pub get
flutter run
```

Requer Flutter 3.x+ (Dart >= 3.3).

## Estrutura

```
lib/
  core/
    app_theme.dart      # Cores e tema global (extraídos do Figma)
    validators.dart      # Validações de e-mail, senha, nome, etc.
  services/
    auth_service.dart    # Lógica de autenticação (mockada, pronta p/ trocar por API real)
  widgets/
    app_text_field.dart  # Campo de texto com label, no padrão do design
    app_buttons.dart      # Botão primário, outline e link inline
    app_logo.dart         # Logo com fallback caso o asset não exista
  screens/
    login_screen.dart
    signup_screen.dart
    verify_account_screen.dart
    forgot_password_screen.dart
  main.dart               # Rotas e tema
```

## Responsividade (mobile + web)

Cada tela usa um `LayoutBuilder` e alterna entre os dois designs do Figma
a partir do breakpoint de **900px** (`lib/core/breakpoints.dart`):

| Tela | Layout MOBILE (< 900px) | Layout WEB (>= 900px) |
|---|---|---|
| Login | Header azul no topo + form | Painel de marca 600px à esquerda + form 400px |
| Cadastro | Header azul no topo + form | Painel de marca 600px à esquerda + form 420px |
| Verificação | Conteúdo centralizado | Card branco de 560px centralizado |
| Recuperação | Conteúdo centralizado | Card branco de 520px centralizado |

No mobile o conteúdo também é limitado a 480px de largura, para não
esticar em tablets estreitos. Toda a lógica (validação, loading, OTP,
cooldown) é compartilhada entre os dois layouts — muda apenas a
composição visual e os tamanhos de fonte/espaçamento.

Widgets do layout web:
- `widgets/brand_panel.dart` — painel azul com logo, título e tagline
- `widgets/auth_card.dart` — card branco com borda, raio 24 e sombra

## Lógica implementada

- **Login**: valida e-mail/senha, mostra loading no botão, exibe erros via
  SnackBar, alterna visibilidade da senha, navega para Cadastro/Recuperação.
- **Cadastro**: valida nome, e-mail, senha (mín. 6 caracteres), confirmação
  de senha e aceite obrigatório dos Termos. Ao concluir, navega para a tela
  de Verificação passando o e-mail cadastrado.
- **Verificação de Conta**: 6 campos de OTP com auto-avanço de foco,
  verificação automática ao preencher o último dígito, botão de reenviar
  código com **cooldown de 30s**, e-mail mascarado (`da••••@email.com`) e
  opção de voltar para editar o e-mail.
- **Recuperação de Senha**: valida e-mail, envia link e troca o conteúdo da
  tela para uma mensagem de confirmação (com opção de reenviar).

## Conectando a uma API real

Toda a lógica de rede está isolada em `lib/services/auth_service.dart`
(usa `Future.delayed` para simular latência). Basta substituir o corpo de
cada método (`login`, `register`, `verifyCode`, `resendCode`,
`sendPasswordResetLink`) por chamadas HTTP reais — a assinatura e o tipo de
retorno (`AuthResult`) podem continuar os mesmos, então nenhuma tela precisa
mudar.

## Logo / assets

O código referencia `assets/images/logo.png`. Não foi possível baixar o
asset diretamente do Figma neste ambiente (domínio bloqueado pela rede),
então:

1. Exporte o ícone do toucan do Figma (nó "Frame" no Header das telas).
2. Salve como `assets/images/logo.png`.

Até lá, o app usa um ícone de fallback automaticamente — nada quebra.

## Fonte

O tema usa a fonte **Inter** via pacote `google_fonts`, igual ao Figma.
