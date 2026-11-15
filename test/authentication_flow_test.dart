import 'package:educano_app/core/navigation/app_routes.dart';
import 'package:educano_app/core/navigation/navigation_service.dart';
import 'package:educano_app/core/models/app_user.dart';
import 'package:educano_app/features/auth/pages/forgot_password_page.dart';
import 'package:educano_app/features/auth/pages/login_page.dart';
import 'package:educano_app/features/auth/pages/signup_page.dart';
import 'package:educano_app/features/auth/pages/verify_account_page.dart';
import 'package:educano_app/main.dart';
import 'package:educano_app/services/auth_service.dart';
import 'package:educano_app/services/api_client.dart';
import 'package:educano_app/services/storage_service.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

import 'support/fake_api.dart';

void main() {
  setUpAll(() {
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
    FakeApi.install();
  });

  setUp(() async {
    FakeApi.reset();
    await StorageService.instance.clearCurrentUser();
  });

  testWidgets('a new installation starts at the login page', (tester) async {
    await tester.pumpWidget(const EducanoApp());
    await tester.pumpAndSettle();

    expect(find.text('Bem-vindo de volta!'), findsOneWidget);
    expect(find.text('Criar conta'), findsOneWidget);
  });

  testWidgets('sign up, verify account and open home', (tester) async {
    tester.view.physicalSize = const Size(1280, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    // Uma sessão antiga não deve transformar o cadastro público em operação
    // administrativa na API.
    await StorageService.instance.saveToken('token-antigo');
    await tester.pumpWidget(_AuthFlowTestApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Criar conta'));
    await tester.pumpAndSettle();

    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), 'Ana Silva');
    await tester.enterText(fields.at(1), 'ana.silva@educano.test');
    await tester.enterText(fields.at(2), FakeApi.password);
    await tester.enterText(fields.at(3), FakeApi.password);
    await tester.tap(find.byType(Checkbox));
    await tester.tap(find.text('Criar conta').last);
    await tester.pumpAndSettle(const Duration(milliseconds: 100));

    expect(FakeApi.authorizationByPath['/auth/register'], isNull);
    expect(FakeApi.requests, contains('POST /auth/register'));
    expect(find.text('Verifique sua conta'), findsOneWidget);
    final codeFields = find.byType(TextField);
    for (var index = 0; index < 6; index++) {
      await tester.enterText(codeFields.at(index), FakeApi.validCode[index]);
    }
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();

    expect(find.text('HOME'), findsOneWidget);
    expect(FakeApi.authorizationByPath['/auth/verify-code'], isNull);
    expect(FakeApi.authorizationByPath['/auth/login'], isNull);
    final user = await StorageService.instance.loadCurrentUser();
    expect(user?.name, 'Ana Silva');
    expect(user?.email, 'ana.silva@educano.test');
    expect(user?.id, isNotEmpty);

    await StorageService.instance.saveSidebarExpanded(false);
    expect(await StorageService.instance.loadSidebarExpanded(), isFalse);

    // Encerra a sessão para parar a renovação periódica do token.
    await AuthService.instance.logout();
  });

  test('restores a saved session through the API session endpoint', () async {
    await StorageService.instance.saveToken('token-de-teste');

    final user = await AuthService.instance.restoreSession();

    expect(user?.email, 'aluno@educano.test');
    expect(await StorageService.instance.loadToken(), 'token-de-teste');
    expect(FakeApi.requests, contains('GET /auth/me'));
    expect(FakeApi.requests, isNot(contains('POST /auth/refresh')));
  });

  test('malformed API responses become a controlled login error', () async {
    FakeApi.responseOverrides['POST /auth/login'] = http.Response(
      '<html>gateway error</html>',
      200,
    );

    final result = await AuthService.instance.login(
      email: 'aluno@educano.test',
      password: FakeApi.password,
    );

    expect(result.success, isFalse);
    expect(result.message, contains('resposta inválida'));
    expect(await StorageService.instance.loadToken(), isNull);
  });

  test('missing list data falls back to an empty collection', () {
    expect(ApiClient.responseList(null, endpoint: '/items.dados'), isEmpty);
    expect(
      () => ApiClient.responseList({'not': 'a list'}, endpoint: '/items.dados'),
      throwsA(isA<ApiException>()),
    );
    expect(
      () => ApiClient.responseMap({}, endpoint: '/auth/login'),
      throwsA(isA<ApiException>()),
    );
  });

  testWidgets('valid login opens home and persists the current user', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1280, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(_AuthFlowTestApp());
    await tester.pumpAndSettle();

    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), 'aluno@educano.test');
    await tester.enterText(fields.at(1), FakeApi.password);
    await tester.tap(find.text('Entrar'));
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();

    expect(find.text('HOME'), findsOneWidget);
    expect(
      (await StorageService.instance.loadCurrentUser())?.name,
      'Ana Souza',
    );
    expect(await StorageService.instance.loadToken(), 'token-de-teste');

    await AuthService.instance.logout();
  });

  testWidgets('profile shows stored user and opens the account plans', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1280, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await StorageService.instance.saveToken('token-de-teste');
    await StorageService.instance.saveCurrentUser(
      const AppUser(
        id: 'profile-test-user',
        name: 'Ana Silva',
        email: 'ana.silva@educano.test',
      ),
    );
    await tester.pumpWidget(const EducanoApp());
    await tester.pumpAndSettle();
    NavigationService.pushNamed(AppRoutes.profile);
    await tester.pumpAndSettle();

    // A sessão é confirmada na API, que devolve os dados atuais da conta.
    expect(find.text('Ana Souza'), findsNWidgets(2));
    expect(find.text('aluno@educano.test'), findsOneWidget);

    await tester.tap(find.text('Ver planos'));
    await tester.pumpAndSettle();

    expect(find.text('Plano de Conta'), findsOneWidget);

    await AuthService.instance.logout();
  });
}

class _AuthFlowTestApp extends StatelessWidget {
  const _AuthFlowTestApp();

  @override
  Widget build(BuildContext context) => MaterialApp(
    navigatorKey: NavigationService.navigatorKey,
    initialRoute: AppRoutes.login,
    onGenerateRoute: (settings) {
      final page = switch (settings.name) {
        AppRoutes.login => const LoginPage(),
        AppRoutes.signup => const SignupPage(),
        AppRoutes.verifyAccount => VerifyAccountPage(
          email: settings.arguments! as String,
        ),
        AppRoutes.forgotPassword => const ForgotPasswordPage(),
        AppRoutes.home => const Scaffold(body: Center(child: Text('HOME'))),
        _ => const LoginPage(),
      };
      return MaterialPageRoute<void>(settings: settings, builder: (_) => page);
    },
  );
}
