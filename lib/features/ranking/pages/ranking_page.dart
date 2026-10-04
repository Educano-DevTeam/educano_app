import 'package:flutter/material.dart';
import '../../../core/layout/app_scaffold.dart';
import '../../../core/navigation/app_menu.dart';
import '../widgets/ranking_content.dart';

class RankingPage extends StatelessWidget {
  const RankingPage({super.key});
  @override
  Widget build(BuildContext context) => const AppScaffold(selectedMenu: AppMenu.ranking, child: RankingContent(selectedMenu: AppMenu.ranking));
}
