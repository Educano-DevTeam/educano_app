import 'package:flutter/material.dart';

import '../../../core/layout/app_scaffold.dart';
import '../../../core/navigation/app_menu.dart';
import '../../../services/api_client.dart';
import '../../../services/users_service.dart';
import '../views/profile_view.dart';

class PublicProfilePage extends StatefulWidget {
  final String userId;
  final String userName;

  const PublicProfilePage({
    super.key,
    required this.userId,
    required this.userName,
  });

  @override
  State<PublicProfilePage> createState() => _PublicProfilePageState();
}

class _PublicProfilePageState extends State<PublicProfilePage> {
  Map<String, dynamic>? _profile;
  String? _error;
  bool _isPrivate = false;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() {
      _loading = true;
      _error = null;
      _isPrivate = false;
    });

    try {
      final profile = await UsersService.instance.profileOf(widget.userId);
      if (!mounted) return;

      if (profile == null || profile['tipoPerfil'] != 'PUBLICO') {
        setState(() {
          _isPrivate = true;
          _loading = false;
        });
        return;
      }

      setState(() {
        _profile = {
          ...profile,
          if (profile['nome'] is! String || (profile['nome'] as String).isEmpty)
            'nome': widget.userName,
        };
        _loading = false;
      });
    } on ApiException catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error.message;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) => AppScaffold(
    selectedMenu: AppMenu.profile,
    child: _loading
        ? const Center(child: CircularProgressIndicator())
        : _error != null
        ? _ProfileLoadError(message: _error!, onRetry: _loadProfile)
        : _isPrivate
        ? const _PrivateProfileMessage()
        : ProfileView(publicProfile: _profile!),
  );
}

class _ProfileLoadError extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ProfileLoadError({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: 12),
          TextButton(onPressed: onRetry, child: const Text('Tentar novamente')),
        ],
      ),
    ),
  );
}

class _PrivateProfileMessage extends StatelessWidget {
  const _PrivateProfileMessage();

  @override
  Widget build(BuildContext context) => const Center(
    child: Padding(
      padding: EdgeInsets.all(24),
      child: Text('Este perfil é privado e não pode ser exibido.'),
    ),
  );
}
