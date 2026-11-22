import 'package:flutter/material.dart';

class ProfileAvatar extends StatelessWidget {
  final String? imageUrl;
  final double radius;
  final Color backgroundColor;
  final Widget placeholder;

  const ProfileAvatar({
    super.key,
    required this.imageUrl,
    required this.radius,
    required this.backgroundColor,
    required this.placeholder,
  });

  @override
  Widget build(BuildContext context) {
    final url = imageUrl?.trim();
    if (url == null || url.isEmpty) return _placeholder();

    return ClipOval(
      child: Image.network(
        url,
        width: radius * 2,
        height: radius * 2,
        fit: BoxFit.cover,
        gaplessPlayback: true,
        webHtmlElementStrategy: WebHtmlElementStrategy.fallback,
        errorBuilder: (_, _, _) => _placeholder(),
      ),
    );
  }

  Widget _placeholder() => CircleAvatar(
    radius: radius,
    backgroundColor: backgroundColor,
    child: placeholder,
  );
}
