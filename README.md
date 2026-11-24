# Educano

Aplicativo educacional desenvolvido em Flutter. O Educano reúne recursos de
estudo para estudantes e telas administrativas em uma interface responsiva para
celulares e telas maiores. Tudo (login, cursos, simulados, loja...) vem da
[API do Educano](https://github.com/Educano-DevTeam/educano_api).

## Funcionalidades

- **Acesso e conta:** entrada, criação de conta, verificação do código enviado
  por e-mail e recuperação de senha por código.
- **Cursos e materiais:** catálogo, conteúdo organizado em sessões e módulos,
  progresso de estudo e visualização de materiais em vídeo, áudio ou PDF.
- **Estudo:** flashcards com revisões agendadas e simulados com configuração,
  resolução com salvamento automático, gabarito comentado e resultado.
- **Área do estudante:** perfil, plano de conta, ranking, loja e inventário,
  configurações e navegação adaptada ao tamanho da tela.
- **Documentos legais:** termos de uso e política de privacidade disponíveis
  durante o cadastro e pelas respectivas rotas da aplicação.
- **Área administrativa:** telas para visão geral, cursos, usuários, questões e
  itens da loja.
- **Experiência responsiva:** navegação com barra inferior em telas estreitas e
  cabeçalho/sidebar em telas maiores.

## Tecnologias

- **Flutter e Dart** para interface e lógica da aplicação. A versão mínima do
  Dart está definida em `pubspec.yaml` (`^3.12.2`).
- **Material Design** e tema próprio do Educano, definidos em `lib/core/theme/`.
- **shared_preferences** para preferências e dados locais, incluindo a sessão do
  usuário e os flashcards.
- **http** para comunicação com a API, incluindo envio de arquivos e renovação
  de sessão.
- **just_audio** e **video_player** para reprodução de áudio e vídeo.
- **syncfusion_flutter_pdfviewer** para visualização de PDFs.
- **file_picker** para seleção de arquivos.
- **flutter_test** e testes de widget para validação dos fluxos e da interface.

## Arquitetura e organização

A aplicação segue uma organização por funcionalidades, apoiada por componentes
e serviços compartilhados:

```text
lib/
├── main.dart                 # Inicialização, tema e registro das rotas
├── app/                      # Configuração complementar da aplicação
├── core/
│   ├── data/repositories/    # Repositórios locais e compartilhados
│   ├── layout/               # Estrutura geral e adaptação responsiva
│   ├── models/               # Modelos compartilhados
│   ├── navigation/           # Rotas, menus e navegação
│   ├── theme/                # Cores, espaçamentos, tipografia e tema
│   └── widgets/              # Componentes reutilizáveis
├── features/                 # Funcionalidades organizadas por domínio
│   ├── auth/                 # Acesso, cadastro e recuperação de conta
│   ├── course/ e courses/    # Cursos, progresso e catálogo
│   ├── dashboard/            # Telas administrativas
│   ├── exam/                 # Simulados e resultados
│   ├── flashcards/           # Cartões de estudo
│   ├── materials/            # Áudio, vídeo e outros materiais
│   └── ...                   # Perfil, ranking, loja, configurações etc.
├── services/                 # Serviços compartilhados de autenticação e storage
└── assets/                   # Imagens, documentos e mídia local
test/                         # Testes de autenticação e interface responsiva
```

As telas de cada funcionalidade são separadas, conforme necessário, em páginas,
views e widgets. Modelos representam os dados, enquanto repositórios e serviços
encapsulam operações locais e regras de domínio. `main.dart` configura o
`MaterialApp`, o tema, o navegador global e as rotas nomeadas. `AppScaffold`
fornece a estrutura comum e escolhe a disposição móvel ou desktop conforme a
largura disponível.

### Integração com a API

- `lib/services/api_client.dart` faz as chamadas HTTP e envia o token. A URL
  vem de `--dart-define=API_URL=...`; por padrão, usa
  `https://educano-api.onrender.com/api`.
- Respostas inválidas da API viram erros controlados; coleções opcionais em
  telas de leitura podem aparecer vazias. Operações de escrita não simulam
  sucesso quando a API não confirma o resultado.
- Os outros arquivos de `lib/services/` cuidam de cada parte (login, cursos,
  simulados, questões, loja, usuários e progresso) e já entregam os dados no
  formato das telas.
- Quando o token de acesso expira, o app tenta renová-lo com o refresh token e
  repete a requisição. Se a renovação falhar, a sessão é encerrada e o usuário
  volta para o login.
- O dashboard só aparece para admin, professor e parceiro. Painel, Usuários e
  Itens são só do admin.
  Itens são só do admin.
- Para rodar local: suba a API e rode `pnpm seed` nela. O seed cria uma conta de
  teste para cada tipo de usuário (está no README da API).
- Já ficaram ligados à API, além das tarefas da Marianne: upload dos materiais
  das aulas (IBL 9), cadastro de questões (IBL 12), cadastro de itens (IBL 22) e
  criação de flashcards (IBL 28).
- A estrutura do projeto inclui diretórios de plataforma para Android, iOS, Web,
  Linux, macOS e Windows. Recursos e plugins podem exigir configuração nativa
  adicional conforme a plataforma de destino. A visualização de PDFs na Web
  carrega o PDF.js por CDN, portanto depende de acesso à internet.

## Requisitos

1. Flutter SDK instalado e disponível no `PATH`, com Dart compatível com a
   restrição declarada em `pubspec.yaml`.
2. Git para obter o código-fonte.
3. Para executar em um dispositivo/emulador, ferramentas da plataforma alvo:
   Android Studio/SDK para Android, Xcode para iOS/macOS (em macOS), ou toolchain
   correspondente para Windows/Linux.
4. Um navegador compatível para executar a versão Web.

Confira a instalação do Flutter e os dispositivos reconhecidos:

```bash
flutter doctor
flutter devices
```

## Como executar

Clone o repositório e acesse a pasta do projeto:

```bash
git clone https://github.com/Educano-DevTeam/educano_app.git
cd educano_app
```

Baixe as dependências:

```bash
flutter pub get
```

Com a API rodando, inicie o app:

```bash
flutter run
```

Para usar outra API (a de produção, por exemplo):

```bash
flutter run --dart-define=API_URL=https://sua-api.com/api
flutter build web --dart-define=API_URL=https://sua-api.com/api
```

Para escolher um destino específico, consulte primeiro o identificador exibido
por `flutter devices` e passe-o ao comando:

```bash
flutter run -d <device-id>
```

Exemplos de execução por plataforma:

```bash
flutter run -d chrome       # Web
flutter run -d windows      # Windows
flutter run -d <device-id>  # Android, iOS, macOS ou Linux
```

Para compilar uma versão de distribuição, use o comando da plataforma alvo:

```bash
flutter build web
flutter build apk
flutter build windows
```

Os artefatos de compilação são gerados pelo Flutter nos diretórios padrão de
build de cada plataforma.

## Verificação

Execute os testes automatizados:

```bash
flutter test
```

Execute o analisador estático:

```bash
flutter analyze
```

Os testes em `test/` cobrem os fluxos de autenticação, o comportamento de algumas
telas em diferentes larguras e interações de simulado. Eles usam uma API falsa
(`test/support/fake_api.dart`), então não precisam de internet.
