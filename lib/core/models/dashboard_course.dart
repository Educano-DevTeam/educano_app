class DashboardCourse {
  final String name;
  final String description;
  final String category;
  final String status;
  final String createdAt;
  final int enrolled;
  final int capacity;

  const DashboardCourse({
    required this.name,
    required this.description,
    required this.category,
    required this.status,
    required this.createdAt,
    required this.enrolled,
    required this.capacity,
  });

  double get progress {
    if (capacity <= 0) return 0;

    return enrolled / capacity;
  }

  DashboardCourse copyWith({
    String? name,
    String? description,
    String? category,
    String? status,
    String? createdAt,
    int? enrolled,
    int? capacity,
  }) {
    return DashboardCourse(
      name: name ?? this.name,
      description: description ?? this.description,
      category: category ?? this.category,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      enrolled: enrolled ?? this.enrolled,
      capacity: capacity ?? this.capacity,
    );
  }
}