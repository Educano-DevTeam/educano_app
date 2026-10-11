import 'package:flutter/material.dart';

import '../views/forgot_password_view.dart';

class ForgotPasswordContent extends StatelessWidget {
  const ForgotPasswordContent({super.key});

  Widget? buildContent() => const ForgotPasswordView();

  @override
  Widget build(BuildContext context) =>
      buildContent() ?? const SizedBox.shrink();
}
