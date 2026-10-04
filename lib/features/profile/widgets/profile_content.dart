import 'package:flutter/material.dart';
import '../../../core/navigation/app_menu.dart';
import '../views/profile_view.dart';

class ProfileContent extends StatelessWidget {
  final AppMenu selectedMenu;
  const ProfileContent({super.key, required this.selectedMenu});
  @override
  Widget build(BuildContext context) => selectedMenu == AppMenu.profile ? const ProfileView() : const SizedBox.shrink();
}
