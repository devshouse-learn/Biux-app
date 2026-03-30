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

class MainShell extends StatefulWidget {
  final Widget child;

  const MainShell({Key? key, required this.child}) : super(key: key);

  @override
  _MainShellState createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _selectedIndex = 0; // Por defecto en Inicio (índice 0)
  bool _isFullScreenRoute = false; // Rutas que ocultan AppBar y BottomNav

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
        return 'BIUX';
      case 1:
        return 'BIUX';
      case 2:
        return 'BIUX';
      case 3:
        return 'BIUX';
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

        // Key por idioma fuerza reconstrucción completa del Scaffold
        return Scaffold(
          key: ValueKey('shell_${l.langCode}'),
          appBar: AppBar(
            backgroundColor: ColorTokens.primary30,
            foregroundColor: ColorTokens.neutral100,
            title: Text(
              _titleForIndex(_selectedIndex, l, context),
              style: Styles.mainMenuTextBiux,
            ),
            actions: [
              // Buscar usuarios (solo en tab de inicio)
              if (_selectedIndex == 0)
                IconButton(
                  icon: const Icon(Icons.search, color: Colors.white),
                  onPressed: () => context.push('/users/search'),
                ),
              // Notificaciones con badge
              Consumer<NotificationsProvider?>(
                builder: (context, provider, child) {
                  final unreadCount = provider?.unreadCount ?? 0;
                  final hasUnread = provider?.hasUnread ?? false;

                  return IconButton(
                    icon: Badge(
                      label: Text('$unreadCount'),
                      isLabelVisible: hasUnread,
                      backgroundColor: Colors.red,
                      child: const Icon(Icons.notifications),
                    ),
                    onPressed: () {
                      context.push('/notifications');
                    },
                  );
                },
              ),
            ],
          ),
          drawer: AppDrawer(),
          bottomNavigationBar: BottomNavigationBar(
            key: ValueKey('nav_${l.langCode}'),
            currentIndex: _selectedIndex,
            onTap: _onTabTapped,
            type: BottomNavigationBarType.fixed,
            backgroundColor: ColorTokens.primary40,
            selectedItemColor: ColorTokens.neutral100,
            unselectedItemColor: ColorTokens.neutral100.withValues(alpha: 0.6),
            showSelectedLabels: false,
            showUnselectedLabels: false,
            items: [
              BottomNavigationBarItem(
                icon: Icon(Icons.home, size: 28),
                label: '',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.directions_bike, size: 28),
                label: '',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.pedal_bike, size: 28),
                label: '',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.shopping_bag, size: 28),
                label: '',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person, size: 28),
                label: '',
              ),
            ],
          ),
          body: ResponsiveHelper.wrapForWeb(
            Container(height: double.infinity, child: widget.child),
            context,
          ),
        );
      },
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
        // Rutas/Roads
        context.go('/rides');
        break;
      case 2:
        // Mis Bicis
        context.go(AppRoutes.myBikes);
        break;
      case 3:
        // Tienda
        context.go('/shop');
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
    } else if (location.startsWith(AppRoutes.roadsList)) {
      setState(() {
        _selectedIndex = 1;
      });
    } else if (location.startsWith('/bikes') || location == AppRoutes.myBikes) {
      setState(() {
        _selectedIndex = 2;
      });
    } else if (location.startsWith('/shop')) {
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
