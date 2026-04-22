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
import 'package:biux/shared/widgets/offline_banner.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class MainShell extends StatefulWidget {
  final Widget child;

  const MainShell({Key? key, required this.child}) : super(key: key);

  @override
  _MainShellState createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _selectedIndex = 0;
  bool _isFullScreenRoute = false;

  static const List<String> _fullScreenRoutes = [
    '/account-settings',
    '/settings/',
    '/help',
    '/edit-username',
    '/edit-user',
  ];

  String _titleForIndex(int index, LocaleNotifier l, BuildContext context) {
    switch (index) {
      case 0:
        return 'Inicio';
      case 1:
        return 'Rodadas';
      case 2:
        return 'Mis Bicis';
      case 3:
        try {
          final userProvider = Provider.of<UserProvider>(
            context,
            listen: false,
          );
          final username = userProvider.user?.username;
          if (username != null && username.isNotEmpty) return '@$username';
          final userName = userProvider.user?.name;
          if (userName != null && userName.isNotEmpty) return userName;
        } catch (_) {}
        return l.t('nav_profile');
      default:
        return AppStrings.APP_NAME.toUpperCase();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<LocaleNotifier, UserProvider>(
      builder: (context, l, userProvider, _) {
        if (_isFullScreenRoute) {
          return widget.child;
        }

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
              if (_selectedIndex == 0)
                IconButton(
                  icon: const Icon(Icons.search, color: Colors.white),
                  onPressed: () => context.push('/users/search'),
                ),
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
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home, size: 28),
                label: '',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.diversity_3, size: 28),
                label: '',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.pedal_bike, size: 28),
                label: '',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person, size: 28),
                label: '',
              ),
            ],
          ),
          body: ResponsiveHelper.wrapForWeb(
            Column(
              children: [
                const OfflineBanner(),
                Expanded(child: widget.child),
              ],
            ),
            context,
          ),
        );
      },
    );
  }

  void _onTabTapped(int index) {
    if (_selectedIndex == index) return; // Evitar renavegar al mismo tab

    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
        context.go('/stories');
        break;
      case 1:
        context.go('/rides');
        break;
      case 2:
        context.go(AppRoutes.myBikes);
        break;
      case 3:
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

    final isFullScreen = _fullScreenRoutes.any(
      (route) => location.startsWith(route),
    );
    if (isFullScreen != _isFullScreenRoute) {
      setState(() {
        _isFullScreenRoute = isFullScreen;
      });
    }

    int newIndex = _selectedIndex;
    if (location.startsWith('/stories')) {
      newIndex = 0;
    } else if (location.startsWith('/rides')) {
      newIndex = 1;
    } else if (location.startsWith('/bikes') ||
        location.startsWith('/my-bikes')) {
      newIndex = 2;
    } else if (location.startsWith('/profile')) {
      newIndex = 3;
    }

    if (newIndex != _selectedIndex) {
      setState(() {
        _selectedIndex = newIndex;
      });
    }
  }
}
