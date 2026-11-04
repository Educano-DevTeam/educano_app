import 'package:flutter/material.dart';

class ProfileCourse {
  final String initials;
  final Color color;
  final String name;
  final String progressLabel;
  final String? id;
  const ProfileCourse({required this.initials, required this.color, required this.name, required this.progressLabel, this.id});
}
