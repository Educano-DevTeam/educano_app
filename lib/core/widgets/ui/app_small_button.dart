import 'package:flutter/material.dart';

import '../../theme/theme.dart';

class AppSmallButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;

  final Color? color;
  final Color? textColor;

  final IconData? icon;

  const AppSmallButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.color,
    this.textColor,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 32,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color ?? EducanoColors.primaryBlue,
          foregroundColor: textColor ?? Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: icon == null
            ? Text(
                text,
                style: const TextStyle(fontSize: 12),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, size: 14),
                  const SizedBox(width: 5),
                  Text(
                    text,
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ),
      ),
    );
  }
}