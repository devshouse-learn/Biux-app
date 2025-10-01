import 'package:biux/config/colors.dart';
import 'package:biux/config/images.dart';
import 'package:biux/config/router/router_path.dart';
import 'package:biux/config/strings.dart';
import 'package:biux/config/styles.dart';
import 'package:biux/ui/screens/group/group_list/group_list_screen.dart';
import 'package:biux/ui/screens/main_menu/main_menu_bloc.dart';
import 'package:biux/ui/screens/map/map_screen.dart';
import 'package:biux/ui/screens/roads/roads_list/roads_list_screen.dart';
import 'package:biux/ui/screens/story/story_view/story_view_bloc.dart';
import 'package:biux/ui/screens/story/story_view/story_view_screen.dart';
import 'package:biux/ui/widgets/app_drawer.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MainMenu extends StatelessWidget {
  MainMenu({Key? key}) : super(key: key);

  final List<Widget> children = [
    StoryViewScreen(),
    RoadsListScreen(),
    GroupListScreen(),
    MapScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final bloc = context.watch<MainMenuBloc>();
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.blackPearl,
        foregroundColor:
            AppColors.white, // Hace que el icono del drawer sea blanco
        title: Selector<MainMenuBloc, int>(
          selector: (_, bloc) => bloc.pageIndex,
          builder: (context, value, child) {
            return _AppBar();
          },
        ),
        actions: [
          Selector<MainMenuBloc, int>(
            selector: (_, bloc) => bloc.pageIndex,
            builder: (context, value, child) {
              return _ActionButton();
            },
          ),
        ],
      ),
      drawer: AppDrawer(),
      bottomNavigationBar: Selector<MainMenuBloc, int>(
          selector: (_, bloc) => bloc.pageIndex,
          builder: (context, value, child) {
            return _BottomNavigationBar();
          }),
      body: Container(
        height: 1500,
        child: IndexedStack(
          alignment: AlignmentDirectional.center,
          index: bloc.pageIndex,
          children: children,
        ),
      ),
    );
  }
}

class _AppBar extends StatelessWidget {
  _AppBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<MainMenuBloc>();
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        // if (bloc.pageIndex == 0)
        //   Text(
        //     '${AppStrings.storyText} ',
        //   )
        // else if (bloc.pageIndex == 1)
        //   Text(
        //     '${AppStrings.rolled} ',
        //   )
        // else if (bloc.pageIndex == 2)
        //   Text(
        //     '${AppStrings.gruposText} ',
        //   )
        // else if (bloc.pageIndex == 3)
        //   Text(
        //     '${AppStrings.map} ',
        //   ),
        Text(
          AppStrings.APP_NAME.toUpperCase(),
          style: Styles.mainMenuTextBiux,
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  _ActionButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<MainMenuBloc>();
    return Row(
      children: <Widget>[
        if (bloc.pageIndex == 0)
          Container(
            height: 32,
            width: 32,
            margin: EdgeInsets.only(right: 30),
            child: GestureDetector(
              onTap: () async {
                final bloc = context.read<StoryViewBloc>();
                final result = await Navigator.pushNamed(
                  context,
                  AppRoutes.storyCreateRoute,
                );
                if (result as bool) {
                  bloc.getIntitalStories();
                }
              },
              child: Image.asset(Images.kImageAdd),
            ),
          ),
      ],
    );
  }
}

class _BottomNavigationBar extends StatelessWidget {
  _BottomNavigationBar({Key? key}) : super(key: key);
  final GlobalKey _bottomNavigationKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<MainMenuBloc>();
    return CurvedNavigationBar(
      height: 65,
      backgroundColor: AppColors.white2,
      key: _bottomNavigationKey,
      color: AppColors.darkBlue,
      buttonBackgroundColor: AppColors.white,
      index: bloc.pageIndex,
      items: <Widget>[
        Image.asset(
          Images.kImageGallery,
          color: bloc.pageIndex == 0 ? AppColors.darkBlue : AppColors.white,
          height: 30,
        ),
        Container(
          child: Icon(
            Icons.directions_bike,
            color: bloc.pageIndex == 1 ? AppColors.darkBlue : AppColors.white,
            size: 30,
          ),
        ),
        Image.asset(
          Images.kImageSocial,
          color: bloc.pageIndex == 2 ? AppColors.darkBlue : AppColors.white,
          height: 30,
        ),
        Image.asset(
          Images.kImageLocation,
          color: bloc.pageIndex == 3 ? AppColors.darkBlue : AppColors.white,
          height: 30,
        ),
      ],
      onTap: bloc.onTabTapped,
    );
  }
}
