import 'package:flutter/material.dart';

import 'course_mini_audio_player.dart';

class CoursePageWithMiniAudio extends StatelessWidget {
  final Widget child;

  const CoursePageWithMiniAudio({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(child: child),
        const Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: CourseMiniAudioPlayer(),
        ),
      ],
    );
  }
}
