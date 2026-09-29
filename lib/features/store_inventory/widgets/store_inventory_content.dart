import 'package:flutter/material.dart';

import '../../../core/navigation/app_menu.dart';
import '../views/store_inventory_view.dart';

class StoreInventoryContent extends StatelessWidget {
  final AppMenu selectedMenu;

  const StoreInventoryContent({
    super.key,
    required this.selectedMenu,
  });

  @override
  Widget build(BuildContext context) {
    switch (selectedMenu) {
      case AppMenu.storeInventory:
        return const StoreInventoryView();

      default:
        return const SizedBox();
    }
  }
}