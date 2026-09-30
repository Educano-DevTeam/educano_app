import 'package:flutter/material.dart';

class AppSummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final String variation;
  final String footer;
  final IconData icon;
  final Color color;
  final Color? variationColor;

  const AppSummaryCard({
    super.key,
    required this.title,
    required this.value,
    required this.variation,
    required this.footer,
    required this.icon,
    required this.color,
    this.variationColor,
  });

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    throw UnimplementedError();
  }

  ...
}