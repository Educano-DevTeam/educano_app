import 'package:flutter/material.dart';

import '../../../core/constants/app_breakpoints.dart';
import '../../../core/layout/app_scaffold.dart';
import '../../../core/navigation/app_menu.dart';
import '../../../core/navigation/app_navigation.dart';
import '../widgets/store_inventory_content.dart';

class StoreInventoryPage extends StatefulWidget {
  const StoreInventoryPage({super.key});

  @override
  State<StoreInventoryPage> createState() => _StoreInventoryPageState();
}

class _StoreInventoryPageState extends State<StoreInventoryPage> {
  final TextEditingController searchController = TextEditingController();

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      selectedMenu: AppMenu.storeInventory,
      child: const StoreInventoryContent(selectedMenu: AppMenu.storeInventory),
    );
  }
}
