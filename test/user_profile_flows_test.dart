import 'package:educano_app/core/models/app_user.dart';
import 'package:educano_app/core/layout/app_scaffold.dart';
import 'package:educano_app/core/navigation/app_menu.dart';
import 'package:educano_app/core/navigation/app_routes.dart';
import 'package:educano_app/core/navigation/navigation_service.dart';
import 'package:educano_app/core/widgets/components/app_bottom_navigation.dart';
import 'package:educano_app/core/widgets/components/app_header.dart';
import 'package:educano_app/core/widgets/ui/app_fab_menu.dart';
import 'package:educano_app/core/widgets/ui/profile_avatar.dart';
import 'package:educano_app/features/profile/pages/public_profile_page.dart';
import 'package:educano_app/features/ranking/pages/ranking_page.dart';
import 'package:educano_app/services/auth_service.dart';
import 'package:educano_app/services/storage_service.dart';
import 'package:educano_app/services/users_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

import 'support/fake_api.dart';

void main() {
  setUpAll(() {
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
    FakeApi.install();
  });
  setUp(FakeApi.reset);

  test('password recovery uses the API reset schema', () async {
    FakeApi.responseOverrides['POST /auth/forgot-password'] = http.Response(
      '{"message":"Se o e-mail estiver cadastrado, enviaremos um código."}',
      200,
      headers: {'content-type': 'application/json; charset=utf-8'},
    );
    FakeApi.responseOverrides['POST /auth/reset-password'] = http.Response(
      '{"message":"Senha redefinida com sucesso."}',
      200,
      headers: {'content-type': 'application/json; charset=utf-8'},
    );

    final sent = await AuthService.instance.sendPasswordResetCode(
      email: 'aluno@educano.test',
    );
    final reset = await AuthService.instance.resetPassword(
      email: 'aluno@educano.test',
      code: 'abc123',
      newPassword: FakeApi.password,
    );

    expect(sent.success, isTrue);
    expect(reset.success, isTrue);
    expect(FakeApi.requestBodiesByPath['/auth/forgot-password'], {
      'email': 'aluno@educano.test',
    });
    expect(FakeApi.requestBodiesByPath['/auth/reset-password'], {
      'email': 'aluno@educano.test',
      'codigo': 'ABC123',
      'senha': FakeApi.password,
    });
  });

  test('private profiles are reported as unavailable by the API', () async {
    FakeApi.responseOverrides['GET /users/private-user/profile'] =
        http.Response(
          '{"message":"Perfil não encontrado."}',
          404,
          headers: {'content-type': 'application/json; charset=utf-8'},
        );

    expect(await UsersService.instance.profileOf('private-user'), isNull);
  });

  test('public profiles return only the API public profile data', () async {
    FakeApi.responseOverrides['GET /users/public-user/profile'] = http.Response(
      '{"dados":{"idUsuario":"public-user","nome":"Ana Souza","tipo":"ALUNO","tipoPerfil":"PUBLICO","xp":120,"nivel":4,"cor":"#425BC2","urlFotoPerfil":"https://storage.example/photo.jpg"}}',
      200,
      headers: {'content-type': 'application/json; charset=utf-8'},
    );

    final profile = await UsersService.instance.profileOf('public-user');

    expect(profile?['tipoPerfil'], 'PUBLICO');
    expect(profile?['nome'], 'Ana Souza');
    expect(profile?['urlFotoPerfil'], 'https://storage.example/photo.jpg');
  });

  testWidgets('public profile page shows the selected user profile data', (
    tester,
  ) async {
    FakeApi.responseOverrides['GET /users/public-user/profile'] = http.Response(
      '{"dados":{"idUsuario":"public-user","nome":"Ana Souza","tipo":"ALUNO","tipoPerfil":"PUBLICO","xp":120,"nivel":4,"moedas":300,"cor":"#425BC2","urlFotoPerfil":""}}',
      200,
      headers: {'content-type': 'application/json; charset=utf-8'},
    );

    await tester.pumpWidget(
      const MaterialApp(
        home: PublicProfilePage(userId: 'public-user', userName: 'Ana Souza'),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Perfil de Ana Souza'), findsOneWidget);
    expect(find.text('Ana Souza'), findsOneWidget);
    expect(find.text('Estudante'), findsAtLeastNWidgets(1));
    expect(find.text('4'), findsOneWidget);
    expect(find.text('120'), findsOneWidget);
    expect(find.text('300'), findsOneWidget);
    expect(find.text('Editar Perfil'), findsNothing);
    expect(FakeApi.requests, contains('GET /users/public-user/profile'));
  });

  testWidgets('ranking opens the selected user public profile', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await StorageService.instance.saveCurrentUser(
      const AppUser(
        id: 'current-user',
        name: 'Usuário atual',
        email: 'atual@educano.test',
      ),
    );
    FakeApi.responseOverrides['GET /ranking'] = http.Response(
      '{"dados":[{"posicao":1,"id":"public-user","nome":"Nome antigo","xp":1,"nivel":1,"urlFotoPerfil":""}],"paginacao":{"temMais":false}}',
      200,
      headers: {'content-type': 'application/json; charset=utf-8'},
    );
    FakeApi.responseOverrides['GET /users/me/profile'] = http.Response(
      '{"perfil":{"tipoPerfil":"PUBLICO","urlFotoPerfil":"","xp":90,"moedas":10}}',
      200,
      headers: {'content-type': 'application/json; charset=utf-8'},
    );
    FakeApi.responseOverrides['GET /users/public-user/profile'] = http.Response(
      '{"dados":{"idUsuario":"public-user","nome":"Ana Souza","tipo":"ALUNO","tipoPerfil":"PUBLICO","xp":120,"nivel":4,"moedas":300,"cor":"#425BC2","urlFotoPerfil":""}}',
      200,
      headers: {'content-type': 'application/json; charset=utf-8'},
    );

    await tester.pumpWidget(
      MaterialApp(
        navigatorKey: NavigationService.navigatorKey,
        home: const RankingPage(),
        onGenerateRoute: (settings) {
          if (settings.name == AppRoutes.publicProfile) {
            final args = settings.arguments as PublicProfileRouteArgs;
            return MaterialPageRoute<void>(
              builder: (_) => PublicProfilePage(
                userId: args.userId,
                userName: args.userName,
              ),
            );
          }
          return null;
        },
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Nome antigo'));
    await tester.pumpAndSettle();

    expect(find.text('Perfil de Ana Souza'), findsOneWidget);
    expect(find.text('4'), findsOneWidget);
    expect(find.text('120'), findsOneWidget);
    expect(find.text('300'), findsOneWidget);
    expect(FakeApi.requests, contains('GET /users/public-user/profile'));
  });

  testWidgets('mobile header avatar opens the profile page', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final searchController = TextEditingController();
    addTearDown(searchController.dispose);

    await tester.pumpWidget(
      MaterialApp(
        navigatorKey: NavigationService.navigatorKey,
        home: Scaffold(
          body: AppHeader(
            isMobile: true,
            onMenuPressed: () {},
            searchController: searchController,
            user: const AppUser(
              id: 'user-id',
              name: 'Ana Silva',
              email: 'ana@educano.test',
            ),
          ),
        ),
        onGenerateRoute: (settings) => MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => const Scaffold(body: Text('Perfil aberto')),
        ),
      ),
    );

    await tester.tap(find.byTooltip('Perfil'));
    await tester.pumpAndSettle();

    expect(find.text('Perfil aberto'), findsOneWidget);
    expect(AppRoutes.profile, '/perfil');
  });

  testWidgets('app header receives the signed current profile photo', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    const photoUrl =
        'https://storage.example/profile-photo.png?signature=fresh';
    await StorageService.instance.saveToken('token-de-teste');
    await StorageService.instance.saveCurrentUser(
      const AppUser(
        id: 'user-id',
        name: 'Ana Silva',
        email: 'ana@educano.test',
      ),
    );
    FakeApi.responseOverrides['GET /users/me/profile'] = http.Response(
      '{"perfil":{"urlFotoPerfil":"$photoUrl"}}',
      200,
      headers: {'content-type': 'application/json; charset=utf-8'},
    );

    await tester.pumpWidget(
      MaterialApp(
        navigatorKey: NavigationService.navigatorKey,
        home: const AppScaffold(
          selectedMenu: AppMenu.home,
          child: Text('Home'),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.byWidgetPredicate(
        (widget) => widget is ProfileAvatar && widget.imageUrl == photoUrl,
      ),
      findsOneWidget,
    );
    expect(FakeApi.requests, contains('GET /users/me/profile'));
  });

  testWidgets('mobile dashboard FAB sits just above bottom navigation', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await StorageService.instance.clearCurrentUser();

    await tester.pumpWidget(
      MaterialApp(
        navigatorKey: NavigationService.navigatorKey,
        home: const AppScaffold(
          selectedMenu: AppMenu.dashboard,
          child: SizedBox.shrink(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final fabButton = find.descendant(
      of: find.byType(AppFabMenu),
      matching: find.byType(InkWell),
    );
    final bottomNavigation = find.byType(AppBottomNavigation);
    final gap =
        tester.getTopLeft(bottomNavigation).dy -
        tester.getRect(fabButton).bottom;

    expect(fabButton, findsOneWidget);
    expect(gap, closeTo(32, 1));
    expect(tester.takeException(), isNull);
  });
}
