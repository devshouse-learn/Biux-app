import 'package:biux/core/design_system/design_system.dart';
import 'package:biux/core/config/router/app_routes.dart';
import 'package:biux/core/config/strings.dart';
import 'package:biux/core/config/styles.dart';
import 'package:biux/core/utils/responsive_helper.dart';
import 'package:biux/core/design_system/locale_notifier.dart';
import 'package:biux/features/social/presentation/providers/notifications_provider.dart';
import 'package:biux/features/users/presentation/providers/user_provider.dart';
import 'app_drawer.dart';
import 'package:flutter/material.dart';
import 'package:biux/core/design_system/color_tokens.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:biux/shared/widgets/custom_icons/groups_icon.dart';

class MainShell extends StatefulWidget {
  final Widget child;

  const MainShell({Key? key, required this.child}) : super(key: key);

  @override
  _MainShellState createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _selectedIndex = 0; // Por defecto en Inicio (índice 0)
  bool _isFullScreenRoute = false; // Rutas que ocultan AppBar y BottomNav
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  /// Rutas que tienen su propio AppBar y no necesitan el shell
  static const List<String> _fullScreenRoutes = [
    '/account-settings',
    '/settings/',
    '/help',
    '/edit-username',
    '/edit-user',
  ];

  /// Retorna el título dinámico según el tab seleccionado
  String _titleForIndex(int index, LocaleNotifier l, BuildContext context) {
    switch (index) {
      case 0:
        return 'BiuX';
      case 1:
        return 'BiuX';
      case 2:
        return 'BiuX';
      case 3:
        return 'BiuX';
      case 4:
        final userProvider = Provider.of<UserProvider>(context, listen: false);
        final username = userProvider.user?.username;
        if (username != null && username.isNotEmpty) return '@$username';
        final userName = userProvider.user?.name;
        if (userName != null && userName.isNotEmpty) return userName;
        return l.t('nav_profile');
      default:
        return AppStrings.APP_NAME.toUpperCase();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Consumer2 garantiza rebuild cuando cambia el idioma o datos de usuario
    return Consumer2<LocaleNotifier, UserProvider>(
      builder: (context, l, userProvider, _) {
        // Si es una ruta de pantalla completa, mostrar solo el child sin shell
        if (_isFullScreenRoute) {
          return widget.child;
        }

        // Colores dinámicos según el tema actual
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final appBarColor = isDark
            ? ColorTokens
                  .neutral95 // Fondo claro en dark mode para que se vea el logo oscuro
            : ColorTokens.primary30;
        final textColor = isDark
            ? ColorTokens
                  .primary30 // Texto oscuro en dark mode
            : ColorTokens.neutral100;
        final navBarColor = isDark
            ? ColorTokens.primary20
            : ColorTokens.neutral100;

        // Key por idioma fuerza reconstrucción completa del Scaffold
        return Scaffold(
          key: _scaffoldKey,
          appBar: AppBar(
            backgroundColor: appBarColor,
            foregroundColor: isDark
                ? ColorTokens.primary30
                : ColorTokens.neutral100,
            leading: GestureDetector(
              onTap: () => _scaffoldKey.currentState?.openDrawer(),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Icon(
                  Icons.menu,
                  size: 28,
                  color: isDark
                      ? ColorTokens.primary30
                      : ColorTokens.neutral100,
                ),
              ),
            ),
            title: _selectedIndex == 4
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _titleForIndex(_selectedIndex, l, context),
                        style: Styles.mainMenuTextBiux.copyWith(
                          color: ColorTokens.neutral100,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        userProvider.user?.profileVisibility == 'private'
                            ? Icons.lock_rounded
                            : Icons.lock_open_rounded,
                        size: 20,
                        color: ColorTokens.neutral100,
                      ),
                    ],
                  )
                : Image.asset(
                    'img/biux_logo_biux_only.png',
                    height: 28,
                    fit: BoxFit.contain,
                  ),
            actions: [
              // Buscar usuarios (solo en tab de inicio)
              if (_selectedIndex == 0)
                IconButton(
                  icon: Icon(Icons.search, color: textColor),
                  onPressed: () => context.push('/users/search'),
                ),
            ],
          ),
          drawer: AppDrawer(),
          bottomNavigationBar: Container(
            decoration: BoxDecoration(
              color: navBarColor,
              border: Border(
                top: BorderSide(color: Colors.grey.shade300, width: 0.5),
              ),
            ),
            child: BottomNavigationBar(
              key: ValueKey('nav_${l.langCode}'),
              currentIndex: _selectedIndex,
              onTap: _onTabTapped,
              type: BottomNavigationBarType.fixed,
              backgroundColor: navBarColor,
              selectedItemColor: isDark
                  ? ColorTokens.primary60
                  : ColorTokens.neutral0,
              unselectedItemColor: isDark
                  ? ColorTokens.neutral70
                  : ColorTokens.neutral60,
              showSelectedLabels: false,
              showUnselectedLabels: false,
              elevation: 0,
              items: [
                _buildNavItem(Icons.home, 0),
                _buildGroupsNavItem(1),
                _buildNotificationsNavItem(2),
                _buildNavItem(Icons.pedal_bike, 3),
                _buildNavItem(Icons.person, 4),
              ],
            ),
          ),
          body: ResponsiveHelper.wrapForWeb(
            Container(height: double.infinity, child: widget.child),
            context,
          ),
        );
      },
    );
  }

  BottomNavigationBarItem _buildNavItem(IconData icon, int index) {
    final isSelected = _selectedIndex == index;
    return BottomNavigationBarItem(
      icon: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 28),
          const SizedBox(height: 4),
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            height: 2,
            width: isSelected ? 24 : 0,
            decoration: BoxDecoration(
              color: isSelected
                  ? (Theme.of(context).brightness == Brightness.dark
                        ? ColorTokens.primary60
                        : ColorTokens.neutral0)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(1),
            ),
          ),
        ],
      ),
      label: '',
    );
  }

  BottomNavigationBarItem _buildGroupsNavItem(int index) {
    final isSelected = _selectedIndex == index;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final iconColor = isSelected
        ? (isDark ? ColorTokens.primary60 : ColorTokens.neutral0)
        : (isDark ? ColorTokens.neutral70 : ColorTokens.neutral60);

    return BottomNavigationBarItem(
      icon: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          GroupsIcon(size: 28, color: iconColor),
          const SizedBox(height: 4),
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            height: 2,
            width: isSelected ? 24 : 0,
            decoration: BoxDecoration(
              color: isSelected
                  ? (isDark ? ColorTokens.primary60 : ColorTokens.neutral0)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(1),
            ),
          ),
        ],
      ),
      label: '',
    );
  }

  BottomNavigationBarItem _buildNotificationsNavItem(int index) {
    final isSelected = _selectedIndex == index;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final iconColor = isSelected
        ? (isDark ? ColorTokens.primary60 : ColorTokens.neutral0)
        : (isDark ? ColorTokens.neutral70 : ColorTokens.neutral60);

    return BottomNavigationBarItem(
      icon: Consumer<NotificationsProvider?>(
        builder: (context, provider, _) {
          final unreadCount = provider?.unreadCount ?? 0;
          final hasUnread = provider?.hasUnread ?? false;

          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Badge(
                label: hasUnread ? Text('$unreadCount') : null,
                backgroundColor: ColorTokens.error50,
                isLabelVisible: hasUnread,
                child: Icon(Icons.notifications, size: 28, color: iconColor),
              ),
              const SizedBox(height: 4),
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                height: 2,
                width: isSelected ? 24 : 0,
                decoration: BoxDecoration(
                  color: isSelected
                      ? (isDark ? ColorTokens.primary60 : ColorTokens.neutral0)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(1),
                ),
              ),
            ],
          );
        },
      ),
      label: '',
    );
  }

  void _onTabTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
        // Inicio
        context.go('/stories');
        break;
      case 1:
        // Mis Grupos
        context.go(AppRoutes.myGroups);
        break;
      case 2:
        // Notificaciones
        context.go('/notifications');
        break;
      case 3:
        // Mis Bicis
        context.go(AppRoutes.myBikes);
        break;
      case 4:
        // Mi Perfil
        context.go('/profile');
        break;
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _updateSelectedIndex();
  }

  void _updateSelectedIndex() {
    final location = GoRouterState.of(context).matchedLocation;

    // Detectar si es una ruta de pantalla completa (sin shell)
    final isFullScreen = _fullScreenRoutes.any(
      (route) => location.startsWith(route),
    );
    if (isFullScreen != _isFullScreenRoute) {
      setState(() {
        _isFullScreenRoute = isFullScreen;
      });
    }

    if (location.startsWith('/stories')) {
      setState(() {
        _selectedIndex = 0;
      });
    } else if (location.startsWith('/my-groups') ||
        location.startsWith(AppRoutes.groupList)) {
      setState(() {
        _selectedIndex = 1;
      });
    } else if (location.startsWith('/notifications')) {
      setState(() {
        _selectedIndex = 2;
      });
    } else if (location.startsWith('/bikes') || location == AppRoutes.myBikes) {
      setState(() {
        _selectedIndex = 3;
      });
    } else if (location.startsWith('/profile')) {
      setState(() {
        _selectedIndex = 4;
      });
    }
  }
}
