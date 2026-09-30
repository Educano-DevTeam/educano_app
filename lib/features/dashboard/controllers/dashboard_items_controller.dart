import 'package:flutter/material.dart';

import '../../../core/data/repositories/dashboard_items_repository.dart';
import '../../../core/models/dashboard_item.dart';

class DashboardItemsController extends ChangeNotifier {
  DashboardItemsController({
    DashboardItemsRepository? repository,
  }) : _repository =
            repository ?? DashboardItemsRepository.instance {
    _items = _repository.getAll();
  }

  final DashboardItemsRepository _repository;

  List<DashboardItem> _items = [];

  List<DashboardItem> get items => List.unmodifiable(_items);

  void add(DashboardItem item) {
    _repository.add(item);
    _refresh();
  }

  void update(
    DashboardItem oldItem,
    DashboardItem updatedItem,
  ) {
    _repository.update(oldItem, updatedItem);
    _refresh();
  }

  void delete(DashboardItem item) {
    _repository.delete(item);
    _refresh();
  }

  void _refresh() {
    _items = _repository.getAll();
    notifyListeners();
  }
}