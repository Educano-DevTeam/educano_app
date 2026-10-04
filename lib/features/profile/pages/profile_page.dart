import 'package:flutter/material.dart';
import '../../../core/layout/app_scaffold.dart';
import '../../../core/navigation/app_menu.dart';
import '../widgets/profile_content.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});
  @override
  Widget build(BuildContext context) => const AppScaffold(selectedMenu: AppMenu.profile, child: ProfileContent(selectedMenu: AppMenu.profile));
}
