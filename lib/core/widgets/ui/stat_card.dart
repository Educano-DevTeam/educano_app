import 'package:flutter/material.dart';
import '../../theme/educano_colors.dart';

class StatCard extends StatelessWidget {
  final String label;
  final String value;
  final Color valueColor;

  const StatCard({super.key, required this.label, required this.value, this.valueColor = EducanoColors.legacyTextPrimary});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
        decoration: BoxDecoration(
          color: EducanoColors.legacyBackground,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: EducanoColors.legacyCardBorder),
        ),
        child: Column(children: [
          Text(label, style: const TextStyle(fontSize: 12, color: EducanoColors.legacyTextSecondary), textAlign: TextAlign.center),
          const SizedBox(height: 6),
          Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: valueColor)),
        ]),
      );
}
