import '../../../core/theme/educano_colors.dart';
import 'package:flutter/material.dart';

/// Logo circular do Educano.
///
class AppLogo extends StatelessWidget {
  final double size;
  final bool onDarkBackground;

  const AppLogo({super.key, this.size = 64, this.onDarkBackground = false});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(size / 2),
      child: Container(
        width: size,
        height: size,
        color: Colors.white,
        child: Image.asset(
          'lib/assets/Educano_Logo.jpeg',
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Icon(
              Icons.school_rounded,
              size: size * 0.55,
              color: EducanoColors.primaryBlue,
            );
          },
        ),
      ),
    );
  }
}
