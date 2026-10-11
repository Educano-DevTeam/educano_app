import 'package:flutter/material.dart';

class DashboardStatistic {
  final String title;
  final String value;
  final String variation;
  final String footer;
  final IconData icon;
  final Color color;
  final Color variationColor;

  const DashboardStatistic({
    required this.title,
    required this.value,
    required this.variation,
    required this.footer,
    required this.icon,
    required this.color,
    required this.variationColor,
  });
}