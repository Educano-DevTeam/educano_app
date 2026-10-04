import 'package:flutter/material.dart';

import '../../../core/data/repositories/flashcard_local_repository.dart';
import '../../../core/layout/app_scaffold.dart';
import '../../../core/navigation/app_menu.dart';
import '../../../core/theme/educano_colors.dart';
import '../flashcard_model.dart';

class FlashcardsPage extends StatefulWidget {
  const FlashcardsPage({super.key});

  @override
  State<FlashcardsPage> createState() => _FlashcardsPageState();
}

class _FlashcardsPageState extends State<FlashcardsPage> {
  final LocalFlashcardRepository _repository = LocalFlashcardRepository();
  List<Flashcard> _cards = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadCards();
  }

  Future<void> _loadCards() async {
    final cards = await _repository.getAll();
    if (!mounted) return;
    setState(() {
      _cards = cards;
      _loading = false;
    });
  }

  Future<void> _createCard() async {
    final draft = await _showEditor();
    if (draft == null) return;
    await _repository.create(Flashcard(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      userId: _repository.userId,
      title: draft.title.trim().isEmpty ? 'Novo Flashcard' : draft.title.trim(),
      question: draft.question.trim(),
      answer: draft.answer.trim(),
      monthlyRepetitions: draft.monthlyRepetitions,
    ));
    await _loadCards();
  }

  Future<void> _editCard(Flashcard card) async {
    final draft = await _showEditor(card: card);
    if (draft == null) return;
    await _repository.update(card.copyWith(
      title: draft.title.trim().isEmpty ? card.title : draft.title.trim(),
      question: draft.question.trim(),
      answer: draft.answer.trim(),
      monthlyRepetitions: draft.monthlyRepetitions,
    ));
    await _loadCards();
  }

  Future<void> _deleteCard(Flashcard card) async {
    if (!await _showDeleteConfirmation(card)) return;
    await _repository.delete(card.id);
    await _loadCards();
  }

  Future<void> _openCard(Flashcard card) async {
    final reviewed = await _repository.review(card.id);
    if (reviewed == null || !mounted) return;
    setState(() {
      _cards = _cards.map((item) => item.id == reviewed.id ? reviewed : item).toList();
    });
    await _showExpandedCard(reviewed);
  }

  Future<_FlashcardDraft?> _showEditor({Flashcard? card}) {
    final titleController = TextEditingController(text: card?.title ?? '');
    final questionController = TextEditingController(text: card?.question ?? '');
    final answerController = TextEditingController(text: card?.answer ?? '');
    int repetitions = card?.monthlyRepetitions ?? 4;

    return showDialog<_FlashcardDraft>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 620, maxHeight: 720),
            child: Material(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              clipBehavior: Clip.antiAlias,
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(28, 24, 28, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      Expanded(
                        child: Text(
                          card == null ? 'Novo Flashcard' : 'Editar Flashcard',
                          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: EducanoColors.textPrimary),
                        ),
                      ),
                      IconButton(onPressed: () => Navigator.pop(dialogContext), icon: const Icon(Icons.close)),
                    ]),
                    const SizedBox(height: 20),
                    const _FieldLabel('Título / assunto'),
                    const SizedBox(height: 8),
                    TextField(controller: titleController, decoration: const InputDecoration(hintText: 'Ex.: Brasil - Geografia')),
                    const SizedBox(height: 18),
                    const _FieldLabel('Pergunta'),
                    const SizedBox(height: 8),
                    TextField(controller: questionController, minLines: 2, maxLines: 5, decoration: const InputDecoration(hintText: 'Selecione ou escreva a pergunta')),
                    const SizedBox(height: 18),
                    const _FieldLabel('Resposta'),
                    const SizedBox(height: 8),
                    TextField(controller: answerController, minLines: 2, maxLines: 7, decoration: const InputDecoration(hintText: 'Resposta')),
                    const SizedBox(height: 22),
                    const _FieldLabel('Quantidade de Repetições (Mensal)'),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [2, 4, 8, 16].map((value) => _RepetitionButton(
                        label: '${value}x',
                        selected: repetitions == value,
                        onPressed: () => setDialogState(() => repetitions = value),
                      )).toList(),
                    ),
                    const SizedBox(height: 10),
                    _RepetitionButton(
                      label: [2, 4, 8, 16].contains(repetitions) ? 'Personalizado' : '${repetitions}x',
                      selected: ![2, 4, 8, 16].contains(repetitions),
                      onPressed: () async {
                        final value = await _showCustomRepetitionDialog(context, repetitions);
                        if (value != null) setDialogState(() => repetitions = value);
                      },
                    ),
                    const SizedBox(height: 28),
                    Row(children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(dialogContext),
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size(0, 54),
                            side: const BorderSide(color: EducanoColors.border, width: 2),
                            foregroundColor: EducanoColors.textSecondary,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Text('Cancelar'),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            if (questionController.text.trim().isEmpty || answerController.text.trim().isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Preencha a pergunta e a resposta.')));
                              return;
                            }
                            Navigator.pop(dialogContext, _FlashcardDraft(
                              title: titleController.text,
                              question: questionController.text,
                              answer: answerController.text,
                              monthlyRepetitions: repetitions,
                            ));
                          },
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size(0, 54),
                            backgroundColor: EducanoColors.primaryBlue,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: Text(card == null ? 'Criar novo Flashcard' : 'Salvar alterações'),
                        ),
                      ),
                    ]),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<int?> _showCustomRepetitionDialog(BuildContext context, int current) async {
    final controller = TextEditingController(text: current.toString());
    return showDialog<int>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Repetições personalizadas'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'Revisões por mês', suffixText: 'x'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () {
              final value = int.tryParse(controller.text);
              if (value == null || value < 1 || value > 30) return;
              Navigator.pop(dialogContext, value);
            },
            child: const Text('Aplicar'),
          ),
        ],
      ),
    );
  }

  Future<bool> _showDeleteConfirmation(Flashcard card) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Excluir Flashcard?'),
        content: Text('Tem certeza que deseja excluir "${card.title}"? Esta ação não poderá ser desfeita.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: const Text('Cancelar')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: EducanoColors.error),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  Future<void> _showExpandedCard(Flashcard card) async {
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 680, maxHeight: 760),
          child: Material(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            clipBehavior: Clip.antiAlias,
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(28, 24, 28, 26),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Expanded(child: Text(card.title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: EducanoColors.textPrimary))),
                  IconButton(
                    tooltip: 'Editar',
                    onPressed: () { Navigator.pop(dialogContext); _editCard(card); },
                    icon: const Icon(Icons.edit_outlined, color: EducanoColors.primaryBlue),
                  ),
                  IconButton(
                    tooltip: 'Excluir',
                    onPressed: () { Navigator.pop(dialogContext); _deleteCard(card); },
                    icon: const Icon(Icons.delete_outline, color: EducanoColors.error),
                  ),
                  IconButton(tooltip: 'Fechar', onPressed: () => Navigator.pop(dialogContext), icon: const Icon(Icons.close)),
                ]),
                const SizedBox(height: 22),
                const _FieldLabel('Pergunta'),
                const SizedBox(height: 8),
                Text(card.question, style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w600, height: 1.35, color: EducanoColors.textPrimary)),
                const SizedBox(height: 22),
                const _FieldLabel('Resposta'),
                const SizedBox(height: 8),
                Text(card.answer, style: const TextStyle(fontSize: 18, height: 1.45, color: EducanoColors.textSecondary)),
                const SizedBox(height: 28),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(color: EducanoColors.searchBackground, borderRadius: BorderRadius.circular(12)),
                  child: Column(children: [
                    _InfoRow('Última visualização', _formatDate(card.lastReviewedAt)),
                    const SizedBox(height: 8),
                    _InfoRow('Próxima visualização', _formatDate(card.nextReviewAt)),
                    const SizedBox(height: 8),
                    _InfoRow('Repetições mensais', '${card.monthlyRepetitions}x'),
                  ]),
                ),
              ]),
            ),
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Ainda não revisado';
    final local = date.toLocal();
    return '${local.day.toString().padLeft(2, '0')}/${local.month.toString().padLeft(2, '0')}/${local.year}';
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      selectedMenu: AppMenu.flashcards,
      child: _loading ? const Center(child: CircularProgressIndicator()) : _buildContent(),
    );
  }

  Widget _buildContent() {
    return LayoutBuilder(builder: (context, constraints) {
      final isMobile = constraints.maxWidth < 700;
      final columns = constraints.maxWidth >= 1100 ? 3 : constraints.maxWidth >= 700 ? 2 : 1;
      return SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(isMobile ? 16 : 40, 28, isMobile ? 16 : 40, 32),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1200),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                const Expanded(child: Text('Flashcards', style: TextStyle(fontSize: 32, fontWeight: FontWeight.w700, color: EducanoColors.textPrimary))),
                if (!isMobile) ElevatedButton.icon(
                  onPressed: _createCard,
                  icon: const Icon(Icons.add, size: 20),
                  label: const Text('Novo Flashcard'),
                  style: ElevatedButton.styleFrom(backgroundColor: EducanoColors.primaryBlue, foregroundColor: Colors.white, minimumSize: const Size(190, 48), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                ),
              ]),
              if (isMobile) ...[
                const SizedBox(height: 16),
                SizedBox(width: double.infinity, child: ElevatedButton.icon(
                  onPressed: _createCard,
                  icon: const Icon(Icons.add, size: 20),
                  label: const Text('Novo Flashcard'),
                  style: ElevatedButton.styleFrom(backgroundColor: EducanoColors.primaryBlue, foregroundColor: Colors.white, minimumSize: const Size(0, 48), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                )),
              ],
              const SizedBox(height: 22),
              if (_cards.isEmpty)
                _EmptyState(onCreate: _createCard)
              else
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _cards.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: columns,
                    crossAxisSpacing: 22,
                    mainAxisSpacing: 22,
                    childAspectRatio: isMobile ? 1.35 : 1.48,
                  ),
                  itemBuilder: (context, index) {
                    final card = _cards[index];
                    return _FlashcardTile(
                      card: card,
                      formatDate: _formatDate,
                      onTap: () => _openCard(card),
                      onEdit: () => _editCard(card),
                      onDelete: () => _deleteCard(card),
                    );
                  },
                ),
            ]),
          ),
        ),
      );
    });
  }
}

class _FlashcardTile extends StatelessWidget {
  const _FlashcardTile({required this.card, required this.formatDate, required this.onTap, required this.onEdit, required this.onDelete});

  final Flashcard card;
  final String Function(DateTime?) formatDate;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 16),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(16), border: Border.all(color: EducanoColors.border, width: 1.5)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Expanded(child: Text(card.title, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700, height: 1.05, color: EducanoColors.textPrimary))),
              _IconAction(icon: Icons.edit_outlined, color: EducanoColors.primaryBlue, tooltip: 'Editar', onPressed: onEdit),
              _IconAction(icon: Icons.delete_outline, color: EducanoColors.error, tooltip: 'Excluir', onPressed: onDelete),
            ]),
            const SizedBox(height: 12),
            Text(card.question, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, height: 1.25, color: EducanoColors.textSecondary)),
            const SizedBox(height: 7),
            Text(card.answer, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 16, height: 1.25, color: EducanoColors.textSecondary)),
            const Spacer(),
            Text('Última visualização: ${formatDate(card.lastReviewedAt)}', maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 10, color: EducanoColors.textSecondary)),
            const SizedBox(height: 4),
            Text('Próxima visualização: ${formatDate(card.nextReviewAt)}', maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 10, color: EducanoColors.textSecondary)),
          ]),
        ),
      ),
    );
  }
}

class _IconAction extends StatelessWidget {
  const _IconAction({required this.icon, required this.color, required this.tooltip, required this.onPressed});
  final IconData icon;
  final Color color;
  final String tooltip;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => IconButton(
    tooltip: tooltip,
    visualDensity: VisualDensity.compact,
    padding: EdgeInsets.zero,
    constraints: const BoxConstraints(minWidth: 30, minHeight: 30),
    onPressed: onPressed,
    icon: Icon(icon, color: color, size: 22),
  );
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);
  final String text;
  @override
  Widget build(BuildContext context) => Text(text, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: EducanoColors.textPrimary));
}

class _RepetitionButton extends StatelessWidget {
  const _RepetitionButton({required this.label, required this.selected, required this.onPressed});
  final String label;
  final bool selected;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => OutlinedButton(
    onPressed: onPressed,
    style: OutlinedButton.styleFrom(
      foregroundColor: selected ? EducanoColors.primaryBlue : EducanoColors.textSecondary,
      backgroundColor: selected ? EducanoColors.primaryBlue.withOpacity(.08) : Colors.white,
      side: BorderSide(color: selected ? EducanoColors.primaryBlue : EducanoColors.border, width: selected ? 2 : 1.5),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ),
    child: Text(label),
  );
}

class _InfoRow extends StatelessWidget {
  const _InfoRow(this.label, this.value);
  final String label;
  final String value;
  @override
  Widget build(BuildContext context) => Row(children: [
    Expanded(child: Text(label, style: const TextStyle(fontSize: 12, color: EducanoColors.textSecondary))),
    const SizedBox(width: 12),
    Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: EducanoColors.textPrimary)),
  ]);
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onCreate});
  final VoidCallback onCreate;
  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: EducanoColors.border)),
    child: Column(children: [
      const Icon(Icons.style_outlined, size: 48, color: EducanoColors.secondaryBlue),
      const SizedBox(height: 12),
      const Text('Nenhum flashcard cadastrado', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
      const SizedBox(height: 6),
      const Text('Crie o primeiro flashcard desta conta para começar.'),
      const SizedBox(height: 18),
      ElevatedButton(onPressed: onCreate, child: const Text('Criar flashcard')),
    ]),
  );
}

class _FlashcardDraft {
  const _FlashcardDraft({required this.title, required this.question, required this.answer, required this.monthlyRepetitions});
  final String title;
  final String question;
  final String answer;
  final int monthlyRepetitions;
}
