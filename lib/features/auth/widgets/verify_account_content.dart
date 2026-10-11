import 'package:flutter/material.dart';

import '../views/verify_account_view.dart';

class VerifyAccountContent extends StatelessWidget {
  final String email;

  const VerifyAccountContent({super.key, required this.email});

  Widget? buildContent() => email.trim().isEmpty
      ? null
      : VerifyAccountView(email: email);

  @override
  Widget build(BuildContext context) =>
      buildContent() ?? const SizedBox.shrink();
}
