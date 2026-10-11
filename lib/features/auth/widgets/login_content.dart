import 'package:flutter/material.dart';

import '../views/login_view.dart';

class LoginContent extends StatelessWidget {
  const LoginContent({super.key});

  Widget? buildContent() => const LoginView();

  @override
  Widget build(BuildContext context) =>
      buildContent() ?? const SizedBox.shrink();
}
