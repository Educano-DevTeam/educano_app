import 'package:flutter/material.dart';
import '../../../core/theme/educano_colors.dart';
import '../../../core/constants/app_breakpoints.dart';
import '../../../core/models/app_ranking_entry.dart';
import '../../../core/navigation/app_routes.dart';
import '../../../core/navigation/navigation_service.dart';
import '../../../core/widgets/ui/stat_card.dart';

import '../../../core/widgets/ui/app_card.dart';
import '../../../core/widgets/ui/profile_avatar.dart';
import '../../../services/api_client.dart';
import '../../../services/progress_service.dart';
import '../../../services/storage_service.dart';
import '../../../services/users_service.dart';

class RankingView extends StatefulWidget {
  const RankingView({super.key});

  @override
  State<RankingView> createState() => _RankingViewState();
}

class _RankingViewState extends State<RankingView> {
  final List<RankingEntry> _entries = [];
  final _search = TextEditingController();
  final _scrollController = ScrollController();
  Map<String, dynamic>? _me;
  int _page = 1;
  bool _hasMore = false;
  bool _loading = true;
  String? _error;
  String? _userId;

  final Set<String> _openingProfileIds = {};

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _load();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 240 &&
        !_loading &&
        _hasMore) {
      _load(more: true);
    }
  }

  @override
  void dispose() {
    _search.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _load({bool more = false}) async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      _userId ??= (await StorageService.instance.loadCurrentUser())?.id;
      final page = more ? _page + 1 : 1;
      final ranking = await ProgressService.instance.ranking(page: page);
      if (!mounted) return;
      setState(() {
        if (!more) {
          _entries.clear();
        }
        _entries.addAll(
          (ranking['dados'] as List).cast<Map<String, dynamic>>().map(
            (e) => RankingEntry.fromApi(e, currentUserId: _userId),
          ),
        );
        final currentEntry = _entries
            .where((entry) => entry.isCurrentUser)
            .firstOrNull;
        if (currentEntry != null && _me != null) {
          _me = {..._me!, 'posicaoRanking': currentEntry.position};
        }
        _page = page;
        _hasMore = (ranking['paginacao'] as Map)['temMais'] == true;
        _loading = false;
      });
      if (!more) {
        try {
          final profile = await UsersService.instance.myProfile();
          if (!mounted) return;
          final currentEntry = _entries
              .where((entry) => entry.isCurrentUser)
              .firstOrNull;
          setState(() {
            _me = {
              ...profile,
              if (currentEntry != null) 'posicaoRanking': currentEntry.position,
            };
          });
        } on ApiException {
          // O ranking é público e continua disponível mesmo sem perfil próprio.
        }
      }
    } on ApiException catch (error) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = error.message;
      });
    }
  }

  List<RankingEntry> get _visible {
    final query = _search.text.trim().toLowerCase();
    if (query.isEmpty) return _entries;
    return _entries.where((e) => e.name.toLowerCase().contains(query)).toList();
  }

  String _photoUrl(RankingEntry entry) {
    if (entry.isCurrentUser) {
      final currentPhoto = _me?['urlFotoPerfil'];
      if (currentPhoto is String && currentPhoto.isNotEmpty) {
        return currentPhoto;
      }
    }
    return entry.photoUrl;
  }

  Future<void> _openProfile(RankingEntry entry) async {
    final id = entry.id;
    if (id == null || _openingProfileIds.contains(id)) return;
    if (entry.isCurrentUser) {
      NavigationService.pushNamed(AppRoutes.profile);
      return;
    }

    setState(() => _openingProfileIds.add(id));
    try {
      await NavigationService.pushNamed(
        AppRoutes.publicProfile,
        arguments: PublicProfileRouteArgs(userId: id, userName: entry.name),
      );
    } finally {
      if (mounted) setState(() => _openingProfileIds.remove(id));
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      controller: _scrollController,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Ranking Global',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: EducanoColors.legacyTextPrimary,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Veja sua posição entre os outros alunos da plataforma.',
            style: TextStyle(
              fontSize: 13,
              color: EducanoColors.legacyTextSecondary,
            ),
          ),
          const SizedBox(height: 16),
          _SearchField(controller: _search, onChanged: (_) => setState(() {})),
          const SizedBox(height: 16),
          _StatsRow(me: _me, entries: _entries),
          const SizedBox(height: 20),
          AppSectionCard(
            padding: EdgeInsets.zero,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.fromLTRB(20, 18, 20, 12),
                  child: Row(
                    children: [
                      Icon(
                        Icons.emoji_events,
                        color: EducanoColors.legacyGold,
                        size: 20,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Ranking por XP',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: EducanoColors.legacyTextPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                if (_error != null)
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        Expanded(child: Text(_error!)),
                        TextButton(
                          onPressed: _load,
                          child: const Text('Tentar novamente'),
                        ),
                      ],
                    ),
                  ),
                if (!_loading && _error == null && _visible.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(20),
                    child: Text('Nenhum aluno encontrado.'),
                  ),
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _visible.length,
                  separatorBuilder: (_, _) => const Divider(height: 1),
                  itemBuilder: (context, index) => _RankingRow(
                    entry: _visible[index],
                    loading: _openingProfileIds.contains(_visible[index].id),
                    photoUrl: _photoUrl(_visible[index]),
                    onTap: () => _openProfile(_visible[index]),
                  ),
                ),
                if (_loading)
                  const Padding(
                    padding: EdgeInsets.all(20),
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (_hasMore)
                  Center(
                    child: TextButton(
                      onPressed: () => _load(more: true),
                      child: const Text('Ver mais posições'),
                    ),
                  ),
                const SizedBox(height: 8),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  const _SearchField({required this.controller, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: EducanoColors.legacyBackground,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: EducanoColors.legacyCardBorder),
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        decoration: const InputDecoration(
          hintText: 'Pesquisar aluno...',
          hintStyle: TextStyle(
            color: EducanoColors.legacyTextSecondary,
            fontSize: 13,
          ),
          prefixIcon: Icon(
            Icons.search,
            size: 20,
            color: EducanoColors.legacyTextSecondary,
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }
}

class _StatsRow extends StatelessWidget {
  final Map<String, dynamic>? me;
  final List<RankingEntry> entries;

  const _StatsRow({required this.me, required this.entries});

  @override
  Widget build(BuildContext context) {
    final bool mobile =
        (MediaQuery.sizeOf(context).width < AppBreakpoints.medium);
    final position = me?['posicaoRanking'] as int?;
    final xp = me?['xp'] as int? ?? 0;
    final third = entries.where((e) => e.position == 3).firstOrNull;
    final missing = third == null ? null : third.xp - xp + 1;
    final List<Widget> cards = [
      StatCard(
        label: 'Sua posição',
        value: position == null ? '—' : '#$position',
        valueColor: EducanoColors.legacyPrimary,
      ),
      StatCard(label: 'Seu XP total', value: '$xp XP'),
      StatCard(
        label: 'Faltam p/ 3º lugar',
        value: position != null && position <= 3
            ? 'No pódio!'
            : missing == null
            ? '—'
            : '$missing XP',
        valueColor: EducanoColors.legacyAmber,
      ),
    ];

    if (mobile) {
      return Column(
        children: [
          for (int i = 0; i < cards.length; i++) ...[
            SizedBox(width: double.infinity, child: cards[i]),
            if (i != cards.length - 1) const SizedBox(height: 12),
          ],
        ],
      );
    }

    return Row(
      children: [
        for (int i = 0; i < cards.length; i++) ...[
          Expanded(child: cards[i]),
          if (i != cards.length - 1) const SizedBox(width: 16),
        ],
      ],
    );
  }
}

class _RankingRow extends StatefulWidget {
  final RankingEntry entry;
  final bool loading;
  final String photoUrl;
  final VoidCallback onTap;

  const _RankingRow({
    required this.entry,
    required this.loading,
    required this.photoUrl,
    required this.onTap,
  });

  @override
  State<_RankingRow> createState() => _RankingRowState();
}

class _RankingRowState extends State<_RankingRow> {
  bool _hovered = false;

  Color get _badgeColor {
    switch (widget.entry.position) {
      case 1:
        return EducanoColors.legacyGold;
      case 2:
        return EducanoColors.legacySilver;
      case 3:
        return EducanoColors.legacyBronze;
      default:
        return const Color(0xFFDDE0EA);
    }
  }

  String _formatXp(int xp) {
    final String digits = xp.toString();
    final StringBuffer buffer = StringBuffer();
    for (int i = 0; i < digits.length; i++) {
      if (i != 0 && (digits.length - i) % 3 == 0) buffer.write('.');
      buffer.write(digits[i]);
    }
    return buffer.toString();
  }

  @override
  Widget build(BuildContext context) {
    final entry = widget.entry;
    final bool isTop3 = entry.position <= 3;

    Color rowColor;
    if (isTop3) {
      rowColor = EducanoColors.legacyTopThreeBackground;
    } else if (entry.isCurrentUser) {
      rowColor = EducanoColors.legacyLavender;
    } else if (_hovered) {
      rowColor = EducanoColors.legacyBackground;
    } else {
      rowColor = Colors.transparent;
    }

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeOut,
          decoration: BoxDecoration(
            color: rowColor,
            border: Border(
              left: BorderSide(
                color: widget.loading
                    ? EducanoColors.legacyPrimary
                    : Colors.transparent,
                width: 3,
              ),
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 17, vertical: 12),
          child: Row(
            children: [
              CircleAvatar(
                radius: 13,
                backgroundColor: _badgeColor,
                child: Text(
                  '${entry.position}',
                  style: TextStyle(
                    color: isTop3
                        ? Colors.white
                        : EducanoColors.legacyTextPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              ProfileAvatar(
                imageUrl: widget.photoUrl,
                radius: 15,
                backgroundColor: const Color(0xFFC9D6F5),
                placeholder: Text(
                  entry.name.isEmpty ? '?' : entry.name[0].toUpperCase(),
                  style: const TextStyle(
                    fontSize: 12,
                    color: EducanoColors.legacyPrimary,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  entry.isCurrentUser ? '${entry.name} (você)' : entry.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13.5,
                    color: EducanoColors.legacyTextPrimary,
                  ),
                ),
              ),
              if (widget.loading) ...[
                const SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                const SizedBox(width: 8),
              ],
              const Icon(
                Icons.bolt,
                size: 16,
                color: EducanoColors.legacyAmber,
              ),
              const SizedBox(width: 4),
              Text(
                '${_formatXp(entry.xp)} XP',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: EducanoColors.legacyPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
