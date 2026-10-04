import 'package:flutter/material.dart';
import '../../../core/layout/app_scaffold.dart';
import '../../../core/navigation/app_menu.dart';
import '../widgets/settings_content.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});
  @override
  Widget build(BuildContext context) => const AppScaffold(selectedMenu: AppMenu.settings, child: SettingsContent(selectedMenu: AppMenu.settings));
}
