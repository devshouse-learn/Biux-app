import 'package:biux/core/config/colors.dart';
import 'package:biux/core/config/images.dart';
import 'package:biux/core/config/router/app_routes.dart';
import 'package:biux/core/config/strings.dart';
import 'package:biux/core/config/styles.dart';
import 'app_drawer.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MainShell extends StatefulWidget {
  final Widget child;

  const MainShell({Key? key, required this.child}) : super(key: key);

  @override
  _MainShellState createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _selectedIndex = 3; // Por defecto en Mapa

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.blackPearl,
        foregroundColor: AppColors.white,
        title: Text(
          AppStrings.APP_NAME.toUpperCase(),
          style: Styles.mainMenuTextBiux,
        ),
        actions: [
          // Botón de acción según la pestaña actual
          _buildActionButton(),
        ],
      ),
      drawer: AppDrawer(),
      bottomNavigationBar: CurvedNavigationBar(
        height: 65,
        backgroundColor: AppColors.white2,
        color: AppColors.darkBlue,
        buttonBackgroundColor: AppColors.white,
        index: _selectedIndex,
        items: <Widget>[
          Image.asset(
            Images.kImageGallery,
            color: _selectedIndex == 0 ? AppColors.darkBlue : AppColors.white,
            height: 30,
          ),
          Container(
            child: Icon(
              Icons.directions_bike,
              color: _selectedIndex == 1 ? AppColors.darkBlue : AppColors.white,
              size: 30,
            ),
          ),
          Image.asset(
            Images.kImageSocial,
            color: _selectedIndex == 2 ? AppColors.darkBlue : AppColors.white,
            height: 30,
          ),
          Image.asset(
            Images.kImageLocation,
            color: _selectedIndex == 3 ? AppColors.darkBlue : AppColors.white,
            height: 30,
          ),
        ],
        onTap: _onTabTapped,
      ),
      body: Container(
        height: double.infinity,
        child: widget.child,
      ),
    );
  }

  Widget _buildActionButton() {
    if (_selectedIndex == 0) {
      // Botón de agregar historia
      return Container(
        height: 32,
        width: 32,
        margin: EdgeInsets.only(right: 30),
        child: GestureDetector(
          onTap: () {
            context.go('/stories/create');
          },
          child: Image.asset(Images.kImageAdd),
        ),
      );
    }
    return SizedBox.shrink();
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
        // Mapa
        context.go(AppRoutes.map);
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
    } else if (location == AppRoutes.map) {
      setState(() {
        _selectedIndex = 3;
      });
    }
  }
}
