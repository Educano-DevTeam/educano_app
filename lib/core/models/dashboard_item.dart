import 'package:flutter/material.dart';

class DashboardItem {
  final String name;
  final String description;
  final int price;
  final IconData icon;
  final Color color;
  final String category;

  const DashboardItem({
    required this.name,
    required this.description,
    required this.price,
    required this.icon,
    required this.color,
    required this.category,
  });

  DashboardItem copyWith({
    String? name,
    String? description,
    int? price,
    IconData? icon,
    Color? color,
    String? category,
  }) {
    return DashboardItem(
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      category: category ?? this.category,
    );
  }
}