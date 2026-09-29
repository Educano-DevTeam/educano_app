import 'package:flutter/material.dart';

class Course {
  final String initials;
  final Color color;
  final String name;
  final String progressLabel;

  const Course({
    required this.initials,
    required this.color,
    required this.name,
    required this.progressLabel,
  });
}
