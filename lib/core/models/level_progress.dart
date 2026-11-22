class LevelProgress {
  static const Map<int, int> _xpRequiredByLevel = {
    1: 250,
    2: 500,
    3: 1000,
    4: 2000,
    5: 5000,
  };

  final int level;
  final int xpInLevel;
  final int xpRequiredForNextLevel;
  final int totalXp;

  const LevelProgress({
    required this.level,
    required this.xpInLevel,
    required this.xpRequiredForNextLevel,
    required this.totalXp,
  });

  factory LevelProgress.fromTotalXp(int totalXp) {
    final xp = totalXp < 0 ? 0 : totalXp;
    var level = 1;
    while (xp >= _xpAtLevel(level) + _xpRequiredForLevel(level)) {
      level++;
    }

    return LevelProgress(
      level: level,
      xpInLevel: xp - _xpAtLevel(level),
      xpRequiredForNextLevel: _xpRequiredForLevel(level),
      totalXp: xp,
    );
  }

  static int _xpRequiredForLevel(int level) {
    final configured = _xpRequiredByLevel[level];
    if (configured != null) return configured;
    return _xpRequiredByLevel[5]! * (1 << (level - 5));
  }

  static int _xpAtLevel(int level) {
    var total = 0;
    for (var current = 1; current < level; current++) {
      total += _xpRequiredForLevel(current);
    }
    return total;
  }

  double get progress => xpInLevel / xpRequiredForNextLevel;
  String get percentLabel => '${(progress * 100).round()}%';
  String get label =>
      '$xpInLevel/$xpRequiredForNextLevel XP para o Level ${level + 1} · $totalXp XP no total';
}
