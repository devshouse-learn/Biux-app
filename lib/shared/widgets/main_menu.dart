import 'package:biux/core/design_system/design_system.dart';
import 'package:biux/core/config/images.dart';
import 'package:biux/core/config/router/router_path.dart';
import 'package:biux/core/config/strings.dart';
import 'package:biux/core/config/styles.dart';
import 'package:biux/features/groups/presentation/screens/group_list/group_list_screen.dart';
import 'package:biux/features/maps/presentation/screens/map_screen.dart';
import 'package:biux/features/rides/presentation/screens/list_rides/ride_list_screen.dart';
import 'package:biux/features/stories/presentation/screens/story_view/story_view_bloc.dart';
import 'package:biux/features/stories/presentation/screens/story_view/story_view_screen.dart';
import 'package:biux/shared/widgets/app_drawer.dart';
import 'package:biux/shared/widgets/main_menu_bloc.dart';

import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:biux/core/design_system/color_tokens.dart';
import 'package:provider/provider.dart';

class MainMenu extends StatelessWidget {
  MainMenu({Key? key}) : super(key: key);

  final List<Widget> children = [
    StoryViewScreen(),
    RideListScreen(),
    GroupListScreen(),
    MapScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final bloc = context.watch<MainMenuBloc>();
    return Scaffold(
      appBar: AppBar(
        backgroundColor: ColorTokens.primary30,
        foregroundColor:
            ColorTokens.neutral100, // Hace que el icono del drawer sea blanco
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
        },
      ),
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
    context.read<MainMenuBloc>();
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
        Text(AppStrings.APP_NAME.toUpperCase(), style: Styles.mainMenuTextBiux),
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
      backgroundColor: ColorTokens.neutral95,
      key: _bottomNavigationKey,
      color: ColorTokens.primary40,
      buttonBackgroundColor: ColorTokens.neutral100,
      index: bloc.pageIndex,
      items: <Widget>[
        Image.asset(
          Images.kImageGallery,
          color: bloc.pageIndex == 0
              ? ColorTokens.primary40
              : ColorTokens.neutral100,
          height: 30,
        ),
        Container(
          child: Icon(
            Icons.directions_bike,
            color: bloc.pageIndex == 1
                ? ColorTokens.primary40
                : ColorTokens.neutral100,
            size: 30,
          ),
        ),
        Image.asset(
          Images.kImageSocial,
          color: bloc.pageIndex == 2
              ? ColorTokens.primary40
              : ColorTokens.neutral100,
          height: 30,
        ),
        Image.asset(
          Images.kImageLocation,
          color: bloc.pageIndex == 3
              ? ColorTokens.primary40
              : ColorTokens.neutral100,
          height: 30,
        ),
      ],
      onTap: bloc.onTabTapped,
    );
  }
}
