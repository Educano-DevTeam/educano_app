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

class HoverButton extends StatefulWidget {
  final String label;
  final IconData? leadingIcon;
  final IconData? trailingIcon;
  final VoidCallback onPressed;
  final Color background;
  final Color foreground;
  final EdgeInsetsGeometry padding;
  final double borderRadius;
  final double fontSize;

  const HoverButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.leadingIcon,
    this.trailingIcon,
    this.background = EducanoColors.legacyPrimary,
    this.foreground = Colors.white,
    this.padding = const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
    this.borderRadius = 8,
    this.fontSize = 12,
  });

  @override
  State<HoverButton> createState() => _HoverButtonState();
}

class _HoverButtonState extends State<HoverButton> {
  bool _hovered = false;

  Color _darken(Color color) => HSLColor.fromColor(color)
      .withLightness((HSLColor.fromColor(color).lightness - 0.08).clamp(0.0, 1.0))
      .toColor();

  @override
  Widget build(BuildContext context) => MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          decoration: BoxDecoration(
            color: _hovered ? _darken(widget.background) : widget.background,
            borderRadius: BorderRadius.circular(widget.borderRadius),
            boxShadow: _hovered
                ? [BoxShadow(color: widget.background.withValues(alpha: 0.35), blurRadius: 10, offset: const Offset(0, 3))]
                : const [],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(widget.borderRadius),
              onTap: widget.onPressed,
              child: Padding(
                padding: widget.padding,
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  if (widget.leadingIcon != null) ...[Icon(widget.leadingIcon, size: 15, color: widget.foreground), const SizedBox(width: 6)],
                  Text(widget.label, style: TextStyle(color: widget.foreground, fontSize: widget.fontSize, fontWeight: FontWeight.w600)),
                  if (widget.trailingIcon != null) ...[const SizedBox(width: 4), Icon(widget.trailingIcon, size: 15, color: widget.foreground)],
                ]),
              ),
            ),
          ),
        ),
      );
}

class HoverOutlineButton extends StatefulWidget {
  final String label;
  final IconData? leadingIcon;
  final VoidCallback onPressed;
  final Color foreground;
  final Color borderColor;

  const HoverOutlineButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.leadingIcon,
    this.foreground = EducanoColors.legacyTextPrimary,
    this.borderColor = EducanoColors.legacyCardBorder,
  });

  @override
  State<HoverOutlineButton> createState() => _HoverOutlineButtonState();
}

class _HoverOutlineButtonState extends State<HoverOutlineButton> {
  bool _hovered = false;
  @override
  Widget build(BuildContext context) => MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          decoration: BoxDecoration(
            color: _hovered ? EducanoColors.legacyBackground : Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: _hovered ? widget.foreground.withValues(alpha: 0.35) : widget.borderColor),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: widget.onPressed,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  if (widget.leadingIcon != null) ...[Icon(widget.leadingIcon, size: 15, color: widget.foreground), const SizedBox(width: 6)],
                  Text(widget.label, style: TextStyle(color: widget.foreground, fontSize: 12.5, fontWeight: FontWeight.w600)),
                ]),
              ),
            ),
          ),
        ),
      );
}
