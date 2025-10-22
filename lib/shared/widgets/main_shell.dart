import 'package:biux/core/design_system/design_system.dart';
import 'package:biux/core/config/images.dart';
import 'package:biux/core/config/router/app_routes.dart';
import 'package:biux/core/config/strings.dart';
import 'package:biux/core/config/styles.dart';
import 'package:biux/features/social/presentation/providers/notifications_provider.dart';
import 'app_drawer.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
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
  int _selectedIndex = 3; // Por defecto en Mis Bicis

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: ColorTokens.primary30,
        foregroundColor: ColorTokens.neutral100,
        title: Text(
          AppStrings.APP_NAME.toUpperCase(),
          style: Styles.mainMenuTextBiux,
        ),
        actions: [
          // Notificaciones con badge
          Consumer<NotificationsProvider>(
            builder: (context, provider, child) {
              return IconButton(
                icon: Badge(
                  label: Text('${provider.unreadCount}'),
                  isLabelVisible: provider.hasUnread,
                  backgroundColor: Colors.red,
                  child: const Icon(Icons.notifications),
                ),
                onPressed: () {
                  context.push('/notifications');
                },
              );
            },
          ),

          const SizedBox(width: 8),
        ],
      ),
      drawer: AppDrawer(),
      bottomNavigationBar: CurvedNavigationBar(
        height: 65,
        backgroundColor: ColorTokens.neutral95,
        color: ColorTokens.primary40,
        buttonBackgroundColor: ColorTokens.neutral100,
        index: _selectedIndex,
        items: <Widget>[
          Image.asset(
            Images.kImageGallery,
            color: _selectedIndex == 0
                ? ColorTokens.primary40
                : ColorTokens.neutral100,
            height: 30,
          ),
          Container(
            child: Icon(
              Icons.directions_bike,
              color: _selectedIndex == 1
                  ? ColorTokens.primary40
                  : ColorTokens.neutral100,
              size: 30,
            ),
          ),
          Image.asset(
            Images.kImageSocial,
            color: _selectedIndex == 2
                ? ColorTokens.primary40
                : ColorTokens.neutral100,
            height: 30,
          ),
          Icon(
            Icons.pedal_bike,
            color: _selectedIndex == 3
                ? ColorTokens.primary40
                : ColorTokens.neutral100,
            size: 30,
          ),
        ],
        onTap: _onTabTapped,
      ),
      body: Container(height: double.infinity, child: widget.child),
    );
  }

  void _onTabTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
        // Historias - temporalmente va a la pantalla placeholder
        context.go('/stories');
        break;
      case 1:
        // Rutas/Roads
        context.go('/rides');
        break;
      case 2:
        // Grupos
        context.go(AppRoutes.groupList);
        break;
      case 3:
        // Mis Bicis
        context.go(AppRoutes.myBikes);
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

    if (location.startsWith('/stories')) {
      setState(() {
        _selectedIndex = 0;
      });
    } else if (location.startsWith(AppRoutes.roadsList)) {
      setState(() {
        _selectedIndex = 1;
      });
    } else if (location.startsWith(AppRoutes.groupList) ||
        location.startsWith(AppRoutes.myGroups)) {
      setState(() {
        _selectedIndex = 2;
      });
    } else if (location.startsWith('/bikes') || location == AppRoutes.myBikes) {
      setState(() {
        _selectedIndex = 3;
      });
    }
  }
}
