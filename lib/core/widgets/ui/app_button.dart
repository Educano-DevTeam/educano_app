import 'package:flutter/material.dart';

import '../../theme/educano_colors.dart';

class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final bool outlined;
  final bool expanded;

  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.backgroundColor,
    this.foregroundColor,
    this.outlined = false,
    this.expanded = false,
  });

  @override
  Widget build(BuildContext context) {
    final background = backgroundColor ?? EducanoColors.primaryBlue;
    final foreground = foregroundColor ?? Colors.white;

    final style = outlined
        ? OutlinedButton.styleFrom(
            foregroundColor: foreground,
            side: BorderSide(color: background),
            minimumSize: const Size(0, 44),
            padding: const EdgeInsets.symmetric(horizontal: 20),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          )
        : ElevatedButton.styleFrom(
            backgroundColor: background,
            foregroundColor: foreground,
            minimumSize: const Size(0, 44),
            padding: const EdgeInsets.symmetric(horizontal: 20),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          );

    final button = icon == null
        ? (outlined
            ? OutlinedButton(
                onPressed: onPressed,
                style: style,
                child: Text(label),
              )
            : ElevatedButton(
                onPressed: onPressed,
                style: style,
                child: Text(label),
              ))
        : (outlined
            ? OutlinedButton.icon(
                onPressed: onPressed,
                style: style,
                icon: Icon(icon, size: 18),
                label: Text(label),
              )
            : ElevatedButton.icon(
                onPressed: onPressed,
                style: style,
                icon: Icon(icon, size: 18),
                label: Text(label),
              ));

    if (!expanded) {
      return button;
    }

    return SizedBox(
      width: double.infinity,
      child: button,
    );
  }
}