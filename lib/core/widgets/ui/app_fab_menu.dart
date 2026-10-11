import 'package:flutter/material.dart';

import '../../theme/theme.dart';

class AppFabAction {
  final String label;
  final VoidCallback onPressed;
  final IconData icon;
  final Color color;

  const AppFabAction({
    required this.label,
    required this.onPressed,
    required this.icon,
    required this.color,
  });
}

class AppFabMenu extends StatefulWidget {
  final List<AppFabAction> actions;

  const AppFabMenu({super.key, required this.actions});

  @override
  State<AppFabMenu> createState() => _AppFabMenuState();
}

class _AppFabMenuState extends State<AppFabMenu>
    with SingleTickerProviderStateMixin {
  bool _isOpen = false;

  late final AnimationController _animationController;

  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 180),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.08), end: Offset.zero).animate(
          CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
        );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleMenu() {
    setState(() {
      _isOpen = !_isOpen;
    });

    if (_isOpen) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
  }

  void _closeMenu() {
    if (!_isOpen) return;

    setState(() {
      _isOpen = false;
    });

    _animationController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 250,
      height: 380,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.bottomRight,
        children: [
          if (_isOpen)
            Positioned(
              right: 0,
              bottom: 68,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: _buildActionsMenu(),
                ),
              ),
            ),

          _buildFab(),
        ],
      ),
    );
  }

  Widget _buildFab() {
    return Material(
      color: EducanoColors.primaryBlue,
      elevation: 6,
      shadowColor: Colors.black26,
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: _toggleMenu,
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: 58,
          height: 58,
          child: AnimatedRotation(
            turns: _isOpen ? 0.125 : 0,
            duration: const Duration(milliseconds: 180),
            child: const Icon(Icons.add_rounded, color: Colors.white, size: 32),
          ),
        ),
      ),
    );
  }

  Widget _buildActionsMenu() {
    return Material(
      color: Colors.transparent,
      child: Container(
        width: 250,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: EducanoColors.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 18,
              offset: Offset(0, 6),
            ),
          ],
          border: Border.all(color: EducanoColors.border),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Título do menu
            const Padding(
              padding: EdgeInsets.only(left: 4, bottom: 10),
              child: Text(
                'Ações Rápidas',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
              ),
            ),

            // Botões das ações
            ...widget.actions.map((action) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 5),
                child: _buildActionButton(action),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(AppFabAction action) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: () {
          _closeMenu();
          action.onPressed();
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: action.color,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: Row(
          children: [
            Icon(action.icon, size: 20),

            const SizedBox(width: 10),

            Expanded(
              child: Text(
                action.label,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
