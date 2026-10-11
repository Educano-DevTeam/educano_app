import 'package:flutter/material.dart';

import '../navigation/app_menu.dart';
import '../navigation/app_navigation.dart';
import '../theme/theme.dart';
import 'responsive_layout.dart';

import '../widgets/components/app_header.dart';
import '../widgets/components/app_sidebar.dart';
import '../widgets/components/app_bottom_navigation.dart';
import '../../features/materials/widgets/course_mini_audio_player.dart';
import '../widgets/ui/app_fab_menu.dart';
import '../../features/dashboard/views/course_editor_view.dart';
import '../../features/dashboard/views/dashboard_users_view.dart';
import '../../features/dashboard/views/dashboard_items_view.dart';
import '../../features/course/widgets/course_editor_dialogs.dart';
import '../theme/educano_colors.dart';
import '../../services/storage_service.dart';
import '../models/app_user.dart';

class AppScaffold extends StatefulWidget {
  final Widget child;
  final AppMenu selectedMenu;

  const AppScaffold({
    super.key,
    required this.child,
    required this.selectedMenu,
  });

  @override
  State<AppScaffold> createState() => _AppScaffoldState();
}

class _AppScaffoldState extends State<AppScaffold> {
  bool _sidebarExpanded = true;
  AppUser? _currentUser;

  final TextEditingController _searchController =
      TextEditingController();

  final GlobalKey<ScaffoldState> _scaffoldKey =
      GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _loadSidebarPreference();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _toggleSidebar() {
    final expanded = !_sidebarExpanded;
    setState(() {
      _sidebarExpanded = expanded;
    });
    _saveSidebarPreference(expanded);
  }

  Future<void> _loadSidebarPreference() async {
    try {
      final expanded = await StorageService.instance.loadSidebarExpanded();
      final user = await StorageService.instance.loadCurrentUser();
      if (mounted) {
        setState(() {
          if (expanded != null) _sidebarExpanded = expanded;
          _currentUser = user;
        });
      }
    } catch (error) {
      _showStorageError(
        'Não foi possível carregar as preferências locais: $error',
      );
    }
  }

  Future<void> _saveSidebarPreference(bool expanded) async {
    try {
      await StorageService.instance.saveSidebarExpanded(expanded);
    } catch (error) {
      _showStorageError('Não foi possível salvar a sidebar: $error');
    }
  }

  void _showStorageError(String message) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    });
  }

  void _handleMenuSelected(AppMenu menu) {
    AppNavigation.onMenuSelected(context, menu);
  }

  void _handleMenuPressed(bool isMobile) {
    if (isMobile) {
      _scaffoldKey.currentState?.openDrawer();
      return;
    }

    _toggleSidebar();
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      mobileBody: _buildMobileLayout(),
      desktopBody: _buildDesktopLayout(),
    );
  }

  Widget _buildMobileLayout() {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: EducanoColors.background,
      drawer: AppSidebar(
        isMobile: true,
        selectedMenu: widget.selectedMenu,
        sidebarExpanded: true,
        onMenuSelected: (menu) {
          Navigator.pop(context);
          _handleMenuSelected(menu);
        },
      ),
      body: SafeArea(
        child: Column(
          children: [
            AppHeader(
              isMobile: true,
              onMenuPressed: () => _handleMenuPressed(true),
              searchController: _searchController,
              user: _currentUser,
            ),

            Expanded(
              child: Stack(children: [
                Positioned.fill(child: widget.child),
                const Positioned(left: 0, right: 0, bottom: 0, child: CourseMiniAudioPlayer()),
                if (_dashboardMenuVisible)
                  Positioned(right: 16, bottom: 68, child: _buildDashboardFab()),
              ]),
            ),

            AppBottomNavigation(
              selectedMenu: widget.selectedMenu,
              onItemSelected: _handleMenuSelected,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDesktopLayout() {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: EducanoColors.background,
      body: SafeArea(
        child: Column(
          children: [
            AppHeader(
              isMobile: false,
              onMenuPressed: () => _handleMenuPressed(false),
              searchController: _searchController,
              user: _currentUser,
            ),

            Expanded(
              child: Row(
                children: [
                  AppSidebar(
                    isMobile: false,
                    selectedMenu: widget.selectedMenu,
                    sidebarExpanded: _sidebarExpanded,
                    onToggleSidebar: _toggleSidebar,
                    onMenuSelected: _handleMenuSelected,
                  ),

                  Expanded(
                    child: Stack(children: [
                      Positioned.fill(child: widget.child),
                      const Positioned(left: 0, right: 0, bottom: 0, child: CourseMiniAudioPlayer()),
                      if (_dashboardMenuVisible)
                        Positioned(right: 24, bottom: 24, child: _buildDashboardFab()),
                    ]),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool get _dashboardMenuVisible => widget.selectedMenu == AppMenu.dashboard || widget.selectedMenu == AppMenu.itensListage || widget.selectedMenu == AppMenu.coursesListage || widget.selectedMenu == AppMenu.questionsListage || widget.selectedMenu == AppMenu.usersListage;

  Widget _buildDashboardFab() => AppFabMenu(actions: [
    AppFabAction(label: 'Cadastrar Usuário', icon: Icons.person_add_alt_rounded, color: EducanoColors.primaryBlue, onPressed: () => showDashboardUserDialog(context)),
    AppFabAction(label: 'Cadastrar Curso', icon: Icons.school_rounded, color: EducanoColors.successGreen, onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CourseEditorView()))),
    AppFabAction(label: 'Cadastrar Questão', icon: Icons.quiz_rounded, color: EducanoColors.accentYellow, onPressed: () => showActivityQuestionDialog(context)),
    AppFabAction(label: 'Cadastrar Item', icon: Icons.store_rounded, color: const Color(0xFFE94B0C), onPressed: () => showDashboardItemDialog(context)),
  ]);
}
