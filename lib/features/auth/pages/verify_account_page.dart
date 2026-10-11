import 'package:flutter/material.dart';

import '../widgets/verify_account_content.dart';

class VerifyAccountPage extends StatelessWidget {
  final String email;

  const VerifyAccountPage({super.key, required this.email});

  @override
  Widget build(BuildContext context) =>
      VerifyAccountContent(email: email);
}
