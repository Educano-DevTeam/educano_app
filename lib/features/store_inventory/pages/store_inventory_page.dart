import 'package:flutter/material.dart';

import '../../../core/layout/app_scaffold.dart';
import '../../../core/navigation/app_menu.dart';
import '../widgets/store_inventory_content.dart';

class StoreInventoryPage extends StatelessWidget {
  const StoreInventoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppScaffold(
      selectedMenu: AppMenu.storeInventory,
      child: StoreInventoryContent(),
    );
  }
}