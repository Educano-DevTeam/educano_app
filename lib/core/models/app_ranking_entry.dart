class RankingEntry {
  final int position;
  final String name;
  final int xp;
  final bool isCurrentUser;

  const RankingEntry({
    required this.position,
    required this.name,
    required this.xp,
    this.isCurrentUser = false,
  });
}