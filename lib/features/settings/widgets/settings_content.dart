import 'package:flutter/material.dart';
import '../../../core/navigation/app_menu.dart';
import '../views/settings_view.dart';

class SettingsContent extends StatelessWidget {
  final AppMenu selectedMenu;
  const SettingsContent({super.key, required this.selectedMenu});
  @override
  Widget build(BuildContext context) => selectedMenu == AppMenu.settings ? const SettingsView() : const SizedBox.shrink();
}
