import 'package:flutter/material.dart';
import '../../../core/theme/educano_colors.dart';
import '../../../core/constants/app_breakpoints.dart';
import '../../../core/models/app_ranking_entry.dart';
import '../../../core/widgets/ui/stat_card.dart';

import '../../../core/widgets/ui/app_card.dart';


class RankingView extends StatefulWidget {
  const RankingView({super.key});

  @override
  State<RankingView> createState() => _RankingViewState();
}

class _RankingViewState extends State<RankingView> {
  static const List<RankingEntry> _entries = [
    RankingEntry(position: 1, name: 'Manuela Souza', xp: 4820),
    RankingEntry(position: 2, name: 'Rafael Cristiano', xp: 4510),
    RankingEntry(position: 3, name: 'Luana Castanho', xp: 4290),
    RankingEntry(position: 4, name: 'Daniel de Oliveira', xp: 3980, isCurrentUser: true),
    RankingEntry(position: 5, name: 'Mateus Lima', xp: 3760),
    RankingEntry(position: 6, name: 'Beatriz Ramos', xp: 3410),
    RankingEntry(position: 7, name: 'João Pedro Alves', xp: 3105),
    RankingEntry(position: 8, name: 'Sofia Marques', xp: 2960),
  ];

  int? _selectedIndex;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Ranking Semanal',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: EducanoColors.legacyTextPrimary),
            ),
            const SizedBox(height: 4),
            const Text(
              'Veja sua posição entre os outros alunos da plataforma.',
              style: TextStyle(fontSize: 13, color: EducanoColors.legacyTextSecondary),
            ),
            const SizedBox(height: 16),
            const _SearchField(),
            const SizedBox(height: 16),
            const _StatsRow(),
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
                        Icon(Icons.emoji_events, color: EducanoColors.legacyGold, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'Ranking Semanal',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: EducanoColors.legacyTextPrimary),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1),
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _entries.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, index) => _RankingRow(
                      entry: _entries[index],
                      selected: _selectedIndex == index,
                      onTap: () => setState(
                        () => _selectedIndex = _selectedIndex == index ? null : index,
                      ),
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
  const _SearchField();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: EducanoColors.legacyBackground,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: EducanoColors.legacyCardBorder),
      ),
      child: const TextField(
        decoration: InputDecoration(
          hintText: 'Pesquisar aluno...',
          hintStyle: TextStyle(color: EducanoColors.legacyTextSecondary, fontSize: 13),
          prefixIcon: Icon(Icons.search, size: 20, color: EducanoColors.legacyTextSecondary),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }
}

class _StatsRow extends StatelessWidget {
  const _StatsRow();

  @override
  Widget build(BuildContext context) {
    final bool mobile = (MediaQuery.sizeOf(context).width < AppBreakpoints.medium);
    const List<Widget> cards = [
      StatCard(label: 'Sua posição', value: '#4', valueColor: EducanoColors.legacyPrimary),
      StatCard(label: 'Seu XP semanal', value: '3.980 XP'),
      StatCard(label: 'Faltam p/ 3º lugar', value: '310 XP', valueColor: EducanoColors.legacyAmber),
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
  final bool selected;
  final VoidCallback onTap;

  const _RankingRow({
    required this.entry,
    required this.selected,
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
    if (widget.selected) {
      rowColor = EducanoColors.legacyPrimary.withValues(alpha: 0.14);
    } else if (isTop3) {
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
                color: widget.selected ? EducanoColors.legacyPrimary : Colors.transparent,
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
                    color: isTop3 ? Colors.white : EducanoColors.legacyTextPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              const CircleAvatar(radius: 15, backgroundColor: Color(0xFFC9D6F5)),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  entry.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13.5,
                    color: EducanoColors.legacyTextPrimary,
                  ),
                ),
              ),
              const Icon(Icons.bolt, size: 16, color: EducanoColors.legacyAmber),
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
