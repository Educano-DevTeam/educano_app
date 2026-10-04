import 'package:flutter/material.dart';
import '../../../core/navigation/app_menu.dart';
import '../views/ranking_view.dart';

class RankingContent extends StatelessWidget {
  final AppMenu selectedMenu;
  const RankingContent({super.key, required this.selectedMenu});
  @override
  Widget build(BuildContext context) => selectedMenu == AppMenu.ranking ? const RankingView() : const SizedBox.shrink();
}
