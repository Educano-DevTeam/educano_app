class RankingEntry {
  final int position;
  final String name;
  final int xp;
  final bool isCurrentUser;
  final String? id;
  final int level;
  final String photoUrl;

  const RankingEntry({
    required this.position,
    required this.name,
    required this.xp,
    this.isCurrentUser = false,
    this.id,
    this.level = 0,
    this.photoUrl = '',
  });

  /// Item retornado por GET /api/ranking.
  factory RankingEntry.fromApi(Map<String, dynamic> json, {String? currentUserId}) =>
      RankingEntry(
        position: json['posicao'] as int,
        name: json['nome'] as String,
        xp: json['xp'] as int,
        id: json['id'] as String,
        level: json['nivel'] as int? ?? 0,
        photoUrl: json['urlFotoPerfil'] as String? ?? '',
        isCurrentUser: json['id'] == currentUserId,
      );
}
