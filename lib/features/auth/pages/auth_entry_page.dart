import 'package:flutter/material.dart';

import '../../../core/models/app_user.dart';
import '../../../core/theme/educano_colors.dart';
import '../../../services/storage_service.dart';
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
    _userFuture = StorageService.instance.loadCurrentUser();
  }

  @override
  Widget build(BuildContext context) => FutureBuilder<AppUser?>(
    future: _userFuture,
    builder: (context, snapshot) {
      if (snapshot.hasError) {
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Não foi possível carregar sua sessão local.'),
              TextButton(
                onPressed: () {
                  setState(() {
                    _userFuture = StorageService.instance.loadCurrentUser();
                  });
                },
                child: const Text('Tentar novamente'),
              ),
            ],
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
