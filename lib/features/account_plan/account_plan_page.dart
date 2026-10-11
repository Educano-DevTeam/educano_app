import 'package:flutter/material.dart';

import '../../core/layout/app_scaffold.dart';
import '../../core/navigation/app_menu.dart';
import 'account_plan_content.dart';

class AccountPlanPage extends StatelessWidget {
  const AccountPlanPage({super.key});

  @override
  Widget build(BuildContext context) => const AppScaffold(
    selectedMenu: AppMenu.profile,
    child: AccountPlanContent(),
  );
}
