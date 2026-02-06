import 'package:biux/core/design_system/design_system.dart';
import 'package:biux/core/config/router/app_routes.dart';
import 'package:biux/core/config/strings.dart';
import 'package:biux/core/config/styles.dart';
import 'package:biux/core/utils/responsive_helper.dart';
import 'package:biux/features/social/presentation/providers/notifications_provider.dart';
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
  int _selectedIndex = 2; // Por defecto en Mis Bicis (ahora es índice 2)

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

          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.campaign),
            tooltip: 'Promociones',
            onPressed: () => context.push('/promotions'),
          ),
        ],
      ),
      drawer: AppDrawer(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onTabTapped,
        type: BottomNavigationBarType.fixed,
        backgroundColor: ColorTokens.primary40,
        selectedItemColor: ColorTokens.neutral100,
        unselectedItemColor: ColorTokens.neutral100.withValues(alpha: 0.6),
        showSelectedLabels: true,
        showUnselectedLabels: true,
        selectedFontSize: 12,
        unselectedFontSize: 10,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.collections, size: 24),
            label: 'Historias',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.directions_bike, size: 24),
            label: 'Rutas',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.pedal_bike, size: 24),
            label: 'Mis Bicis',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_bag, size: 24),
            label: 'Tienda',
          ),
        ],
      ),
      body: ResponsiveHelper.wrapForWeb(
        Container(height: double.infinity, child: widget.child),
        context,
      ),
    );
  }

  void _onTabTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
        // Historias
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
    } else if (location.startsWith('/bikes') || location == AppRoutes.myBikes) {
      setState(() {
        _selectedIndex = 2;
      });
    } else if (location.startsWith('/shop')) {
      setState(() {
        _selectedIndex = 3;
      });
    }
  }
}
