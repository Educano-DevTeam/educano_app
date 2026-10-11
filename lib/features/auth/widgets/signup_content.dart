import 'package:flutter/material.dart';

import '../views/signup_view.dart';

class SignupContent extends StatelessWidget {
  const SignupContent({super.key});

  Widget? buildContent() => const SignupView();

  @override
  Widget build(BuildContext context) =>
      buildContent() ?? const SizedBox.shrink();
}
