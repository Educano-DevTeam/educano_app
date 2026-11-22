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
import '../../features/dashboard/views/dashboard_users_view.dart';
import '../../features/dashboard/views/dashboard_items_view.dart';
import '../../features/dashboard/views/dashboard_questions_view.dart';
import '../../features/dashboard/views/dashboard_courses_view.dart';
import '../theme/educano_colors.dart';
import '../../services/storage_service.dart';
import '../../services/api_client.dart';
import '../../services/users_service.dart';
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
  static bool? _cachedSidebarExpanded;

  bool _sidebarExpanded = _cachedSidebarExpanded ?? true;
  bool _sidebarManuallyToggled = false;
  AppUser? _currentUser;
  String? _profilePhotoUrl;

  final TextEditingController _searchController = TextEditingController();

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

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
    _cachedSidebarExpanded = expanded;
    setState(() {
      _sidebarExpanded = expanded;
      _sidebarManuallyToggled = true;
    });
    _saveSidebarPreference(expanded);
  }

  Future<void> _loadSidebarPreference() async {
    try {
      final expanded = await StorageService.instance.loadSidebarExpanded();
      final user = await StorageService.instance.loadCurrentUser();
      if (_cachedSidebarExpanded == null && expanded != null) {
        _cachedSidebarExpanded = expanded;
      }
      if (mounted) {
        setState(() {
          if (!_sidebarManuallyToggled) {
            _sidebarExpanded = _cachedSidebarExpanded ?? expanded ?? true;
          }
          _currentUser = user;
        });
      }
      if (user != null) _loadProfilePhoto();
    } catch (error) {
      _showStorageError(
        'Não foi possível carregar as preferências locais: $error',
      );
    }
  }

  Future<void> _loadProfilePhoto() async {
    try {
      final profile = await UsersService.instance.myProfile();
      if (!mounted) return;
      setState(() {
        _profilePhotoUrl = profile['urlFotoPerfil'] as String?;
      });
    } on ApiException catch (error) {
      if (!mounted || error.isUnauthorized) return;
      _showStorageError(
        'Não foi possível carregar a foto de perfil: ${error.message}',
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
        user: _currentUser,
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
              profilePhotoUrl: _profilePhotoUrl,
            ),

            Expanded(
              child: Stack(
                children: [
                  Positioned.fill(child: widget.child),
                  const Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: CourseMiniAudioPlayer(),
                  ),
                  if (_dashboardMenuVisible)
                    Positioned(
                      right: 16,
                      bottom: 32,
                      child: _buildDashboardFab(),
                    ),
                ],
              ),
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
              profilePhotoUrl: _profilePhotoUrl,
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
                    user: _currentUser,
                  ),

                  Expanded(
                    child: Stack(
                      children: [
                        Positioned.fill(child: widget.child),
                        const Positioned(
                          left: 0,
                          right: 0,
                          bottom: 0,
                          child: CourseMiniAudioPlayer(),
                        ),
                        if (_dashboardMenuVisible)
                          Positioned(
                            right: 24,
                            bottom: 24,
                            child: _buildDashboardFab(),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool get _dashboardMenuVisible =>
      widget.selectedMenu == AppMenu.dashboard ||
      widget.selectedMenu == AppMenu.itensListage ||
      widget.selectedMenu == AppMenu.coursesListage ||
      widget.selectedMenu == AppMenu.questionsListage ||
      widget.selectedMenu == AppMenu.usersListage;

  Widget _buildDashboardFab() {
    final isAdmin = _currentUser?.isAdmin ?? false;
    final canManageCourses = isAdmin || _currentUser?.type == 'PARCEIRO';
    return AppFabMenu(
      actions: [
        if (isAdmin)
          AppFabAction(
            label: 'Cadastrar Usuário',
            icon: Icons.person_add_alt_rounded,
            color: EducanoColors.primaryBlue,
            onPressed: () => showDashboardUserDialog(context),
          ),
        if (canManageCourses)
          AppFabAction(
            label: 'Cadastrar Curso',
            icon: Icons.school_rounded,
            color: EducanoColors.successGreen,
            onPressed: () => openDashboardCourseEditor(context),
          ),
        AppFabAction(
          label: 'Cadastrar Questão',
          icon: Icons.quiz_rounded,
          color: EducanoColors.accentYellow,
          onPressed: () => createQuestionFromDashboard(context),
        ),
        if (isAdmin)
          AppFabAction(
            label: 'Cadastrar Item',
            icon: Icons.store_rounded,
            color: const Color(0xFFE94B0C),
            onPressed: () => showDashboardItemDialog(context),
          ),
      ],
    );
  }
}
