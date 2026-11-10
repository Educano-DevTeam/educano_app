import 'package:flutter/material.dart';

import '../../../core/models/app_user.dart';
import '../../../core/theme/educano_colors.dart';
import '../../../services/auth_service.dart';
import '../../home/pages/home_page.dart';
import 'login_page.dart';

class AuthEntryPage extends StatefulWidget {
  const AuthEntryPage({super.key});

  @override
  State<AuthEntryPage> createState() => _AuthEntryPageState();
}

class _AuthEntryPageState extends State<AuthEntryPage> {
  late Future<AppUser?> _userFuture;

  @override
  void initState() {
    super.initState();
    _userFuture = AuthService.instance.restoreSession();
  }

  @override
  Widget build(BuildContext context) => FutureBuilder<AppUser?>(
    future: _userFuture,
    builder: (context, snapshot) {
      if (snapshot.hasError) {
        return Material(
          color: EducanoColors.background,
          child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Não foi possível conectar ao servidor do Educano.'),
              TextButton(
                onPressed: () {
                  setState(() {
                    _userFuture = AuthService.instance.restoreSession();
                  });
                },
                child: const Text('Tentar novamente'),
              ),
            ],
          ),
          ),
        );
      }
      if (!snapshot.hasData && snapshot.connectionState != ConnectionState.done) {
        return const ColoredBox(
          color: EducanoColors.background,
          child: Center(
            child: CircularProgressIndicator(color: EducanoColors.primaryBlue),
          ),
        );
      }
      return snapshot.data == null ? const LoginPage() : const HomePage();
    },
  );
}
