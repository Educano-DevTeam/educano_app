import 'package:flutter/material.dart';

import '../../models/dashboard_item.dart';
import '../../theme/theme.dart';

class DashboardItemsRepository {
  DashboardItemsRepository._();

  static final DashboardItemsRepository instance =
      DashboardItemsRepository._();

  final List<DashboardItem> _items = [
    DashboardItem(
      name: 'Boost de XP',
      description: 'Dobra o XP ganho por 24 horas.',
      price: 200,
      icon: Icons.bolt_rounded,
      color: EducanoColors.accentYellow,
      category: 'Boosts',
    ),
    DashboardItem(
      name: 'Escudo de Sequência',
      description: 'Protege sua sequência por um dia.',
      price: 150,
      icon: Icons.shield_rounded,
      color: EducanoColors.primaryBlue,
      category: 'Proteção',
    ),
    DashboardItem(
      name: 'Dica Extra',
      description: 'Revela uma dica em qualquer questão.',
      price: 80,
      icon: Icons.lightbulb_rounded,
      color: EducanoColors.successGreen,
      category: 'Estudos',
    ),
    DashboardItem(
      name: 'Tempo Extra',
      description: 'Adiciona 5 minutos em simulados.',
      price: 120,
      icon: Icons.timer_rounded,
      color: EducanoColors.successGreen,
      category: 'Estudos',
    ),
    DashboardItem(
      name: 'Reviver Tentativa',
      description: 'Refaz uma questão errada.',
      price: 100,
      icon: Icons.refresh_rounded,
      color: EducanoColors.error,
      category: 'Estudos',
    ),
    DashboardItem(
      name: 'Avatar Especial',
      description: 'Desbloqueie um avatar exclusivo.',
      price: 500,
      icon: Icons.face_rounded,
      color: EducanoColors.darkGreen,
      category: 'Personalização',
    ),
  ];

  List<DashboardItem> getAll() {
    return List.unmodifiable(_items);
  }

  void add(DashboardItem item) {
    _items.add(item);
  }

  void update(
    DashboardItem oldItem,
    DashboardItem updatedItem,
  ) {
    final index = _items.indexOf(oldItem);

    if (index == -1) return;

    _items[index] = updatedItem;
  }

  void delete(DashboardItem item) {
    _items.remove(item);
  }
}