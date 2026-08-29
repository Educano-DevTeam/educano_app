import 'package:flutter/material.dart';

import '../../theme/theme.dart';

class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;

  final Color? color;
  final Color? textColor;

  final IconData? icon;

  final double height;
  final double borderRadius;

  const AppButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.color,
    this.textColor,
    this.icon,
    this.height = 44,
    this.borderRadius = 8,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: height,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color ?? EducanoColors.primaryBlue,
          foregroundColor: textColor ?? Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
        ),
        child: icon == null
            ? Text(text)
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, size: 18),
                  const SizedBox(width: 8),
                  Text(text),
                ],
              ),
      ),
    );
  }
}